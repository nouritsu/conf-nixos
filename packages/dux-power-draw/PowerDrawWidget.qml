pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Shapes
import qs.Common
import qs.Modules.Plugins
import qs.Services
import qs.DCommon.Widgets
import qs.Widgets

PluginComponent {
    id: root

    // sampling, history, energy and conservation live in the daemon, shared by every bar
    readonly property var daemon: PluginService.pluginDaemonInstances[pluginId] ?? null
    readonly property var gpu: daemon?.gpu ?? null

    // chart bands and their meters; the total gets its own line
    readonly property color cpuColor: Theme.primary
    readonly property color gpuColor: Theme.tertiary
    readonly property color restColor: Theme.onSurfaceVariant
    readonly property color totalColor: Theme.onSurface

    // ryzen's tjmax, when the sensor has no crit
    readonly property real cpuMaxTemp: isFinite(daemon?.cpuMaxTemp ?? NaN) ? daemon.cpuMaxTemp : 95

    // each span averaged into this many chart columns
    readonly property var spans: [
        {
            "label": "5m",
            "seconds": 300,
            "buckets": 150
        },
        {
            "label": "30m",
            "seconds": 1800,
            "buckets": 180
        },
        {
            "label": "2h",
            "seconds": 7200,
            "buckets": 240
        },
        {
            "label": "24h",
            "seconds": 86400,
            "buckets": 288
        }
    ]
    property int spanIndex: 0

    // popout tab with a battery: 0 power, 1 battery
    property int tab: 0

    readonly property var sourceNames: ["cpu", "gpu", "rest"]
    readonly property var sourceLabels: ({
            "cpu": "CPU",
            "gpu": "GPU",
            "rest": "Rest"
        })
    readonly property var pillSources: [
        {
            "key": "cpu",
            "icon": "memory",
            "reserve": "00 W"
        },
        {
            "key": "gpu",
            "icon": "developer_board",
            "reserve": "000 W"
        }
    ]

    readonly property string statusLine: `${Math.round(BatteryService.batteryLevel)}% · ${BatteryService.batteryStatus}`

    readonly property color stateColor: {
        if (BatteryService.isLowBattery && !BatteryService.isCharging)
            return Theme.error;
        if (BatteryService.isCharging || BatteryService.isPluggedIn)
            return Theme.primary;
        return Theme.surfaceText;
    }

    readonly property color pillIconColor: {
        if (!BatteryService.batteryAvailable)
            return Theme.widgetIconColor;
        if (BatteryService.isLowBattery && !BatteryService.isCharging)
            return Theme.error;
        if (BatteryService.isCharging || BatteryService.isPluggedIn)
            return Theme.primary;
        return Theme.widgetIconColor;
    }

    function sourceWatts(key) {
        switch (key) {
        case "cpu":
            return daemon?.cpuW ?? NaN;
        case "gpu":
            return daemon?.gpuW ?? NaN;
        default:
            return daemon?.restW ?? NaN;
        }
    }

    function sourceColor(key) {
        return key === "cpu" ? cpuColor : key === "gpu" ? gpuColor : restColor;
    }

    function watts(value) {
        return isFinite(value) ? `${Math.round(value)} W` : "– W";
    }

    // one decimal, for the cards
    function preciseWatts(value) {
        return isFinite(value) ? `${value.toFixed(1)} W` : "–";
    }

    function percent(ratio) {
        return isFinite(ratio) ? `${Math.round(ratio * 100)} %` : "–";
    }

    function number(value, digits, unit) {
        return isFinite(value) ? `${value.toFixed(digits)} ${unit}` : "–";
    }

    function energyText(wh) {
        return wh < 1000 ? `${Math.round(wh)} Wh` : `${(wh / 1000).toFixed(wh < 10000 ? 2 : 1)} kWh`;
    }

    function costText(wh) {
        return `${(wh / 1000 * (daemon?.priceCt ?? 0) / 100).toFixed(2)} €`;
    }

    function clock(time, seconds) {
        const format = SettingsData.use24HourClock ? (seconds ? "HH:mm:ss" : "HH:mm") : (seconds ? "h:mm:ss ap" : "h:mm ap");
        return Qt.formatTime(new Date(time * 1000), format);
    }

    // clock limits worth knowing; idle and app or display clocks are routine
    function gpuLimits(reasons) {
        const names = [[0x4, "power cap"], [0x8, "hardware slowdown"], [0x20, "temperature"], [0x40, "hardware temperature"], [0x80, "power brake"]];
        return names.filter(entry => reasons & entry[0]).map(entry => entry[1]).join(", ");
    }

    // cpu details: the board's core rail on the pc, rapl's zones with psys
    readonly property var cpuDetailLabels: daemon?.platform ? ["Package", "SoC", "Platform"] : ["Core rail", "Vcore", "Current"]

    function cpuDetail(label) {
        const d = daemon;
        if (!d)
            return "–";
        switch (label) {
        case "Package":
            return preciseWatts(d.pkgW);
        case "SoC":
            return preciseWatts(d.pkgW - d.coreW - d.uncoreW);
        case "Platform":
            return preciseWatts(d.psysW);
        case "Core rail":
            return preciseWatts(d.ecW);
        case "Vcore":
            return number(d.vcore, 2, "V");
        default:
            return number(d.amps, 0, "A");
        }
    }

    horizontalBarPill: Component {
        Row {
            spacing: Theme.spacingS

            // the battery, or a plug without one
            Row {
                spacing: Theme.spacingXS
                anchors.verticalCenter: parent.verticalCenter

                DIcon {
                    name: BatteryService.getBatteryIcon()
                    size: root.iconSize
                    color: root.pillIconColor
                    anchors.verticalCenter: parent.verticalCenter
                }

                StyledText {
                    visible: BatteryService.batteryAvailable
                    text: `${BatteryService.batteryLevel}%`
                    font.pixelSize: root.textSize
                    color: Theme.widgetTextColor
                    anchors.verticalCenter: parent.verticalCenter
                }

                DIcon {
                    visible: root.daemon?.conservation === 1
                    name: "battery_android_frame_shield"
                    size: root.iconSize
                    color: Theme.primary
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            Repeater {
                model: root.pillSources

                Row {
                    id: pillSource

                    required property var modelData

                    spacing: Theme.spacingXS
                    anchors.verticalCenter: parent.verticalCenter

                    DIcon {
                        name: pillSource.modelData.icon
                        size: root.iconSize
                        color: Theme.widgetIconColor
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    NumericText {
                        text: root.watts(root.sourceWatts(pillSource.modelData.key))
                        reserveText: pillSource.modelData.reserve
                        font.pixelSize: root.textSize
                        color: Theme.widgetTextColor
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }
        }
    }

    verticalBarPill: Component {
        Column {
            spacing: Theme.spacingXS

            DIcon {
                name: BatteryService.getBatteryIcon()
                size: root.iconSize
                color: root.pillIconColor
                anchors.horizontalCenter: parent.horizontalCenter
            }

            StyledText {
                visible: BatteryService.batteryAvailable
                text: String(BatteryService.batteryLevel)
                font.pixelSize: root.textSize
                color: Theme.widgetTextColor
                anchors.horizontalCenter: parent.horizontalCenter
            }

            DIcon {
                visible: root.daemon?.conservation === 1
                name: "battery_android_frame_shield"
                size: root.iconSize
                color: Theme.primary
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Repeater {
                model: root.pillSources

                Column {
                    id: pillColumn

                    required property var modelData
                    readonly property real value: root.sourceWatts(modelData.key)

                    spacing: 1
                    anchors.horizontalCenter: parent.horizontalCenter

                    DIcon {
                        name: pillColumn.modelData.icon
                        size: root.iconSize
                        color: Theme.widgetIconColor
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    StyledText {
                        text: isFinite(pillColumn.value) ? String(Math.round(pillColumn.value)) : "–"
                        font.pixelSize: root.textSize
                        color: Theme.widgetTextColor
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                }
            }
        }
    }

    // icon, title, and a muted detail filling the rest
    component CardHeader: Row {
        id: header

        property string icon
        property string title
        property string detail
        property color color

        spacing: Theme.spacingS

        DIcon {
            id: headerIcon

            name: header.icon
            size: Theme.iconSize
            color: header.color
            anchors.verticalCenter: parent.verticalCenter
        }

        StyledText {
            id: headerTitle

            text: header.title
            font.pixelSize: Theme.fontSizeMedium
            font.weight: Theme.fontWeightMedium
            color: Theme.onSurface
            anchors.verticalCenter: parent.verticalCenter
        }

        StyledText {
            width: header.width - headerIcon.width - headerTitle.width - header.spacing * 2
            text: header.detail
            font.pixelSize: Theme.fontSizeSmall
            color: Theme.onSurfaceVariant
            wrapMode: Text.NoWrap
            elide: Text.ElideRight
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    // a big reading with a muted note on its baseline
    component BigValue: Row {
        id: big

        property string value
        property string note

        spacing: Theme.spacingXS

        StyledText {
            id: bigText

            text: big.value
            font.pixelSize: Theme.fontSizeXLarge
            color: Theme.onSurface
        }

        StyledText {
            text: big.note
            font.pixelSize: Theme.fontSizeSmall
            color: Theme.onSurfaceVariant
            anchors.baseline: bigText.baseline
        }
    }

    // btop-style row: label, bar, value
    component Meter: Item {
        id: meter

        property string label
        property real ratio: NaN
        property string value
        property color color: Theme.primary
        property real labelWidth: 0
        property real valueWidth: 0

        height: Math.max(meterLabel.implicitHeight, meterValue.implicitHeight)

        StyledText {
            id: meterLabel

            width: meter.labelWidth
            text: meter.label
            font.pixelSize: Theme.fontSizeSmall
            color: Theme.onSurfaceVariant
            anchors.verticalCenter: parent.verticalCenter
        }

        Rectangle {
            x: meter.labelWidth + Theme.spacingS
            width: meter.width - x - meter.valueWidth - Theme.spacingS
            height: Theme.spacingXS
            radius: height / 2
            color: Theme.withAlpha(Theme.onSurface, 0.12)
            anchors.verticalCenter: parent.verticalCenter

            Rectangle {
                width: parent.width * (isFinite(meter.ratio) ? Math.max(0, Math.min(1, meter.ratio)) : 0)
                height: parent.height
                radius: parent.radius
                color: meter.color
            }
        }

        StyledText {
            id: meterValue

            width: meter.valueWidth
            text: meter.value
            font.pixelSize: Theme.fontSizeSmall
            color: Theme.onSurface
            horizontalAlignment: Text.AlignRight
            wrapMode: Text.NoWrap
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    // a muted label and its value
    component Detail: Row {
        id: detail

        property string label
        property string value

        spacing: Theme.spacingXS

        StyledText {
            text: detail.label
            font.pixelSize: Theme.fontSizeSmall
            color: Theme.onSurfaceVariant
        }

        StyledText {
            text: detail.value
            font.pixelSize: Theme.fontSizeSmall
            color: Theme.onSurface
        }
    }

    // upower's charge history: discharge in primary, charging in green, gaps dashed
    component ChargeChart: Item {
        id: chart

        property var daemon: null

        readonly property real padL: 6
        readonly property real padR: 12
        readonly property real padT: 16
        readonly property real padB: 22

        // samples further apart are a recording gap
        readonly property int gapS: 1200

        property bool hoverVisible: false
        property real hoverX: 0
        property real hoverY: 0
        property string hoverLabel: ""
        property bool hoverCharging: false

        function isChargingState(state) {
            return state === 1 || state === 4 || state === 5;
        }

        function updateHover(mouseX) {
            const cw = width - padL - padR;
            const ch = height - padT - padB;
            const samples = daemon?.chargeSamples ?? [];
            if (cw <= 0 || samples.length === 0) {
                hoverVisible = false;
                return;
            }
            const now = Math.floor(Date.now() / 1000);
            const span = (daemon?.historyHours ?? 24) * 3600;
            const t0 = now - span;
            const t = t0 + (mouseX - padL) / cw * span;
            let best = null;
            let distance = Number.MAX_VALUE;
            // only in-window samples, or the dot pins to the left edge
            for (const sample of samples) {
                if (sample.t < t0)
                    continue;
                const d = Math.abs(sample.t - t);
                if (d < distance) {
                    distance = d;
                    best = sample;
                }
            }
            if (!best || distance > span / 8) {
                hoverVisible = false;
                return;
            }
            hoverX = Math.min(Math.max(padL + (best.t - t0) / span * cw, padL), padL + cw);
            hoverY = padT + (100 - best.v) / 100 * ch;
            hoverLabel = Qt.formatTime(new Date(best.t * 1000), SettingsData.use24HourClock ? "HH:mm" : "h:mm ap") + " · " + Math.round(best.v) + "%";
            hoverCharging = isChargingState(best.s);
            hoverVisible = true;
        }

        Canvas {
            id: canvas

            anchors.fill: parent
            renderStrategy: Canvas.Threaded

            onPaint: {
                const ctx = getContext("2d");
                ctx.reset();
                const padL = chart.padL;
                const padT = chart.padT;
                const cw = width - padL - chart.padR;
                const ch = height - padT - chart.padB;
                if (cw <= 0 || ch <= 0)
                    return;

                const now = Math.floor(Date.now() / 1000);
                const hours = chart.daemon?.historyHours ?? 24;
                const span = hours * 3600;
                const t0 = now - span;
                const X = t => padL + (t - t0) / span * cw;
                const Y = v => padT + (100 - v) / 100 * ch;

                const pts = (chart.daemon?.chargeSamples ?? []).filter(sample => sample.t >= t0 - 3600);

                // hairlines with labels above them
                const gridColor = Theme.withAlpha(Theme.outline, 0.10);
                ctx.lineWidth = 1;
                ctx.strokeStyle = gridColor;
                ctx.font = `${Theme.fontSizeSmall}px sans-serif`;
                ctx.fillStyle = Theme.withAlpha(Theme.surfaceVariantText, 0.8);
                ctx.textAlign = "left";
                ctx.textBaseline = "bottom";
                for (const v of [0, 50, 100]) {
                    ctx.beginPath();
                    ctx.moveTo(padL, Y(v));
                    ctx.lineTo(padL + cw, Y(v));
                    ctx.stroke();
                    ctx.fillText(v + "%", padL, Y(v) - 2);
                }

                // ticks on round hours
                ctx.textBaseline = "top";
                ctx.textAlign = "center";
                const step = (hours <= 12 ? 3 : 6) * 3600;
                const d0 = new Date(t0 * 1000);
                const dayStart = new Date(d0.getFullYear(), d0.getMonth(), d0.getDate()).getTime() / 1000;
                for (let tick = dayStart + Math.ceil((t0 - dayStart) / step) * step; tick <= now; tick += step) {
                    const x = X(tick);
                    if (x < padL + 18 || x > padL + cw - 18)
                        continue;
                    ctx.strokeStyle = gridColor;
                    ctx.beginPath();
                    ctx.moveTo(x, padT);
                    ctx.lineTo(x, padT + ch);
                    ctx.stroke();
                    ctx.fillText(Qt.formatTime(new Date(tick * 1000), SettingsData.use24HourClock ? "HH:mm" : "h ap"), x, padT + ch + 6);
                }

                if (pts.length < 2)
                    return;

                // runs split at recording gaps
                const runs = [];
                let run = [pts[0]];
                for (let i = 1; i < pts.length; i++) {
                    if (pts[i].t - pts[i - 1].t > chart.gapS) {
                        runs.push(run);
                        run = [];
                    }
                    run.push(pts[i]);
                }
                runs.push(run);

                ctx.save();
                ctx.beginPath();
                ctx.rect(padL, padT, cw, ch);
                ctx.clip();

                const gradient = ctx.createLinearGradient(0, padT, 0, padT + ch);
                gradient.addColorStop(0, Theme.withAlpha(Theme.primary, 0.20));
                gradient.addColorStop(1, Theme.withAlpha(Theme.primary, 0.0));

                // smooth path through quadratic midpoints
                function tracePath(rp) {
                    ctx.moveTo(X(rp[0].t), Y(rp[0].v));
                    if (rp.length === 2) {
                        ctx.lineTo(X(rp[1].t), Y(rp[1].v));
                        return;
                    }
                    for (let i = 1; i < rp.length - 1; i++) {
                        const xc = (X(rp[i].t) + X(rp[i + 1].t)) / 2;
                        const yc = (Y(rp[i].v) + Y(rp[i + 1].v)) / 2;
                        ctx.quadraticCurveTo(X(rp[i].t), Y(rp[i].v), xc, yc);
                    }
                    ctx.lineTo(X(rp[rp.length - 1].t), Y(rp[rp.length - 1].v));
                }

                for (const rp of runs) {
                    if (rp.length < 2)
                        continue;

                    // fill only runs wide enough to read as area
                    if (X(rp[rp.length - 1].t) - X(rp[0].t) >= 8) {
                        ctx.beginPath();
                        tracePath(rp);
                        ctx.lineTo(X(rp[rp.length - 1].t), padT + ch);
                        ctx.lineTo(X(rp[0].t), padT + ch);
                        ctx.closePath();
                        ctx.fillStyle = gradient;
                        ctx.fill();
                    }

                    // charging spans get their own colour
                    ctx.lineWidth = 2.5;
                    ctx.lineJoin = "round";
                    ctx.lineCap = "round";
                    let i = 1;
                    while (i < rp.length) {
                        const charging = chart.isChargingState(rp[i].s);
                        const segment = [rp[i - 1]];
                        while (i < rp.length && chart.isChargingState(rp[i].s) === charging) {
                            segment.push(rp[i]);
                            i++;
                        }
                        ctx.beginPath();
                        tracePath(segment);
                        ctx.strokeStyle = charging ? Theme.success : Theme.primary;
                        ctx.stroke();
                    }
                }

                // faint connectors across gaps
                ctx.setLineDash([2, 5]);
                ctx.lineWidth = 1;
                ctx.strokeStyle = Theme.withAlpha(Theme.outline, 0.35);
                for (let r = 1; r < runs.length; r++) {
                    const a = runs[r - 1][runs[r - 1].length - 1];
                    const b = runs[r][0];
                    ctx.beginPath();
                    ctx.moveTo(X(a.t), Y(a.v));
                    ctx.lineTo(X(b.t), Y(b.v));
                    ctx.stroke();
                }
                ctx.setLineDash([]);
                ctx.restore();

                // the newest sample, unclipped
                const last = pts[pts.length - 1];
                if (now - last.t < chart.gapS) {
                    ctx.beginPath();
                    ctx.arc(Math.min(X(last.t), padL + cw), Y(last.v), 3.5, 0, Math.PI * 2);
                    ctx.fillStyle = chart.isChargingState(last.s) ? Theme.success : Theme.primary;
                    ctx.fill();
                }
            }
        }

        StyledText {
            anchors.centerIn: parent
            visible: (chart.daemon?.chargeSamples.length ?? 0) < 2 && !(chart.daemon?.historyLoading ?? false)
            text: "No battery history yet"
            color: Theme.surfaceVariantText
            font.pixelSize: Theme.fontSizeSmall
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            acceptedButtons: Qt.NoButton
            onPositionChanged: mouse => chart.updateHover(mouse.x)
            onExited: chart.hoverVisible = false
        }

        Rectangle {
            visible: chart.hoverVisible
            x: chart.hoverX
            y: chart.padT
            width: 1
            height: chart.height - chart.padT - chart.padB
            color: Theme.withAlpha(Theme.primary, 0.35)
        }

        Rectangle {
            visible: chart.hoverVisible
            x: chart.hoverX - width / 2
            y: chart.hoverY - height / 2
            width: 10
            height: 10
            radius: 5
            color: chart.hoverCharging ? Theme.success : Theme.primary
            border.color: Theme.surfaceContainerHigh
            border.width: 2
        }

        Rectangle {
            visible: chart.hoverVisible
            x: Math.min(Math.max(chart.hoverX - width / 2, 0), chart.width - width)
            y: chart.hoverY - height - 12 < 0 ? chart.hoverY + 12 : chart.hoverY - height - 12
            width: tipText.implicitWidth + Theme.spacingM * 2
            height: tipText.implicitHeight + Theme.spacingS * 2
            radius: Theme.cornerRadius
            color: Theme.surfaceContainerHighest
            border.color: Theme.outlineLight
            border.width: 1

            StyledText {
                id: tipText

                anchors.centerIn: parent
                text: chart.hoverLabel
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.surfaceText
            }
        }

        Connections {
            target: chart.daemon

            function onChargeSamplesChanged() {
                canvas.requestPaint();
            }

            function onHistoryHoursChanged() {
                canvas.requestPaint();
            }
        }

        Connections {
            target: Theme

            function onPrimaryChanged() {
                canvas.requestPaint();
            }

            function onIsLightModeChanged() {
                canvas.requestPaint();
            }
        }

        // keep the now edge fresh while it's shown
        Timer {
            interval: 60000
            repeat: true
            running: canvas.visible
            onTriggered: canvas.requestPaint()
        }

        Component.onCompleted: canvas.requestPaint()
    }

    // batteryPlus's panel: status, stats and charge history
    component BatteryPanel: Column {
        id: panel

        property var widget: null
        readonly property var daemon: widget?.daemon ?? null
        readonly property var tileLabels: ["Health", "Capacity", "Energy", "Voltage", "Avg drain", "Est. runtime"]

        // empty hides the tile
        function tileValue(label) {
            switch (label) {
            case "Health":
                return BatteryService.batteryHealth;
            case "Capacity":
                return BatteryService.batteryCapacity > 0 ? BatteryService.batteryCapacity.toFixed(1) + " Wh" : "N/A";
            case "Energy":
                return BatteryService.batteryEnergy > 0 ? BatteryService.batteryEnergy.toFixed(1) + " Wh" : "N/A";
            case "Voltage":
                return isFinite(daemon?.batteryVolts ?? NaN) ? daemon.batteryVolts.toFixed(1) + " V" : "";
            case "Avg drain":
                return (daemon?.averageDrainW ?? 0) > 0 ? daemon.averageDrainW.toFixed(1) + " W" : "";
            default:
                return (daemon?.fullChargeHours ?? 0) > 0 ? daemon.formatHours(daemon.fullChargeHours) : "";
            }
        }

        spacing: PopoutMetrics.contentGap

        DCard {
            width: panel.width
            height: statusRow.implicitHeight + pad * 2
            restRadius: Theme.cornerRadiusL

            Row {
                id: statusRow

                width: parent.width
                spacing: Theme.spacingM

                DIcon {
                    id: statusIcon

                    name: BatteryService.getBatteryIcon()
                    size: Theme.iconSizeLarge
                    color: panel.widget?.stateColor ?? Theme.surfaceText
                    anchors.verticalCenter: parent.verticalCenter
                }

                Column {
                    width: parent.width - statusIcon.width - parent.spacing
                    spacing: Theme.spacingXS
                    anchors.verticalCenter: parent.verticalCenter

                    Row {
                        spacing: Theme.spacingS

                        StyledText {
                            id: levelText

                            text: `${BatteryService.batteryLevel}%`
                            font.pixelSize: Theme.fontSizeXLarge
                            font.weight: Font.Bold
                            color: panel.widget?.stateColor ?? Theme.surfaceText
                        }

                        StyledText {
                            text: BatteryService.batteryStatus
                            font.pixelSize: Theme.fontSizeLarge
                            font.weight: Font.Medium
                            color: panel.widget?.stateColor ?? Theme.surfaceText
                            anchors.baseline: levelText.baseline
                        }
                    }

                    StyledText {
                        width: parent.width
                        text: {
                            const time = BatteryService.formatTimeRemaining();
                            if (time === "Unknown")
                                return "";
                            return BatteryService.isCharging ? "Time until full: " + time : "Time remaining: " + time;
                        }
                        visible: text !== ""
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.surfaceTextMedium
                        elide: Text.ElideRight
                    }

                    StyledText {
                        width: parent.width
                        text: panel.daemon?.sinceUnplug ?? ""
                        visible: text !== ""
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.surfaceTextMedium
                        elide: Text.ElideRight
                    }
                }
            }
        }

        Grid {
            id: tiles

            width: panel.width
            columns: 3
            columnSpacing: Theme.spacingS
            rowSpacing: Theme.spacingS

            Repeater {
                model: panel.tileLabels

                DCard {
                    id: tile

                    required property string modelData
                    readonly property string value: panel.tileValue(modelData)

                    visible: value !== ""
                    width: (tiles.width - tiles.columnSpacing * 2) / 3
                    height: tileColumn.implicitHeight + pad * 2
                    restRadius: Theme.cornerRadiusM

                    Column {
                        id: tileColumn

                        width: parent.width
                        spacing: 2

                        StyledText {
                            width: parent.width
                            text: tile.modelData
                            font.pixelSize: Theme.fontSizeSmall
                            font.weight: Font.Medium
                            color: Theme.primary
                            horizontalAlignment: Text.AlignHCenter
                        }

                        StyledText {
                            width: parent.width
                            text: tile.value
                            font.pixelSize: Theme.fontSizeMedium
                            font.weight: Font.Bold
                            color: Theme.surfaceText
                            horizontalAlignment: Text.AlignHCenter
                        }
                    }
                }
            }
        }

        DCard {
            width: panel.width
            height: historyColumn.implicitHeight + pad * 2
            restRadius: Theme.cornerRadiusL

            Column {
                id: historyColumn

                width: parent.width
                spacing: Theme.spacingS

                Item {
                    width: parent.width
                    height: historyGroup.height

                    StyledText {
                        text: "History"
                        font.pixelSize: Theme.fontSizeSmall
                        font.weight: Theme.fontWeightMedium
                        color: Theme.primary
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    DButtonGroup {
                        id: historyGroup

                        readonly property var spans: [12, 24]

                        anchors.right: parent.right
                        size: "small"
                        checkEnabled: false
                        model: spans.map(hours => hours + "h")
                        currentIndex: spans.indexOf(panel.daemon?.historyHours ?? 24)
                        onSelectionChanged: (index, selected) => {
                            if (selected && panel.daemon)
                                panel.daemon.historyHours = spans[index];
                        }
                    }
                }

                ChargeChart {
                    width: parent.width
                    height: Theme.iconButtonSize * 4
                    daemon: panel.daemon
                }
            }
        }
    }

    // conservation first, then the power profiles
    component ModesCard: DCard {
        id: modes

        property var daemon: null
        readonly property var profiles: PowerProfileWatcher.availableProfiles
        readonly property bool conservable: (daemon?.conservation ?? -1) >= 0
        readonly property var shieldOption: ({
                "text": "Conservation",
                "icon": "battery_android_frame_shield",
                "tooltip": "Conservation: charge to about 60%"
            })

        function syncShield() {
            shieldGroup.currentSelection = modes.daemon?.conservation === 1 ? [modes.shieldOption] : [];
        }

        visible: PowerProfileWatcher.available || conservable
        height: modesColumn.implicitHeight + pad * 2
        restRadius: Theme.cornerRadiusL

        Column {
            id: modesColumn

            width: parent.width
            spacing: Theme.spacingS

            StyledText {
                text: "Mode"
                font.pixelSize: Theme.fontSizeSmall
                font.weight: Theme.fontWeightMedium
                color: Theme.primary
            }

            Row {
                id: modesRow

                width: parent.width
                spacing: Theme.spacingS

                // its own toggle; it combines with any profile
                DButtonGroup {
                    id: shieldGroup

                    visible: modes.conservable
                    width: (modesRow.width - modesRow.spacing) / 4
                    fillWidth: true
                    iconOnly: true
                    checkEnabled: false
                    size: "small"
                    selectionMode: "multi"
                    model: [modes.shieldOption]
                    enabled: !(modes.daemon?.conservationBusy ?? true)
                    Component.onCompleted: modes.syncShield()
                    onSelectionChanged: (index, selected) => modes.daemon?.setConservation(selected)
                }

                DButtonGroup {
                    width: modesRow.width - (shieldGroup.visible ? shieldGroup.width + modesRow.spacing : 0)
                    visible: PowerProfileWatcher.available
                    fillWidth: true
                    iconOnly: true
                    checkEnabled: false
                    size: "small"
                    model: modes.profiles.map(profile => ({
                                "text": Theme.getPowerProfileLabel(profile),
                                "icon": ["eco", "speed", "bolt"][profile]
                            }))
                    currentIndex: modes.profiles.indexOf(PowerProfileWatcher.currentProfile)
                    onSelectionChanged: (index, selected) => {
                        if (selected && !PowerProfileWatcher.applyProfile(modes.profiles[index]))
                            ToastService.showError("Failed to set power profile");
                    }
                }
            }
        }

        // the sysfs reading wins, also after a failed or cancelled pkexec
        Connections {
            target: modes.daemon

            function onConservationChanged() {
                modes.syncShield();
            }

            function onConservationBusyChanged() {
                modes.syncShield();
            }
        }
    }

    // control center: batteryPlus's tile, only with a battery
    ccWidgetIcon: BatteryService.batteryAvailable ? BatteryService.getBatteryIcon() : ""
    ccWidgetPrimaryText: "Battery"
    ccWidgetSecondaryText: statusLine
    ccWidgetIsActive: BatteryService.isCharging
    ccDetailHeight: 540

    onCcWidgetToggled: daemon?.refreshHistory()

    ccDetailContent: Component {
        Rectangle {
            width: parent.width
            height: Math.min(parent.height, detailColumn.implicitHeight + Theme.spacingL * 2)
            radius: Theme.cornerRadius
            color: Theme.nestedSurface
            border.color: Theme.outlineMedium
            border.width: Theme.layerOutlineWidth

            Column {
                id: detailColumn

                x: Theme.spacingL
                y: Theme.spacingL
                width: parent.width - Theme.spacingL * 2
                spacing: PopoutMetrics.contentGap

                BatteryPanel {
                    width: parent.width
                    widget: root
                }

                ModesCard {
                    width: parent.width
                    daemon: root.daemon
                }
            }
        }
    }

    popoutWidth: 600

    popoutContent: Component {
        Column {
            id: popout

            // set by the plugin popout
            property var parentPopout: null

            // the chart's columns, refreshed each sample while open
            property var view: null
            property int hover: -1

            readonly property bool hasBattery: BatteryService.batteryAvailable
            readonly property real labelWidth: labelMetrics.implicitWidth
            readonly property real valueWidth: valueMetrics.implicitWidth

            function refresh() {
                if (!root.interactionActive || !root.daemon)
                    return;
                const span = root.spans[root.spanIndex];
                view = root.daemon.series(span.seconds, span.buckets);
            }

            spacing: PopoutMetrics.contentGap

            Component.onCompleted: refresh()

            Connections {
                target: root.daemon

                function onRevisionChanged() {
                    popout.refresh();
                }
            }

            Connections {
                target: root

                function onInteractionActiveChanged() {
                    popout.refresh();
                    if (root.interactionActive)
                        root.daemon?.refreshHistoryIfStale();
                }

                function onSpanIndexChanged() {
                    popout.refresh();
                }
            }

            StyledText {
                id: labelMetrics

                visible: false
                text: "Threads"
                font.pixelSize: Theme.fontSizeSmall
            }

            StyledText {
                id: valueMetrics

                visible: false
                text: "88.8 / 88.8 GB"
                font.pixelSize: Theme.fontSizeSmall
            }

            DButtonGroup {
                visible: popout.hasBattery
                width: popout.width
                fillWidth: true
                checkEnabled: false
                size: "small"
                model: ["Power", "Battery"]
                currentIndex: root.tab
                onSelectionChanged: (index, selected) => {
                    if (selected)
                        root.tab = index;
                }
            }

            Column {
                id: powerTab

                visible: !popout.hasBattery || root.tab === 0
                width: popout.width
                spacing: PopoutMetrics.contentGap

                // headline total, its split, and the stacked history
                DCard {
                    id: chartCard

                    readonly property var bands: root.daemon?.sources ?? ["cpu", "gpu"]
                    readonly property var points: popout.view?.points ?? []
                    readonly property var hovered: popout.hover >= 0 && popout.hover < points.length ? points[popout.hover] : null
                    readonly property real hoverTime: popout.view && points.length > 0 ? popout.view.start + (popout.hover + 0.5) * (popout.view.end - popout.view.start) / points.length : 0
                    readonly property real shownTotal: popout.hover >= 0 ? (hovered ? hovered.reduce((sum, value) => sum + value, 0) : NaN) : root.daemon?.totalW ?? NaN

                    // the scale, rounded up from the tallest column
                    readonly property real ceiling: {
                        const tallest = Math.max(0, ...points.filter(point => point).map(point => point.reduce((sum, value) => sum + value, 0)));
                        return [20, 50, 100, 150, 200, 300, 400, 500, 750, 1000].find(step => step >= tallest * 1.05) ?? Math.ceil(tallest / 500) * 500;
                    }

                    function shown(key) {
                        if (popout.hover < 0)
                            return root.sourceWatts(key);
                        return hovered ? hovered[root.sourceNames.indexOf(key)] : NaN;
                    }

                    // stacked bands from the floor up; the top edge is drawn again as the total
                    function paths(width, height) {
                        const out = {
                            "fills": ["", "", ""],
                            "edges": ["", ""],
                            "total": ""
                        };
                        const count = points.length;
                        const layers = bands.length;
                        if (count === 0 || width <= 0)
                            return out;
                        const step = width / count;
                        const inset = Theme.spacingXS;
                        const top = chartCard.ceiling;
                        const y = value => Number(inset + (1 - Math.min(value, top) / top) * (height - inset * 2)).toFixed(1);
                        const floor = Number(height - inset).toFixed(1);
                        let i = 0;
                        while (i < count) {
                            if (!points[i]) {
                                i++;
                                continue;
                            }
                            // columns fill their bucket, so a run reaches both its edges
                            const run = [];
                            const first = i;
                            while (i < count && points[i]) {
                                run.push([(i + 0.5) * step, points[i]]);
                                i++;
                            }
                            run.unshift([first * step, run[0][1]]);
                            run.push([i * step, run[run.length - 1][1]]);

                            // each layer's top is the running sum of those below it
                            const edges = [];
                            for (let k = 0; k < layers; k++)
                                edges.push(run.map(p => `${p[0].toFixed(1)} ${y(p[1].slice(0, k + 1).reduce((sum, value) => sum + value, 0))}`));
                            const bottom = [`${run[run.length - 1][0].toFixed(1)} ${floor}`, `${run[0][0].toFixed(1)} ${floor}`];
                            for (let k = 0; k < layers; k++) {
                                const lower = k === 0 ? bottom : edges[k - 1].slice().reverse();
                                out.fills[k] += ` M ${edges[k].join(" L ")} L ${lower.join(" L ")} Z`;
                                if (k < layers - 1)
                                    out.edges[k] += ` M ${edges[k].join(" L ")}`;
                            }
                            out.total += ` M ${edges[layers - 1].join(" L ")}`;
                        }
                        return out;
                    }

                    width: popout.width
                    height: chartColumn.implicitHeight + pad * 2
                    restRadius: Theme.cornerRadiusL

                    Column {
                        id: chartColumn

                        width: parent.width
                        spacing: Theme.spacingS

                        Item {
                            width: parent.width
                            height: Math.max(headline.implicitHeight, spanGroup.height)

                            Column {
                                id: headline

                                anchors.left: parent.left
                                anchors.right: spanGroup.left
                                anchors.rightMargin: Theme.spacingS
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: Theme.spacingXXS

                                Row {
                                    spacing: Theme.spacingS

                                    StyledText {
                                        id: totalText

                                        text: root.watts(chartCard.shownTotal)
                                        font.pixelSize: Theme.fontSizeXXLarge
                                        color: Theme.onSurface
                                    }

                                    StyledText {
                                        text: popout.hover >= 0 ? root.clock(chartCard.hoverTime, root.spanIndex < 3) : "now"
                                        font.pixelSize: Theme.fontSizeSmall
                                        color: Theme.onSurfaceVariant
                                        anchors.baseline: totalText.baseline
                                    }
                                }

                                Row {
                                    spacing: Theme.spacingM

                                    Repeater {
                                        model: chartCard.bands

                                        Row {
                                            id: legendEntry

                                            required property string modelData

                                            spacing: Theme.spacingXS

                                            Rectangle {
                                                width: Theme.spacingS
                                                height: width
                                                radius: width / 2
                                                color: root.sourceColor(legendEntry.modelData)
                                                anchors.verticalCenter: parent.verticalCenter
                                            }

                                            StyledText {
                                                text: `${root.sourceLabels[legendEntry.modelData]} ${root.watts(chartCard.shown(legendEntry.modelData))}`
                                                font.pixelSize: Theme.fontSizeSmall
                                                color: Theme.onSurface
                                            }
                                        }
                                    }

                                    Row {
                                        spacing: Theme.spacingXS

                                        Rectangle {
                                            width: Theme.spacingM
                                            height: Theme.outlineWidthFocused
                                            radius: height / 2
                                            color: root.totalColor
                                            anchors.verticalCenter: parent.verticalCenter
                                        }

                                        StyledText {
                                            text: `Total ${root.watts(chartCard.shownTotal)}`
                                            font.pixelSize: Theme.fontSizeSmall
                                            color: Theme.onSurface
                                        }
                                    }
                                }
                            }

                            DButtonGroup {
                                id: spanGroup

                                anchors.right: parent.right
                                anchors.top: parent.top
                                size: "small"
                                checkEnabled: false
                                model: root.spans.map(span => span.label)
                                currentIndex: root.spanIndex
                                onSelectionChanged: (index, selected) => {
                                    if (selected)
                                        root.spanIndex = index;
                                }
                            }
                        }

                        Item {
                            width: parent.width
                            height: Theme.iconButtonSize * 4

                            Item {
                                id: plot

                                readonly property var paths: chartCard.paths(width, height)

                                width: parent.width - axisMetrics.implicitWidth - Theme.spacingS
                                height: parent.height

                                Repeater {
                                    model: 3

                                    Rectangle {
                                        required property int index

                                        y: Theme.spacingXS + index * (plot.height - Theme.spacingXS * 2) / 2
                                        width: plot.width
                                        height: Theme.dividerWidth
                                        color: Theme.outlineVariant
                                    }
                                }

                                Shape {
                                    anchors.fill: parent
                                    preferredRendererType: Shape.CurveRenderer

                                    ShapePath {
                                        strokeColor: "transparent"
                                        strokeWidth: 0
                                        fillColor: Theme.withAlpha(root.cpuColor, 0.3)

                                        PathSvg {
                                            path: plot.paths.fills[0]
                                        }
                                    }

                                    ShapePath {
                                        strokeColor: "transparent"
                                        strokeWidth: 0
                                        fillColor: Theme.withAlpha(root.gpuColor, 0.3)

                                        PathSvg {
                                            path: plot.paths.fills[1]
                                        }
                                    }

                                    ShapePath {
                                        strokeColor: "transparent"
                                        strokeWidth: 0
                                        fillColor: Theme.withAlpha(root.restColor, 0.25)

                                        PathSvg {
                                            path: plot.paths.fills[2]
                                        }
                                    }

                                    ShapePath {
                                        strokeColor: root.cpuColor
                                        strokeWidth: 1
                                        fillColor: "transparent"
                                        joinStyle: ShapePath.RoundJoin

                                        PathSvg {
                                            path: plot.paths.edges[0]
                                        }
                                    }

                                    ShapePath {
                                        strokeColor: root.gpuColor
                                        strokeWidth: 1
                                        fillColor: "transparent"
                                        joinStyle: ShapePath.RoundJoin

                                        PathSvg {
                                            path: plot.paths.edges[1]
                                        }
                                    }

                                    ShapePath {
                                        strokeColor: root.totalColor
                                        strokeWidth: Theme.outlineWidthFocused
                                        fillColor: "transparent"
                                        joinStyle: ShapePath.RoundJoin
                                        capStyle: ShapePath.RoundCap

                                        PathSvg {
                                            path: plot.paths.total
                                        }
                                    }
                                }

                                Rectangle {
                                    visible: popout.hover >= 0
                                    x: (popout.hover + 0.5) * plot.width / Math.max(1, chartCard.points.length) - width / 2
                                    width: Theme.dividerWidth
                                    height: plot.height
                                    color: Theme.outline
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    acceptedButtons: Qt.NoButton
                                    hoverEnabled: true
                                    onPositionChanged: mouse => {
                                        const count = chartCard.points.length;
                                        popout.hover = count > 0 ? Math.max(0, Math.min(count - 1, Math.floor(mouse.x / width * count))) : -1;
                                    }
                                    onExited: popout.hover = -1
                                }
                            }

                            StyledText {
                                id: axisMetrics

                                visible: false
                                text: "1000 W"
                                font.pixelSize: Theme.fontSizeSmall
                            }

                            Repeater {
                                model: [1, 0.5, 0]

                                StyledText {
                                    required property real modelData

                                    anchors.right: parent.right
                                    y: Theme.spacingXS + (1 - modelData) * (plot.height - Theme.spacingXS * 2) - height / 2
                                    text: `${Math.round(chartCard.ceiling * modelData)} W`
                                    font.pixelSize: Theme.fontSizeSmall
                                    color: Theme.onSurfaceVariant
                                }
                            }
                        }

                        // start, the span's average and peak, now
                        Item {
                            width: plot.width
                            height: spanStats.implicitHeight

                            StyledText {
                                anchors.left: parent.left
                                text: popout.view ? root.clock(popout.view.start, false) : ""
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.onSurfaceVariant
                            }

                            StyledText {
                                id: spanStats

                                anchors.horizontalCenter: parent.horizontalCenter
                                text: `avg ${root.watts(popout.view?.average ?? NaN)} · peak ${root.watts(popout.view?.peak ?? NaN)}`
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.onSurfaceVariant
                            }

                            StyledText {
                                anchors.right: parent.right
                                text: "now"
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.onSurfaceVariant
                            }
                        }
                    }
                }

                Row {
                    id: cards

                    readonly property real cardWidth: (width - spacing) / 2
                    readonly property real cardHeight: Math.max(cpuColumn.implicitHeight, gpuColumn.implicitHeight) + Theme.spacingM * 2

                    width: popout.width
                    spacing: PopoutMetrics.contentGap

                    DCard {
                        width: cards.cardWidth
                        height: cards.cardHeight
                        restRadius: Theme.cornerRadiusL

                        Column {
                            id: cpuColumn

                            width: parent.width
                            spacing: Theme.spacingS

                            CardHeader {
                                width: parent.width
                                icon: "memory"
                                title: "CPU"
                                detail: root.daemon?.cpuModel ?? ""
                                color: root.cpuColor
                            }

                            BigValue {
                                value: root.preciseWatts(root.daemon?.cpuW ?? NaN)
                                note: root.daemon?.cpuNote ?? ""
                            }

                            Meter {
                                width: parent.width
                                labelWidth: popout.labelWidth
                                valueWidth: popout.valueWidth
                                label: "Load"
                                ratio: root.daemon?.cpuLoad ?? NaN
                                value: root.percent(ratio)
                                color: root.cpuColor
                            }

                            Meter {
                                width: parent.width
                                labelWidth: popout.labelWidth
                                valueWidth: popout.valueWidth
                                label: "Temp"
                                ratio: (root.daemon?.cpuTemp ?? NaN) / root.cpuMaxTemp
                                value: root.number(root.daemon?.cpuTemp ?? NaN, 0, "°C")
                                color: root.cpuColor
                            }

                            Meter {
                                width: parent.width
                                labelWidth: popout.labelWidth
                                valueWidth: popout.valueWidth
                                label: "Clock"
                                ratio: (root.daemon?.cpuGhz ?? NaN) / (root.daemon?.cpuMaxGhz ?? NaN)
                                value: root.number(root.daemon?.cpuGhz ?? NaN, 2, "GHz")
                                color: root.cpuColor
                            }

                            // each thread's load, btop's core graph
                            Item {
                                id: threads

                                readonly property int count: root.daemon?.threadLoads.length ?? 0

                                width: parent.width
                                height: Theme.iconSize
                                visible: count > 0

                                StyledText {
                                    width: popout.labelWidth
                                    text: "Threads"
                                    font.pixelSize: Theme.fontSizeSmall
                                    color: Theme.onSurfaceVariant
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                Row {
                                    id: threadBars

                                    x: popout.labelWidth + Theme.spacingS
                                    width: parent.width - x
                                    height: parent.height
                                    spacing: Theme.spacingXXS

                                    Repeater {
                                        model: threads.count

                                        Rectangle {
                                            id: threadBar

                                            required property int index

                                            width: (threadBars.width - threadBars.spacing * (threads.count - 1)) / threads.count
                                            height: threadBars.height
                                            radius: Theme.spacingXXS
                                            color: Theme.withAlpha(Theme.onSurface, 0.12)

                                            Rectangle {
                                                anchors.bottom: parent.bottom
                                                width: parent.width
                                                height: parent.height * Math.max(0, Math.min(1, root.daemon?.threadLoads[threadBar.index] ?? 0))
                                                radius: parent.radius
                                                color: root.cpuColor
                                            }
                                        }
                                    }
                                }
                            }

                            Grid {
                                id: cpuDetails

                                width: parent.width
                                columns: 2
                                rowSpacing: Theme.spacingXXS

                                Repeater {
                                    model: root.cpuDetailLabels

                                    Detail {
                                        required property string modelData

                                        width: cpuDetails.width / 2
                                        label: modelData
                                        value: root.cpuDetail(modelData)
                                    }
                                }
                            }
                        }
                    }

                    DCard {
                        width: cards.cardWidth
                        height: cards.cardHeight
                        restRadius: Theme.cornerRadiusL

                        Column {
                            id: gpuColumn

                            width: parent.width
                            spacing: Theme.spacingS

                            CardHeader {
                                width: parent.width
                                icon: "developer_board"
                                title: "GPU"
                                detail: root.gpu?.name ?? root.daemon?.igpuName ?? ""
                                color: root.gpuColor
                            }

                            StyledText {
                                visible: !root.gpu && !root.daemon?.igpuName
                                text: "No GPU reading"
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.onSurfaceVariant
                            }

                            // an nvidia card, through nvidia-smi
                            Column {
                                width: parent.width
                                spacing: Theme.spacingS
                                visible: !!root.gpu

                                BigValue {
                                    value: root.preciseWatts(root.gpu?.watts ?? NaN)
                                    note: isFinite(root.gpu?.limit ?? NaN) ? `of ${Math.round(root.gpu.limit)} W` : ""
                                }

                                Meter {
                                    width: parent.width
                                    labelWidth: popout.labelWidth
                                    valueWidth: popout.valueWidth
                                    label: "Power"
                                    ratio: (root.gpu?.watts ?? NaN) / (root.gpu?.limit ?? NaN)
                                    value: root.percent(ratio)
                                    color: root.gpuColor
                                }

                                Meter {
                                    width: parent.width
                                    labelWidth: popout.labelWidth
                                    valueWidth: popout.valueWidth
                                    label: "Load"
                                    ratio: root.gpu?.load ?? NaN
                                    value: root.percent(ratio)
                                    color: root.gpuColor
                                }

                                Meter {
                                    width: parent.width
                                    labelWidth: popout.labelWidth
                                    valueWidth: popout.valueWidth
                                    label: "Temp"
                                    ratio: (root.gpu?.temp ?? NaN) / (root.daemon?.gpuMaxTemp ?? NaN)
                                    value: root.number(root.gpu?.temp ?? NaN, 0, "°C")
                                    color: root.gpuColor
                                }

                                Meter {
                                    width: parent.width
                                    labelWidth: popout.labelWidth
                                    valueWidth: popout.valueWidth
                                    label: "Fan"
                                    ratio: root.gpu?.fan ?? NaN
                                    value: root.percent(ratio)
                                    color: root.gpuColor
                                }

                                Meter {
                                    width: parent.width
                                    labelWidth: popout.labelWidth
                                    valueWidth: popout.valueWidth
                                    label: "VRAM"
                                    ratio: (root.gpu?.vramUsed ?? NaN) / (root.gpu?.vramTotal ?? NaN)
                                    value: isFinite(ratio) ? `${(root.gpu.vramUsed / 1024).toFixed(1)} / ${(root.gpu.vramTotal / 1024).toFixed(1)} GB` : "–"
                                    color: root.gpuColor
                                }

                                Meter {
                                    width: parent.width
                                    labelWidth: popout.labelWidth
                                    valueWidth: popout.valueWidth
                                    label: "Clock"
                                    ratio: (root.gpu?.clock ?? NaN) / (root.gpu?.maxClock ?? NaN)
                                    value: root.number(root.gpu?.clock ?? NaN, 0, "MHz")
                                    color: root.gpuColor
                                }

                                Grid {
                                    id: gpuDetails

                                    width: parent.width
                                    columns: 2
                                    rowSpacing: Theme.spacingXXS

                                    Detail {
                                        width: gpuDetails.width / 2
                                        label: "Memory"
                                        value: root.number(root.gpu?.memClock ?? NaN, 0, "MHz")
                                    }

                                    Detail {
                                        width: gpuDetails.width / 2
                                        label: "State"
                                        value: root.gpu?.pstate ?? "–"
                                    }

                                    Detail {
                                        width: gpuDetails.width / 2
                                        label: "PCIe"
                                        value: isFinite(root.gpu?.pcieGen ?? NaN) ? `Gen ${root.gpu.pcieGen} ×${root.gpu.pcieWidth}` : "–"
                                    }
                                }

                                Row {
                                    readonly property string limits: root.gpuLimits(root.gpu?.reasons ?? 0)

                                    width: parent.width
                                    spacing: Theme.spacingXS
                                    visible: limits !== ""

                                    DIcon {
                                        name: "speed"
                                        size: Theme.iconSizeSmall
                                        color: Theme.warning
                                        anchors.verticalCenter: parent.verticalCenter
                                    }

                                    StyledText {
                                        width: parent.width - Theme.iconSizeSmall - parent.spacing
                                        text: `Held back by ${parent.limits}`
                                        font.pixelSize: Theme.fontSizeSmall
                                        color: Theme.warning
                                        wrapMode: Text.Wrap
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                }
                            }

                            // an intel igpu: rapl's uncore zone and its clock
                            Column {
                                width: parent.width
                                spacing: Theme.spacingS
                                visible: !root.gpu && !!root.daemon?.igpuName

                                BigValue {
                                    value: root.preciseWatts(root.daemon?.uncoreW ?? NaN)
                                    note: "integrated"
                                }

                                Meter {
                                    width: parent.width
                                    labelWidth: popout.labelWidth
                                    valueWidth: popout.valueWidth
                                    label: "Clock"
                                    ratio: (root.daemon?.igpuMhz ?? NaN) / (root.daemon?.igpuMaxMhz ?? NaN)
                                    value: root.number(root.daemon?.igpuMhz ?? NaN, 0, "MHz")
                                    color: root.gpuColor
                                }
                            }
                        }
                    }
                }

                DCard {
                    width: popout.width
                    height: energyColumn.implicitHeight + pad * 2
                    restRadius: Theme.cornerRadiusL

                    Column {
                        id: energyColumn

                        width: parent.width
                        spacing: Theme.spacingS

                        Row {
                            spacing: Theme.spacingS

                            StyledText {
                                text: "Energy"
                                font.pixelSize: Theme.fontSizeSmall
                                font.weight: Theme.fontWeightMedium
                                color: Theme.primary
                            }

                            StyledText {
                                text: root.daemon?.platform ? "Whole laptop, while Dux runs" : "CPU + GPU, while Dux runs"
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.onSurfaceVariant
                            }
                        }

                        Row {
                            id: energyRow

                            width: parent.width

                            Repeater {
                                model: [
                                    {
                                        "label": "Today",
                                        "days": 1
                                    },
                                    {
                                        "label": "7 days",
                                        "days": 7
                                    },
                                    {
                                        "label": "30 days",
                                        "days": 30
                                    }
                                ]

                                Column {
                                    id: energyEntry

                                    required property var modelData
                                    // refreshed with the chart
                                    readonly property real wh: popout.view && root.daemon ? root.daemon.energy(modelData.days) : 0

                                    width: energyRow.width / 3
                                    spacing: Theme.spacingXXS

                                    StyledText {
                                        text: root.energyText(energyEntry.wh)
                                        font.pixelSize: Theme.fontSizeMedium
                                        font.weight: Theme.fontWeightMedium
                                        color: Theme.onSurface
                                    }

                                    StyledText {
                                        visible: (root.daemon?.priceCt ?? 0) > 0
                                        text: root.costText(energyEntry.wh)
                                        font.pixelSize: Theme.fontSizeSmall
                                        color: Theme.onSurface
                                    }

                                    StyledText {
                                        text: energyEntry.modelData.label
                                        font.pixelSize: Theme.fontSizeSmall
                                        color: Theme.onSurfaceVariant
                                    }
                                }
                            }
                        }
                    }
                }
            }

            BatteryPanel {
                visible: popout.hasBattery && root.tab === 1
                width: popout.width
                widget: root
            }

            ModesCard {
                width: popout.width
                daemon: root.daemon
            }
        }
    }
}
