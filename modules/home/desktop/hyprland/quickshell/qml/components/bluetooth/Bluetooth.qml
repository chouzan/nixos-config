pragma ComponentBehavior: Bound

import Quickshell.Bluetooth
import QtQuick
import "../../config"
import "../../services"
import "../base"

Item {
    id: root

    property bool menuVisible: false

    implicitWidth: Config.iconSize
    implicitHeight: parent ? parent.height : 30

    // Address of the row whose actions/details are expanded (single at a time).
    property string _expandedAddress: ""

    readonly property string iconName: !BluetoothState.available ? "bluetooth-x-duotone.svg"
        : !BluetoothState.powered ? "bluetooth-slash-duotone.svg"
        : BluetoothState.connected ? "bluetooth-connected-duotone.svg"
        : "bluetooth-duotone.svg"

    function deviceIcon(btIcon) {
        return BluetoothState.iconFor(btIcon)
    }

    // ---- Connected device tracking ----

    // ---- Bar display ----

    HoverPill {
        active: hover.containsMouse || root.menuVisible
    }

    SvgIcon {
        anchors.centerIn: parent
        icon: root.iconName
        color: !BluetoothState.available ? Theme.error : Theme.textPrimary
        size: Config.iconSize
    }

    HoverTrigger {
        id: hover
        suppressed: root.menuVisible
        acceptedButtons: Qt.LeftButton
        cursorShape: Qt.PointingHandCursor
        onClicked: root.menuVisible = !root.menuVisible
    }

    onMenuVisibleChanged: BluetoothState.setDiscovering(root.menuVisible)

    // The adapter can disappear while the menu is open.
    Connections {
        target: BluetoothState

        function onAvailableChanged() {
            if (!BluetoothState.available)
                root.menuVisible = false;
        }
    }

    // ---- Hover Info ----

    InfoPopup {
        target: root
        title: "Bluetooth"
        open: hover.infoVisible
        suppressed: root.menuVisible

        Repeater {
            model: BluetoothState._deviceModel

            Row {
                id: deviceRow

                required property var modelData
                visible: deviceRow.modelData.state
                    === BluetoothDeviceState.Connected
                spacing: 8

                SvgIcon {
                    icon: root.deviceIcon(deviceRow.modelData.icon)
                    color: Theme.textPrimary
                    size: Config.fontSize
                    anchors.verticalCenter: parent.verticalCenter
                }

                Text {
                    text: deviceRow.modelData.name
                    color: Theme.textPrimary
                    font.pixelSize: Config.fontSize
                    font.family: Config.fontFamily
                    renderType: Text.NativeRendering
                }

                Text {
                    visible: deviceRow.modelData.batteryAvailable
                    text: Math.round(deviceRow.modelData.battery * 100) + "%"
                    color: Theme.textSecondary
                    font.pixelSize: Config.fontSize
                    font.family: Config.fontFamily
                    renderType: Text.NativeRendering
                }
            }
        }

        Row {
            visible: !BluetoothState.connected
            spacing: 8

            SvgIcon {
                icon: root.iconName
                color: !BluetoothState.available ? Theme.error : Theme.textPrimary
                size: Config.fontSize
                anchors.verticalCenter: parent.verticalCenter
            }

            Text {
                text: !BluetoothState.available ? "Unavailable"
                    : !BluetoothState.powered ? "Powered off"
                    : "Not connected"
                color: !BluetoothState.available ? Theme.error : Theme.textSecondary
                font.pixelSize: Config.fontSize
                font.family: Config.fontFamily
                renderType: Text.NativeRendering
            }
        }

        Text {
            visible: BluetoothState.adapter !== null && BluetoothState.adapter.name !== "" && BluetoothState.powered
            text: BluetoothState.adapter ? BluetoothState.adapter.name : ""
            color: Theme.textSecondary
            font.pixelSize: Config.fontSizeSmall
            font.family: Config.fontFamily
            renderType: Text.NativeRendering
        }
    }

    // ---- Click Menu ----

    MenuPopup {
        target: root
        name: "bluetooth"
        open: root.menuVisible
        onDismissed: root.menuVisible = false

        PopupMenu {
            title: "Bluetooth"

            headerContent: ToggleSwitch {
                enabled: BluetoothState.available
                checked: BluetoothState.powered
                onToggled: {
                    BluetoothState.togglePower()
                }
            }

            MenuSeparator {}

            Item {
                width: parent.width
                height: 210

                // Shared row wiring: click a saved/connected row to open its
                // actions (single row open at a time); new rows pair on click.
                Component {
                    id: btDelegate

                    BluetoothItem {
                        width: parent.width
                        icon: root.deviceIcon(modelData.icon)
                        expandedAddress: root._expandedAddress
                        onExpandToggled: (address) => {
                            root._expandedAddress =
                                root._expandedAddress === address ? "" : address
                        }
                    }
                }

                ScrollList {
                    id: deviceScroll
                    anchors.fill: parent

                    // Active devices on top, new devices below, saved
                    // (known but disconnected) last — the usual layout.
                    ItemSection {
                        title: "Connected"
                        model: BluetoothState.connectedDevices
                        delegate: btDelegate
                    }

                    ItemSection {
                        title: "Available"
                        model: BluetoothState.availableDevices
                        delegate: btDelegate
                    }

                    ItemSection {
                        title: "Saved"
                        model: BluetoothState.savedDevices
                        delegate: btDelegate
                    }
                }

                Text {
                    visible: deviceScroll.contentHeight === 0
                    anchors.centerIn: parent
                    text: !BluetoothState.powered ? "Bluetooth is off"
                        : BluetoothState.adapter && BluetoothState.adapter.discovering ? "Scanning…"
                        : "No devices"
                    color: Theme.textSecondary
                    font.pixelSize: Config.fontSizeSmall
                    font.family: Config.fontFamily
                    renderType: Text.NativeRendering
                }
            }
        }
    }
}
