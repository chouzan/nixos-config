pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import "../../config"
import "../../services"

Item {
    id: root

    property bool compact: false
    readonly property int maxVisibleItems: compact ? 4 : -1

    implicitWidth: trayRow.implicitWidth
    implicitHeight: parent ? parent.height : 30

    RowLayout {
        id: trayRow
        anchors.centerIn: parent
        spacing: 4

        Repeater {
            model: TrayState.items

            Item {
                id: trayItem

                required property var modelData
                required property int index
                visible: root.maxVisibleItems < 0 || index < root.maxVisibleItems
                implicitWidth: Config.iconSize
                implicitHeight: Config.iconSize
                Layout.alignment: Qt.AlignVCenter

                Image {
                    anchors.fill: parent
                    source: trayItem.modelData.icon ?? ""
                    sourceSize.width: Config.iconSize
                    sourceSize.height: Config.iconSize
                    smooth: true
                }

                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                    cursorShape: Qt.PointingHandCursor

                    onClicked: (mouse) => {
                        if (mouse.button === Qt.LeftButton) {
                            if (trayItem.modelData.onlyMenu && trayItem.modelData.hasMenu)
                                TrayState.showMenu(trayItem.modelData, this, mouse.x, mouse.y);
                            else
                                TrayState.activate(trayItem.modelData);
                        } else if (mouse.button === Qt.RightButton) {
                            if (trayItem.modelData.hasMenu)
                                TrayState.showMenu(trayItem.modelData, this, mouse.x, mouse.y);
                        }
                    }
                }
            }
        }
    }
}
