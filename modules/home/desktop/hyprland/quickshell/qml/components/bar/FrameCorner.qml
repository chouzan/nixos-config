import QtQuick
import QtQuick.Shapes
import "../../config"

Shape {
    id: corner

    required property string position
    property color frameColor

    readonly property real fw: Config.frameWidth
    readonly property real r: Config.frameRadius
    readonly property var pts: {
        var W = fw + r;
        switch (position) {
        case "topLeft":
            return { sx: 0, sy: 0, l1x: 0, l1y: r, l2x: fw, l2y: r, ax: W, ay: 0, l3x: 0, l3y: 0 };
        case "topRight":
            return { sx: W, sy: 0, l1x: 0, l1y: 0, l2x: 0, l2y: 0, ax: r, ay: r, l3x: W, l3y: r };
        case "bottomLeft":
            return { sx: 0, sy: r, l1x: W, l1y: r, l2x: W, l2y: r, ax: fw, ay: 0, l3x: 0, l3y: 0 };
        case "bottomRight":
            return { sx: W, sy: r, l1x: W, l1y: 0, l2x: r, l2y: 0, ax: 0, ay: r, l3x: W, l3y: r };
        }
    }

    width: fw + r
    height: r
    antialiasing: true

    ShapePath {
        fillColor: corner.frameColor
        strokeColor: "transparent"
        strokeWidth: 0

        startX: corner.pts.sx
        startY: corner.pts.sy

        PathLine { x: corner.pts.l1x; y: corner.pts.l1y }
        PathLine { x: corner.pts.l2x; y: corner.pts.l2y }

        PathArc {
            x: corner.pts.ax
            y: corner.pts.ay
            radiusX: corner.r
            radiusY: corner.r
            direction: PathArc.Clockwise
        }

        PathLine { x: corner.pts.l3x; y: corner.pts.l3y }
    }
}
