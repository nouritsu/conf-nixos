pragma ComponentBehavior: Bound

import QtQuick
import Quickshell.Widgets
import qs.Common
import qs.Modules.Plugins
import qs.Services
import qs.DCommon.Widgets

PluginSettings {
    id: root

    pluginId: "privacyApps"

    // the indicator's popout can't open while only hidden apps are active, so they come back here
    readonly property var daemon: PluginService.pluginDaemonInstances[pluginId] ?? null
    readonly property var entries: {
        const hidden = daemon?.hidden ?? {};
        const shown = Object.keys(hidden).map(key => ({
                    "key": key,
                    "name": hidden[key].name,
                    "icon": hidden[key].icon,
                    "locked": false
                })).sort((a, b) => a.name.localeCompare(b.name));
        const locked = (daemon?.ignored ?? []).map(key => ({
                    "key": key,
                    "name": key,
                    "icon": "",
                    "locked": true
                }));
        return shown.concat(locked);
    }

    StyledText {
        width: parent.width
        text: "Hidden apps"
        font.pixelSize: Theme.fontSizeLarge
        font.weight: Theme.fontWeightMedium
        color: Theme.surfaceText
    }

    StyledText {
        width: parent.width
        text: root.entries.length > 0 ? "They don't light the privacy indicator. Locked ones are ignored in the config." : "Nothing hidden"
        font.pixelSize: Theme.fontSizeSmall
        color: Theme.surfaceVariantText
    }

    Column {
        width: parent.width
        spacing: Theme.groupedListGap

        Repeater {
            model: root.entries

            DListRow {
                id: entryRow

                required property var modelData
                required property int index

                width: parent.width
                implicitHeight: Theme.menuItemHeight
                firstInGroup: index === 0
                lastInGroup: index === root.entries.length - 1

                Row {
                    anchors.left: parent.left
                    anchors.right: showButton.left
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
                            source: entryRow.modelData.icon
                            asynchronous: true
                            mipmap: true
                            smooth: true
                        }

                        StyledText {
                            anchors.centerIn: parent
                            visible: appIcon.status !== Image.Ready
                            text: entryRow.modelData.name.charAt(0).toUpperCase()
                            color: Theme.surfaceText
                            font.pixelSize: Theme.fontSizeSmall
                        }
                    }

                    StyledText {
                        width: parent.width - Theme.iconSizeMedium - parent.spacing
                        text: entryRow.modelData.name
                        color: Theme.surfaceText
                        font.pixelSize: Theme.fontSizeSmall
                        font.weight: Theme.fontWeightMedium
                        wrapMode: Text.NoWrap
                        elide: Text.ElideRight
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                Item {
                    id: showButton

                    width: Theme.iconSizeSmall + Theme.spacingM
                    height: width
                    anchors.right: parent.right
                    anchors.rightMargin: Theme.spacingS
                    anchors.verticalCenter: parent.verticalCenter

                    DIcon {
                        name: entryRow.modelData.locked ? "lock" : "visibility_off"
                        size: Theme.iconSizeSmall
                        color: entryRow.modelData.locked ? Theme.onSurface_38 : Theme.surfaceVariantText
                        anchors.centerIn: parent
                    }

                    StateLayer {
                        cornerRadius: Theme.cornerRadiusFull
                        enabled: !entryRow.modelData.locked
                        disabled: entryRow.modelData.locked
                        tooltipText: "Show"
                        onClicked: root.daemon?.setHidden({
                            "key": entryRow.modelData.key
                        }, false)
                    }
                }
            }
        }
    }
}
