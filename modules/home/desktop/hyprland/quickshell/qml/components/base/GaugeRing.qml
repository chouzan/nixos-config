import QtQuick
import "../../config"

// Circular progress gauge: a faint full-circle track with an arc that fills
// clockwise from 12 o'clock by `progress` (0..1), and a free center slot for
// an icon (or anything else). Extracted from SystemGauge's three identical
// CPU/GPU/RAM rings.
Item {
    id: root

    property real progress: 0
    property color ringColor: Theme.textPrimary
    property int ringSize: 24
    property int lineWidth: 2
    // Hide the track/arc (center slot only), e.g. when there's no progress.
    property bool ringVisible: true
    // Ease the arc between values instead of snapping.
    property bool animated: false

    default property alias content: center.data

    implicitWidth: root.ringSize
    implicitHeight: root.ringSize

    Canvas {
        id: canvas
        anchors.fill: parent
        visible: root.ringVisible

        property real progress: root.progress
        property color ringColor: root.ringColor

        Behavior on progress {
            enabled: root.animated
            NumberAnimation { duration: Config.animShort; easing.type: Easing.OutCubic }
        }

        onProgressChanged: requestPaint()
        onRingColorChanged: requestPaint()
        Component.onCompleted: requestPaint()

        onPaint: {
            var ctx = getContext("2d")
            ctx.reset()
            var cx = width / 2, cy = height / 2
            var r = Math.min(cx, cy) - 1.5

            ctx.beginPath()
            ctx.arc(cx, cy, r, 0, 2 * Math.PI)
            ctx.strokeStyle = Qt.rgba(
                Theme.base02.r, Theme.base02.g, Theme.base02.b, 0.5)
            ctx.lineWidth = root.lineWidth
            ctx.stroke()

            if (canvas.progress > 0) {
                ctx.beginPath()
                var start = -Math.PI / 2
                ctx.arc(cx, cy, r, start, start + 2 * Math.PI * canvas.progress)
                ctx.strokeStyle = canvas.ringColor.toString()
                ctx.lineWidth = root.lineWidth
                ctx.stroke()
            }
        }
    }

    Item {
        id: center
        anchors.fill: parent
    }
}
