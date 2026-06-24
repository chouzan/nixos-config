pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import "../../config"
import "../../services"
import "../base"

Item {
    id: root

    property bool menuVisible: false

    // Row icon matching the device type. On ALSA the node only carries a
    // generic `device.icon-name` and no `device.form-factor` (those live on the
    // parent device, which Quickshell does not expose), so `node.description`
    // is the real signal — it names the endpoint role: Headphones / Speakers /
    // Microphone / HDMI / Line / … Form-factor and `device.api` are still
    // matched for setups that do populate them (e.g. bluez5). Mirrors
    // Bluetooth.deviceIcon.
    // A Bluetooth node names its device by address, in either spelling, and
    // BlueZ already classifies that device. Asking it keeps this icon and the
    // one in the Bluetooth menu the same for one piece of hardware.
    function bluetoothIcon(node) {
        var name = "" + (node.name || "")
        if (name.indexOf("bluez") !== 0)
            return ""

        var address = name.match(/([0-9A-Fa-f]{2}[:_]){5}[0-9A-Fa-f]{2}/)
        if (!address)
            return ""

        return BluetoothState.iconForAddress(address[0].replace(/_/g, ":"))
    }

    function nodeIcon(node) {
        if (!node)
            return "speaker-hifi-duotone.svg"

        var known = root.bluetoothIcon(node)
        if (known)
            return known

        var p = node.properties || ({})
        var ff = ("" + (p["device.form-factor"] || p["node.form-factor"] || ""))
            .toLowerCase()
        var api = ("" + (p["device.api"] || "")).toLowerCase()
        var text = ("" + (node.description || "") + " " + (node.name || "")
            + " " + (p["device.icon-name"] || "")).toLowerCase()

        if (ff === "webcam" || api === "libcamera" || api === "v4l2"
            || text.indexOf("webcam") >= 0 || text.indexOf("camera") >= 0)
            return "webcam-duotone.svg"
        if (ff === "headset" || text.indexOf("headset") >= 0)
            return "headset-duotone.svg"
        if (text.indexOf("headphone") >= 0)
            return "headphones-duotone.svg"
        if (text.indexOf("hdmi") >= 0 || text.indexOf("displayport") >= 0
            || text.indexOf("display port") >= 0)
            return "monitor-duotone.svg"
        if (ff === "speaker" || text.indexOf("speaker") >= 0
            || text.indexOf("spdif") >= 0 || text.indexOf("s/pdif") >= 0
            || text.indexOf("digital") >= 0)
            return "speaker-hifi-duotone.svg"
        if (ff === "microphone" || text.indexOf("line") >= 0
            || text.indexOf("microphone") >= 0 || text.indexOf("mic") >= 0)
            return "microphone-duotone.svg"
        if (api === "bluez5" || text.indexOf("bluetooth") >= 0)
            return "bluetooth-duotone.svg"
        // Generic card / built-in / unknown.
        return node.isSink ? "desktop-tower-duotone.svg" : "microphone-duotone.svg"
    }

    readonly property string iconName: !AudioState.available ? "speaker-x-duotone.svg"
        : AudioState.muted ? "speaker-slash-duotone.svg"
        : AudioState.volume <= 0 ? "speaker-none-duotone.svg"
        : AudioState.volume <= 0.5 ? "speaker-low-duotone.svg"
        : "speaker-high-duotone.svg"

    property int pillHeight: 26

    implicitWidth: audioRow.implicitWidth
    implicitHeight: parent ? parent.height : 30

    HoverPill {
        active: hover.containsMouse || root.menuVisible
        pillHeight: root.pillHeight
    }

    RowLayout {
        id: audioRow
        anchors.centerIn: parent
        spacing: 4

        SvgIcon {
            icon: root.iconName
            color: AudioState.available ? Theme.textPrimary : Theme.error
            size: Config.iconSize
        }

        Text {
            text: Math.round(AudioState.volume * 100) + "%"
            color: Theme.textPrimary
            font.pixelSize: Config.fontSizeSmall
            font.family: Config.fontFamilyMono
            renderType: Text.NativeRendering
        }
    }

    HoverTrigger {
        id: hover
        suppressed: root.menuVisible
        acceptedButtons: Qt.LeftButton | Qt.MiddleButton
        cursorShape: Qt.PointingHandCursor

        onClicked: (mouse) => {
            if (mouse.button === Qt.LeftButton)
                root.menuVisible = !root.menuVisible
            else if (mouse.button === Qt.MiddleButton)
                AudioState.toggleMute()
        }

        onWheel: (event) => {
            AudioState.stepVolume(event.angleDelta.y > 0 ? 0.05 : -0.05)
        }
    }

    InfoPopup {
        target: root
        title: "Audio"
        open: hover.infoVisible
        suppressed: root.menuVisible

        Row {
            spacing: 8

            SvgIcon {
                icon: root.iconName
                color: AudioState.available ? Theme.textPrimary : Theme.error
                size: Config.fontSize
                anchors.verticalCenter: parent.verticalCenter
            }

            Text {
                text: AudioState.sinkName || "Unknown"
                color: AudioState.sinkName ? Theme.textPrimary : Theme.textSecondary
                font.pixelSize: Config.fontSize
                font.family: Config.fontFamily
                renderType: Text.NativeRendering
            }
        }

        Row {
            spacing: 8

            SvgIcon {
                icon: AudioState.sourceMuted ? "microphone-slash-duotone.svg"
                    : "microphone-duotone.svg"
                color: Theme.textPrimary
                size: Config.fontSize
                anchors.verticalCenter: parent.verticalCenter
            }

            Text {
                text: AudioState.sourceName || "Unknown"
                color: AudioState.sourceName ? Theme.textPrimary : Theme.textSecondary
                font.pixelSize: Config.fontSize
                font.family: Config.fontFamily
                renderType: Text.NativeRendering
            }
        }
    }

    // ---- Click Menu ----

    MenuPopup {
        target: root
        name: "audio"
        open: root.menuVisible
        onDismissed: root.menuVisible = false

        PopupMenu {
            title: "Audio"

            headerContent: ToggleSwitch {
                enabled: AudioState.available
                checked: AudioState.available && !AudioState.muted
                onToggled: AudioState.toggleMute()
            }

            MenuSeparator {}

            SectionHeader { text: "Output" }

            Column {
                width: parent.width
                spacing: 2

                Repeater {
                    model: AudioState.sinks

                    ListItem {
                        required property var modelData
                        readonly property bool isCurrent: AudioState.sink && modelData.id === AudioState.sink.id
                        width: parent.width
                        icon: root.nodeIcon(modelData)
                        label: modelData.description || modelData.nickname || modelData.name
                        highlighted: isCurrent
                        iconColor: isCurrent ? Theme.textBright : Theme.textPrimary
                        onClicked: AudioState.setDefaultSink(modelData)
                    }
                }
            }

            SectionHeader { text: "Input" }

            Column {
                width: parent.width
                spacing: 2

                Repeater {
                    model: AudioState.sources

                    ListItem {
                        required property var modelData
                        readonly property bool isCurrent: AudioState.source && modelData.id === AudioState.source.id
                        width: parent.width
                        icon: root.nodeIcon(modelData)
                        label: modelData.description || modelData.nickname || modelData.name
                        highlighted: isCurrent
                        iconColor: isCurrent ? Theme.textBright : Theme.textPrimary
                        onClicked: AudioState.setDefaultSource(modelData)
                    }
                }
            }
        }
    }
}
