import QtQuick
import "../../config"

Item {
    id: root

    property bool highlighted: false
    property string icon: ""
    property color iconColor: Theme.textPrimary
    property string label: ""
    property bool expanded: false

    property alias trailingContent: trailingSlot.data
    property alias expandedContent: expandedSlot.data

    signal clicked()

    width: parent ? parent.width : 200
    height: mainRow.height + 8 + expandedSlot.height

    Rectangle {
        anchors.fill: parent
        radius: 4
        // Persistent "current" state reads stronger than a transient hover.
        color: root.highlighted ? Theme.surfaceHover
            : rowMouse.containsMouse
                ? Qt.rgba(Theme.base02.r, Theme.base02.g, Theme.base02.b, 0.35)
                : "transparent"

        Behavior on color { ColorAnimation { duration: Config.animShort } }
    }

    MouseArea {
        id: rowMouse
        anchors.left: parent.left
        anchors.right: parent.right
        height: mainRow.height + 8
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }

    Item {
        id: mainRow
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: 4
        anchors.rightMargin: 4
        y: 4
        height: labelText.height

        SvgIcon {
            id: iconItem
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            icon: root.icon
            color: root.iconColor
            size: Config.fontSize
            visible: root.icon !== ""
        }

        Text {
            id: labelText
            anchors.left: iconItem.visible ? iconItem.right : parent.left
            anchors.leftMargin: iconItem.visible ? 8 : 0
            anchors.right: trailingSlot.children.length > 0 ? trailingSlot.left : parent.right
            anchors.rightMargin: trailingSlot.children.length > 0 ? 8 : 0
            anchors.verticalCenter: parent.verticalCenter
            text: root.label
            color: root.iconColor
            font.pixelSize: Config.fontSize
            font.family: Config.fontFamily
            renderType: Text.NativeRendering
            elide: Text.ElideRight
        }

        Item {
            id: trailingSlot
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            width: childrenRect.width
            height: childrenRect.height
        }
    }

    Item {
        id: expandedSlot
        anchors.top: mainRow.bottom
        anchors.topMargin: 4
        width: parent.width
        height: root.expanded ? expandedSlot.childrenRect.height : 0
        clip: true

        Behavior on height {
            NumberAnimation { duration: Config.animMedium; easing.type: Easing.OutCubic }
        }
    }
}
