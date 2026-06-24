import QtQuick
import "../../config"

// Bar-widget hover behaviour, extracted from the MouseArea + Timer block that
// was repeated across every interactive widget. Tracks the pointer and, after
// `delay`, raises `infoVisible` so the widget can reveal its info popup.
// `suppressed` (e.g. while the widget's own menu is open) forces it closed.
// It IS the widget's MouseArea, so consumers still set cursorShape /
// acceptedButtons / onClicked / onWheel as on any MouseArea.
MouseArea {
    id: root

    property bool infoVisible: false
    property int delay: Config.hoverDelay
    property bool suppressed: false

    // Reveal quickly while another widget's info is up (or just was), so moving
    // along the bar doesn't wait out the full delay at every widget.
    readonly property int _revealDelay: HoverState.hoverWarm ? Config.hoverWarmDelay : root.delay

    property bool _holdsHoverInfo: false

    anchors.fill: parent
    hoverEnabled: true

    onContainsMouseChanged: {
        if (root.suppressed)
            return;
        if (containsMouse)
            infoTimer.restart();
        else {
            infoTimer.stop();
            root.infoVisible = false;
        }
    }

    onSuppressedChanged: {
        if (root.suppressed) {
            infoTimer.stop();
            root.infoVisible = false;
        }
    }

    // Track this widget's contribution to the shared warm state.
    onInfoVisibleChanged: {
        if (root.infoVisible && !root._holdsHoverInfo) {
            HoverState.acquireHoverInfo();
            root._holdsHoverInfo = true;
        } else if (!root.infoVisible && root._holdsHoverInfo) {
            HoverState.releaseHoverInfo();
            root._holdsHoverInfo = false;
        }
    }

    Component.onDestruction: if (root._holdsHoverInfo)
        HoverState.releaseHoverInfo()

    Timer {
        id: infoTimer
        interval: root._revealDelay
        onTriggered: root.infoVisible = true
    }
}
