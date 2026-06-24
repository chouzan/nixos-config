pragma ComponentBehavior: Bound

import QtQuick
import "../../config"
import "../../services"
import "../base"

Item {
    id: root

    property bool menuVisible: false
    property string _expandedSsid: ""
    property string selectedSsid: ""
    property var selectedNetwork: null
    property string connectError: ""

    function clearSelection() {
        selectedSsid = ""
        selectedNetwork = null
        connectError = ""
    }


    implicitWidth: Config.iconSize
    implicitHeight: parent ? parent.height : 30

    // ---- Icon ----

    function signalIcon(pct) {
        if (pct > 66) return "wifi-high-duotone.svg"
        if (pct > 33) return "wifi-medium-duotone.svg"
        if (pct > 0) return "wifi-low-duotone.svg"
        return "wifi-none-duotone.svg"
    }

    // The wired icon shows when the wired device holds the default route, and
    // still shows when the route is unknown and only that device is connected.
    readonly property bool preferWired: NetworkState.isPrimaryWired || (!NetworkState.isPrimaryWifi && NetworkState.isEthernet)

    readonly property string iconName: {
        if (root.preferWired) return NetworkState.hasConnection ? "network-duotone.svg" : "network-x-duotone.svg"
        if (!NetworkState.wifiEnabled) return "wifi-slash-duotone.svg"
        if (!NetworkState.isWifi || !NetworkState.hasConnection) return "wifi-x-duotone.svg"
        return root.signalIcon(NetworkState.signalPct)
    }

    readonly property color iconColor: (!NetworkState.hasConnection && (NetworkState.isEthernet || NetworkState.isWifi))
        ? Theme.error : Theme.textPrimary

    // ---- Menu state ----

    onMenuVisibleChanged: {
        if (!menuVisible) {
            root.clearSelection()
            root._expandedSsid = ""
        }
        if (menuVisible) networkScroll.flickable.contentY = 0
        NetworkState.setScanning(root.menuVisible)
    }

    // The service reports the outcome; the prompt is this view's business.
    Connections {
        target: NetworkState

        function onConnectionFailed(ssid, network, canRetry) {
            if (!canRetry)
                return;
            root.selectedSsid = ssid;
            root.selectedNetwork = network;
            root.connectError = ssid;
            root._expandedSsid = ssid;
        }
    }

    // ---- Bar display ----

    HoverPill {
        active: hover.containsMouse || root.menuVisible
    }

    SvgIcon {
        anchors.centerIn: parent
        icon: root.iconName
        color: root.iconColor
        size: Config.iconSize
    }

    HoverTrigger {
        id: hover
        suppressed: root.menuVisible
        acceptedButtons: Qt.LeftButton
        cursorShape: Qt.PointingHandCursor
        onClicked: root.menuVisible = !root.menuVisible
    }

    // ---- Hover Info ----

    InfoPopup {
        target: root
        title: "Network"
        open: hover.infoVisible
        suppressed: root.menuVisible

        Row {
            spacing: 8

            SvgIcon {
                icon: root.iconName
                color: root.iconColor
                size: Config.fontSize
                anchors.verticalCenter: parent.verticalCenter
            }

            Text {
                text: !NetworkState.wifiEnabled && !NetworkState.isEthernet ? "Wi-Fi disabled"
                    : NetworkState.connectionName || "Not connected"
                color: NetworkState.connectionName ? Theme.textPrimary : Theme.textSecondary
                font.pixelSize: Config.fontSize
                font.family: Config.fontFamily
                renderType: Text.NativeRendering
            }
        }

        Text {
            visible: NetworkState.ipAddress !== ""
            text: NetworkState.ipAddress
            color: Theme.textSecondary
            font.pixelSize: Config.fontSizeSmall
            font.family: Config.fontFamilyMono
            renderType: Text.NativeRendering
        }

        Text {
            visible: NetworkState.deviceName !== ""
            text: NetworkState.deviceName
            color: Theme.textSecondary
            font.pixelSize: Config.fontSizeSmall
            font.family: Config.fontFamily
            renderType: Text.NativeRendering
        }
    }

    // ---- Click Menu ----

    MenuPopup {
        target: root
        name: "network"
        open: root.menuVisible
        onDismissed: root.menuVisible = false

        PopupMenu {
            title: "Network"

            headerContent: ToggleSwitch {
                checked: NetworkState.wifiEnabled
                onToggled: NetworkState.toggleWifi()
            }

            Column {
                visible: NetworkState.connectionName !== ""
                width: parent.width
                spacing: 2

                Row {
                    spacing: 8

                    SvgIcon {
                        icon: root.iconName
                        color: Theme.textPrimary
                        size: Config.fontSize
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Text {
                        text: NetworkState.connectionName
                        color: Theme.textPrimary
                        font.pixelSize: Config.fontSize
                        font.family: Config.fontFamily
                        renderType: Text.NativeRendering
                    }
                }

                Text {
                    visible: NetworkState.ipAddress !== ""
                    text: NetworkState.ipAddress
                    color: Theme.textSecondary
                    font.pixelSize: Config.fontSizeSmall
                    font.family: Config.fontFamilyMono
                    renderType: Text.NativeRendering
                }
            }

            MenuSeparator {
                visible: NetworkState.wifiEnabled && NetworkState.wifiDevice !== null
            }

            Item {
                visible: NetworkState.wifiEnabled && NetworkState.wifiDevice !== null
                width: parent.width
                height: 210

                Component {
                    id: networkDelegate

                    NetworkItem {
                        width: parent.width
                        expandedSsid: root._expandedSsid
                        selectedSsid: root.selectedSsid
                        connectError: root.connectError

                        onExpandToggled: (ssid) => {
                            if (root._expandedSsid === ssid) {
                                root._expandedSsid = ""
                            } else {
                                root._expandedSsid = ssid
                            }
                            root.clearSelection()
                        }

                        onSelected: (ssid, network) => {
                            root.connectError = ""
                            root.selectedSsid = ssid
                            root.selectedNetwork = network
                            root._expandedSsid = ssid
                        }

                        onDeselected: root.clearSelection()

                        onConnectRequested: (network, psk) => {
                            root.connectError = ""
                            root.selectedSsid = network.name
                            root.selectedNetwork = network
                            root._expandedSsid = network.name

                            NetworkState.connect(network, psk)
                        }

                        onScrollRequested: (delegateY, delegateHeight) => {
                            var finalBottom = delegateY + delegateHeight
                            if (finalBottom > networkScroll.flickable.contentY + networkScroll.flickable.height) {
                                scrollAnim.to = Math.max(0, finalBottom - networkScroll.flickable.height)
                                scrollAnim.start()
                            }
                        }
                    }
                }

                ScrollList {
                    id: networkScroll
                    anchors.fill: parent

                    ItemSection {
                        title: "Connected"
                        model: NetworkState.connectedWifiNetworks
                        delegate: networkDelegate
                    }

                    ItemSection {
                        title: "Available"
                        model: NetworkState.availableWifiNetworks
                        delegate: networkDelegate
                    }

                    ItemSection {
                        title: "Saved"
                        model: NetworkState.savedWifiNetworks
                        delegate: networkDelegate
                    }
                }

                // Auto-scroll an expanding row into view (see onScrollRequested).
                NumberAnimation {
                    id: scrollAnim
                    target: networkScroll.flickable
                    property: "contentY"
                    duration: Config.animMedium
                    easing.type: Easing.OutCubic
                }

                Text {
                    visible: NetworkState.connectedWifiNetworks.length
                        + NetworkState.availableWifiNetworks.length
                        + NetworkState.savedWifiNetworks.length === 0
                    anchors.centerIn: parent
                    text: "No networks"
                    color: Theme.textSecondary
                    font.pixelSize: Config.fontSizeSmall
                    font.family: Config.fontFamily
                    renderType: Text.NativeRendering
                }
            }

            Text {
                visible: !NetworkState.wifiEnabled
                text: "Wi-Fi is off"
                color: Theme.textSecondary
                font.pixelSize: Config.fontSizeSmall
                font.family: Config.fontFamily
                renderType: Text.NativeRendering
            }
        }
    }

}
