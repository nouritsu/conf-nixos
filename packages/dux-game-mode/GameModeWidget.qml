import QtQuick
import Quickshell
import Quickshell.Io
import qs.Common
import qs.Widgets
import qs.Modules.Plugins

PluginComponent {
    id: root

    // 1 while gamemode is active, written by game mode's hooks
    property bool active: false

    FileView {
        path: Quickshell.env("XDG_RUNTIME_DIR") + "/game-mode/active"
        watchChanges: true
        printErrors: false
        onFileChanged: reload()
        onLoaded: root.active = text().trim() === "1"
        onLoadFailed: root.active = false
    }

    onActiveChanged: setVisibilityOverride(active)
    Component.onCompleted: setVisibilityOverride(active)

    // same as which-key g t
    pillClickAction: () => Quickshell.execDetached(["game-mode-toggle"])

    horizontalBarPill: Component {
        DankIcon {
            name: "sports_esports"
            size: root.iconSize
            color: Theme.primary
        }
    }

    verticalBarPill: Component {
        DankIcon {
            name: "sports_esports"
            size: root.iconSize
            color: Theme.primary
        }
    }
}
