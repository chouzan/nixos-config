import QtQuick
import "../../config"

Rectangle {
    id: widgetInfo

    property string title: ""
    default property alias content: contentColumn.data

    width: mainColumn.width + 2 * Config.popupRadius + 8
    height: mainColumn.height + 16
    color: Theme.background
    radius: Config.popupRadius

    Column {
        id: mainColumn
        anchors.centerIn: parent
        spacing: 2

        Text {
            text: widgetInfo.title
            color: Theme.textSecondary
            font.pixelSize: Config.fontSize
            font.family: Config.fontFamily
            renderType: Text.NativeRendering
        }

        Item {
            width: 1; height: 2
            visible: contentColumn.children.length > 0
        }

        Column {
            id: contentColumn
            spacing: 2
            visible: children.length > 0
        }
    }
}
