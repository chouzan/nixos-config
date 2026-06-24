pragma Singleton

import Quickshell
import Quickshell.Services.Mpris
import QtQuick

// The player the interface follows, and what it reports. Views read this rather
// than the players themselves, so which of several players the bar shows is
// decided in one place.
Singleton {
    id: root

    // A player that plays comes first, then one that is paused, so the bar
    // follows what the user listens to rather than the first that registered.
    readonly property var player: {
        var players = Mpris.players.values;
        for (var i = 0; i < players.length; i++) {
            if (players[i] && players[i].isPlaying)
                return players[i];
        }
        for (var j = 0; j < players.length; j++) {
            if (players[j] && players[j].playbackState === MprisPlaybackState.Paused)
                return players[j];
        }
        return null;
    }

    readonly property bool hasContent: player !== null && (player.isPlaying || (player.trackTitle || "") !== "")

    readonly property bool isPlaying: player !== null && player.isPlaying
    readonly property string trackTitle: player ? player.trackTitle || "" : ""
    readonly property string trackArtist: player ? player.trackArtist || "" : ""

    readonly property bool lengthSupported: player !== null && player.lengthSupported
    readonly property real length: player ? player.length : 0
    readonly property real position: player ? player.position : 0

    readonly property bool shuffleSupported: player !== null && player.shuffleSupported
    readonly property bool shuffle: player !== null && player.shuffle
    readonly property bool loopSupported: player !== null && player.loopSupported
    readonly property bool loopActive: player !== null && player.loopSupported && player.loopState !== MprisLoopState.None
    readonly property bool loopsTrack: player !== null && player.loopState === MprisLoopState.Track

    // A player reports its position only when it jumps, to spare the work of
    // reporting each moment. Reading the property always gives the position of
    // that moment, so ask the player to report while a view shows the progress.
    // A view takes a reference while it draws the progress, and the player is
    // left alone when none does.
    property int _positionWatchers: 0

    function watchPosition() {
        root._positionWatchers += 1;
    }

    function unwatchPosition() {
        root._positionWatchers = Math.max(0, root._positionWatchers - 1);
    }

    Timer {
        running: root.isPlaying && root._positionWatchers > 0
        interval: 1000
        repeat: true
        // A player can close between the moment the timer is armed and the
        // moment it fires.
        onTriggered: {
            if (root.player)
                root.player.positionChanged();
        }
    }

    function togglePlaying() {
        if (!root.player)
            return;
        if (root.player.isPlaying)
            root.player.pause();
        else
            root.player.play();
    }
}
