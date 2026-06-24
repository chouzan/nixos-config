import Quickshell
import QtQuick
import "../../config"
import "../base"

Item {
    id: root

    property bool compact: false
    property bool menuVisible: false
    // A fullscreen window covers the bar — stop the per-second tick while hidden.
    property bool occluded: false

    onMenuVisibleChanged: {
        if (menuVisible) calendar.goToday()
    }

    // The time is tabular, so ticking digits never move it. Only the day name
    // varies, so reserve the widest one in place of the date on screen and
    // measure everything else as it stands.
    readonly property int dateReserve: Math.max(monMetrics.width, tueMetrics.width, wedMetrics.width, thuMetrics.width, friMetrics.width, satMetrics.width, sunMetrics.width)

    implicitWidth: clockRow.implicitWidth - dateMetrics.width + root.dateReserve
    implicitHeight: parent ? parent.height : 30

    // Every day name, so the reservation holds whatever font is themed in
    // rather than depending on which days happen to be widest in this one.
    // Declared one by one because a set generated from a list cannot be typed
    // for static checking.
    TextMetrics {
        id: monMetrics
        font: root.clockFont
        text: root.compact ? "Mon, 00-00" : "Mon, 0000-00-00"
    }

    TextMetrics {
        id: tueMetrics
        font: root.clockFont
        text: root.compact ? "Tue, 00-00" : "Tue, 0000-00-00"
    }

    TextMetrics {
        id: wedMetrics
        font: root.clockFont
        text: root.compact ? "Wed, 00-00" : "Wed, 0000-00-00"
    }

    TextMetrics {
        id: thuMetrics
        font: root.clockFont
        text: root.compact ? "Thu, 00-00" : "Thu, 0000-00-00"
    }

    TextMetrics {
        id: friMetrics
        font: root.clockFont
        text: root.compact ? "Fri, 00-00" : "Fri, 0000-00-00"
    }

    TextMetrics {
        id: satMetrics
        font: root.clockFont
        text: root.compact ? "Sat, 00-00" : "Sat, 0000-00-00"
    }

    TextMetrics {
        id: sunMetrics
        font: root.clockFont
        text: root.compact ? "Sun, 00-00" : "Sun, 0000-00-00"
    }

    TextMetrics {
        id: dateMetrics
        font: root.clockFont
        text: dateText.text
    }

    readonly property font clockFont: Config.tnumFont(Config.fontSize)

    readonly property font timeFont: Config.tnumFont(Config.fontSize, 1)

    HoverPill {
        active: hover.containsMouse || root.menuVisible
    }

    Row {
        id: clockRow
        anchors.centerIn: parent
        spacing: 10

        SvgIcon {
            visible: !root.compact
            anchors.verticalCenter: parent.verticalCenter
            icon: "clock-duotone.svg"
            color: Theme.textPrimary
            size: Config.iconSize
        }

        Text {
            id: timeText
            anchors.verticalCenter: parent.verticalCenter
            text: Qt.formatDateTime(clock.date, "HH:mm:ss")
            color: Theme.textPrimary
            font: root.timeFont
            renderType: Text.NativeRendering
        }

        Rectangle {
            id: dot
            anchors.verticalCenter: parent.verticalCenter
            width: 3.7
            height: 3.7
            radius: 1.85
            color: Theme.textPrimary
        }

        Text {
            id: dateText
            anchors.verticalCenter: parent.verticalCenter
            text: Qt.formatDateTime(clock.date, root.compact ? "ddd, MM-dd" : "ddd, yyyy-MM-dd")
            color: Theme.textPrimary
            font: root.clockFont
            renderType: Text.NativeRendering
        }
    }

    HoverTrigger {
        id: hover
        suppressed: root.menuVisible
        acceptedButtons: Qt.LeftButton
        cursorShape: Qt.PointingHandCursor
        onClicked: root.menuVisible = !root.menuVisible
    }

    InfoPopup {
        target: root
        title: "Clock"
        open: hover.infoVisible
        suppressed: root.menuVisible
    }

    MenuPopup {
        target: root
        name: "clock"
        open: root.menuVisible
        onDismissed: root.menuVisible = false

        Calendar { id: calendar }
    }

    SystemClock {
        id: clock
        precision: SystemClock.Seconds
        enabled: !root.occluded
    }
}
