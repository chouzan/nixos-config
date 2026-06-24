import QtQuick
import "../../config"
import "../../services"
import "../base"

Item {
    id: root

    property color iconColor: IdleState.inhibited ? Theme.warning : Theme.textPrimary

    property int pillHeight: 26

    implicitWidth: Config.iconSize
    implicitHeight: parent ? parent.height : 30

    HoverPill {
        active: hover.containsMouse
        pillHeight: root.pillHeight
    }

    SvgIcon {
        anchors.centerIn: parent
        icon: "coffee-duotone.svg"
        color: root.iconColor
        size: Config.iconSize
    }

    HoverTrigger {
        id: hover
        cursorShape: Qt.PointingHandCursor
        onClicked: IdleState.toggleInhibit()
    }

    InfoPopup {
        target: root
        title: "Idle Inhibitor"
        open: hover.infoVisible
    }
}
