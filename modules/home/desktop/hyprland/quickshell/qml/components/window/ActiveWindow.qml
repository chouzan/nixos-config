import QtQuick
import QtQuick.Layouts
import "../../config"
import "../../services"
import "../base"

Item {
    id: root

    readonly property string windowTitle: CompositorState.activeWindowTitle
    readonly property bool hasContent: {
        var t = windowTitle.replace(/[\s​‌‍⁠﻿­]/g, "");
        return t.length > 0;
    }

    implicitWidth: activeRow.implicitWidth
    implicitHeight: parent ? parent.height : 30

    RowLayout {
        id: activeRow
        anchors.centerIn: parent
        spacing: 4

        SvgIcon {
            icon: "app-window-duotone.svg"
            color: Theme.textPrimary
            size: Config.iconSize
        }

        MarqueeText {
            visible: root.hasContent
            hovered: hover.containsMouse
            text: root.windowTitle
            maxWidth: 201
        }
    }

    HoverTrigger { id: hover }

    InfoPopup {
        target: root
        title: "Window Title"
        open: hover.infoVisible
    }

}
