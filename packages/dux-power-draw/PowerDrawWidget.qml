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

    // sampling, history and energy live in the daemon, shared by every bar
    readonly property var daemon: PluginService.pluginDaemonInstances[pluginId] ?? null
    readonly property var gpu: daemon?.gpu ?? null

    // chart series, and their meters
    readonly property color cpuColor: Theme.primary
    readonly property color gpuColor: Theme.tertiary

    // ryzen's tjmax
    readonly property real cpuMaxTemp: 95

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

    readonly property var sources: [
        {
            "key": "cpu",
            "label": "CPU",
            "icon": "memory",
            "reserve": "00 W"
        },
        {
            "key": "gpu",
            "label": "GPU",
            "icon": "auto_awesome_mosaic",
            "reserve": "000 W"
        }
    ]

    function sourceWatts(key) {
        return key === "cpu" ? daemon?.cpuW ?? NaN : daemon?.gpuW ?? NaN;
    }

    function sourceColor(key) {
        return key === "cpu" ? cpuColor : gpuColor;
    }

    function watts(value) {
        return isFinite(value) ? `${Math.round(value)} W` : "– W";
    }

    // one decimal, for the cards
    function preciseWatts(value) {
        return isFinite(value) ? `${value.toFixed(1)} W` : "– W";
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

    horizontalBarPill: Component {
        Row {
            spacing: Theme.spacingS

            Repeater {
                model: root.sources

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

            Repeater {
                model: root.sources

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

    popoutWidth: 600

    popoutContent: Component {
        Column {
            id: popout

            // set by the plugin popout
            property var parentPopout: null

            // the chart's columns, refreshed each sample while open
            property var view: null
            property int hover: -1

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

            // headline total, its split, and the stacked history
            DCard {
                id: chartCard

                readonly property var points: popout.view?.points ?? []
                readonly property var hovered: popout.hover >= 0 && popout.hover < points.length ? points[popout.hover] : null
                readonly property real shownCpu: popout.hover >= 0 ? hovered?.[0] ?? NaN : root.daemon?.cpuW ?? NaN
                readonly property real shownGpu: popout.hover >= 0 ? hovered?.[1] ?? NaN : root.daemon?.gpuW ?? NaN
                readonly property real hoverTime: popout.view && points.length > 0 ? popout.view.start + (popout.hover + 0.5) * (popout.view.end - popout.view.start) / points.length : 0

                // the scale, rounded up from the tallest column
                readonly property real ceiling: {
                    const tallest = Math.max(0, ...points.filter(point => point).map(point => point[0] + point[1]));
                    return [20, 50, 100, 150, 200, 300, 400, 500, 750, 1000].find(step => step >= tallest * 1.05) ?? Math.ceil(tallest / 500) * 500;
                }

                // stacked bands: cpu from the floor, gpu on top of it
                function paths(width, height) {
                    const out = {
                        "cpuFill": "",
                        "gpuFill": "",
                        "cpuLine": "",
                        "totalLine": ""
                    };
                    const count = points.length;
                    if (count === 0 || width <= 0)
                        return out;
                    const step = width / count;
                    const inset = Theme.spacingXS;
                    const ceiling = chartCard.ceiling;
                    const y = value => Number(inset + (1 - Math.min(value, ceiling) / ceiling) * (height - inset * 2)).toFixed(1);
                    const floor = (height - inset).toFixed(1);
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
                            run.push([(i + 0.5) * step, points[i][0], points[i][0] + points[i][1]]);
                            i++;
                        }
                        run.unshift([first * step, run[0][1], run[0][2]]);
                        run.push([i * step, run[run.length - 1][1], run[run.length - 1][2]]);

                        const cpuEdge = run.map(p => `${p[0].toFixed(1)} ${y(p[1])}`);
                        const totalEdge = run.map(p => `${p[0].toFixed(1)} ${y(p[2])}`);
                        const left = run[0][0].toFixed(1);
                        const right = run[run.length - 1][0].toFixed(1);
                        out.cpuLine += ` M ${cpuEdge.join(" L ")}`;
                        out.totalLine += ` M ${totalEdge.join(" L ")}`;
                        out.cpuFill += ` M ${left} ${floor} L ${cpuEdge.join(" L ")} L ${right} ${floor} Z`;
                        out.gpuFill += ` M ${totalEdge.join(" L ")} L ${cpuEdge.reverse().join(" L ")} Z`;
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

                                    text: isFinite(chartCard.shownCpu) || isFinite(chartCard.shownGpu) ? root.watts((isFinite(chartCard.shownCpu) ? chartCard.shownCpu : 0) + (isFinite(chartCard.shownGpu) ? chartCard.shownGpu : 0)) : "– W"
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
                                    model: root.sources

                                    Row {
                                        id: legendEntry

                                        required property var modelData

                                        spacing: Theme.spacingXS

                                        Rectangle {
                                            width: Theme.spacingS
                                            height: width
                                            radius: width / 2
                                            color: root.sourceColor(legendEntry.modelData.key)
                                            anchors.verticalCenter: parent.verticalCenter
                                        }

                                        StyledText {
                                            text: `${legendEntry.modelData.label} ${root.watts(legendEntry.modelData.key === "cpu" ? chartCard.shownCpu : chartCard.shownGpu)}`
                                            font.pixelSize: Theme.fontSizeSmall
                                            color: Theme.onSurface
                                        }
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
                                    fillColor: Theme.withAlpha(root.gpuColor, 0.3)

                                    PathSvg {
                                        path: plot.paths.gpuFill
                                    }
                                }

                                ShapePath {
                                    strokeColor: "transparent"
                                    strokeWidth: 0
                                    fillColor: Theme.withAlpha(root.cpuColor, 0.3)

                                    PathSvg {
                                        path: plot.paths.cpuFill
                                    }
                                }

                                ShapePath {
                                    strokeColor: root.gpuColor
                                    strokeWidth: Theme.outlineWidthFocused
                                    fillColor: "transparent"
                                    joinStyle: ShapePath.RoundJoin
                                    capStyle: ShapePath.RoundCap

                                    PathSvg {
                                        path: plot.paths.totalLine
                                    }
                                }

                                ShapePath {
                                    strokeColor: root.cpuColor
                                    strokeWidth: Theme.outlineWidthFocused
                                    fillColor: "transparent"
                                    joinStyle: ShapePath.RoundJoin
                                    capStyle: ShapePath.RoundCap

                                    PathSvg {
                                        path: plot.paths.cpuLine
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
                            note: root.daemon?.cpuFromRapl ? "package" : "VRM estimate"
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
                            ratio: (root.daemon?.tctl ?? NaN) / root.cpuMaxTemp
                            value: root.number(root.daemon?.tctl ?? NaN, 0, "°C")
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

                            Detail {
                                width: cpuDetails.width / 2
                                label: "Cores"
                                value: root.preciseWatts(root.daemon?.coreW ?? NaN)
                            }

                            Detail {
                                width: cpuDetails.width / 2
                                label: "SoC"
                                value: root.preciseWatts((root.daemon?.cpuFromRapl ? root.daemon.cpuW : NaN) - (root.daemon?.coreW ?? NaN))
                            }

                            Detail {
                                width: cpuDetails.width / 2
                                label: "Vcore"
                                value: root.number(root.daemon?.vcore ?? NaN, 2, "V")
                            }

                            Detail {
                                width: cpuDetails.width / 2
                                label: "Current"
                                value: root.number(root.daemon?.amps ?? NaN, 0, "A")
                            }
                        }

                        DButtonGroup {
                            id: profileGroup

                            readonly property var profiles: PowerProfileWatcher.availableProfiles

                            width: parent.width
                            visible: PowerProfileWatcher.available
                            fillWidth: true
                            iconOnly: true
                            checkEnabled: false
                            size: "small"
                            model: profiles.map(profile => ({
                                        "text": Theme.getPowerProfileLabel(profile),
                                        "icon": ["eco", "speed", "bolt"][profile]
                                    }))
                            currentIndex: profiles.indexOf(PowerProfileWatcher.currentProfile)
                            onSelectionChanged: (index, selected) => {
                                if (selected && !PowerProfileWatcher.applyProfile(profiles[index]))
                                    ToastService.showError("Failed to set power profile");
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
                            icon: "auto_awesome_mosaic"
                            title: "GPU"
                            detail: root.gpu?.name ?? ""
                            color: root.gpuColor
                        }

                        StyledText {
                            visible: !root.gpu
                            text: "No reading from nvidia-smi"
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.onSurfaceVariant
                        }

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
                            text: "CPU + GPU, while Dux runs"
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
    }
}
