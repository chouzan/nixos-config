import QtQuick
import QtQuick.Layouts
import "../../config"
import "../../services"
import "../base"

Item {
    id: root

    property int pillAnimDuration: Config.animMedium

    // A full-screen window covers the bar, so the ring is hidden.
    property bool occluded: false

    // The position of a player is only worth following while this widget draws
    // it. Hold a reference for as long as that is true, and let it go when the
    // ring is hidden, the track has no length, or the widget goes away.
    readonly property bool showsProgress: !root.occluded && MediaState.hasContent && MediaState.lengthSupported && MediaState.length > 0

    property bool _watchesPosition: false

    function _syncPositionWatch() {
        if (root.showsProgress && !root._watchesPosition) {
            MediaState.watchPosition();
            root._watchesPosition = true;
        } else if (!root.showsProgress && root._watchesPosition) {
            MediaState.unwatchPosition();
            root._watchesPosition = false;
        }
    }

    onShowsProgressChanged: root._syncPositionWatch()
    Component.onCompleted: root._syncPositionWatch()
    Component.onDestruction: if (root._watchesPosition)
        MediaState.unwatchPosition()

    readonly property int fixedContentWidth: progressIcon.ringSize + 6 + 201
        + 6 + Config.iconSize + 6 + Config.iconSize

    implicitWidth: MediaState.hasContent ? fixedContentWidth : progressIcon.implicitWidth
    implicitHeight: parent ? parent.height : 30

    RowLayout {
        id: mediaRow
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        spacing: 6

        GaugeRing {
            id: progressIcon
            property int innerIconSize: Config.iconSize - 4
            Layout.alignment: Qt.AlignVCenter
            ringSize: MediaState.hasContent ? progressIcon.innerIconSize + 10 : Config.iconSize
            ringVisible: MediaState.hasContent && MediaState.player
                && MediaState.lengthSupported && MediaState.length > 0
            progress: {
                if (!MediaState.player || !MediaState.lengthSupported
                    || MediaState.length <= 0) return 0;
                return Math.max(0, Math.min(1,
                    MediaState.position / MediaState.length));
            }

            SvgIcon {
                anchors.centerIn: parent
                icon: "music-notes-duotone.svg"
                color: Theme.textPrimary
                size: Config.iconSize
                opacity: MediaState.player ? 0 : 1
                Behavior on opacity { NumberAnimation { duration: root.pillAnimDuration } }
            }

            SvgIcon {
                anchors.centerIn: parent
                icon: MediaState.player && MediaState.isPlaying
                    ? "play-duotone.svg" : "pause-duotone.svg"
                color: Theme.textPrimary
                size: progressIcon.innerIconSize
                opacity: MediaState.player ? 1 : 0
                Behavior on opacity { NumberAnimation { duration: root.pillAnimDuration } }
            }
        }

        MarqueeText {
            visible: MediaState.hasContent
            hovered: hover.containsMouse
            Layout.fillWidth: true
            text: {
                if (!MediaState.player) return "";
                var artist = MediaState.trackArtist || "";
                var title = MediaState.trackTitle || "";
                if (artist && title) return artist + " - " + title;
                return title || artist || "";
            }
        }

        SvgIcon {
            visible: MediaState.hasContent && MediaState.player && MediaState.shuffleSupported
                && MediaState.shuffle
            icon: "shuffle-duotone.svg"
            color: Theme.textPrimary
            size: Config.iconSize
        }

        SvgIcon {
            visible: MediaState.hasContent && MediaState.loopActive
            icon: MediaState.loopsTrack ? "repeat-once-duotone.svg" : "repeat-duotone.svg"
            color: Theme.textPrimary
            size: Config.iconSize
        }
    }

    HoverTrigger {
        id: hover
        cursorShape: MediaState.hasContent ? Qt.PointingHandCursor : Qt.ArrowCursor
        onClicked: {
            if (!MediaState.player) return;
            MediaState.togglePlaying();
        }
    }

    InfoPopup {
        target: root
        title: "Media"
        open: hover.infoVisible
    }
}
