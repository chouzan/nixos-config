import QtQuick
import "../../config"

Rectangle {
    id: root

    property string title: ""
    property alias headerContent: headerSlot.data
    default property alias content: contentColumn.data
    property int contentWidth: 240

    width: mainColumn.width + 2 * Config.popupRadius + 8
    height: mainColumn.height + 20
    color: Theme.background
    radius: Config.popupRadius

    Column {
        id: mainColumn
        anchors.centerIn: parent
        width: root.contentWidth
        spacing: 6

        Item {
            width: parent.width
            height: Math.max(titleText.height, headerSlot.childrenRect.height)
            visible: root.title !== "" || headerSlot.children.length > 0

            Text {
                id: titleText
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                text: root.title
                color: Theme.textSecondary
                font.pixelSize: Config.fontSize
                font.family: Config.fontFamily
                renderType: Text.NativeRendering
                visible: root.title !== ""
            }

            Item {
                id: headerSlot
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                width: childrenRect.width
                height: childrenRect.height
            }
        }

        Column {
            id: contentColumn
            width: parent.width
            spacing: 6
        }
    }
}
