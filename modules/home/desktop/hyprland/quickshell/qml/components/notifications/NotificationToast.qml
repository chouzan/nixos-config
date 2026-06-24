pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Wayland
import QtQuick
import "../../config"
import "../../services"
import "../base"

// Transient popup stack. Renders Notifications.toasts (the server and history
// live in the Notifications singleton); each toast auto-dismisses and can
// invoke the notification's actions while it is live.
Scope {
    id: root

    readonly property int toastWidth: 380
    readonly property int toastGap: 6

    readonly property var targetScreen: CompositorState.focusedScreen

    Panel {
        id: toastWindow
        screen: root.targetScreen

        anchors {
            top: true
            right: true
        }

        // PanelWindow's grouped margins lack complete tooling metadata.
        // qmllint disable unqualified unresolved-type
        margins {
            // qmllint enable unqualified unresolved-type
            top: Config.barHeight + Config.popupGap - toastWindow.pad
            right: Config.frameWidth + Config.popupGap - toastWindow.pad
        }

        WlrLayershell.namespace: "quickshell:notifications"

        // One layer below the widget popups (Panel defaults to Overlay) so an
        // open widget is never covered by an arriving toast, while toasts still
        // float above ordinary windows.
        WlrLayershell.layer: WlrLayer.Top

        visible: Notifications.toasts.count > 0

        Column {
            id: toastColumn
            width: root.toastWidth
            spacing: root.toastGap

            Repeater {
                model: Notifications.toasts

                Rectangle {
                    id: toast
                    required property var model

                    readonly property int notifId: toast.model.nid
                    property var notifRef:
                        Notifications.notifMap[toast.model.nid] || null

                    width: root.toastWidth
                    implicitHeight: contentColumn.implicitHeight
                        + 2 * Config.groupPadding
                    radius: Config.popupRadius
                    color: Theme.surface
                    opacity: 0

                    NumberAnimation {
                        id: enterAnim
                        target: toast
                        property: "opacity"
                        to: 1
                        duration: Config.animMedium
                    }

                    SequentialAnimation {
                        id: dismissAnim
                        NumberAnimation {
                            target: toast
                            property: "opacity"
                            to: 0
                            duration: Config.animMedium
                        }
                        ScriptAction {
                            script: Notifications.dismissToast(toast.notifId)
                        }
                    }

                    Component.onCompleted: enterAnim.start()

                    // The centre lists this notification already, so fade the
                    // toast out as the centre fades in.
                    Connections {
                        target: Notifications

                        function onCentreOpenChanged() {
                            if (Notifications.centreOpen && !dismissAnim.running)
                                dismissAnim.start();
                        }
                    }

                    Timer {
                        id: dismissTimer
                        interval: toast.model.timeout
                        running: toast.model.timeout > 0
                            && !hoverArea.containsMouse
                            && !dismissAnim.running
                        onTriggered: dismissAnim.start()
                    }

                    function defaultAction() {
                        if (!toast.notifRef) return null;
                        var actions = toast.notifRef.actions;
                        for (var i = 0; i < actions.length; i++) {
                            if (actions[i].identifier === "default")
                                return actions[i];
                        }
                        return null;
                    }

                    MouseArea {
                        id: hoverArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: toast.defaultAction()
                            ? Qt.PointingHandCursor : Qt.ArrowCursor
                        onClicked: {
                            var action = toast.defaultAction();
                            if (action) {
                                if (toast.model.hasActions)
                                    toast.height = toast.implicitHeight;
                                Notifications.invokeAction(action);
                                dismissAnim.start();
                            }
                        }
                    }

                    Column {
                        id: contentColumn
                        anchors {
                            left: parent.left
                            right: parent.right
                            top: parent.top
                            margins: Config.groupPadding
                            rightMargin: Config.groupPadding * 2 + 14
                        }
                        spacing: 4

                        Row {
                            spacing: 6

                            SvgIcon {
                                icon: toast.model.icon
                                    ? toast.model.icon
                                    : toast.model.isCritical
                                        ? "bell-ringing-duotone.svg"
                                        : "bell-duotone.svg"
                                size: 14
                                color: toast.model.isCritical
                                    ? Theme.error : Theme.textSecondary
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            SvgIcon {
                                visible: toast.model.hasDefaultAction
                                icon: "cursor-click-duotone.svg"
                                size: 12
                                color: Theme.textSecondary
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Text {
                                text: toast.model.appName
                                color: Theme.textSecondary
                                font.pixelSize: Config.fontSizeBase + 2
                                font.family: Config.fontFamily
                                renderType: Text.NativeRendering
                            }
                        }

                        Text {
                            width: parent.width
                            text: toast.model.summary
                            color: Theme.textPrimary
                            font.pixelSize: Config.fontSizeSmall
                            font.family: Config.fontFamily
                            font.bold: true
                            wrapMode: Text.WordWrap
                            renderType: Text.NativeRendering
                        }

                        Text {
                            width: parent.width
                            visible: toast.model.body !== ""
                            text: toast.model.body
                            color: Theme.textSecondary
                            font.pixelSize: Config.fontSizeBase + 2
                            font.family: Config.fontFamily
                            wrapMode: Text.WordWrap
                            maximumLineCount: 3
                            elide: Text.ElideRight
                            renderType: Text.NativeRendering
                        }

                        Flow {
                            width: parent.width
                            visible: toast.model.hasActions
                                && toast.notifRef !== null
                            spacing: 4

                            Repeater {
                                model: toast.notifRef
                                    ? toast.notifRef.actions : []

                                Rectangle {
                                    id: action

                                    required property var modelData

                                    visible: !!(action.modelData.text
                                        && action.modelData.text.trim())
                                    width: actionLabel.implicitWidth + 16
                                    height: visible ? actionLabel.implicitHeight + 8 : 0
                                    radius: height / 2
                                    color: actionMouse.containsMouse
                                        ? Theme.surfaceHover : Qt.rgba(
                                            Theme.base02.r, Theme.base02.g,
                                            Theme.base02.b, 0.5)

                                    Text {
                                        id: actionLabel
                                        anchors.centerIn: parent
                                        text: action.modelData.text
                                        color: Theme.textPrimary
                                        font.pixelSize: Config.fontSizeBase + 1
                                        font.family: Config.fontFamily
                                        renderType: Text.NativeRendering
                                    }

                                    MouseArea {
                                        id: actionMouse
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            toast.height = toast.implicitHeight;
                                            Notifications.invokeAction(action.modelData);
                                            dismissAnim.start();
                                        }
                                    }
                                }
                            }
                        }
                    }

                    SvgIcon {
                        id: closeIcon
                        anchors {
                            top: parent.top
                            right: parent.right
                            topMargin: Config.groupPadding
                            rightMargin: Config.groupPadding
                        }
                        icon: "x-duotone.svg"
                        color: Theme.textSecondary
                        size: 14
                        opacity: hoverArea.containsMouse ? 1 : 0

                        Behavior on opacity {
                            NumberAnimation { duration: Config.animShort }
                        }

                        MouseArea {
                            anchors.fill: parent
                            anchors.margins: -4
                            cursorShape: Qt.PointingHandCursor
                            onClicked: dismissAnim.start()
                        }
                    }
                }
            }
        }
    }
}
