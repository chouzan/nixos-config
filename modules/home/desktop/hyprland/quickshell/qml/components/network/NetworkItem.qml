import Quickshell.Networking
import QtQuick
import "../../config"
import "../../services"
import "../base"

ListItem {
    id: root

    required property var modelData
    property string expandedSsid: ""
    property string selectedSsid: ""
    property string connectError: ""

    signal expandToggled(string ssid)
    signal selected(string ssid, var network)
    signal deselected()
    signal connectRequested(var network, string psk)
    signal scrollRequested(real delegateY, real delegateHeight)

    icon: signalIcon(signalPct)
    iconColor: root.isConnected ? Theme.textBright : Theme.textPrimary
    label: modelData.name || "Hidden network"
    highlighted: root.isConnected
    expanded: root.isExpanded

    readonly property int signalPct: Math.round(modelData.signalStrength * 100)
    readonly property bool isConnected: modelData.connected
    readonly property bool isExpanded: modelData.name !== "" && root.expandedSsid === modelData.name
    readonly property bool isBusy: modelData.state === ConnectionState.Connecting
        || modelData.state === ConnectionState.Disconnecting
    readonly property bool isPskNetwork: NetworkState.canUsePsk(root.modelData)
    readonly property bool hasError: root.connectError === modelData.name

    readonly property bool showPassword: root.isExpanded
        && root.isPskNetwork
        && (root.hasError || root.selectedSsid === modelData.name)

    property bool showDetails: false

    readonly property string statusText: {
        switch (modelData.state) {
            case ConnectionState.Connecting: return "Connecting..."
            case ConnectionState.Disconnecting: return "Disconnecting..."
            default: return modelData.connected ? "Connected" : root.signalPct + "%"
        }
    }

    function signalIcon(pct) {
        if (pct > 66) return "wifi-high-duotone.svg"
        if (pct > 33) return "wifi-medium-duotone.svg"
        if (pct > 0) return "wifi-low-duotone.svg"
        return "wifi-none-duotone.svg"
    }

    function securityText(security) {
        switch (security) {
            case WifiSecurityType.Wpa3SuiteB192: return "WPA3 Suite B"
            case WifiSecurityType.Sae: return "WPA3"
            case WifiSecurityType.Wpa2Eap: return "WPA2 Enterprise"
            case WifiSecurityType.Wpa2Psk: return "WPA2"
            case WifiSecurityType.WpaEap: return "WPA Enterprise"
            case WifiSecurityType.WpaPsk: return "WPA"
            case WifiSecurityType.StaticWep: return "WEP"
            case WifiSecurityType.DynamicWep: return "Dynamic WEP"
            case WifiSecurityType.Leap: return "LEAP"
            case WifiSecurityType.Owe: return "OWE"
            case WifiSecurityType.Open: return "Open"
            default: return "Unknown"
        }
    }

    function stateText(state) {
        switch (state) {
            case ConnectionState.Connecting: return "Connecting"
            case ConnectionState.Connected: return "Connected"
            case ConnectionState.Disconnecting: return "Disconnecting"
            case ConnectionState.Disconnected: return "Disconnected"
            default: return "Unknown"
        }
    }

    function requestConnect() {
        if (root.isBusy) return
        if (root.isConnected) {
            NetworkState.disconnect(root.modelData)
        } else if (root.modelData.known || root.modelData.security === WifiSecurityType.Open) {
            root.connectRequested(root.modelData, "")
        } else if (root.isPskNetwork) {
            root.selected(root.modelData.name, root.modelData)
        } else {
            root.connectRequested(root.modelData, "")
        }
    }

    onClicked: {
        root.expandToggled(modelData.name)
    }

    onExpandedChanged: {
        if (!expanded) {
            showDetails = false
            return
        }
        Qt.callLater(function() {
            root.scrollRequested(root.y, root.height)
        })
    }

    onShowPasswordChanged: {
        if (showPassword) {
            passInput.text = ""
            passInput.forceActiveFocus()
            Qt.callLater(function() {
                root.scrollRequested(root.y, root.height)
            })
        }
    }

    trailingContent: Row {
        spacing: 6

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: root.statusText
            color: root.modelData.connected ? Theme.textBright
                : root.modelData.state === ConnectionState.Connecting ? Theme.warning
                : Theme.textSecondary
            font.pixelSize: Config.fontSizeSmall
            font.family: Config.fontFamily
            renderType: Text.NativeRendering
        }

        SvgIcon {
            visible: root.modelData.security !== WifiSecurityType.Open
            anchors.verticalCenter: parent.verticalCenter
            icon: "lock-duotone.svg"
            color: Theme.textSecondary
            size: Config.fontSizeSmall
        }
    }

    expandedContent: Column {
        id: actionColumn
        x: 26
        width: parent ? parent.width - 30 : 200
        spacing: 6

        Row {
            width: parent.width
            spacing: 6

            ActionButton {
                label: root.isBusy ? root.stateText(root.modelData.state)
                    : root.isConnected ? "Disconnect" : "Connect"
                enabled: !root.isBusy
                onClicked: root.requestConnect()
            }

            ActionButton {
                visible: root.modelData.known
                label: "Forget"
                enabled: !root.isBusy
                destructive: true
                onClicked: {
                    NetworkState.forget(root.modelData)
                    root.deselected()
                }
            }

            ActionButton {
                label: root.showDetails ? "Hide" : "Details"
                onClicked: root.showDetails = !root.showDetails
            }
        }

        Row {
            visible: root.showPassword
            width: parent.width
            spacing: 4

            Rectangle {
                width: parent.width - connectRect.width - parent.spacing
                height: 26
                radius: 4
                color: Theme.background
                border.width: root.hasError ? 1 : 0
                border.color: Theme.error

                TextInput {
                    id: passInput
                    anchors.fill: parent
                    anchors.margins: 4
                    echoMode: TextInput.Password
                    color: Theme.textPrimary
                    font.pixelSize: Config.fontSizeSmall
                    font.family: Config.fontFamily
                    clip: true
                    maximumLength: 63

                    readonly property bool validLength: text.length >= 8 && text.length <= 63

                    Keys.onReturnPressed: {
                        if (validLength) root.connectRequested(root.modelData, text)
                    }

                    Keys.onEscapePressed: root.deselected()
                }
            }

            Rectangle {
                id: connectRect
                width: connectLabel.width + 16
                height: 26
                radius: 4
                color: connectBtn.containsMouse
                    ? Qt.rgba(Theme.textPrimary.r, Theme.textPrimary.g, Theme.textPrimary.b, 0.15)
                    : "transparent"

                Text {
                    id: connectLabel
                    anchors.centerIn: parent
                    text: "Connect"
                    color: Theme.textPrimary
                    font.pixelSize: Config.fontSizeSmall
                    font.family: Config.fontFamily
                    renderType: Text.NativeRendering
                }

                MouseArea {
                    id: connectBtn
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (passInput.validLength) root.connectRequested(root.modelData, passInput.text)
                    }
                }
            }
        }

        Text {
            visible: root.showPassword
                && (root.hasError || (passInput.text.length > 0 && passInput.text.length < 8))
            text: root.hasError ? "Incorrect password" : "Min 8 characters"
            color: root.hasError ? Theme.error : Theme.textSecondary
            font.pixelSize: Config.fontSizeSmall
            font.family: Config.fontFamily
            renderType: Text.NativeRendering
        }

        Column {
            visible: root.showDetails
            width: parent.width
            spacing: 2

            DetailRow { key: "Security"; value: root.securityText(root.modelData.security) }
            DetailRow { key: "Signal"; value: root.signalPct + "%" }
            DetailRow { key: "State"; value: root.stateText(root.modelData.state) }
            DetailRow { key: "Saved"; value: root.modelData.known ? "Yes" : "No" }
        }
    }
}
