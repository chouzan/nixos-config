import QtQuick
import QtQuick.Layouts
import "../../config"
import "../../services"
import "../base"

Item {
    id: root


    readonly property string iconName: BatteryState.charging ? "battery-charging-duotone.svg"
        : BatteryState.percentage > 80 ? "battery-full-duotone.svg"
        : BatteryState.percentage > 60 ? "battery-high-duotone.svg"
        : BatteryState.percentage > 40 ? "battery-medium-duotone.svg"
        : BatteryState.percentage > 20 ? "battery-low-duotone.svg"
        : BatteryState.percentage > 5 ? "battery-warning-duotone.svg"
        : "battery-empty-duotone.svg"

    readonly property color batteryColor: BatteryState.percentage <= 10 ? Theme.error
        : BatteryState.percentage <= 20 ? Theme.warning
        : BatteryState.charging ? Theme.success
        : Theme.textPrimary

    function formatTime(sec) {
        if (sec <= 0) return ""
        var h = Math.floor(sec / 3600)
        var m = Math.floor((sec % 3600) / 60)
        return h + ":" + (m < 10 ? "0" : "") + m
    }

    visible: BatteryState.hasBattery
    implicitWidth: BatteryState.hasBattery ? batteryRow.implicitWidth : 0
    implicitHeight: parent ? parent.height : 30

    RowLayout {
        id: batteryRow
        anchors.centerIn: parent
        spacing: 4
        visible: BatteryState.hasBattery

        SvgIcon {
            icon: root.iconName
            color: root.batteryColor
            size: Config.iconSize
        }

        Text {
            text: Math.round(BatteryState.percentage) + "%"
            color: root.batteryColor
            font.pixelSize: Config.fontSizeSmall
            font.family: Config.fontFamily
            renderType: Text.NativeRendering
        }
    }

    HoverTrigger { id: hover }

    InfoPopup {
        target: root
        title: "Battery"
        open: hover.infoVisible

        Row {
            spacing: 8

            SvgIcon {
                icon: root.iconName
                color: root.batteryColor
                size: Config.fontSize
                anchors.verticalCenter: parent.verticalCenter
            }

            Text {
                text: Math.round(BatteryState.percentage) + "%"
                color: root.batteryColor
                font: Config.tnumFont(Config.fontSize)
                renderType: Text.NativeRendering
            }

            Text {
                text: BatteryState.fullyCharged ? "Fully charged"
                    : BatteryState.charging ? "Charging" : "Discharging"
                color: BatteryState.fullyCharged ? Theme.success
                    : BatteryState.charging ? Theme.success : Theme.textSecondary
                font.pixelSize: Config.fontSize
                font.family: Config.fontFamily
                renderType: Text.NativeRendering
            }
        }

        Row {
            visible: BatteryState.changeRate > 0 && !BatteryState.fullyCharged
            spacing: 8

            Text {
                text: BatteryState.changeRate.toFixed(1) + " W"
                color: Theme.textPrimary
                font: Config.tnumFont(Config.fontSizeSmall)
                renderType: Text.NativeRendering
            }

            Text {
                visible: BatteryState.charging ? BatteryState.timeToFull > 0 : BatteryState.timeToEmpty > 0
                text: BatteryState.charging
                    ? root.formatTime(BatteryState.timeToFull) + " to full"
                    : root.formatTime(BatteryState.timeToEmpty) + " remaining"
                color: Theme.textSecondary
                font: Config.tnumFont(Config.fontSizeSmall)
                renderType: Text.NativeRendering
            }
        }

        Text {
            visible: BatteryState.healthSupported
            text: "Health  " + BatteryState.health.toFixed(1) + "%"
            color: Theme.textSecondary
            font.pixelSize: Config.fontSizeSmall
            font.family: Config.fontFamily
            renderType: Text.NativeRendering
        }
    }
}
