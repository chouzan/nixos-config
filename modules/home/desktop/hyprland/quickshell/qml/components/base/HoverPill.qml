import QtQuick
import "../../config"

// Background highlight that fades in behind a clickable bar widget on hover
// (or while its menu is open). Declare it before the widget's content so it
// sits behind. Sized to the widget's implicit width.
Rectangle {
    id: root

    property bool active: false
    property int pillHeight: 26

    anchors.centerIn: parent
    width: parent ? parent.implicitWidth : 0
    height: pillHeight
    radius: height / 2
    color: Qt.rgba(Theme.base02.r, Theme.base02.g, Theme.base02.b, 0.5)
    opacity: active ? 1 : 0

    Behavior on opacity { NumberAnimation { duration: Config.animShort } }
}
