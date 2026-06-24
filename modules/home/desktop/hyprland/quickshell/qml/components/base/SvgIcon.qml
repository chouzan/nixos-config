import Quickshell.Io
import QtQuick
import "../../config"

Item {
    id: root

    property string icon: ""
    property color color: Theme.textPrimary
    property int size: Config.iconSize

    implicitWidth: size
    implicitHeight: size

    FileView {
        id: svgFile
        path: root.icon ? Config.iconRoot + root.icon : ""
        preload: true
    }

    Image {
        anchors.fill: parent
        property real dpr: Screen.devicePixelRatio || 1
        sourceSize: Qt.size(root.size * dpr, root.size * dpr)
        source: {
            if (!root.icon) return "";
            var svg = svgFile.text();
            if (!svg) return "";
            var c = root.color.toString();
            var colored = svg.replace(/currentColor/g, c);
            return "data:image/svg+xml," + encodeURIComponent(colored);
        }
    }
}
