import QtQuick
import QtQuick.Layouts
import "../../config"

Item {
    id: group
    clip: true

    default property alias content: layout.data
    property int leftPadding: Config.groupPadding
    property int rightPadding: Config.groupPadding
    property int fixedWidth: 0
    readonly property int animDuration: Config.animMedium

    implicitWidth: fixedWidth > 0 ? fixedWidth
        : layout.implicitWidth + leftPadding + rightPadding
    implicitHeight: parent ? parent.height : Config.barHeight

    Behavior on implicitWidth {
        NumberAnimation { duration: Config.animMedium; easing.type: Easing.OutCubic }
    }

    // Pill background
    Rectangle {
        anchors.fill: parent
        anchors.topMargin: Config.groupMargin
        anchors.bottomMargin: Config.groupMargin
        color: Theme.surface
        radius: Config.barRadius
        visible: layout.implicitWidth > 0

        Behavior on color {
            ColorAnimation { duration: Config.animMedium }
        }
    }

    RowLayout {
        id: layout

        anchors {
            fill: parent
            leftMargin: group.leftPadding
            rightMargin: group.rightPadding
            topMargin: Config.groupMargin
            bottomMargin: Config.groupMargin
        }
        spacing: Config.widgetSpacing
    }
}
