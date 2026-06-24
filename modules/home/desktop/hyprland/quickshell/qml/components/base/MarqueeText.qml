import QtQuick
import "../../config"

Item {
    id: root

    property string text: ""
    property color color: Theme.textPrimary
    property int pixelSize: Config.fontSizeSmall
    property string family: Config.fontFamily
    property int maxWidth: 201
    property int pauseDuration: Config.animPause
    property real scrollSpeed: 30
    property int fadeWidth: 16
    // Full there-and-back cycles to auto-play once the text changes; hovering
    // scrolls continuously to read a long title.
    property int autoLoops: 1
    property bool hovered: false

    readonly property real viewportWidth: root.width > 0 ? root.width : root.maxWidth
    readonly property bool overflows: innerText.implicitWidth > root.viewportWidth
    readonly property real scrollEnd: -(innerText.implicitWidth - root.viewportWidth)

    implicitWidth: Math.min(innerText.implicitWidth, root.maxWidth)
    implicitHeight: innerText.implicitHeight
    clip: true

    Text {
        id: innerText
        y: 0
        text: root.text
        color: root.color
        font.pixelSize: root.pixelSize
        font.family: root.family
        renderType: Text.NativeRendering
    }

    Rectangle {
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: root.fadeWidth
        visible: root.overflows && innerText.x < 0
        opacity: Math.min(1, -innerText.x / root.fadeWidth)
        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop { position: 0.0; color: Theme.surface }
            GradientStop { position: 1.0; color: "transparent" }
        }
    }

    Rectangle {
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: root.fadeWidth
        visible: root.overflows && innerText.x > root.scrollEnd
        opacity: Math.min(1, (innerText.x - root.scrollEnd) / root.fadeWidth)
        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop { position: 0.0; color: "transparent" }
            GradientStop { position: 1.0; color: Theme.surface }
        }
    }

    // Scroll continuously only while hovered, plus a one-off finite reveal when
    // the text changes; otherwise the marquee sits static. An always-visible bar
    // must not loop an animation 24/7 — every frame re-renders the whole bar
    // surface. Hover to read a long title in full.
    SequentialAnimation {
        id: scrollAnim

        PauseAnimation { duration: root.pauseDuration }

        NumberAnimation {
            target: innerText
            property: "x"
            from: 0
            to: root.scrollEnd
            duration: Math.max(0,
                (innerText.implicitWidth - root.viewportWidth) / root.scrollSpeed * 1000)
        }

        PauseAnimation { duration: root.pauseDuration }

        NumberAnimation {
            target: innerText
            property: "x"
            from: root.scrollEnd
            to: 0
            duration: Math.max(0,
                (innerText.implicitWidth - root.viewportWidth) / root.scrollSpeed * 1000)
        }

        onStopped: innerText.x = 0
    }

    // Play a one-off reveal (hover drives its own continuous scroll). Imperative
    // + restart() so the finite loops actually stop — a bound `running` would
    // restart forever. Triggered on text/overflow/visible changes so a track
    // change re-reveals even after layout settles.
    function _reveal() {
        if (root.hovered || !root.overflows || !root.visible)
            return;
        scrollAnim.loops = root.autoLoops;
        scrollAnim.restart();
    }

    onHoveredChanged: {
        if (root.hovered && root.overflows && root.visible) {
            scrollAnim.loops = Animation.Infinite;
            scrollAnim.restart();
        } else {
            scrollAnim.stop();
        }
    }
    // Parent layouts may animate this viewport after the text changes. Restart
    // until its width settles so the animation does not retain a stale endpoint.
    onWidthChanged: root._reveal()
    onOverflowsChanged: root.overflows ? root._reveal() : scrollAnim.stop()
    onVisibleChanged: root.visible ? root._reveal() : scrollAnim.stop()
    onTextChanged: root._reveal()
    Component.onCompleted: root._reveal()
}
