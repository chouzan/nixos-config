pragma ComponentBehavior: Bound

import QtQuick
import "../../config"
import "../../services"
import "../base"

// Session and power actions. The menu is split by what survives the action:
// above the separator the session is still there afterwards, below it is gone.
// Confirmation is a separate concern, asked for anything expensive to trigger
// by accident, and each row asks in place rather than opening a dialog.
Item {
    id: root

    property color iconColor: Theme.textPrimary
    property int pillHeight: 26
    property bool menuVisible: false

    // Row awaiting its second click, cleared on a timeout or when the menu goes
    // away, so a half-confirmed action never lingers.
    property string pendingAction: ""

    implicitWidth: Config.iconSize
    implicitHeight: parent ? parent.height : 30

    readonly property var actions: [
        {
            id: "lock",
            label: "Lock",
            icon: "lock-duotone.svg",
            confirm: false,
            endsSession: false
        },
        {
            id: "suspend",
            label: "Suspend",
            icon: "moon-duotone.svg",
            confirm: false,
            endsSession: false
        },
        {
            // Untested on this host, and swap is smaller than RAM, so ask
            // before starting a suspend to disk. Drop the confirmation once
            // hibernation is known to work here.
            id: "hibernate",
            label: "Hibernate",
            icon: "hard-drive-duotone.svg",
            confirm: true,
            endsSession: false
        },
        {
            // uwsm owns the session, so stop it rather than killing the
            // compositor and leaving its units behind.
            id: "logout",
            label: "Log out",
            icon: "sign-out-duotone.svg",
            confirm: true,
            endsSession: true
        },
        {
            id: "reboot",
            label: "Restart",
            icon: "arrows-clockwise-duotone.svg",
            confirm: true,
            endsSession: true
        },
        {
            id: "shutdown",
            label: "Shut down",
            icon: "power-duotone.svg",
            confirm: true,
            endsSession: true
        }
    ]

    property string queuedAction: ""

    function trigger(action) {
        if (action.confirm && root.pendingAction !== action.id) {
            root.pendingAction = action.id;
            confirmTimer.restart();
            return;
        }
        root.pendingAction = "";
        confirmTimer.stop();
        root.menuVisible = false;

        // Closing the menu only asks the compositor to unmap the popup. Running
        // the action in the same breath lets a lock screen map on top of a
        // popup that is still up, which then reappears on unlock, so let the
        // unmap land first.
        root.queuedAction = action.id;
        runTimer.restart();
    }

    Timer {
        id: runTimer
        interval: Config.animShort
        onTriggered: {
            if (!root.queuedAction)
                return;
            var id = root.queuedAction;
            root.queuedAction = "";
            SessionState.perform(id);
        }
    }

    onMenuVisibleChanged: if (!root.menuVisible) {
        root.pendingAction = "";
        confirmTimer.stop();
    }

    Timer {
        id: confirmTimer
        interval: 4000
        onTriggered: root.pendingAction = ""
    }

    HoverPill {
        active: hover.containsMouse || root.menuVisible
        pillHeight: root.pillHeight
    }

    SvgIcon {
        anchors.centerIn: parent
        icon: "power-duotone.svg"
        color: root.iconColor
        size: Config.iconSize
    }

    HoverTrigger {
        id: hover
        cursorShape: Qt.PointingHandCursor
        suppressed: root.menuVisible
        onClicked: root.menuVisible = !root.menuVisible
    }

    InfoPopup {
        target: root
        title: "Power"
        open: hover.infoVisible
        suppressed: root.menuVisible
    }

    MenuPopup {
        target: root
        name: "power"
        open: root.menuVisible
        onDismissed: root.menuVisible = false

        PopupMenu {
            title: "Power"

            Repeater {
                model: root.actions

                Column {
                    id: row

                    required property var modelData

                    readonly property bool pending: root.pendingAction === row.modelData.id

                    width: parent.width
                    spacing: 6

                    // The session survives everything above this line.
                    MenuSeparator {
                        visible: row.modelData.id === "logout"
                    }

                    ListItem {
                        highlighted: row.pending
                        icon: row.modelData.icon
                        iconColor: row.pending ? Theme.warning : Theme.textPrimary
                        label: row.pending ? "Confirm " + row.modelData.label.toLowerCase() + "?" : row.modelData.label
                        onClicked: root.trigger(row.modelData)
                    }
                }
            }
        }
    }
}
