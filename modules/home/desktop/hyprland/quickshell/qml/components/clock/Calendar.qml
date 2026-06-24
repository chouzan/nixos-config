pragma ComponentBehavior: Bound

import Quickshell
import QtQuick
import "../../config"
import "../base"

// Month calendar card for the Clock popup. Drill-up navigation
// (days -> months -> years) covers month change, year change, and
// jump-to-date in one mechanism. ISO week numbers down the left (Monday
// week-start). Renders event markers from a generic `events` model that
// stays empty until a provider (gcalcli/khal/CalDAV) fills it later.
Rectangle {
    id: root

    // 0 = days, 1 = months, 2 = years
    property int viewMode: 0
    property date displayed: new Date()
    property date selected: new Date()
    property var events: []

    readonly property date today: sys.date

    readonly property int dayCellW: 34
    readonly property int dayCellH: 30
    readonly property int weekColW: 24
    readonly property int bodyWidth: weekColW + 7 * dayCellW

    readonly property var weekdayLabels: ["Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"]

    // Tabular figures so the year in the header keeps a fixed width.
    readonly property font titleFont: Config.tnumFont(Config.fontSize)

    color: Theme.background
    radius: Config.popupRadius
    implicitWidth: content.implicitWidth + 24
    implicitHeight: content.implicitHeight + 24

    SystemClock {
        id: sys
        precision: SystemClock.Hours
    }

    // Wheel over the card steps the current period (month / year / decade).
    WheelHandler {
        onWheel: (event) => root.step(event.angleDelta.y > 0 ? -1 : 1)
    }

    // ---- Date helpers ----

    function sameDate(a, b) {
        return a.getFullYear() === b.getFullYear()
            && a.getMonth() === b.getMonth()
            && a.getDate() === b.getDate()
    }

    function decadeStart(y) {
        return y - (y % 10)
    }

    // ISO 8601 week number (Thursday-based).
    function isoWeek(d) {
        var date = new Date(Date.UTC(d.getFullYear(), d.getMonth(), d.getDate()))
        var dayNum = (date.getUTCDay() + 6) % 7
        date.setUTCDate(date.getUTCDate() - dayNum + 3)
        var firstThursday = new Date(Date.UTC(date.getUTCFullYear(), 0, 4))
        var firstDayNum = (firstThursday.getUTCDay() + 6) % 7
        firstThursday.setUTCDate(firstThursday.getUTCDate() - firstDayNum + 3)
        return 1 + Math.round((date.getTime() - firstThursday.getTime()) / (7 * 864e5))
    }

    // Six Monday-start rows for the displayed month, each with its ISO week
    // number and 7 day cells (leading/trailing days flagged muted).
    readonly property var weeks: {
        var y = root.displayed.getFullYear()
        var m = root.displayed.getMonth()
        var firstWeekday = (new Date(y, m, 1).getDay() + 6) % 7
        var start = new Date(y, m, 1 - firstWeekday)
        var rows = []
        for (var w = 0; w < 6; w++) {
            var days = []
            var monday = null
            for (var d = 0; d < 7; d++) {
                var cur = new Date(start.getFullYear(), start.getMonth(),
                    start.getDate() + w * 7 + d)
                if (d === 0) monday = cur
                days.push({
                    day: cur.getDate(),
                    date: cur,
                    muted: cur.getMonth() !== m,
                    isToday: root.sameDate(cur, root.today),
                    isSelected: root.sameDate(cur, root.selected),
                })
            }
            rows.push({ week: root.isoWeek(monday), days: days })
        }
        return rows
    }

    readonly property string headerTitle: {
        if (root.viewMode === 0) return Qt.formatDate(root.displayed, "MMMM yyyy")
        if (root.viewMode === 1) return Qt.formatDate(root.displayed, "yyyy")
        var ds = root.decadeStart(root.displayed.getFullYear())
        return ds + " – " + (ds + 9)
    }

    // ---- Navigation ----

    function step(dir) {
        var y = root.displayed.getFullYear()
        var m = root.displayed.getMonth()
        if (root.viewMode === 0) root.displayed = new Date(y, m + dir, 1)
        else if (root.viewMode === 1) root.displayed = new Date(y + dir, m, 1)
        else root.displayed = new Date(y + dir * 10, m, 1)
    }

    function zoomOut() {
        if (root.viewMode < 2) root.viewMode += 1
    }

    function goToday() {
        root.displayed = root.today
        root.selected = root.today
        root.viewMode = 0
    }

    function selectDay(d) {
        root.selected = d
        if (d.getMonth() !== root.displayed.getMonth()
            || d.getFullYear() !== root.displayed.getFullYear())
            root.displayed = new Date(d.getFullYear(), d.getMonth(), 1)
    }

    function pickMonth(m) {
        root.displayed = new Date(root.displayed.getFullYear(), m, 1)
        root.viewMode = 0
    }

    function pickYear(y) {
        root.displayed = new Date(y, root.displayed.getMonth(), 1)
        root.viewMode = 1
    }

    Column {
        id: content
        anchors.centerIn: parent
        width: root.bodyWidth
        spacing: 8

        // ---- Header: title (zoom out) + Today + prev/next ----

        Item {
            width: parent.width
            height: 28

            Text {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                text: root.headerTitle
                color: Theme.textPrimary
                font: root.titleFont
                renderType: Text.NativeRendering

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.zoomOut()
                }
            }

            Row {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                spacing: 8

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "Today"
                    color: todayMouse.containsMouse ? Theme.textBright : Theme.textSecondary
                    font.pixelSize: Config.fontSizeSmall
                    font.family: Config.fontFamily
                    renderType: Text.NativeRendering

                    MouseArea {
                        id: todayMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.goToday()
                    }
                }

                Item {
                    width: 22
                    height: 22
                    anchors.verticalCenter: parent.verticalCenter

                    SvgIcon {
                        anchors.centerIn: parent
                        icon: "caret-left-duotone.svg"
                        size: Config.fontSize
                        color: prevMouse.containsMouse ? Theme.textBright : Theme.textSecondary
                    }

                    MouseArea {
                        id: prevMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.step(-1)
                    }
                }

                Item {
                    width: 22
                    height: 22
                    anchors.verticalCenter: parent.verticalCenter

                    SvgIcon {
                        anchors.centerIn: parent
                        icon: "caret-right-duotone.svg"
                        size: Config.fontSize
                        color: nextMouse.containsMouse ? Theme.textBright : Theme.textSecondary
                    }

                    MouseArea {
                        id: nextMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.step(1)
                    }
                }
            }
        }

        // ---- Days view ----

        Column {
            visible: root.viewMode === 0
            spacing: 0

            Row {
                spacing: 0

                Item {
                    width: root.weekColW
                    height: 22
                }

                Repeater {
                    model: root.weekdayLabels

                    Text {
                        required property string modelData
                        width: root.dayCellW
                        height: 22
                        text: modelData
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        color: Theme.textSecondary
                        font.pixelSize: Config.fontSizeSmall
                        font.family: Config.fontFamily
                        renderType: Text.NativeRendering
                    }
                }
            }

            Repeater {
                model: root.weeks

                Row {
                    required property var modelData
                    spacing: 0

                    Text {
                        width: root.weekColW
                        height: root.dayCellH
                        text: parent.modelData.week
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        color: Theme.textSecondary
                        opacity: 0.6
                        font.pixelSize: Config.fontSizeSmall
                        font.family: Config.fontFamilyMono
                        renderType: Text.NativeRendering
                    }

                    Repeater {
                        model: parent.modelData.days

                        CalendarCell {
                            required property var modelData
                            width: root.dayCellW
                            height: root.dayCellH
                            label: modelData.day
                            muted: modelData.muted
                            today: modelData.isToday
                            selected: modelData.isSelected
                            onClicked: root.selectDay(modelData.date)
                        }
                    }
                }
            }
        }

        // ---- Months view ----

        Grid {
            visible: root.viewMode === 1
            columns: 3

            Repeater {
                model: 12

                CalendarCell {
                    required property int index
                    width: root.bodyWidth / 3
                    height: 45
                    label: Qt.formatDate(new Date(2000, index, 1), "MMM")
                    today: index === root.today.getMonth()
                        && root.displayed.getFullYear() === root.today.getFullYear()
                    selected: index === root.displayed.getMonth()
                    onClicked: root.pickMonth(index)
                }
            }
        }

        // ---- Years view (decade, first/last muted) ----

        Grid {
            visible: root.viewMode === 2
            columns: 3

            Repeater {
                model: 12

                CalendarCell {
                    required property int index
                    readonly property int yr: root.decadeStart(root.displayed.getFullYear()) - 1 + index
                    width: root.bodyWidth / 3
                    height: 45
                    label: yr
                    muted: index === 0 || index === 11
                    today: yr === root.today.getFullYear()
                    selected: yr === root.displayed.getFullYear()
                    onClicked: root.pickYear(yr)
                }
            }
        }
    }
}
