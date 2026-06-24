pragma ComponentBehavior: Bound

import Quickshell.Wayland
import QtQuick
import "../../config"
import "../../services"
import "../base"

// Per-monitor view over the shared PrayerTimeState singleton.
Item {
    id: root

    property bool compact: false

    implicitHeight: parent ? parent.height : 30

    readonly property bool hovered: hover.containsMouse

    // ---- Colors (driven by shared PrayerTimeState) ----

    readonly property color iconColor: PrayerTimeState.adhanActive ? Theme.error : PrayerTimeState.adhanApproaching ? Theme.warning : Theme.textPrimary
    readonly property color currentNameColor: PrayerTimeState.adhanActive ? Theme.error : Theme.textPrimary
    readonly property color currentDurColor: PrayerTimeState.adhanActive ? Theme.error : Theme.textPrimary
    readonly property color nextNameColor: PrayerTimeState.adhanApproaching ? Theme.warning : Theme.textPrimary
    readonly property color nextDurColor: PrayerTimeState.adhanApproaching ? Theme.warning : Theme.textPrimary

    // ---- Display ----

    readonly property font nameFont: Config.tnumFont(Config.fontSize)

    readonly property font durFont: Config.tnumFont(Config.fontSize, 1)

    readonly property font signFont: Qt.font({
        family: Config.fontFamily,
        pixelSize: Config.fontSize
    })

    function formatDuration(totalSec, ceil) {
        var s = Math.abs(totalSec)
        var totalMin = ceil ? Math.ceil(s / 60) : Math.floor(s / 60)
        var h = Math.floor(totalMin / 60)
        var m = totalMin % 60
        return (h < 10 ? "0" : "") + h + ":" + (m < 10 ? "0" : "") + m
    }

    // Prayer-time Date → "HH:mm"; blank until the schedule is computed.
    function formatTime(t) {
        if (!t || isNaN(t.getTime())) return ""
        return Qt.formatDateTime(t, "HH:mm")
    }

    // The pill reserves the widest pair the schedule can actually show, not the
    // widest name twice: the names always arrive as (current, next) from a
    // fixed cycle, so pairs like Maghrib + Maghrib never occur and reserving
    // for them leaves dead space. Measured, since the widest pair depends on
    // the font, not on string length.
    // Keep these keys in step with PrayerTimeState.prayerOrder: widestPair looks
    // each name up here, and a missing one makes the sum NaN, which silently
    // collapses the reservation rather than failing. Declared one by one
    // because a set generated from the order cannot be typed for static
    // checking.
    readonly property var nameWidths: ({
            "Fajr": fajrMetrics.width,
            "Sunrise": sunriseMetrics.width,
            "Dhuhr": dhuhrMetrics.width,
            "Asr": asrMetrics.width,
            "Maghrib": maghribMetrics.width,
            "Isha": ishaMetrics.width
        })

    readonly property int widestPair: {
        var order = PrayerTimeState.prayerOrder;
        var widest = 0;
        for (var i = 0; i < order.length; i++) {
            var pair = root.nameWidths[order[i]] + root.nameWidths[order[(i + 1) % order.length]];
            if (pair > widest)
                widest = pair;
        }
        return widest;
    }

    // Swap the names on screen for that reserved pair, leaving every other part
    // of the row measured as it stands.
    implicitWidth: prayerRow.implicitWidth - currentNameMetrics.width - nextNameMetrics.width + root.widestPair

    TextMetrics {
        id: currentNameMetrics
        font: root.nameFont
        text: PrayerTimeState.currentPrayer
    }

    TextMetrics {
        id: nextNameMetrics
        font: root.nameFont
        text: PrayerTimeState.nextPrayer
    }

    TextMetrics {
        id: fajrMetrics
        font: root.nameFont
        text: "Fajr"
    }

    TextMetrics {
        id: sunriseMetrics
        font: root.nameFont
        text: "Sunrise"
    }

    TextMetrics {
        id: dhuhrMetrics
        font: root.nameFont
        text: "Dhuhr"
    }

    TextMetrics {
        id: asrMetrics
        font: root.nameFont
        text: "Asr"
    }

    TextMetrics {
        id: maghribMetrics
        font: root.nameFont
        text: "Maghrib"
    }

    TextMetrics {
        id: ishaMetrics
        font: root.nameFont
        text: "Isha"
    }

    TextMetrics {
        id: durMetrics
        font: root.durFont
        text: "00:00"
    }

    TextMetrics {
        id: signMetrics
        font: root.signFont
        text: "+"
    }

    Row {
        id: prayerRow
        anchors.centerIn: parent
        spacing: 10

        SvgIcon {
            visible: !root.compact
            anchors.verticalCenter: parent.verticalCenter
            icon: "mosque-duotone.svg"
            color: root.iconColor
            size: Config.iconSize
        }

        Row {
            anchors.verticalCenter: parent.verticalCenter
            spacing: 10

            Text {
                text: PrayerTimeState.currentPrayer
                color: root.currentNameColor
                font: root.nameFont
                renderType: Text.NativeRendering
            }

            Item {
                width: signMetrics.width + durMetrics.width
                height: elapsedText.implicitHeight

                Text {
                    anchors.right: elapsedText.left
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.verticalCenterOffset: -1
                    text: "+"
                    color: root.currentDurColor
                    font: root.signFont
                    renderType: Text.NativeRendering
                    opacity: root.hovered ? 0 : 1
                    Behavior on opacity { NumberAnimation { duration: Config.animShort } }
                }

                Text {
                    id: elapsedText
                    anchors.right: parent.right
                    text: root.hovered ? root.formatTime(PrayerTimeState.currentTime) : root.formatDuration(PrayerTimeState.elapsedSec)
                    color: root.currentDurColor
                    font: root.durFont
                    renderType: Text.NativeRendering
                }
            }
        }

        Rectangle {
            anchors.verticalCenter: parent.verticalCenter
            width: 3.7
            height: 3.7
            radius: 1.85
            color: Theme.textPrimary
        }

        Row {
            anchors.verticalCenter: parent.verticalCenter
            spacing: 10

            Text {
                text: PrayerTimeState.nextPrayer
                color: root.nextNameColor
                font: root.nameFont
                renderType: Text.NativeRendering
            }

            Item {
                width: signMetrics.width + durMetrics.width
                height: countdownText.implicitHeight

                Text {
                    anchors.right: countdownText.left
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.verticalCenterOffset: -1
                    text: "-"
                    color: root.nextDurColor
                    font: root.signFont
                    renderType: Text.NativeRendering
                    opacity: root.hovered ? 0 : 1
                    Behavior on opacity { NumberAnimation { duration: Config.animShort } }
                }

                Text {
                    id: countdownText
                    anchors.right: parent.right
                    text: root.hovered ? root.formatTime(PrayerTimeState.nextTime) : root.formatDuration(PrayerTimeState.countdownSec, true)
                    color: root.nextDurColor
                    font: root.durFont
                    renderType: Text.NativeRendering
                }
            }
        }
    }

    HoverTrigger { id: hover }

    // ---- Popup ----

    property bool popupVisible: hover.infoVisible || popupWindow.hovered

    AnchoredPanel {
        id: popupWindow
        visible: root.popupVisible
        target: root

        anchors.top: true

        // PanelWindow's grouped margins lack complete tooling metadata.
        // qmllint disable unqualified unresolved-type
        margins.top: Config.barHeight + Config.popupGap - popupWindow.pad
        // qmllint enable unqualified unresolved-type

        WlrLayershell.namespace: "quickshell:prayer-popup"

        Rectangle {
            id: popupContent
            width: popupColumn.width + 2 * Config.barRadius
            height: popupColumn.height + 24
            color: Theme.background
            radius: Config.popupRadius

            Column {
                id: popupColumn
                anchors.centerIn: parent
                spacing: 4

                Text {
                    text: "Prayer Times"
                    color: Theme.textSecondary
                    font.pixelSize: Config.fontSize
                    font.family: Config.fontFamily
                    renderType: Text.NativeRendering
                }

                Item { width: 1; height: 2 }

                Repeater {
                    model: PrayerTimeState.prayerOrder.length

                    Item {
                        id: rowItem
                        required property int index
                        readonly property string name: PrayerTimeState.prayerOrder[index]
                        readonly property bool isCurrent: index === PrayerTimeState.currentIndex
                        readonly property bool isPast: PrayerTimeState.currentIndex >= 0 && index < PrayerTimeState.currentIndex && !isNext
                        readonly property bool isNext: index === PrayerTimeState.currentIndex + 1
                            || (PrayerTimeState.currentIndex === PrayerTimeState.prayerOrder.length - 1 && index === 0)

                        readonly property color rowColor: {
                            if (isCurrent && PrayerTimeState.adhanActive) return Theme.error
                            if (isCurrent) return Theme.textPrimary
                            if (isNext && PrayerTimeState.adhanApproaching) return Theme.warning
                            if (isPast) return Theme.textSecondary
                            return Theme.textPrimary
                        }

                        width: popupRow.width
                        height: popupRow.height + (isCurrent ? progressBar.height + 6 : 0)

                        Row {
                            id: popupRow
                            spacing: 12

                            SvgIcon {
                                icon: rowItem.isCurrent ? "caret-right-duotone.svg"
                                    : rowItem.isPast ? "check-duotone.svg" : ""
                                color: rowItem.rowColor
                                size: Config.fontSize
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Text {
                                width: nameMetrics.width
                                text: rowItem.name
                                color: rowItem.rowColor
                                font.pixelSize: Config.fontSize
                                font.family: Config.fontFamily
                                renderType: Text.NativeRendering
                            }

                            Text {
                                text: root.formatTime(PrayerTimeState.prayerTimes[rowItem.index])
                                color: rowItem.rowColor
                                font: Config.tnumFont(Config.fontSize)
                                renderType: Text.NativeRendering
                            }
                        }

                        ProgressBar {
                            id: progressBar
                            visible: rowItem.isCurrent
                            anchors.top: popupRow.bottom
                            anchors.topMargin: 4
                            anchors.left: popupRow.left
                            anchors.leftMargin: 26
                            width: popupRow.width - 26
                            value: PrayerTimeState.periodProgress
                            fillColor: rowItem.rowColor
                            animated: true
                        }
                    }
                }
            }

            TextMetrics {
                id: nameMetrics
                font.pixelSize: Config.fontSize
                font.family: Config.fontFamily
                text: "Maghrib"
            }
        }

    }
}
