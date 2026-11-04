package main

import (
	"context"
	"crypto/tls"
	"encoding/json"
	"errors"
	"flag"
	"fmt"
	"image/color"
	"net"
	"net/http"
	"os"
	"strings"
	"sync"
	"syscall"
	"time"

	"charm.land/bubbles/v2/spinner"
	tea "charm.land/bubbletea/v2"
	"charm.land/lipgloss/v2"
	"github.com/charmbracelet/x/term"
)

// one entry of the list the isup aspect writes
type Check struct {
	ID    string `json:"id"`
	Name  string `json:"name"`
	Group string `json:"group"`
	// statuspage.io base url
	Status string `json:"status"`
	// components or component groups that count; empty is the whole page
	Components []string `json:"components"`
	URL        string   `json:"url"`
	// a resolver to query directly
	DNS string `json:"dns"`
}

type State int

const (
	Pending State = iota
	Up
	Degraded
	Down
)

func (s State) MarshalText() ([]byte, error) {
	return []byte([...]string{"pending", "up", "degraded", "down"}[s]), nil
}

type Result struct {
	State     State
	Detail    string
	Latency   time.Duration
	Incidents []string
}

var client = &http.Client{Timeout: 5 * time.Second}

func run(c Check) Result {
	var jobs []func() Result
	if c.Status != "" {
		jobs = append(jobs, func() Result { return statusPage(c.Status, c.Components) })
	}
	if c.URL != "" {
		jobs = append(jobs, func() Result { return probe(c.URL) })
	}
	if c.DNS != "" {
		jobs = append(jobs, func() Result { return resolve(c.DNS) })
	}
	if len(jobs) == 0 {
		return Result{State: Down, Detail: "nothing to check"}
	}

	parts := make([]Result, len(jobs))
	var wg sync.WaitGroup
	for i, job := range jobs {
		wg.Go(func() { parts[i] = job() })
	}
	wg.Wait()

	// worst part wins, ties go to the status page
	var r Result
	for _, p := range parts {
		if p.State > r.State {
			r.State, r.Detail = p.State, p.Detail
		}
		if r.Latency == 0 {
			r.Latency = p.Latency
		}
		r.Incidents = append(r.Incidents, p.Incidents...)
	}
	if c.Status != "" && parts[0].State == Up && r.State == Down {
		r.Detail += ", status page operational"
	}
	return r
}

type summary struct {
	Status struct {
		Indicator   string `json:"indicator"`
		Description string `json:"description"`
	} `json:"status"`
	Components []struct {
		ID      string `json:"id"`
		Name    string `json:"name"`
		Status  string `json:"status"`
		Group   bool   `json:"group"`
		GroupID string `json:"group_id"`
	} `json:"components"`
	Incidents []struct {
		Name       string `json:"name"`
		Components []struct {
			ID string `json:"id"`
		} `json:"components"`
	} `json:"incidents"`
}

func statusPage(base string, want []string) Result {
	var s summary
	if err := getJSON(strings.TrimSuffix(base, "/")+"/api/v2/summary.json", &s); err != nil {
		return Result{State: Degraded, Detail: "status page " + short(err)}
	}

	if len(want) == 0 {
		r := Result{State: indicator(s.Status.Indicator), Detail: strings.ToLower(s.Status.Description)}
		for _, i := range s.Incidents {
			r.Incidents = append(r.Incidents, i.Name)
		}
		return r
	}

	wanted := func(name string) bool {
		for _, w := range want {
			if strings.EqualFold(w, name) {
				return true
			}
		}
		return false
	}
	groups := map[string]string{}
	for _, c := range s.Components {
		if c.Group {
			groups[c.ID] = c.Name
		}
	}

	// group rows only sum up their children
	r := Result{State: Up, Detail: "operational"}
	picked := map[string]bool{}
	var bad []string
	for _, c := range s.Components {
		group := groups[c.GroupID]
		if c.Group || !wanted(c.Name) && !wanted(group) {
			continue
		}
		picked[c.ID] = true
		if st := component(c.Status); st != Up {
			r.State = max(r.State, st)
			bad = append(bad, strings.TrimSpace(group+" "+c.Name)+" "+labels[c.Status])
		}
	}
	if len(picked) == 0 {
		return Result{State: Degraded, Detail: "no component " + strings.Join(want, ", ")}
	}
	if len(bad) > 0 {
		r.Detail = strings.Join(bad, ", ")
	}

	for _, i := range s.Incidents {
		for _, c := range i.Components {
			if picked[c.ID] {
				r.Incidents = append(r.Incidents, i.Name)
				break
			}
		}
	}
	return r
}

