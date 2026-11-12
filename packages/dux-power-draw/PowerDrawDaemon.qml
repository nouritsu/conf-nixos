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

    // latest readings, NaN where a sensor is missing
    // rapl's package power, else the ec's vcore x current
    property real cpuW: NaN
    property bool cpuFromRapl: false
    property real coreW: NaN
    property real vcore: NaN
    property real amps: NaN
    property real tctl: NaN
    property real cpuGhz: NaN
    property real cpuLoad: NaN
    property var threadLoads: []

    property var gpu: null
    property real gpuMaxTemp: NaN
    readonly property real gpuW: gpu?.watts ?? NaN

    // [time, cpu W, gpu W] each second for 2 h; changed in place, revision ticks
    property var recent: []
    // [epoch minute, cpu W, gpu W] averages for 24 h, saved
    property var minutes: []
    // "yyyy-MM-dd" -> [cpu Wh, gpu Wh] for 31 days, saved
    property var days: ({})
    property int revision: 0

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
            cpuModel = sample.model.replace(/^(AMD|Intel\(R\) Core\(TM\)) /, "").replace(/ \d+-Core Processor$/, "");
            cpuMaxGhz = reading(sample.maxKhz, 1e6);
            return;
        }

        const last = _last;
        _last = sample;
        const dt = last ? sample.t - last.t : 0;
        // the first line, or the one after a suspend
        if (!(dt > 0 && dt < 5))
            return;

        // rapl counters wrap at range
        const rate = (now, before) => {
            if (now === null || before === null)
                return NaN;
            const delta = now >= before ? now - before : now - before + sample.range;
            return delta >= 0 ? delta / 1e6 / dt : NaN;
        };
        const pkg = rate(sample.pkg, last.pkg);
        coreW = rate(sample.core, last.core);
        vcore = reading(sample.vcore, 1000);
        amps = reading(sample.amps, 1000);
        cpuFromRapl = isFinite(pkg);
        cpuW = cpuFromRapl ? pkg : vcore * amps;
        tctl = reading(sample.tctl, 1000);
        cpuGhz = reading(sample.khz, 1e6);

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
        const cpu = isFinite(cpuW) ? cpuW : null;
        const gpuNow = isFinite(gpuW) ? gpuW : null;

        recent.push([t, cpu, gpuNow]);
        while (recent.length > 0 && recent[0][0] < t - 7200)
            recent.shift();

        // energy, on the day it was drawn
        const key = Qt.formatDate(new Date(t * 1000), "yyyy-MM-dd");
        const day = days[key] ?? (days[key] = [0, 0]);
        day[0] += (cpu ?? 0) * dt / 3600;
        day[1] += (gpuNow ?? 0) * dt / 3600;

        const minute = Math.floor(t / 60);
        if (_minute && _minute.minute !== minute)
            closeMinute();
        if (!_minute)
            _minute = {
                "minute": minute,
                "cpu": [0, 0],
                "gpu": [0, 0]
            };
        if (cpu !== null) {
            _minute.cpu[0] += cpu;
            _minute.cpu[1]++;
        }
        if (gpuNow !== null) {
            _minute.gpu[0] += gpuNow;
            _minute.gpu[1]++;
        }

        revision++;
    }

    function closeMinute() {
        const done = _minute;
        _minute = null;
        const average = sum => sum[1] > 0 ? sum[0] / sum[1] : null;
        minutes.push([done.minute, average(done.cpu), average(done.gpu)]);
        while (minutes.length > 0 && minutes[0][0] <= done.minute - 1440)
            minutes.shift();

        const oldest = Qt.formatDate(new Date((done.minute - 31 * 1440) * 60000), "yyyy-MM-dd");
        for (const key in days) {
            if (key < oldest)
                delete days[key];
        }
        save();
    }

    // a minute is "minute,cpu,gpu"; one string keeps the state file small
    function save() {
        const round = value => value === null ? "" : value.toFixed(1);
        PluginService.savePluginState(pluginId, "minutes", minutes.map(m => `${m[0]},${round(m[1])},${round(m[2])}`).join(";"));
        PluginService.savePluginState(pluginId, "days", JSON.parse(JSON.stringify(days)));
    }

    function load() {
        const stored = PluginService.loadPluginState(pluginId, "minutes", "");
        minutes = stored ? stored.split(";").map(entry => {
            const [minute, cpuAverage, gpuAverage] = entry.split(",");
            return [Number(minute), cpuAverage === "" ? null : Number(cpuAverage), gpuAverage === "" ? null : Number(gpuAverage)];
        }) : [];
        days = JSON.parse(JSON.stringify(PluginService.loadPluginState(pluginId, "days", {})));
    }

    // the last span seconds in buckets columns of [cpu, gpu] averages, null where nothing was recorded
    function series(span, buckets) {
        const end = Date.now() / 1000;
        const start = end - span;
        const source = span > 7200 ? minutes.map(m => [m[0] * 60 + 30, m[1], m[2]]) : recent;
        const sums = [];
        let total = 0;
        let count = 0;
        let peak = 0;
        for (const sample of source) {
            if (sample[0] < start)
                continue;
            const i = Math.min(buckets - 1, Math.floor((sample[0] - start) / span * buckets));
            const sum = sums[i] ?? (sums[i] = [0, 0, 0]);
            sum[0] += sample[1] ?? 0;
            sum[1] += sample[2] ?? 0;
            sum[2]++;
            const watts = (sample[1] ?? 0) + (sample[2] ?? 0);
            total += watts;
            count++;
            peak = Math.max(peak, watts);
        }
        const points = [];
        for (let i = 0; i < buckets; i++)
            points.push(sums[i] ? [sums[i][0] / sums[i][2], sums[i][1] / sums[i][2]] : null);
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
                total += day[0] + day[1];
        }
        return total;
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
            root.cpuW = NaN;
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
        running: true

        stdout: SplitParser {
            onRead: data => root.gpuLine(data)
        }

        onRunningChanged: {
            if (running)
                return;
            root.gpu = null;
            gpuRetry.start();
        }
    }

    // no nvidia gpu, or a driver update waiting on a reboot
    Timer {
        id: gpuRetry

        interval: 30000
        onTriggered: gpuStream.running = true
    }

    Component.onCompleted: {
        load();
        Proc.runCommand(null, ["nvidia-smi", "-q", "-d", "TEMPERATURE"], (output, exitCode) => {
            const match = output.match(/GPU Max Operating Temp\s*:\s*(\d+)/);
            if (exitCode === 0 && match)
                root.gpuMaxTemp = Number(match[1]);
        }, 0);
    }
}
