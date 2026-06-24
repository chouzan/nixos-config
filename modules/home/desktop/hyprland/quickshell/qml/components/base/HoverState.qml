pragma Singleton

import Quickshell
import QtQuick
import "../../config"

// Transient interaction state shared between bar widgets, as opposed to the
// service singletons (Notifications, SystemMetrics, ...) that own a process or
// a clock. Nothing here outlives the pointer.
Singleton {
    id: root

    // Widgets currently showing their hover info. Counted rather than a flag
    // because a popup can appear before the previous one has hidden.
    property int _hoverInfos: 0

    // True while an info popup is up, and briefly afterwards, so moving along
    // the bar reveals the next widget without waiting out the full delay again.
    readonly property bool hoverWarm: root._hoverInfos > 0 || graceTimer.running

    function acquireHoverInfo() {
        root._hoverInfos += 1;
        graceTimer.stop();
    }

    function releaseHoverInfo() {
        root._hoverInfos = Math.max(0, root._hoverInfos - 1);
        if (root._hoverInfos === 0)
            graceTimer.restart();
    }

    Timer {
        id: graceTimer
        interval: Config.hoverWarmGrace
    }
}
