import QtQuick
import "../../config"

// Generic calendar cell — a labelled square shared by the day, month, and
// year grids. `today` and `selected` get persistent backgrounds (today wins);
// `muted` dims adjacent-period labels; hover tints like ListItem.
Item {
    id: root

    property string label: ""
    property bool today: false
    property bool selected: false
    property bool muted: false
    signal clicked()

    // Tabular figures so digit cells (days, years) share a fixed advance and
    // line up regardless of which digits render; harmless on text labels.
    readonly property font cellFont: Config.tnumFont(Config.fontSizeSmall)

    implicitWidth: 34
    implicitHeight: 30

    Rectangle {
        anchors.fill: parent
        anchors.margins: 2
        radius: 4
        color: root.today ? Theme.primary
            : root.selected ? Theme.surfaceHover
            : cellMouse.containsMouse
                ? Qt.rgba(Theme.base02.r, Theme.base02.g, Theme.base02.b, 0.35)
                : "transparent"

        Behavior on color { ColorAnimation { duration: Config.animShort } }
    }

    Text {
        anchors.centerIn: parent
        text: root.label
        color: root.today ? Theme.textBright
            : root.muted ? Theme.textSecondary
            : Theme.textPrimary
        font: root.cellFont
        renderType: Text.NativeRendering
    }

    MouseArea {
        id: cellMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
