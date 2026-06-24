import QtQuick
import "../../config"
import "../../services"
import "../base"

// One entry in the notification history: app + summary + body + relative time,
// with a pin (survives "Clear") and a remove affordance. Display-only — once a
// notification has left the toast its live actions are gone, so history does
// not re-invoke them. Acts on the Notifications singleton by entry id.
Rectangle {
    id: root

    required property var entry
    property double now: Date.now()

    implicitHeight: layout.implicitHeight + 2 * Config.groupPadding
    radius: Config.popupRadius
    color: cardMouse.containsMouse ? Theme.surfaceHover : Theme.surface

    Behavior on color { ColorAnimation { duration: Config.animShort } }

    // Coarse "time ago" label; refreshed by the caller ticking `now`.
    function relTime(ms, nowMs) {
        var s = Math.floor(Math.max(0, nowMs - ms) / 1000)
        if (s < 60) return "now"
        var m = Math.floor(s / 60)
        if (m < 60) return m + "m"
        var h = Math.floor(m / 60)
        if (h < 24) return h + "h"
        var d = Math.floor(h / 24)
        if (d < 7) return d + "d"
        return Math.floor(d / 7) + "w"
    }

    MouseArea {
        id: cardMouse
        anchors.fill: parent
        hoverEnabled: true
    }

    Column {
        id: layout
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            margins: Config.groupPadding
        }
        spacing: 3

        Item {
            width: parent.width
            height: 16

            Row {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                spacing: 6

                SvgIcon {
                    icon: root.entry.icon
                        ? root.entry.icon
                        : root.entry.isCritical
                            ? "bell-ringing-duotone.svg"
                            : "bell-duotone.svg"
                    size: 14
                    color: root.entry.isCritical ? Theme.error : Theme.textSecondary
                    anchors.verticalCenter: parent.verticalCenter
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: root.entry.appName
                    color: Theme.textSecondary
                    font.pixelSize: Config.fontSizeBase + 2
                    font.family: Config.fontFamily
                    renderType: Text.NativeRendering
                }
            }

            Row {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                spacing: 8

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: root.relTime(root.entry.time, root.now)
                    color: Theme.textSecondary
                    font.pixelSize: Config.fontSizeBase + 1
                    font.family: Config.fontFamily
                    renderType: Text.NativeRendering
                }

                SvgIcon {
                    id: pinIcon
                    anchors.verticalCenter: parent.verticalCenter
                    icon: "push-pin-duotone.svg"
                    size: 14
                    color: root.entry.pinned ? Theme.primary : Theme.textSecondary
                    opacity: root.entry.pinned || cardMouse.containsMouse
                        || pinMouse.containsMouse ? 1 : 0.35

                    MouseArea {
                        id: pinMouse
                        anchors.fill: parent
                        anchors.margins: -3
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Notifications.togglePin(root.entry.hid)
                    }
                }

                SvgIcon {
                    id: removeIcon
                    anchors.verticalCenter: parent.verticalCenter
                    icon: "x-duotone.svg"
                    size: 14
                    color: Theme.textSecondary
                    opacity: cardMouse.containsMouse || removeMouse.containsMouse
                        ? 1 : 0.35

                    MouseArea {
                        id: removeMouse
                        anchors.fill: parent
                        anchors.margins: -3
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Notifications.removeHistory(root.entry.hid)
                    }
                }
            }
        }

        Text {
            width: parent.width
            text: root.entry.summary
            color: Theme.textPrimary
            font.pixelSize: Config.fontSizeSmall
            font.family: Config.fontFamily
            font.bold: true
            wrapMode: Text.WordWrap
            maximumLineCount: 2
            elide: Text.ElideRight
            renderType: Text.NativeRendering
        }

        Text {
            width: parent.width
            visible: root.entry.body !== ""
            text: root.entry.body
            color: Theme.textSecondary
            font.pixelSize: Config.fontSizeBase + 2
            font.family: Config.fontFamily
            wrapMode: Text.WordWrap
            maximumLineCount: 3
            elide: Text.ElideRight
            renderType: Text.NativeRendering
        }
    }
}