func indicator(s string) State {
	switch s {
	case "none":
		return Up
	case "major", "critical":
		return Down
	}
	return Degraded
}

var labels = map[string]string{
	"degraded_performance": "degraded",
	"partial_outage":       "partial outage",
	"major_outage":         "down",
	"under_maintenance":    "maintenance",
}

func component(s string) State {
	switch s {
	case "operational":
		return Up
	case "major_outage":
		return Down
	}
	return Degraded
}

// a stalled connect usually goes through on the second try
func get(url string) (*http.Response, error) {
	req, err := http.NewRequest(http.MethodGet, url, nil)
	if err != nil {
		return nil, err
	}
	req.Header.Set("User-Agent", "isup")
	// mcp servers hold the stream open without one
	req.Header.Set("Accept", "*/*")

	resp, err := client.Do(req)
	if err != nil {
		resp, err = client.Do(req)
	}
	return resp, err
}

func getJSON(url string, v any) error {
	resp, err := get(url)
	if err != nil {
		return err
	}
	defer resp.Body.Close()
	if resp.StatusCode != http.StatusOK {
		return fmt.Errorf("HTTP %d", resp.StatusCode)
	}
	return json.NewDecoder(resp.Body).Decode(v)
}

func probe(url string) Result {
	start := time.Now()
	resp, err := get(url)
	if err != nil {
		return Result{State: Down, Detail: short(err)}
	}
	latency := time.Since(start)
	resp.Body.Close()

	// it answered; logins and bot walls say 401/403
	state := Up
	if resp.StatusCode >= 500 {
		state = Down
	}
	return Result{State: state, Detail: fmt.Sprintf("HTTP %d", resp.StatusCode), Latency: latency}
}

// through that server alone, not the system's resolver list
func resolve(server string) Result {
	r := &net.Resolver{
		PreferGo: true,
		Dial: func(ctx context.Context, network, _ string) (net.Conn, error) {
			var d net.Dialer
			return d.DialContext(ctx, network, net.JoinHostPort(server, "53"))
		},
	}
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	start := time.Now()
	if _, err := r.LookupHost(ctx, "nixos.org."); err != nil {
		return Result{State: Down, Detail: short(err)}
	}
	return Result{State: Up, Detail: "answers", Latency: time.Since(start)}
}

func short(err error) string {
	var ne net.Error
	var dns *net.DNSError
	var cert *tls.CertificateVerificationError
	switch {
	case errors.As(err, &ne) && ne.Timeout():
		return "timed out"
	case errors.As(err, &dns) && dns.IsNotFound:
		return "no such host"
	case errors.Is(err, syscall.ECONNREFUSED):
		return "connection refused"
	case errors.Is(err, syscall.ENETUNREACH), errors.Is(err, syscall.EHOSTUNREACH):
		return "unreachable"
	case errors.As(err, &cert):
		return "bad certificate"
	}
	msg := err.Error()
	if i := strings.LastIndex(msg, ": "); i >= 0 {
		msg = msg[i+2:]
	}
	return msg
}

// Output

