import QtQuick

// Generic vertical scroll area for popup menus holding static content: a
// Flickable stacking its children in a column, with the shared wheel handling
// and scrollbar. Content goes in the default slot; contentHeight is taken from
// it. For a list built from a model, use ScrollListView instead.
Item {
    id: root

    default property alias content: contentColumn.data
    property int spacing: 6
    property alias stepPixels: scrollArea.stepPixels
    property alias glideDuration: scrollArea.glideDuration

    readonly property alias flickable: flick
    readonly property alias contentHeight: flick.contentHeight

    Flickable {
        id: flick
        anchors.fill: parent
        contentHeight: contentColumn.height
        clip: true
        boundsBehavior: Flickable.StopAtBounds

        Column {
            id: contentColumn
            width: flick.width
            spacing: root.spacing
        }
    }

    ScrollArea {
        id: scrollArea
        flickable: flick
    }
}
