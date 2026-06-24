import QtQuick
import "../../config"

Item {
    id: root

    property bool checked: false
    signal toggled()

    property color offTrackColor: Theme.surfaceHover
    property color offThumbColor: Theme.textSecondary
    property color onTrackColor: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.4)
    property color onThumbColor: Theme.primary

    width: 34
    height: 18
    opacity: root.enabled ? 1 : 0.55

    Behavior on opacity { NumberAnimation { duration: Config.animShort } }

    Rectangle {
        anchors.fill: parent
        radius: height / 2
        color: root.checked ? root.onTrackColor : root.offTrackColor

        Behavior on color { ColorAnimation { duration: Config.animShort; easing.type: Easing.OutCubic } }

        Rectangle {
            y: 2
            x: root.checked ? parent.width - width - 2 : 2
            width: 14; height: 14
            radius: 7
            color: root.checked ? root.onThumbColor : root.offThumbColor

            Behavior on x { NumberAnimation { duration: Config.animShort; easing.type: Easing.OutCubic } }
            Behavior on color { ColorAnimation { duration: Config.animShort; easing.type: Easing.OutCubic } }
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: root.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
        onClicked: root.toggled()
    }
}
