import QtQuick
import qs.Common
import qs.Services
import qs.Widgets
import qs.Modules.Plugins

PluginComponent {
    id: root

    // niri's left + right struts, filled in at build
    readonly property int struts: @struts@

    // the gaps DMS writes into niri's layout; -2 leaves niri's default
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

    // niri's working area: the screen minus DMS's side bars/frame and the struts
    readonly property var layout: ShellLayout.forScreen(screenName)
    readonly property real workingWidth: (layout?.screen.width ?? 0) - (layout?.edges.left.reservation ?? 0) - (layout?.edges.right.reservation ?? 0) - struts

    // niri sizes a tile at (working - gaps) * proportion - gaps; fullscreen caps at 100
    readonly property int percent: tileSize && workingWidth > gaps ? Math.round(Math.min(1, (tileSize[0] + gaps) / (workingWidth - gaps)) * 100) : -1

    onPercentChanged: setVisibilityOverride(percent >= 0)
    Component.onCompleted: setVisibilityOverride(percent >= 0)

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
            spacing: Theme.spacingXS

            DankIcon {
                name: "width"
                size: root.iconSize
                color: Theme.widgetIconColor
                anchors.verticalCenter: parent.verticalCenter
            }

            NumericText {
                text: root.percent + "%"
                reserveText: "100%"
                width: Math.ceil(Math.max(implicitWidth, reservedWidth))
                font.pixelSize: root.textSize
                color: Theme.widgetTextColor
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }

    verticalBarPill: Component {
        Column {
            spacing: 1

            DankIcon {
                name: "width"
                size: root.iconSize
                color: Theme.widgetIconColor
                anchors.horizontalCenter: parent.horizontalCenter
            }

            StyledText {
                text: root.percent
                font.pixelSize: root.textSize
                color: Theme.widgetTextColor
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
    }
}
