pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    property bool inhibited: false

    function toggleInhibit() {
        if (!inhibited) {
            inhibitProc.running = true;
            root.inhibited = true;
        } else {
            inhibitProc.running = false;
            root.inhibited = false;
        }
    }

    Process {
        id: inhibitProc
        command: ["systemd-inhibit", "--what=idle", "--who=quickshell-bar",
                  "--why=user-requested", "--mode=block", "sleep", "infinity"]
    }

    IpcHandler {
        target: "idle"

        function toggleInhibit() {
            root.toggleInhibit();
        }
    }
}
