pragma ComponentBehavior: Bound

import QtQuick
import qs.Common
import qs.Modules.DBar
import qs.Modules.Plugins
import qs.Services
import qs.DCommon.Widgets

PluginComponent {
    id: root

    // {serial, name, battery, charging, dpi, maxDpi, asleep}, or null with no mouse;
    // asleep keeps the last battery and dpi
    property var mouse: null
    readonly property bool asleep: mouse?.asleep ?? false
    readonly property int battery: mouse?.battery !== undefined ? Math.round(mouse.battery) : -1
    readonly property bool charging: !asleep && (mouse?.charging ?? false)
    readonly property bool low: battery >= 0 && battery <= 20 && !charging

    readonly property var presets: [400, 800, 1200, 1600, 2400, 3200]

    function refresh() {
        Proc.runCommand(null, ["@razer@"], (output, exitCode) => {
            if (exitCode !== 0)
                return;
            try {
                const read = JSON.parse(output.trim());
                root.mouse = read.serial ? Object.assign({}, read.asleep ? root.mouse : {}, read) : null;
            } catch (e) {}
        }, 0, 5000, root);
    }

    function setDpi(value) {
        if (!mouse || asleep)
            return;
        mouse = Object.assign({}, mouse, {
            "dpi": value
        });
        Proc.runCommand(null, ["@razer@", "dpi", mouse.serial, String(value)], () => root.refresh(), 0, 5000, root);
    }

    // same steps as the controller widget's corner icon
    function batteryIcon(level) {
        if (charging)
            return level >= 95 ? "battery_charging_full" : level >= 75 ? "battery_charging_80" : level >= 55 ? "battery_charging_60" : level >= 30 ? "battery_charging_30" : "battery_charging_20";
        return level >= 90 ? "battery_6_bar" : level >= 75 ? "battery_5_bar" : level >= 60 ? "battery_4_bar" : level >= 45 ? "battery_3_bar" : level >= 25 ? "battery_2_bar" : level >= 15 ? "battery_1_bar" : "battery_alert";
    }

    Timer {
        running: true
        repeat: true
        triggeredOnStart: true
        interval: 60000
        onTriggered: root.refresh()
    }

    onInteractionActiveChanged: {
        if (interactionActive)
            refresh();
    }

    onMouseChanged: setVisibilityOverride(mouse !== null)
    Component.onCompleted: setVisibilityOverride(false)

    // mouse icon, its battery in the corner, then the percentage
    component MouseIcon: Item {
        width: icon.width
        height: icon.height

        DIcon {
            id: icon

            name: "mouse"
            size: Theme.iconSize
            color: root.asleep ? Theme.surfaceVariantText : Theme.primary
        }

        DIcon {
            visible: !root.charging && root.battery >= 0
            name: root.batteryIcon(root.battery)
            size: icon.size * 0.52
            color: root.low ? Theme.warning : Theme.surfaceVariantText
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.rightMargin: -2
            anchors.bottomMargin: -1
        }

        Rectangle {
            visible: root.charging
            width: icon.size * 0.34
            height: width
            radius: width / 2
            color: Theme.success
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.rightMargin: -2
            anchors.bottomMargin: -1
        }
    }

    horizontalBarPill: Component {
        Row {
            spacing: Theme.spacingS

            MouseIcon {
                anchors.verticalCenter: parent.verticalCenter
            }

            StyledText {
                text: root.battery >= 0 ? root.battery + "%" : " - "
                font.pixelSize: Theme.fontSizeMedium
                color: Theme.surfaceText
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }

    verticalBarPill: Component {
        Column {
            spacing: Theme.spacingXS

            MouseIcon {
                anchors.horizontalCenter: parent.horizontalCenter
            }

            StyledText {
                text: root.battery >= 0 ? root.battery : "-"
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.surfaceText
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
    }

    popoutWidth: 240

    // the presets, the current one ticked
    popoutContent: Component {
        PopoutComponent {
            id: popout

            headerText: root.mouse?.name.replace(/^Razer /, "").replace(/ \(Wireless\)$/, "") ?? "Razer Mouse"

            Column {
                id: presetColumn

                width: parent.width
                spacing: Theme.groupedListGap

                Repeater {
                    model: root.presets

                    DListRow {
                        id: presetRow

                        required property int modelData
                        required property int index
                        readonly property bool current: root.mouse?.dpi === modelData

                        width: presetColumn.width
                        implicitHeight: BarMetrics.menuRowHeight
                        firstInGroup: index === 0
                        lastInGroup: index === root.presets.length - 1
                        enabled: !root.asleep && modelData <= (root.mouse?.maxDpi ?? 0)

                        StyledText {
                            text: `${presetRow.modelData} DPI`
                            color: presetRow.current ? Theme.primary : Theme.surfaceText
                            font.pixelSize: Theme.fontSizeMedium
                            font.weight: presetRow.current ? Theme.fontWeightMedium : Font.Normal
                            anchors.left: parent.left
                            anchors.leftMargin: Theme.spacingM
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        DIcon {
                            visible: presetRow.current
                            name: "check"
                            size: Theme.iconSizeSmall
                            color: Theme.primary
                            anchors.right: parent.right
                            anchors.rightMargin: Theme.spacingM
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        StateLayer {
                            stateColor: Theme.primary
                            disabled: !presetRow.enabled
                            onClicked: root.setDpi(presetRow.modelData)
                        }
                    }
                }

                // asleep, or sitting off the presets, e.g. set from its own button
                StyledText {
                    visible: root.asleep || (root.mouse?.dpi !== undefined && !root.presets.includes(root.mouse.dpi))
                    width: parent.width
                    text: root.asleep ? "Asleep, move it to wake it" : `Now ${root.mouse?.dpi} DPI`
                    color: Theme.surfaceVariantText
                    font.pixelSize: Theme.fontSizeSmall
                    horizontalAlignment: Text.AlignHCenter
                }
            }
        }
    }
}
