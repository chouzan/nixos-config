pragma Singleton

import Quickshell
import Quickshell.Services.Pipewire

// The audio devices as the interface needs them. Views read this rather than
// Pipewire, so the default nodes are tracked once and every view sees the same
// volume and mute state.
Singleton {
    id: root

    // Reactive default sink/source — no polling, no boot race.
    readonly property PwNode sink: Pipewire.defaultAudioSink
    readonly property PwNode source: Pipewire.defaultAudioSource
    readonly property var sinkAudio: sink ? sink.audio : null
    readonly property var sourceAudio: source ? source.audio : null

    readonly property bool available: sink !== null
    readonly property real volume: sinkAudio ? sinkAudio.volume : 0
    readonly property bool muted: sinkAudio ? sinkAudio.muted : false
    readonly property string sinkName: sink ? sink.description : ""
    readonly property string sourceName: source ? source.description : ""
    readonly property bool sourceMuted: sourceAudio ? sourceAudio.muted : false

    // Real output/input devices only — exclude app streams, video, midi, and
    // driver nodes. Pre-filtered and id-sorted so the menu rows map 1:1 to
    // devices (no collapsed placeholders, stable order).
    readonly property var sinks: root._audioNodes(true)
    readonly property var sources: root._audioNodes(false)

    function _audioNodes(wantSink) {
        var out = [];
        var all = Pipewire.nodes.values;
        for (var i = 0; i < all.length; i++) {
            var n = all[i];
            if (n && n.audio && !n.isStream && n.isSink === wantSink)
                out.push(n);
        }
        out.sort(function (a, b) {
            return a.id - b.id;
        });
        return out;
    }

    function toggleMute() {
        if (!root.sinkAudio)
            return;
        root.sinkAudio.muted = !root.sinkAudio.muted;
    }

    // Steps by `delta` and keeps the result within the range the device takes.
    function stepVolume(delta) {
        if (!root.sinkAudio)
            return;
        root.sinkAudio.volume = Math.max(0, Math.min(1, root.sinkAudio.volume + delta));
    }

    function setDefaultSink(node) {
        Pipewire.preferredDefaultAudioSink = node;
    }

    function setDefaultSource(node) {
        Pipewire.preferredDefaultAudioSource = node;
    }

    // Binding the nodes makes their audio (volume/mute) properties valid.
    PwObjectTracker {
        objects: [root.sink, root.source]
    }
}
