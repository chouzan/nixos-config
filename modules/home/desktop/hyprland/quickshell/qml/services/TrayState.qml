pragma Singleton

import Quickshell
import Quickshell.Services.SystemTray

// The items other programs put in the tray, and what can be done with one.
// Views read this rather than the tray service, so the interface never talks to
// another program itself.
Singleton {
    id: root

    readonly property var items: SystemTray.items

    // Tell the program its icon was activated.
    function activate(item) {
        if (item)
            item.activate();
    }

    // The menu belongs to the program, and it opens where the pointer is, so
    // the caller passes the item it clicked and the point within it.
    function showMenu(item, anchor, x, y) {
        if (item)
            item.display(anchor, x, y);
    }
}
