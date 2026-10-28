pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Widgets
import qs.Common
import qs.Modules.DBar
import qs.Modules.Plugins
import qs.Services
import qs.DCommon.Widgets

PluginComponent {
    id: root

    // streams, blocks and actions live in the daemon, shared by every bar
    readonly property var daemon: PluginService.pluginDaemonInstances[pluginId] ?? null
    readonly property var apps: daemon?.apps ?? []
    readonly property var blockedKinds: daemon?.blockedKinds ?? ({})
    readonly property bool micActive: daemon?.micActive ?? false

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
            "shown": PrivacyService.cameraActive || !!blockedKinds.camera,
            "active": PrivacyService.cameraActive,
            "color": Theme.error,
            "dot": true
        },
        {
            "icon": "screen_share",
            "shown": PrivacyService.screensharingActive || !!blockedKinds.screen,
            "active": PrivacyService.screensharingActive,
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
            "camera": "camera_video",
            "screen": "screen_share"
        })

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

    // a menu row, as in the focused window popout
    component ActionRow: Item {
        id: actionRow

        property string icon
        property string text
        property bool danger: false

        signal triggered

        height: BarMetrics.menuRowHeight

        Row {
            anchors.fill: parent
            anchors.leftMargin: Theme.spacingS
            spacing: Theme.spacingS

            DIcon {
                name: actionRow.icon
                size: Theme.iconSizeSmall
                color: actionRow.danger ? Theme.error : Theme.surfaceText
                anchors.verticalCenter: parent.verticalCenter
            }

            StyledText {
                text: actionRow.text
                color: actionRow.danger ? Theme.error : Theme.surfaceText
                font.pixelSize: Theme.fontSizeSmall
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        StateLayer {
            cornerRadius: BarMetrics.menuItemRadius
            stateColor: actionRow.danger ? Theme.error : Theme.surfaceText
            onClicked: actionRow.triggered()
        }
    }

    popoutWidth: 340

    popoutContent: Component {
        Column {
            id: popout

            spacing: Theme.spacingL

            StyledText {
                visible: root.apps.length === 0
                width: popout.width
                text: "Can't tell which app is using it"
                color: Theme.surfaceVariantText
                font.pixelSize: Theme.fontSizeSmall
                wrapMode: Text.Wrap
            }

            Repeater {
                model: root.apps

                // one app: icon and name, what it uses and its pid, then block and kill
                Column {
                    id: section

                    required property var modelData
                    readonly property var app: modelData
                    readonly property var block: root.daemon?.blocks[app.key] ?? null
                    readonly property var inUse: ["mic", "camera", "screen"].filter(kind => app.kinds[kind])
                    readonly property var blockKinds: ["mic", "camera", "screen"].filter(kind => (app.kinds[kind] && app.blockable[kind]) || block?.[kind])
                    readonly property var details: [
                        {
                            "label": "Using",
                            "value": inUse.map(kind => root.kindNames[kind].charAt(0).toUpperCase() + root.kindNames[kind].slice(1)).join(", "),
                            "copyable": false
                        },
                        {
                            "label": "PID",
                            "value": app.pid > 0 ? app.pid.toString() : "Unavailable",
                            "copyable": app.pid > 0
                        }
                    ]

                    width: popout.width
                    spacing: Theme.spacingXXS

                    Row {
                        width: parent.width
                        height: BarMetrics.menuRowHeight
                        spacing: Theme.spacingS

                        Item {
                            width: Theme.iconSizeMedium
                            height: Theme.iconSizeMedium
                            anchors.verticalCenter: parent.verticalCenter

                            IconImage {
                                id: appIcon
                                anchors.fill: parent
                                source: section.app.icon
                                asynchronous: true
                                mipmap: true
                                smooth: true
                            }

                            StyledText {
                                anchors.centerIn: parent
                                visible: appIcon.status !== Image.Ready
                                text: section.app.name.charAt(0).toUpperCase()
                                color: Theme.surfaceText
                                font.pixelSize: Theme.fontSizeMedium
                            }
                        }

                        StyledText {
                            width: parent.width - Theme.iconSizeMedium - Theme.spacingS
                            text: section.app.name
                            color: Theme.surfaceText
                            font.pixelSize: Theme.fontSizeMedium
                            font.weight: Theme.fontWeightMedium
                            elide: Text.ElideRight
                            maximumLineCount: 2
                            wrapMode: Text.Wrap
                            clip: true
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    // nothing to show for a blocked app that has nothing open
                    Repeater {
                        model: section.inUse.length > 0 ? section.details : []

                        delegate: DListRow {
                            id: detailRow

                            required property var modelData
                            required property int index
                            readonly property real labelWidth: Theme.iconButtonSize + Theme.iconSizeLarge

                            width: section.width
                            implicitHeight: Theme.listItemHeight
                            firstInGroup: index === 0
                            lastInGroup: index === section.details.length - 1

                            Row {
                                anchors.fill: parent
                                anchors.leftMargin: Theme.spacingL
                                anchors.rightMargin: Theme.spacingL
                                spacing: Theme.spacingS

                                StyledText {
                                    width: detailRow.labelWidth
                                    text: detailRow.modelData.label
                                    color: detailRow.supportingContentColor
                                    font.pixelSize: Theme.fontSizeSmall
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                StyledText {
                                    width: parent.width - detailRow.labelWidth - Theme.spacingS
                                    text: detailRow.modelData.value
                                    color: detailRow.contentColor
                                    font.pixelSize: Theme.fontSizeSmall
                                    font.family: SettingsData.monoFontFamily
                                    elide: Text.ElideRight
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }

                            StateLayer {
                                topLeftRadius: detailRow.firstInGroup ? Theme.groupedListOuterRadius : Theme.groupedListInnerRadius
                                topRightRadius: topLeftRadius
                                bottomLeftRadius: detailRow.lastInGroup ? Theme.groupedListOuterRadius : Theme.groupedListInnerRadius
                                bottomRightRadius: bottomLeftRadius
                                enabled: detailRow.modelData.copyable
                                disabled: !detailRow.modelData.copyable
                                onClicked: root.copyValue(detailRow.modelData.value)
                            }
                        }
                    }

                    Rectangle {
                        visible: section.inUse.length > 0
                        width: parent.width
                        height: Theme.dividerWidth
                        color: Theme.outlineVariant
                    }

                    Repeater {
                        model: section.blockKinds

                        ActionRow {
                            required property string modelData
                            readonly property bool blocked: !!section.block?.[modelData]

                            width: section.width
                            icon: blocked ? root.kindIcons[modelData] : "block"
                            text: (blocked ? "Unblock " : "Block ") + root.kindNames[modelData]
                            onTriggered: root.daemon.setBlocked(section.app, modelData, !blocked)
                        }
                    }

                    ActionRow {
                        visible: section.app.pid > 0
                        width: section.width
                        icon: "close"
                        text: "Kill"
                        danger: true
                        onTriggered: {
                            root.daemon.kill(section.app, "TERM");
                            root.closePopout();
                        }
                    }

                    ActionRow {
                        visible: section.app.pid > 0
                        width: section.width
                        icon: "skull"
                        text: "Force kill"
                        danger: true
                        onTriggered: {
                            root.daemon.kill(section.app, "KILL");
                            root.closePopout();
                        }
                    }
                }
            }
        }
    }
}
