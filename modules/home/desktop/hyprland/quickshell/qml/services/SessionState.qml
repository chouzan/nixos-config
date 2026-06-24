pragma Singleton

import Quickshell
import Quickshell.Io

// The session actions. A view asks for an action by name and does not carry the
// command that performs it, so what "log out" means on this system is settled
// here and not in the menu that offers it.
Singleton {
    id: root

    // Ending the session is the compositor's business, so it goes through uwsm
    // rather than a kill of the compositor, which would leave its units behind.
    readonly property var _commands: ({
            lock: ["loginctl", "lock-session"],
            suspend: ["systemctl", "suspend"],
            hibernate: ["systemctl", "hibernate"],
            logout: ["uwsm", "stop"],
            reboot: ["systemctl", "reboot"],
            shutdown: ["systemctl", "poweroff"]
        })

    readonly property var actionIds: Object.keys(root._commands)

    function perform(id) {
        var command = root._commands[id];
        if (!command)
            return;
        actionProcess.command = command;
        actionProcess.running = true;
    }

    Process {
        id: actionProcess
    }
}