var (
	mauve    = lipgloss.Color("#cba6f7")
	green    = lipgloss.Color("#a6e3a1")
	yellow   = lipgloss.Color("#f9e2af")
	red      = lipgloss.Color("#f38ba8")
	subtext  = lipgloss.Color("#a6adc8")
	overlay  = lipgloss.Color("#6c7086")
	heading  = lipgloss.NewStyle().Foreground(mauve).Bold(true)
	faint    = fg(overlay)
	icons    = map[State]string{Up: "\u2713", Degraded: "!", Down: "\u2717"}
	iconTone = map[State]lipgloss.Style{Up: fg(green), Degraded: fg(yellow), Down: fg(red)}
	textTone = map[State]lipgloss.Style{Pending: faint, Up: fg(subtext), Degraded: fg(yellow), Down: fg(red)}
)

func fg(c color.Color) lipgloss.Style {
	return lipgloss.NewStyle().Foreground(c)
}

type row struct {
	Check
	Result
}

func detail(r row) string {
	if r.State == Pending {
		return "checking\u2026"
	}
	return r.Detail
}

// width 0 is unlimited
func render(rows []row, spin string, width int) string {
	nameW := 0
	for _, r := range rows {
		nameW = max(nameW, lipgloss.Width(r.Name))
	}
	// icon, name, latency and the gaps
	detailMax := 56
	if width > 0 {
		detailMax = min(detailMax, width-nameW-17)
	}
	detailW := 0
	for _, r := range rows {
		detailW = max(detailW, min(lipgloss.Width(detail(r)), detailMax))
	}

	var b strings.Builder
	counts := map[State]int{}
	group := ""
	for _, r := range rows {
		counts[r.State]++
		if r.Group != group {
			group = r.Group
			b.WriteString(heading.Render(group) + "\n")
		}

		icon := spin
		if r.State != Pending {
			icon = iconTone[r.State].Render(icons[r.State])
		}
		latency := ""
		if r.Latency > 0 {
			latency = fmt.Sprintf("%d ms", r.Latency.Milliseconds())
		}
		fmt.Fprintf(&b, "  %s %s  %s  %s\n",
			icon,
			pad(r.Name, nameW),
			textTone[r.State].Render(pad(truncate(detail(r), detailMax), detailW)),
			faint.Render(fmt.Sprintf("%7s", latency)))

		for _, i := range r.Incidents {
			b.WriteString("    " + faint.Render(truncate(i, max(width-4, 0))) + "\n")
		}
	}

	if counts[Pending] == 0 {
		parts := []string{fg(green).Render(fmt.Sprintf("%d up", counts[Up]))}
		if n := counts[Degraded]; n > 0 {
			parts = append(parts, fg(yellow).Render(fmt.Sprintf("%d degraded", n)))
		}
		if n := counts[Down]; n > 0 {
			parts = append(parts, fg(red).Render(fmt.Sprintf("%d down", n)))
		}
		b.WriteString(strings.Join(parts, faint.Render(", ")) + "\n")
	}
	return b.String()
}

func pad(s string, w int) string {
	return s + strings.Repeat(" ", max(w-lipgloss.Width(s), 0))
}

// 0 keeps it whole
func truncate(s string, w int) string {
	r := []rune(s)
	if w <= 0 || len(r) <= w {
		return s
	}
	return string(r[:w-1]) + "\u2026"
}

// TUI

type done struct {
	i int
	r Result
}

type model struct {
	rows    []row
	left    int
	width   int
	spinner spinner.Model
	stopped bool
}

// tea.Batch runs every command in its own goroutine
func (m model) Init() tea.Cmd {
	cmds := []tea.Cmd{m.spinner.Tick}
	for i, r := range m.rows {
		cmds = append(cmds, func() tea.Msg { return done{i, run(r.Check)} })
	}
	return tea.Batch(cmds...)
}

