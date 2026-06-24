pragma ComponentBehavior: Bound

import Quickshell
import QtQuick
import "../../config"
import "../../services"
import "../base"

Item {
    id: root

    property color iconColor: Theme.textPrimary
    property bool menuVisible: false

    property int pillHeight: 26

    implicitWidth: Config.iconSize
    implicitHeight: parent ? parent.height : 30

    // Hold a centre reference while this monitor's menu is open, so toasts stay
    // suppressed for as long as any monitor is showing the history.
    property bool _holdsCentre: false

    function _syncCentre() {
        if (root.menuVisible && !root._holdsCentre) {
            Notifications.acquireCentre();
            root._holdsCentre = true;
        } else if (!root.menuVisible && root._holdsCentre) {
            Notifications.releaseCentre();
            root._holdsCentre = false;
        }
    }

    onMenuVisibleChanged: {
        if (menuVisible)
            Notifications.markAllRead();
        root._syncCentre();
    }

    Component.onDestruction: if (root._holdsCentre)
        Notifications.releaseCentre()

    HoverPill {
        active: hover.containsMouse || root.menuVisible
        pillHeight: root.pillHeight
    }

    SvgIcon {
        id: bellIcon
        anchors.centerIn: parent
        // One glyph family carries the whole state: silenced, ringing while
        // something is unread, and idle once it has been read.
        icon: Notifications.dnd ? "bell-slash-duotone.svg" : Notifications.unreadCount > 0 ? "bell-ringing-duotone.svg" : "bell-duotone.svg"
        color: root.iconColor
        size: Config.iconSize
    }

    HoverTrigger {
        id: hover
        suppressed: root.menuVisible
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton
        onClicked: root.menuVisible = !root.menuVisible
    }

    InfoPopup {
        target: root
        title: "Notifications"
        open: hover.infoVisible
        suppressed: root.menuVisible
    }

    MenuPopup {
        target: root
        name: "notification"
        open: root.menuVisible
        onDismissed: root.menuVisible = false

        // Ticks once a minute so the cards' relative times stay current.
        SystemClock {
            id: nowClock
            precision: SystemClock.Minutes
        }

        PopupMenu {
            title: "Notifications"
            contentWidth: 320

            headerContent: Row {
                spacing: 10

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    visible: Notifications.visibleHistory.length > 0
                    text: "Clear"
                    color: clearMouse.containsMouse
                        ? Theme.textBright : Theme.textSecondary
                    font.pixelSize: Config.fontSizeSmall
                    font.family: Config.fontFamily
                    renderType: Text.NativeRendering

                    MouseArea {
                        id: clearMouse
                        anchors.fill: parent
                        anchors.margins: -4
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Notifications.clearHistory()
                    }
                }

                ToggleSwitch {
                    anchors.verticalCenter: parent.verticalCenter
                    // Switch reads as "notifications on"; DND is the inverse.
                    checked: !Notifications.dnd
                    onToggled: Notifications.toggleDnd()
                }
            }

            MenuSeparator {}

            Item {
                width: parent.width
                height: 340

                ScrollListView {
                    id: historyList
                    anchors.fill: parent
                    model: Notifications.visibleHistoryModel

                    delegate: NotificationCard {
                        required property var model
                        width: historyList.width
                        entry: model
                        now: nowClock.date.getTime()
                    }
                }

                Text {
                    visible: Notifications.visibleHistory.length === 0
                    anchors.centerIn: parent
                    text: "No notifications"
                    color: Theme.textSecondary
                    font.pixelSize: Config.fontSizeSmall
                    font.family: Config.fontFamily
                    renderType: Text.NativeRendering
                }
            }
        }
    }
}
