pragma Singleton

import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import QtQuick

// The compositor as the interface needs it: which screen has the focus, which
// screen a full-screen window covers, and the workspaces of a screen. Views
// read this rather than the compositor, so the same question has one answer
// everywhere.
Singleton {
    id: root

    // The screen the user works on. Overlays that appear once, and not per
    // screen, follow this one.
    readonly property var focusedScreen: {
        var name = Hyprland.focusedMonitor ? Hyprland.focusedMonitor.name : "";
        for (var i = 0; i < Quickshell.screens.length; i++) {
            if (Quickshell.screens[i].name === name)
                return Quickshell.screens[i];
        }
        return Quickshell.screens[0];
    }

    // True while a full-screen window covers the given screen. A maximised
    // window keeps the reserved area and does not count, and a full-screen
    // window on a hidden workspace does not either, because the compositor
    // reports the screens a window is visible on.
    function isOccluded(screen) {
        if (!screen)
            return false;
        var list = ToplevelManager.toplevels.values;
        for (var i = 0; i < list.length; i++) {
            var toplevel = list[i];
            if (!toplevel || !toplevel.fullscreen)
                continue;
            var screens = toplevel.screens;
            for (var j = 0; j < screens.length; j++)
                if (screens[j] && screens[j].name === screen.name)
                    return true;
        }
        return false;
    }

    // ---- Active window ----

    // The compositor keeps the focused toplevel and its title current, so read
    // them. An event for the focused window alone would miss the title
    // changing while the same window keeps the focus.
    readonly property string activeWindowTitle: Hyprland.activeToplevel ? Hyprland.activeToplevel.title : ""

    // ---- Workspaces ----

    function monitorFor(screen) {
        return screen ? Hyprland.monitorFor(screen) : null;
    }

    function activeWorkspaceFor(screen) {
        var monitor = root.monitorFor(screen);
        return monitor && monitor.activeWorkspace ? monitor.activeWorkspace : null;
    }

    // A workspace holds windows on the given screen.
    function isWorkspaceOccupied(name, screen) {
        var monitor = root.monitorFor(screen);
        if (!monitor)
            return false;
        var all = Hyprland.workspaces.values;
        for (var i = 0; i < all.length; i++) {
            if (all[i] && all[i].name === name && all[i].monitor === monitor)
                return true;
        }
        return false;
    }

    // Hyprland reads the argument of a dispatch as Lua, so the call goes
    // through the hl.dsp API and not the older name of the dispatcher.
    function focusWorkspace(name) {
        Hyprland.dispatch("hl.dsp.focus({workspace = 'name:" + name + "'})");
    }
}
