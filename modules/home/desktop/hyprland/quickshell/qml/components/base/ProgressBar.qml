import QtQuick
import "../../config"

// Horizontal progress bar: a track Rectangle with a proportional fill.
// `value` is clamped to 0..1; set width (and optionally height / fillColor /
// animated) on the instance. Extracted from the repeated track+fill pattern.
Rectangle {
    id: root

    property real value: 0
    property color fillColor: Theme.textPrimary
    property bool animated: false

    height: 3
    radius: height / 2
    color: Theme.surfaceHover

    Rectangle {
        width: parent.width * Math.max(0, Math.min(1, root.value))
        height: parent.height
        radius: parent.radius
        color: root.fillColor

        Behavior on width {
            enabled: root.animated
            NumberAnimation { duration: Config.animShort }
        }
    }
}
