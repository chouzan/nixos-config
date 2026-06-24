import QtQuick
import "../../config"

// Small pill button for the expanded actions on a list row (Connect,
// Disconnect, Forget). Destructive actions tint red on hover.
Item {
    id: root

    property string label: ""
    property bool destructive: false
    signal clicked()

    implicitWidth: labelText.implicitWidth + 20
    implicitHeight: 24
    opacity: root.enabled ? 1 : 0.55

    Behavior on opacity { NumberAnimation { duration: Config.animShort } }

    Rectangle {
        anchors.fill: parent
        radius: height / 2
        color: root.enabled && mouse.containsMouse
            ? (root.destructive
                ? Qt.rgba(Theme.error.r, Theme.error.g, Theme.error.b, 0.25)
                : Theme.surfaceHover)
            : Qt.rgba(Theme.base02.r, Theme.base02.g, Theme.base02.b, 0.35)

        Behavior on color { ColorAnimation { duration: Config.animShort } }
    }

    Text {
        id: labelText
        anchors.centerIn: parent
        text: root.label
        color: root.destructive && root.enabled && mouse.containsMouse ? Theme.error : Theme.textPrimary
        font.pixelSize: Config.fontSizeSmall
        font.family: Config.fontFamily
        renderType: Text.NativeRendering
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: root.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
        onClicked: root.clicked()
    }
}
