pragma ComponentBehavior: Bound

import Quickshell
import QtQuick
import "../../config"
import "../../services"
import "../base"

Item {
    id: root

    required property ShellScreen screen
    property int dotSize: 24
    property int dotSpacing: 4

    readonly property var activeWs: CompositorState.activeWorkspaceFor(root.screen)

    readonly property var workspaces: [
        { name: "primary", label: "Primary" },
        { name: "auxiliary", label: "Auxiliary" },
        { name: "other", label: "Other" },
    ]

    readonly property int activePillWidth: widestLabelMetrics.width
        + dotSize - widestInitialMetrics.width
    readonly property int fixedWidth: activePillWidth
        + (workspaces.length - 1) * dotSize
        + (workspaces.length - 1) * dotSpacing

    TextMetrics {
        id: widestLabelMetrics
        font.pixelSize: Config.fontSizeSmall
        font.family: Config.fontFamily
        text: "Auxiliary"
    }

    TextMetrics {
        id: widestInitialMetrics
        font.pixelSize: Config.fontSizeSmall
        font.family: Config.fontFamily
        text: "A"
    }

    implicitWidth: fixedWidth
    implicitHeight: parent ? parent.height : dotSize

    Item {
        id: wsContainer
        anchors.fill: parent

        Repeater {
            id: wsRepeater
            model: root.workspaces

            Item {
                id: wsItem
                required property var modelData
                required property int index

                readonly property string wsName: modelData.name
                readonly property string wsLabel: modelData.label
                readonly property bool isActive: root.activeWs
                    && root.activeWs.name === wsName
                readonly property bool isOccupied: CompositorState.isWorkspaceOccupied(wsName, root.screen)

                x: {
                    if (index === 0) return 0;
                    if (index === root.workspaces.length - 1)
                        return root.fixedWidth - width;
                    var pW = wsRepeater.itemAt(0)
                        ? wsRepeater.itemAt(0).width : root.dotSize;
                    var oW = wsRepeater.itemAt(root.workspaces.length - 1)
                        ? wsRepeater.itemAt(root.workspaces.length - 1).width
                        : root.dotSize;
                    var gap = root.fixedWidth - pW - oW - 2 * root.dotSpacing;
                    return pW + root.dotSpacing + (gap - width) / 2;
                }
                width: pill.width
                height: root.dotSize
                anchors.verticalCenter: parent.verticalCenter

                Rectangle {
                    id: pill
                    anchors.centerIn: parent
                    width: root.dotSize
                    height: root.dotSize
                    radius: height / 2
                    clip: true
                    color: Theme.surface

                    Text {
                        id: wsLabelText
                        anchors.left: parent.left
                        anchors.leftMargin: (root.dotSize - wsInitial.implicitWidth) / 2
                        anchors.verticalCenter: parent.verticalCenter
                        text: wsItem.wsLabel
                        font.pixelSize: Config.fontSizeSmall
                        font.family: Config.fontFamily
                        font.bold: false
                        renderType: Text.NativeRendering
                        color: Theme.textPrimary
                        opacity: 0
                    }

                    Text {
                        id: wsInitial
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.verticalCenter: parent.verticalCenter
                        text: wsItem.wsLabel.charAt(0)
                        font.pixelSize: Config.fontSizeSmall
                        font.family: Config.fontFamily
                        font.bold: false
                        renderType: Text.NativeRendering
                        color: Theme.textPrimary
                        opacity: 1
                    }
                }

                states: [
                    State {
                        name: "active"
                        when: wsItem.isActive
                        PropertyChanges {
                            pill.width: wsLabelText.implicitWidth + root.dotSize
                                - wsInitial.implicitWidth
                            pill.color: Theme.primary
                        }
                        PropertyChanges { wsLabelText.opacity: 1 }
                        PropertyChanges { wsInitial.opacity: 0 }
                    },
                    State {
                        name: "inactive"
                        when: !wsItem.isActive
                        PropertyChanges {
                            pill.width: root.dotSize
                            pill.color: wsItem.isOccupied
                                ? Qt.rgba(Theme.base02.r, Theme.base02.g, Theme.base02.b, 0.5)
                                : Theme.surface
                        }
                        PropertyChanges { wsLabelText.opacity: 0 }
                        PropertyChanges { wsInitial.opacity: 1 }
                    }
                ]

                transitions: [
                    Transition {
                        from: "active"; to: "inactive"
                        SequentialAnimation {
                            ParallelAnimation {
                                NumberAnimation {
                                    target: pill; property: "width"
                                    duration: Config.animMedium; easing.type: Easing.OutCubic
                                }
                                ColorAnimation {
                                    target: pill; property: "color"
                                    duration: Config.animMedium
                                }
                            }
                            PropertyAction { target: wsLabelText; property: "opacity" }
                            PropertyAction { target: wsInitial; property: "opacity" }
                        }
                    },
                    Transition {
                        from: "inactive"; to: "active"
                        SequentialAnimation {
                            PropertyAction { target: wsInitial; property: "opacity" }
                            PropertyAction { target: wsLabelText; property: "opacity" }
                            ParallelAnimation {
                                NumberAnimation {
                                    target: pill; property: "width"
                                    duration: Config.animMedium; easing.type: Easing.OutCubic
                                }
                                ColorAnimation {
                                    target: pill; property: "color"
                                    duration: Config.animMedium
                                }
                            }
                        }
                    }
                ]

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: CompositorState.focusWorkspace(wsItem.wsName)
                    onWheel: (event) => root.cycleWorkspace(event)
                }
            }
        }
    }

    HoverTrigger {
        id: hover
        acceptedButtons: Qt.NoButton
        cursorShape: Qt.PointingHandCursor
    }

    InfoPopup {
        target: root
        title: "Workspaces"
        open: hover.infoVisible
    }

    function cycleWorkspace(event) {
        var names = root.workspaces.map(w => w.name);
        var current = root.activeWs ? root.activeWs.name : "";
        var idx = names.indexOf(current);
        if (idx < 0) idx = 0;

        if (event.angleDelta.y > 0) {
            idx = (idx - 1 + names.length) % names.length;
        } else {
            idx = (idx + 1) % names.length;
        }
        CompositorState.focusWorkspace(names[idx]);
    }

}
