import QtQuick
import QtQuick.Layouts
import Quickshell
import "../../config"
import "../../services"
import "../audio"
import "../battery"
import "../bluetooth"
import "../clock"
import "../idle"
import "../media"
import "../network"
import "../notifications"
import "../power"
import "../prayer"
import "../system"
import "../tray"
import "../window"
import "../workspaces"

Item {
    id: content

    required property ShellScreen screen
    readonly property bool compact: width < 2500

    // A real-fullscreen window covers this monitor's bar (Hyprland mode 2 /
    // `fullscreen 0`); a maximized window (mode 1 / `fullscreen 1`) respects the
    // reserved area and leaves the bar visible. wlr-foreign-toplevel reports the
    // two as distinct states (`fullscreen` vs `maximized`), and `screens` is the
    // set the window is *currently visible on* — so this stays per-monitor and
    // workspace-aware (a fullscreen window on a hidden workspace doesn't count).
    //
    // Widgets doing continuous display-only work (gauge poll, per-second clock)
    // pause while occluded; background duties (prayer-time notifications, history
    // pruning) keep going.
    readonly property bool occluded: CompositorState.isOccluded(content.screen)

    // Left section
    BarGroup {
        id: leftGroup

        anchors {
            top: parent.top
            bottom: parent.bottom
            left: parent.left
        }

        ActiveWindow {
            id: activeWindow
            Layout.fillHeight: true
        }
    }

    // Clock, media and prayer share one pill width so the bar keeps a steady
    // rhythm: the widest content sets it and the others match. Each reserves a
    // stable width of its own, so this settles rather than tracking live text.
    readonly property int sharedPillWidth: Math.max(clock.implicitWidth, media.implicitWidth, prayer.implicitWidth) + 2 * Config.barRadius

    // Workspace anchored to screen center
    BarGroup {
        id: workspaceGroup

        anchors {
            top: parent.top
            bottom: parent.bottom
            horizontalCenter: parent.horizontalCenter
        }

        Workspaces {
            screen: content.screen
            Layout.fillHeight: true
        }
    }

    // Clock — left flank of workspace, pinned to the center edge
    BarGroup {
        id: clockGroup
        fixedWidth: content.sharedPillWidth
        leftPadding: Config.barRadius
        rightPadding: Config.barRadius

        anchors {
            top: parent.top
            bottom: parent.bottom
            right: workspaceGroup.left
            rightMargin: Config.groupSpacing
        }

        Clock {
            id: clock
            compact: content.compact
            occluded: content.occluded
            Layout.fillHeight: true
            // Fill the shared pill so the row centres in it rather than
            // sitting at the start with the slack piled on one side.
            Layout.fillWidth: true
        }
    }

    // Media — left of clock; grows outward so clock stays put
    BarGroup {
        id: mediaGroup
        fixedWidth: MediaState.hasContent ? content.sharedPillWidth : 0

        anchors {
            top: parent.top
            bottom: parent.bottom
            right: clockGroup.left
            rightMargin: Config.groupSpacing
        }

        Media {
            id: media
            occluded: content.occluded
            pillAnimDuration: mediaGroup.animDuration
            Layout.fillHeight: true
            Layout.fillWidth: true
        }
    }

    // Prayer — right flank of workspace
    BarGroup {
        id: prayerGroup
        fixedWidth: content.sharedPillWidth
        leftPadding: Config.barRadius
        rightPadding: Config.barRadius

        anchors {
            top: parent.top
            bottom: parent.bottom
            left: workspaceGroup.right
            leftMargin: Config.groupSpacing
        }

        PrayerTimeView {
            id: prayer
            compact: content.compact
            Layout.fillHeight: true
            Layout.fillWidth: true
        }
    }

    // Right section
    Row {
        id: rightSection

        anchors {
            top: parent.top
            bottom: parent.bottom
            right: parent.right
        }
        spacing: Config.groupSpacing

        Item {
            width: systray.implicitWidth + Config.widgetSpacing
            height: parent.height

            SystemTrayWidget {
                id: systray
                compact: content.compact
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        BarGroup {
            anchors {
                top: parent.top
                bottom: parent.bottom
            }

            SystemGauge {
                compact: content.compact
                occluded: content.occluded
                Layout.fillHeight: true
            }
        }

        BarGroup {
            anchors {
                top: parent.top
                bottom: parent.bottom
            }

            IdleInhibit {
                Layout.fillHeight: true
            }

            Audio {
                Layout.fillHeight: true
            }

            Bluetooth {
                Layout.fillHeight: true
            }

            Network {
                Layout.fillHeight: true
            }

            Battery {
                Layout.fillHeight: true
            }

            NotificationIndicator {
                Layout.fillHeight: true
            }
        }

        // Session control sits apart from the status widgets: those report and
        // adjust, this one ends what you are doing.
        BarGroup {
            anchors {
                top: parent.top
                bottom: parent.bottom
            }

            PowerMenu {
                Layout.fillHeight: true
            }
        }
    }
}