func (m model) Update(msg tea.Msg) (tea.Model, tea.Cmd) {
	switch msg := msg.(type) {
	case done:
		m.rows[msg.i].Result = msg.r
		m.left--
		if m.left == 0 {
			return m, tea.Quit
		}
	case tea.WindowSizeMsg:
		m.width = msg.Width
	case tea.KeyPressMsg:
		switch msg.String() {
		case "ctrl+c", "q", "esc":
			m.stopped = true
			return m, tea.Quit
		}
	case spinner.TickMsg:
		var cmd tea.Cmd
		m.spinner, cmd = m.spinner.Update(msg)
		return m, cmd
	}
	return m, nil
}

func (m model) View() tea.View {
	spin := m.spinner.View()
	if m.stopped {
		spin = faint.Render("-")
	}
	return tea.NewView(render(m.rows, spin, m.width))
}

// Main

func load(path string, args []string) ([]Check, error) {
	if path == "" {
		return nil, errors.New("no --checks file")
	}
	data, err := os.ReadFile(path)
	if err != nil {
		return nil, err
	}
	var checks []Check
	if err := json.Unmarshal(data, &checks); err != nil {
		return nil, err
	}
	if len(args) == 0 {
		return checks, nil
	}

	// any arg inside an id, name or group
	var picked []Check
	for _, c := range checks {
		hay := strings.ToLower(c.ID + "\n" + c.Name + "\n" + c.Group)
		for _, a := range args {
			if strings.Contains(hay, strings.ToLower(a)) {
				picked = append(picked, c)
				break
			}
		}
	}
	if len(picked) == 0 {
		return nil, fmt.Errorf("nothing matches %s", strings.Join(args, " "))
	}
	return picked, nil
}

func runAll(rows []row) {
	var wg sync.WaitGroup
	for i := range rows {
		wg.Go(func() { rows[i].Result = run(rows[i].Check) })
	}
	wg.Wait()
}

func printJSON(rows []row) {
	type out struct {
		ID        string   `json:"id"`
		Name      string   `json:"name"`
		Group     string   `json:"group"`
		State     State    `json:"state"`
		Detail    string   `json:"detail"`
		LatencyMS int64    `json:"latency_ms,omitempty"`
		Incidents []string `json:"incidents,omitempty"`
	}
	list := make([]out, len(rows))
	for i, r := range rows {
		list[i] = out{r.ID, r.Name, r.Group, r.State, r.Detail, r.Latency.Milliseconds(), r.Incidents}
	}
	enc := json.NewEncoder(os.Stdout)
	enc.SetIndent("", "  ")
	_ = enc.Encode(list)
}

func main() {
	checksPath := flag.String("checks", "", "json list of checks")
	asJSON := flag.Bool("json", false, "print results as json")
	flag.Usage = func() {
		fmt.Fprintln(os.Stderr, "usage: isup [--json] [name or group...]")
	}
	flag.Parse()

	checks, err := load(*checksPath, flag.Args())
	if err == nil && len(checks) == 0 {
		err = errors.New("no checks")
	}
	if err != nil {
		fmt.Fprintln(os.Stderr, "isup:", err)
		os.Exit(2)
	}
	rows := make([]row, len(checks))
	for i, c := range checks {
		rows[i].Check = c
	}

	switch {
	case *asJSON:
		runAll(rows)
		printJSON(rows)
	case term.IsTerminal(os.Stdout.Fd()):
		spin := spinner.New(spinner.WithSpinner(spinner.MiniDot), spinner.WithStyle(fg(mauve)))
		final, err := tea.NewProgram(model{rows: rows, left: len(rows), spinner: spin}).Run()
		if err != nil {
			fmt.Fprintln(os.Stderr, "isup:", err)
			os.Exit(2)
		}
		if final.(model).stopped {
			os.Exit(130)
		}
	default:
		runAll(rows)
		lipgloss.Print(render(rows, "", 0))
	}

	for _, r := range rows {
		if r.State != Up {
			os.Exit(1)
		}
	}
}
