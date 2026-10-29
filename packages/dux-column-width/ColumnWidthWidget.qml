import QtQuick
import qs.Common
import qs.Services
import qs.Widgets
import qs.Modules.Plugins

PluginComponent {
    id: root

    // niri's struts per axis, filled in at build
    readonly property int strutsX: @strutsX@
    readonly property int strutsY: @strutsY@

    // the gaps Dux writes into niri's layout; -2 leaves niri's default
    readonly property int gaps: {
        const override = SettingsData.niriLayoutGapsOverride;
        if (override >= 0)
            return override;
        if (override === -2)
            return 16;
        return Math.max(4, SettingsData.getPrimaryBarConfig()?.spacing ?? 4);
    }

    // this screen's active window, tiled only
    readonly property string screenName: parentScreen?.name ?? ""
    readonly property var workspace: NiriService.allWorkspaces.find(ws => ws.output === screenName && ws.is_active) ?? null
    readonly property var window: workspace ? NiriService.windows.find(w => w.id === workspace.active_window_id) ?? null : null
    readonly property var tileSize: window && !window.is_floating ? window.layout?.tile_size ?? null : null

    // niri's working area: the screen minus Dux's bars/frame and the struts
    readonly property var layout: ShellLayout.forScreen(screenName)
    readonly property real workingWidth: (layout?.screen.width ?? 0) - (layout?.edges.left.reservation ?? 0) - (layout?.edges.right.reservation ?? 0) - strutsX
    readonly property real workingHeight: (layout?.screen.height ?? 0) - (layout?.edges.top.reservation ?? 0) - (layout?.edges.bottom.reservation ?? 0) - strutsY

    // niri sizes a tile at (working - gaps) * proportion - gaps; fullscreen caps at 100
    function percentOf(tile, working) {
        return Math.round(Math.min(1, (tile + gaps) / (working - gaps)) * 100);
    }

    readonly property int widthPercent: tileSize && workingWidth > gaps ? percentOf(tileSize[0], workingWidth) : -1
    readonly property int heightPercent: tileSize && workingHeight > gaps ? percentOf(tileSize[1], workingHeight) : -1
    readonly property var axes: [
        {
            "icon": "width",
            "percent": widthPercent
        },
        {
            "icon": "height",
            "percent": heightPercent
        }
    ]

    // hidden for floating windows and tiles filling both axes
    readonly property bool shown: widthPercent >= 0 && heightPercent >= 0 && (widthPercent !== 100 || heightPercent !== 100)

    onShownChanged: setVisibilityOverride(shown)
    Component.onCompleted: setVisibilityOverride(shown)

    // click cycles the preset widths, same as Mod+R
    pillClickAction: () => NiriService.send({
        "Action": {
            "SwitchPresetColumnWidth": {}
        }
    })

    // right click toggles maximize, same as Mod+M
    pillRightClickAction: () => NiriService.send({
        "Action": {
            "MaximizeColumn": {}
        }
    })

    horizontalBarPill: Component {
        Row {
            spacing: Theme.spacingS

            Repeater {
                model: root.axes

                Row {
                    id: axisRow

                    required property var modelData

                    spacing: Theme.spacingXS
                    anchors.verticalCenter: parent.verticalCenter

                    DankIcon {
                        name: axisRow.modelData.icon
                        size: root.iconSize
                        color: Theme.widgetIconColor
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    NumericText {
                        text: axisRow.modelData.percent + "%"
                        reserveText: "100%"
                        width: Math.ceil(Math.max(implicitWidth, reservedWidth))
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
                model: root.axes

                Column {
                    id: axisColumn

                    required property var modelData

                    spacing: 1
                    anchors.horizontalCenter: parent.horizontalCenter

                    DankIcon {
                        name: axisColumn.modelData.icon
                        size: root.iconSize
                        color: Theme.widgetIconColor
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    StyledText {
                        text: axisColumn.modelData.percent
                        font.pixelSize: root.textSize
                        color: Theme.widgetTextColor
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                }
            }
        }
    }
}
