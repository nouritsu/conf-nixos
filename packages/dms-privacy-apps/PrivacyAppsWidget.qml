pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Widgets
import qs.Common
import qs.Modules.DBar
import qs.Modules.Plugins
import qs.Services
import qs.DCommon.Widgets
import qs.Widgets

PluginComponent {
    id: root

    // streams, blocks and actions live in the daemon, shared by every bar
    readonly property var daemon: PluginService.pluginDaemonInstances[pluginId] ?? null
    readonly property var apps: daemon?.apps ?? []
    readonly property var blockedKinds: daemon?.blockedKinds ?? ({})
    // hidden and config-ignored apps never light the pill
    readonly property bool micActive: daemon?.micActive ?? false
    readonly property bool cameraActive: daemon?.cameraActive ?? false
    readonly property bool screenActive: PrivacyService.screensharingActive && !daemon?.ignoredOnly.screen

    readonly property real dpr: parentScreen ? CompositorService.getScreenScale(parentScreen) : 1

    // same icons as the built-in indicator; a blocked kind stays, unlit, so it can be unblocked
    readonly property var indicators: [
        {
            "icon": AudioService.source?.audio && !AudioService.source.audio.muted && AudioService.source.audio.volume !== 0.0 ? "mic" : "mic_off",
            "shown": micActive || !!blockedKinds.mic,
            "active": micActive,
            "color": Theme.error,
            "dot": false
        },
        {
            "icon": "camera_video",
            "shown": cameraActive || !!blockedKinds.camera,
            "active": cameraActive,
            "color": Theme.error,
            "dot": true
        },
        {
            "icon": "screen_share",
            "shown": screenActive || !!blockedKinds.screen,
            "active": screenActive,
            "color": Theme.warning,
            "dot": false
        }
    ]
    readonly property bool shown: indicators.some(indicator => indicator.shown)

    readonly property var kindNames: ({
            "mic": "microphone",
            "camera": "camera",
            "screen": "screen sharing"
        })
    readonly property var kindIcons: ({
            "mic": "mic",
            "camera": "videocam",
            "screen": "screen_share"
        })
    readonly property var blockedIcons: ({
            "mic": "mic_off",
            "camera": "videocam_off",
            "screen": "stop_screen_share"
        })
    // popout column order
    readonly property var accessKinds: ["camera", "mic", "screen"]

    // the popout's header toggle, kept while dms runs
    property bool showHidden: false

    onShownChanged: setVisibilityOverride(shown)
    Component.onCompleted: setVisibilityOverride(shown)

    Ref {
        service: PrivacyService
    }

    function copyValue(value) {
        Quickshell.execDetached(["dms", "cl", "copy", value.toString()]);
        ToastService.showInfo("Copied to clipboard");
        closePopout();
    }

    component Indicator: Item {
        id: indicator

        required property var modelData
        property real dpr: 1

        visible: modelData.shown
        width: BarMetrics.iconSlot
        height: BarMetrics.iconSlot

        DIcon {
            name: indicator.modelData.icon
            size: Theme.iconSizeSmall
            color: indicator.modelData.active ? indicator.modelData.color : Theme.surfaceText
            filled: indicator.modelData.active
            anchors.centerIn: parent
        }

        Rectangle {
            width: BarMetrics.indicatorDot
            height: BarMetrics.indicatorDot
            radius: Theme.cornerRadiusFull
            color: Theme.error
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.rightMargin: -Theme.spacingXXS
            anchors.topMargin: -Theme.hairline(indicator.dpr)
            visible: indicator.modelData.dot && indicator.modelData.active
        }
    }

    horizontalBarPill: Component {
        Row {
            spacing: Theme.spacingXS

            Repeater {
                model: root.indicators

                Indicator {
                    dpr: root.dpr
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
        }
    }

    verticalBarPill: Component {
        Column {
            spacing: Theme.spacingXS

            Repeater {
                model: root.indicators

                Indicator {
                    dpr: root.dpr
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }
        }
    }

    // a small icon button; unclickable ones still show their state
    component SmallButton: Item {
        id: button

        property string icon
        property color color: Theme.surfaceVariantText
        property bool filled: false
        property color stateColor: Theme.surfaceText
        property bool clickable: true
        property string tooltip

        signal triggered

        width: Theme.iconSizeSmall + Theme.spacingM
        height: width

        DIcon {
            name: button.icon
            size: Theme.iconSizeSmall
            color: button.color
            filled: button.filled
            anchors.centerIn: parent
        }

        StateLayer {
            cornerRadius: Theme.cornerRadiusFull
            stateColor: button.stateColor
            enabled: button.clickable
            disabled: !button.clickable
            tooltipText: button.tooltip
            onClicked: button.triggered()
        }
    }

    // widest row, set from the popout; past the cap names elide
    property real rowsWidth: 0
    popoutWidth: Math.min(600, Math.max(340, Math.ceil(rowsWidth) + PopoutMetrics.contentPadding * 2))

    popoutContent: Component {
        Column {
            id: popout

            // set by the plugin popout; its tracker closes the menu with it
            property var parentPopout: null
            property var menuApp: null
            readonly property int hiddenCount: root.apps.filter(app => app.ignore).length
            readonly property var shownApps: root.showHidden ? root.apps : root.apps.filter(app => !app.ignore)

            spacing: Theme.groupedListGap

            // kept on close so the popout doesn't shrink mid-animation
            Binding {
                target: root
                property: "rowsWidth"
                value: Math.max(0, ...Array.from(popout.children, child => child.naturalWidth ?? 0))
                restoreMode: Binding.RestoreNone
            }

            // at the cursor, in the popout's screen coordinates
            function openMenu(app, item, x, y) {
                const window = popout.QsWindow.window;
                const screen = window?.screen;
                if (!screen)
                    return;
                const pos = item.mapToGlobal(x, y);
                const originX = window.anchors.left ? window.margins.left : window.anchors.right ? screen.width - window.margins.right - window.width : 0;
                const originY = window.anchors.top ? window.margins.top : window.anchors.bottom ? screen.height - window.margins.bottom - window.height : 0;
                menuApp = app;
                killMenu.open(screen, pos.x - screen.x + originX, pos.y - screen.y + originY, false);
            }

            function kill(signal) {
                root.daemon.kill(menuApp, signal);
                root.closePopout();
            }

            // only when something is hidden
            Item {
                visible: popout.hiddenCount > 0
                width: popout.width
                height: Theme.iconSizeSmall + Theme.spacingM

                Row {
                    id: showHiddenToggle

                    anchors.right: parent.right
                    anchors.rightMargin: Theme.spacingS
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: Theme.spacingXS

                    StyledText {
                        text: `Show hidden (${popout.hiddenCount})`
                        color: root.showHidden ? Theme.primary : Theme.surfaceVariantText
                        font.pixelSize: Theme.fontSizeSmall
                        wrapMode: Text.NoWrap
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    DIcon {
                        name: root.showHidden ? "visibility" : "visibility_off"
                        size: Theme.iconSizeSmall
                        color: root.showHidden ? Theme.primary : Theme.surfaceVariantText
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                StateLayer {
                    anchors.fill: showHiddenToggle
                    anchors.margins: -Theme.spacingXS
                    cornerRadius: Theme.cornerRadiusS
                    stateColor: Theme.primary
                    onClicked: root.showHidden = !root.showHidden
                }
            }

            StyledText {
                visible: popout.shownApps.length === 0
                width: popout.width
                text: "Can't tell which app is using it"
                color: Theme.surfaceVariantText
                font.pixelSize: Theme.fontSizeSmall
                wrapMode: Text.Wrap
            }

            Repeater {
                model: popout.shownApps

                // one app: icon, name and pid, then its access toggles and hide; right-click to kill
                DListRow {
                    id: appRow

                    required property var modelData
                    required property int index
                    readonly property var app: modelData
                    readonly property var block: root.daemon?.blocks[app.key] ?? null
                    // the row with the name unelided
                    readonly property real naturalWidth: Theme.spacingM + Theme.iconSizeMedium + Theme.spacingS + nameText.implicitWidth + (app.pid > 0 ? Theme.spacingXS + pidText.implicitWidth : 0) + Theme.spacingS + toggles.width + Theme.spacingS

                    width: popout.width
                    implicitHeight: BarMetrics.menuRowHeight
                    firstInGroup: index === 0
                    lastInGroup: index === popout.shownApps.length - 1

                    MouseArea {
                        id: rowMouse

                        anchors.fill: parent
                        acceptedButtons: Qt.RightButton
                        enabled: appRow.app.pid > 0
                        onClicked: mouse => popout.openMenu(appRow.app, rowMouse, mouse.x, mouse.y)
                    }

                    Row {
                        id: identity

                        anchors.left: parent.left
                        anchors.right: toggles.left
                        anchors.leftMargin: Theme.spacingM
                        anchors.rightMargin: Theme.spacingS
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: Theme.spacingS

                        Item {
                            width: Theme.iconSizeMedium
                            height: Theme.iconSizeMedium
                            anchors.verticalCenter: parent.verticalCenter

                            IconImage {
                                id: appIcon
                                anchors.fill: parent
                                source: appRow.app.icon
                                asynchronous: true
                                mipmap: true
                                smooth: true
                            }

                            StyledText {
                                anchors.centerIn: parent
                                visible: appIcon.status !== Image.Ready
                                text: appRow.app.name.charAt(0).toUpperCase()
                                color: Theme.surfaceText
                                font.pixelSize: Theme.fontSizeSmall
                            }
                        }

                        // one line, "Name (PID)"; a long name elides before the pid
                        Row {
                            spacing: Theme.spacingXS
                            anchors.verticalCenter: parent.verticalCenter

                            StyledText {
                                id: nameText

                                width: Math.min(implicitWidth, identity.width - Theme.iconSizeMedium - identity.spacing - (pidText.visible ? pidText.implicitWidth + Theme.spacingXS : 0))
                                text: appRow.app.name
                                color: Theme.surfaceText
                                font.pixelSize: Theme.fontSizeSmall
                                font.weight: Theme.fontWeightMedium
                                wrapMode: Text.NoWrap
                                elide: Text.ElideRight
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            StyledText {
                                id: pidText

                                visible: appRow.app.pid > 0
                                text: `(${appRow.app.pid})`
                                color: Theme.surfaceVariantText
                                font.pixelSize: Theme.fontSizeSmall
                                wrapMode: Text.NoWrap
                                anchors.baseline: nameText.baseline

                                StateLayer {
                                    cornerRadius: Theme.cornerRadiusS
                                    tooltipText: "Copy PID"
                                    onClicked: root.copyValue(appRow.app.pid)
                                }
                            }
                        }
                    }

                    Row {
                        id: toggles

                        anchors.right: parent.right
                        anchors.rightMargin: Theme.spacingS
                        anchors.verticalCenter: parent.verticalCenter

                        Repeater {
                            model: root.accessKinds

                            // greyed unused, mauve in use, slashed red blocked; in use or blocked toggles the block
                            SmallButton {
                                required property string modelData
                                readonly property bool inUse: !!appRow.app.kinds[modelData]
                                readonly property bool blocked: !!appRow.block?.[modelData]

                                icon: blocked ? root.blockedIcons[modelData] : root.kindIcons[modelData]
                                color: blocked ? Theme.error : inUse ? Theme.primary : Theme.onSurface_38
                                filled: inUse && !blocked
                                stateColor: blocked ? Theme.error : Theme.primary
                                clickable: blocked || (inUse && !!appRow.app.blockable[modelData])
                                tooltip: (blocked ? "Unblock " : "Block ") + root.kindNames[modelData]
                                onTriggered: root.daemon.setBlocked(appRow.app, modelData, !blocked)
                            }
                        }

                        Item {
                            width: Theme.spacingXS
                            height: 1
                        }

                        // config-ignored apps get a lock; only the config shows them again
                        SmallButton {
                            readonly property string ignore: appRow.app.ignore ?? ""

                            icon: ignore === "config" ? "lock" : ignore ? "visibility_off" : "visibility"
                            color: ignore === "config" ? Theme.onSurface_38 : Theme.surfaceVariantText
                            clickable: ignore !== "config" && !!appRow.app.key
                            tooltip: ignore ? "Show" : "Hide"
                            onTriggered: root.daemon.setHidden(appRow.app, !ignore)
                        }
                    }
                }
            }

            DContextMenu {
                id: killMenu

                layerNamespace: "dms:plugins:privacyApps:menu"
                transientSurfaceTracker: popout.parentPopout?.transientSurfaceTracker ?? null
                menuItems: [
                    {
                        "type": "item",
                        "icon": "close",
                        "text": "Kill",
                        "isDestructive": true,
                        "action": () => popout.kill("TERM")
                    },
                    {
                        "type": "item",
                        "icon": "skull",
                        "text": "Force kill",
                        "isDestructive": true,
                        "action": () => popout.kill("KILL")
                    }
                ]
            }
        }
    }
}
