pragma ComponentBehavior: Bound

import QtQuick
import Quickshell.Io
import qs.Common
import qs.Services
import qs.Modules.Plugins

PluginComponent {
    id: root

    // ct per kWh, pinned; 0 leaves cost out
    readonly property real priceCt: Number(pluginData.priceCt ?? 0)

    property string cpuModel: ""
    property real cpuMaxGhz: NaN
    property real cpuMaxTemp: NaN
    property var ranges: ({})

    // latest readings, NaN where a sensor is missing
    property real pkgW: NaN
    property real coreW: NaN
    property real uncoreW: NaN
    property real psysW: NaN
    property real vcore: NaN
    property real amps: NaN
    property real cpuTemp: NaN
    property real cpuGhz: NaN
    property real cpuLoad: NaN
    property var threadLoads: []

    property string igpuName: ""
    property real igpuMhz: NaN
    property real igpuMaxMhz: NaN

    property bool hasNvidia: false
    property var gpu: null
    property real gpuMaxTemp: NaN

    property real batteryVolts: NaN

    // lenovo conservation mode: -1 without the hardware, else 0 or 1
    property int conservation: -1
    property int _conservationTarget: -1
    readonly property bool conservationBusy: _conservationTarget >= 0

    // amd's core zone reads a single core, so only intel's counts
    property bool intel: false
    // intel's psys covers the whole platform: cores, igpu and the rest stack up to it
    readonly property bool platform: ranges.psys !== null && ranges.psys !== undefined

    readonly property real ecW: vcore * amps
    readonly property real cpuW: platform ? coreW : isFinite(pkgW) ? pkgW : ecW
    readonly property string cpuNote: platform ? "cores" : isFinite(pkgW) ? "package" : "VRM estimate"
    readonly property real gpuW: gpu ? gpu.watts : uncoreW
    readonly property real restW: platform ? Math.max(0, psysW - coreW - uncoreW) : NaN
    readonly property real totalW: platform ? psysW : (isFinite(cpuW) || isFinite(gpuW)) ? (isFinite(cpuW) ? cpuW : 0) + (isFinite(gpuW) ? gpuW : 0) : NaN

    // chart bands, bottom up
    readonly property var sources: platform ? ["cpu", "gpu", "rest"] : ["cpu", "gpu"]

    // [time, cpu W, gpu W, rest W] each second for 2 h; changed in place, revision ticks
    property var recent: []
    // [epoch minute, cpu W, gpu W, rest W] averages for 24 h, saved
    property var minutes: []
    // "yyyy-MM-dd" -> [cpu Wh, gpu Wh, rest Wh] for 31 days, saved
    property var days: ({})
    property int revision: 0

    // upower's charge history: {t, v, s} every few minutes over a day
    property var chargeSamples: []
    property real historyFetchedAt: 0
    property bool historyLoading: false
    property int historyHours: pluginData.historyHours ?? 24

    property var _last: null
    property var _minute: null

    readonly property var gpuFields: ["name", "power.draw", "power.limit", "temperature.gpu", "utilization.gpu", "clocks.gr", "clocks.mem", "clocks.max.gr", "fan.speed", "pstate", "memory.used", "memory.total", "pcie.link.gen.gpucurrent", "pcie.link.width.current", "clocks_event_reasons.active"]

    function reading(value, scale) {
        return value === null || value === undefined ? NaN : value / scale;
    }

    function cpuLine(line) {
        let sample;
        try {
            sample = JSON.parse(line);
        } catch (e) {
            return;
        }
        if (sample.model !== undefined) {
            intel = sample.model.includes("Intel");
            cpuModel =sample.model.replace(/^(AMD|\d+th Gen Intel\(R\) Core\(TM\)|Intel\(R\) Core\(TM\)) /, "").replace(/ \d+-Core Processor$/, "");
            cpuMaxGhz = reading(sample.maxKhz, 1e6);
            cpuMaxTemp = reading(sample.tcrit, 1000);
            ranges = sample.ranges;
            igpuName = (sample.igpuName.match(/\[(.*)\]/)?.[1] ?? sample.igpuName).trim();
            igpuMaxMhz = reading(sample.igpuMax, 1);
            return;
        }

        conservation = sample.conservation === null ? -1 : sample.conservation;
        cpuTemp = reading(sample.temp, 1000);
        cpuGhz = reading(sample.khz, 1e6);
        igpuMhz = reading(sample.igpuMhz, 1);
        batteryVolts = reading(sample.volts, 1e6);
        vcore = reading(sample.vcore, 1000);
        amps = reading(sample.amps, 1000);

        const last = _last;
        _last = sample;
        const dt = last ? sample.t - last.t : 0;
        // the first line, or the one after a suspend
        if (!(dt > 0 && dt < 5))
            return;

        // rapl counters wrap at their zone's range
        const rate = key => {
            const now = sample[key];
            const before = last[key];
            if (now === null || before === null)
                return NaN;
            const delta = now >= before ? now - before : now - before + (ranges[key] ?? 0);
            return delta >= 0 ? delta / 1e6 / dt : NaN;
        };
        pkgW = rate("pkg");
        coreW = intel ? rate("core") : NaN;
        uncoreW = rate("uncore");
        psysW = rate("psys");

        const loads = sample.busy.map((busy, i) => {
            const total = sample.total[i] - (last.total[i] ?? 0);
            return total > 0 ? Math.min(1, (busy - (last.busy[i] ?? 0)) / total) : 0;
        });
        cpuLoad = loads.length > 0 ? loads[0] : NaN;
        threadLoads = loads.slice(1);

        record(sample.t, dt);
    }

    function gpuLine(line) {
        const fields = line.split(",").map(field => field.trim());
        if (fields.length < gpuFields.length)
            return;
        const value = i => {
            const number = parseFloat(fields[i]);
            return isFinite(number) ? number : NaN;
        };
        gpu = {
            "name": fields[0].replace(/^NVIDIA (GeForce )?/, ""),
            "watts": value(1),
            "limit": value(2),
            "temp": value(3),
            "load": value(4) / 100,
            "clock": value(5),
            "memClock": value(6),
            "maxClock": value(7),
            "fan": value(8) / 100,
            "pstate": fields[9],
            "vramUsed": value(10),
            "vramTotal": value(11),
            "pcieGen": value(12),
            "pcieWidth": value(13),
            "reasons": parseInt(fields[14], 16) || 0
        };
    }

    function record(t, dt) {
        const values = [cpuW, gpuW, restW].map(value => isFinite(value) ? value : null);

        recent.push([t].concat(values));
        while (recent.length > 0 && recent[0][0] < t - 7200)
            recent.shift();

        // energy, on the day it was drawn
        const key = Qt.formatDate(new Date(t * 1000), "yyyy-MM-dd");
        const day = days[key] ?? (days[key] = [0, 0, 0]);
        values.forEach((value, i) => {
            day[i] = (day[i] ?? 0) + (value ?? 0) * dt / 3600;
        });

        const minute = Math.floor(t / 60);
        if (_minute && _minute.minute !== minute)
            closeMinute();
        if (!_minute)
            _minute = {
                "minute": minute,
                "sums": [[0, 0], [0, 0], [0, 0]]
            };
        values.forEach((value, i) => {
            if (value !== null) {
                _minute.sums[i][0] += value;
                _minute.sums[i][1]++;
            }
        });

        revision++;
    }

    function closeMinute() {
        const done = _minute;
        _minute = null;
        minutes.push([done.minute].concat(done.sums.map(sum => sum[1] > 0 ? sum[0] / sum[1] : null)));
        while (minutes.length > 0 && minutes[0][0] <= done.minute - 1440)
            minutes.shift();

        const oldest = Qt.formatDate(new Date((done.minute - 31 * 1440) * 60000), "yyyy-MM-dd");
        for (const key in days) {
            if (key < oldest)
                delete days[key];
        }
        save();
    }

    // a minute is "minute,cpu,gpu,rest"; one string keeps the state file small
    function save() {
        const round = value => value === null || value === undefined ? "" : value.toFixed(1);
        PluginService.savePluginState(pluginId, "minutes", minutes.map(m => [m[0]].concat(m.slice(1).map(round)).join(",")).join(";"));
        PluginService.savePluginState(pluginId, "days", JSON.parse(JSON.stringify(days)));
    }

    function load() {
        const stored = PluginService.loadPluginState(pluginId, "minutes", "");
        minutes = stored ? stored.split(";").map(entry => {
            const fields = entry.split(",");
            return [Number(fields[0])].concat([1, 2, 3].map(i => fields[i] === undefined || fields[i] === "" ? null : Number(fields[i])));
        }) : [];
        days = JSON.parse(JSON.stringify(PluginService.loadPluginState(pluginId, "days", {})));
    }

    // the last span seconds in buckets columns of [cpu, gpu, rest] averages, null where nothing was recorded
    function series(span, buckets) {
        const end = Date.now() / 1000;
        const start = end - span;
        const source = span > 7200 ? minutes.map(m => [m[0] * 60 + 30].concat(m.slice(1))) : recent;
        const sums = [];
        let total = 0;
        let count = 0;
        let peak = 0;
        for (const sample of source) {
            // nothing readable is a gap, not 0 W
            if (sample[0] < start || sample.slice(1).every(value => value === null || value === undefined))
                continue;
            const i = Math.min(buckets - 1, Math.floor((sample[0] - start) / span * buckets));
            const sum = sums[i] ?? (sums[i] = [0, 0, 0, 0]);
            let watts = 0;
            for (let k = 0; k < 3; k++) {
                sum[k] += sample[k + 1] ?? 0;
                watts += sample[k + 1] ?? 0;
            }
            sum[3]++;
            total += watts;
            count++;
            peak = Math.max(peak, watts);
        }
        const points = [];
        for (let i = 0; i < buckets; i++)
            points.push(sums[i] ? sums[i].slice(0, 3).map(sum => sum / sums[i][3]) : null);
        return {
            "start": start,
            "end": end,
            "points": points,
            "average": count > 0 ? total / count : NaN,
            "peak": count > 0 ? peak : NaN
        };
    }

    // Wh over the last count days, today included
    function energy(count) {
        const now = new Date();
        let total = 0;
        for (let i = 0; i < count; i++) {
            const day = days[Qt.formatDate(new Date(now.getFullYear(), now.getMonth(), now.getDate() - i), "yyyy-MM-dd")];
            if (day)
                total += day.reduce((sum, wh) => sum + (wh ?? 0), 0);
        }
        return total;
    }

    function setConservation(on) {
        const target = on ? 1 : 0;
        if (conservation < 0 || conservationBusy || target === conservation)
            return;
        _conservationTarget = target;
        Proc.runCommand("powerDraw.conservation", ["pkexec", "@conservation@", String(target)], (output, exitCode) => {
            root._conservationTarget = -1;
            if (exitCode === 0)
                ToastService.showInfo(target ? "Conservation mode on" : "Conservation mode off");
            else if (exitCode === 126 || exitCode === 127)
                ToastService.showError("Authentication failed, or no polkit agent is running");
            else
                ToastService.showError(`Couldn't change conservation mode (${exitCode})`);
        }, 0);
    }

    function refreshHistory() {
        if (historyLoading || !BatteryService.batteryAvailable)
            return;
        historyLoading = true;
        Proc.runCommand("powerDraw.history", ["@history@"], (output, exitCode) => {
            root.historyLoading = false;
            if (exitCode === 0)
                root.parseHistory(output);
        }, 0);
    }

    function refreshHistoryIfStale() {
        if (Date.now() / 1000 - historyFetchedAt >= 60)
            refreshHistory();
    }

    function parseHistory(output) {
        const pattern = /\((?:uint32 )?(\d{6,12}), ([0-9.]+), (?:uint32 )?(\d+)\)/g;
        const list = [];
        let match;
        while ((match = pattern.exec(output)) !== null) {
            const level = parseFloat(match[2]);
            if (level <= 0)
                continue;
            list.push({
                "t": parseInt(match[1]),
                "v": Math.min(100, level),
                "s": parseInt(match[3])
            });
        }
        list.sort((a, b) => a.t - b.t);
        chargeSamples = list;
        historyFetchedAt = Date.now() / 1000;
    }

    // measured discharge power over the history window, from the charge history and pack capacity
    readonly property real averageDrainW: {
        const capacity = BatteryService.batteryCapacity;
        if (capacity <= 0 || chargeSamples.length < 2)
            return 0;
        const start = Math.floor(Date.now() / 1000) - historyHours * 3600;
        let percent = 0;
        let seconds = 0;
        for (let i = 1; i < chargeSamples.length; i++) {
            const a = chargeSamples[i - 1];
            const b = chargeSamples[i];
            if (b.t < start || b.s !== 2 || a.s !== 2)
                continue;
            const dt = b.t - a.t;
            if (dt <= 0 || dt > 1200 || a.v <= b.v)
                continue;
            percent += a.v - b.v;
            seconds += dt;
        }
        if (seconds < 600)
            return 0;
        return (percent / 100 * capacity) / (seconds / 3600);
    }

    // runtime on a full charge at that measured drain
    readonly property real fullChargeHours: averageDrainW > 0 && BatteryService.batteryCapacity > 0 ? BatteryService.batteryCapacity / averageDrainW : 0

    function formatHours(hours) {
        let h = Math.floor(hours);
        let m = Math.round((hours - h) * 60);
        if (m === 60) {
            h++;
            m = 0;
        }
        return h > 0 ? `${h}h ${m}m` : `${m}m`;
    }

    // use since the battery was last unplugged, walking discharge samples back from now
    readonly property string sinceUnplug: {
        if (BatteryService.isCharging || BatteryService.isPluggedIn || chargeSamples.length < 2)
            return "";
        let i = chargeSamples.length - 1;
        while (i > 0 && chargeSamples[i - 1].s === 2)
            i--;
        const start = chargeSamples[i];
        const duration = Math.floor(Date.now() / 1000) - start.t;
        if (duration < 300 || duration > 86400)
            return "";
        const used = Math.round(start.v - BatteryService.batteryLevel);
        return used < 1 ? "" : `Used ${used}% in ${formatHours(duration / 3600)} on battery`;
    }

    Process {
        id: sampler

        command: ["@sampler@"]
        running: true

        stdout: SplitParser {
            onRead: data => root.cpuLine(data)
        }

        onRunningChanged: {
            if (running)
                return;
            root._last = null;
            root.pkgW = NaN;
            root.psysW = NaN;
            samplerRetry.start();
        }
    }

    Timer {
        id: samplerRetry

        interval: 5000
        onTriggered: sampler.running = true
    }

    Process {
        id: gpuStream

        command: ["nvidia-smi", "--query-gpu=" + root.gpuFields.join(","), "--format=csv,noheader,nounits", "-lms", "1000"]
        running: root.hasNvidia

        stdout: SplitParser {
            onRead: data => root.gpuLine(data)
        }

        onRunningChanged: {
            if (running)
                return;
            root.gpu = null;
            if (root.hasNvidia)
                gpuRetry.start();
        }
    }

    // a driver update waiting on a reboot
    Timer {
        id: gpuRetry

        interval: 30000
        onTriggered: gpuStream.running = true
    }

    Timer {
        interval: 300000
        repeat: true
        running: BatteryService.batteryAvailable
        triggeredOnStart: true
        onTriggered: root.refreshHistory()
    }

    Component.onCompleted: {
        load();
        Proc.runCommand(null, ["nvidia-smi", "-q", "-d", "TEMPERATURE"], (output, exitCode) => {
            if (exitCode !== 0)
                return;
            const match = output.match(/GPU Max Operating Temp\s*:\s*(\d+)/);
            if (match)
                root.gpuMaxTemp = Number(match[1]);
            root.hasNvidia = true;
        }, 0);
    }
}
