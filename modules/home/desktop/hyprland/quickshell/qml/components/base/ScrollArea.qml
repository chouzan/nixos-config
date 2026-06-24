import QtQuick
import "../../config"

// Wheel handling and scrollbar for a Flickable, including a ListView, which is
// one. Qt's default Flickable wheel scrolling is slow and, worse, stalls when
// the wheel spins fast (each notch restarts its flick timeline before it
// travels), so this steps contentY by the wheel delta instead: linear, and
// consistent across menus.
//
// Declare it after the flickable it drives, so its wheel handler sits on top.
Item {
    id: root

    required property Flickable flickable

    // Pixels scrolled per wheel notch (angleDelta is 120 units per notch).
    property int stepPixels: 80

    // Glide time for each wheel step. Defaults to the shared short-motion
    // duration; overridable per instance since scroll feel is its own concern.
    property int glideDuration: Config.animShort

    anchors.fill: root.flickable

    // Glide to the target instead of teleporting per notch.
    NumberAnimation {
        id: wheelAnim
        target: root.flickable
        property: "contentY"
        duration: root.glideDuration
        easing.type: Easing.OutCubic
    }

    WheelHandler {
        acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
        onWheel: event => {
            // Prefer pixelDelta (touchpads / high-res wheels); fall back to
            // angleDelta (120 units per notch) scaled to a pixel step.
            var dy = event.pixelDelta.y !== 0 ? event.pixelDelta.y : event.angleDelta.y / 120 * root.stepPixels;
            if (dy === 0)
                return;
            var flick = root.flickable;
            var max = Math.max(0, flick.contentHeight - flick.height);
            // Accumulate onto the in-flight target so fast spins reach further
            // while still landing on a single smooth glide.
            var base = wheelAnim.running ? wheelAnim.to : flick.contentY;
            var dest = Math.max(0, Math.min(max, base - dy));
            wheelAnim.stop();
            wheelAnim.from = flick.contentY;
            wheelAnim.to = dest;
            wheelAnim.start();
        }
    }

    Rectangle {
        visible: root.flickable.contentHeight > root.flickable.height
        anchors.right: parent.right
        anchors.rightMargin: 1
        width: 3
        radius: 1.5
        color: Theme.textSecondary
        opacity: 0.3
        y: root.flickable.visibleArea.yPosition * root.height
        height: Math.max(root.flickable.visibleArea.heightRatio * root.height, 12)
    }
}
