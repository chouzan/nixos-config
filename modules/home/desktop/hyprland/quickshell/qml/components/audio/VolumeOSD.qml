import Quickshell
import Quickshell.Wayland
import QtQuick
import "../../config"
import "../../services"
import "../base"

Scope {
    id: root

    property bool visible: false

    Panel {
        id: osdWindow
        screen: CompositorState.focusedScreen

        anchors {
            bottom: true
        }

        // PanelWindow's grouped margins lack complete tooling metadata.
        // qmllint disable unqualified unresolved-type
        margins {
            // qmllint enable unqualified unresolved-type
            bottom: Config.frameWidth + Config.popupGap - osdWindow.pad
        }

        WlrLayershell.namespace: "quickshell:osd"

        visible: root.visible

        Rectangle {
            id: osdPill
            width: osdRow.width + 2 * Config.barRadius
            height: Config.barHeight - 2 * Config.groupMargin
            color: Theme.background
            radius: Config.popupRadius

            Row {
                id: osdRow
                anchors.centerIn: parent
                spacing: Config.widgetSpacing

                SvgIcon {
                    anchors.verticalCenter: parent.verticalCenter
                    icon: AudioState.muted ? "speaker-slash-duotone.svg"
                        : AudioState.volume <= 0 ? "speaker-none-duotone.svg"
                        : AudioState.volume <= 0.5 ? "speaker-low-duotone.svg"
                        : "speaker-high-duotone.svg"
                    color: Theme.textPrimary
                    size: Config.iconSize
                }

                ProgressBar {
                    width: 120
                    height: 4
                    anchors.verticalCenter: parent.verticalCenter
                    value: AudioState.volume
                    animated: true
                }

                TextMetrics {
                    id: pctMetrics
                    font: pctText.font
                    text: "100"
                }

                Item {
                    width: pctMetrics.width
                    height: pctText.implicitHeight
                    anchors.verticalCenter: parent.verticalCenter

                    Text {
                        id: pctText
                        anchors.right: parent.right
                        text: Math.round(AudioState.volume * 100)
                        color: Theme.textPrimary
                        font: Config.tnumFont(Config.fontSizeSmall)
                        renderType: Text.NativeRendering
                    }
                }
            }
        }
    }

    // Show the OSD on volume and mute changes, but not on the reading that
    // arrives with a sink. The service can reach that reading before this view
    // exists, so take the baseline from it rather than wait to observe it.
    property real prevVolume: -1
    property bool prevMuted: false

    function syncBaseline() {
        if (!AudioState.sinkAudio) {
            root.prevVolume = -1;
            return;
        }
        root.prevVolume = AudioState.volume;
        root.prevMuted = AudioState.muted;
    }

    Component.onCompleted: root.syncBaseline()

    // The service owns the values now, so watch it instead of local copies.
    Connections {
        target: AudioState

        function onVolumeChanged() {
            if (!AudioState.sinkAudio)
                return;
            if (root.prevVolume >= 0 && Math.abs(AudioState.volume - root.prevVolume) > 0.001) {
                root.visible = true;
                hideTimer.restart();
            }
            root.prevVolume = AudioState.volume;
        }

        // A different sink brings its own levels, which are not a change the
        // user made.
        function onSinkAudioChanged() {
            root.syncBaseline();
        }

        function onMutedChanged() {
            if (!AudioState.sinkAudio)
                return;
            if (root.prevVolume >= 0 && AudioState.muted !== root.prevMuted) {
                root.visible = true;
                hideTimer.restart();
            }
            root.prevMuted = AudioState.muted;
        }
    }

    Timer {
        id: hideTimer
        interval: 1500
        onTriggered: root.visible = false
    }
}
