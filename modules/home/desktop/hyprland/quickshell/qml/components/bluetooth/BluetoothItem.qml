import Quickshell.Bluetooth
import QtQuick
import "../../config"
import "../../services"
import "../base"

// One row per device. Unpaired ("new") devices pair on click; paired devices
// (connected or saved) expand to reveal actions and, behind a toggle, their
// identifiers. The parent owns which row is open via expandedAddress.
ListItem {
    id: root

    required property var modelData
    property string expandedAddress: ""

    signal expandToggled(string address)

    // A failed pair() is otherwise silent — pairing ends without `paired` going
    // true. Surface it, clearing after a few seconds or on retry/success.
    property bool _awaitingPair: false
    property bool pairFailed: false

    readonly property bool isConnected: modelData.state === BluetoothDeviceState.Connected
    readonly property bool isPaired: modelData.paired
    readonly property bool isBusy: modelData.state === BluetoothDeviceState.Connecting
        || modelData.state === BluetoothDeviceState.Disconnecting
        || modelData.pairing

    readonly property string statusText: {
        if (root.pairFailed) return "Pairing failed"
        switch (modelData.state) {
            case BluetoothDeviceState.Connected: return "Connected"
            case BluetoothDeviceState.Connecting: return "Connecting…"
            case BluetoothDeviceState.Disconnecting: return "Disconnecting…"
            default: return modelData.pairing ? "Pairing…" : ""
        }
    }

    label: modelData.name || modelData.address
    highlighted: isConnected
    iconColor: isConnected ? Theme.textBright : Theme.textPrimary
    expanded: isPaired && root.expandedAddress === modelData.address

    // Details stay collapsed by default; forget them when the row closes.
    property bool showDetails: false
    onExpandedChanged: if (!expanded) showDetails = false

    onClicked: {
        if (root.isPaired) {
            root.expandToggled(modelData.address)
        } else if (!root.isBusy) {
            root.pairFailed = false
            root._awaitingPair = true
            BluetoothState.pair(root.modelData)
        }
    }

    // Infer pair success/failure from the pairing/paired transitions.
    Connections {
        target: root.modelData

        function onPairingChanged() {
            if (root.modelData.pairing || !root._awaitingPair)
                return
            root._awaitingPair = false
            if (!root.modelData.paired) {
                root.pairFailed = true
                pairFailReset.restart()
            }
        }

        function onPairedChanged() {
            if (root.modelData.paired) {
                root._awaitingPair = false
                root.pairFailed = false
            }
        }
    }

    Timer {
        id: pairFailReset
        interval: 4000
        onTriggered: root.pairFailed = false
    }

    trailingContent: Row {
        spacing: 6

        Text {
            visible: root.modelData.batteryAvailable && root.isConnected
            text: Math.round(root.modelData.battery * 100) + "%"
            color: Theme.textSecondary
            font.pixelSize: Config.fontSizeSmall
            font.family: Config.fontFamily
            renderType: Text.NativeRendering
            anchors.verticalCenter: parent.verticalCenter
        }

        Text {
            text: root.statusText
            visible: text !== ""
            color: root.pairFailed ? Theme.error
                : root.isConnected ? Theme.textBright : Theme.textSecondary
            font.pixelSize: Config.fontSizeSmall
            font.family: Config.fontFamily
            renderType: Text.NativeRendering
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    expandedContent: Column {
        x: 26
        width: parent ? parent.width - 30 : 200
        spacing: 6

        Row {
            spacing: 6

            ActionButton {
                label: root.isConnected ? "Disconnect" : "Connect"
                enabled: !root.isBusy
                onClicked: {
                    if (root.isConnected) BluetoothState.disconnect(root.modelData)
                    else BluetoothState.connect(root.modelData)
                }
            }

            ActionButton {
                label: "Forget"
                enabled: !root.isBusy
                destructive: true
                onClicked: BluetoothState.forget(root.modelData)
            }

            ActionButton {
                label: root.showDetails ? "Hide" : "Details"
                onClicked: root.showDetails = !root.showDetails
            }
        }

        Column {
            visible: root.showDetails
            width: parent.width
            spacing: 2

            DetailRow { key: "MAC"; value: root.modelData.address; mono: true }
            DetailRow { key: "Path"; value: root.modelData.dbusPath; mono: true }
        }
    }
}
