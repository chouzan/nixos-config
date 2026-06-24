import QtQuick

// Generic titled section of items for a popup menu: hides itself when the
// model is empty, renders a SectionHeader, then one delegate per model entry.
// Callers pass a model (array) and a row Component (delegate). Specialized
// sections should reuse this rather than re-implement the pattern.
Column {
    id: root

    property string title: ""
    property var model: []
    property Component delegate: null

    width: parent ? parent.width : 200
    spacing: 2
    visible: root.model.length > 0

    SectionHeader { text: root.title }

    Repeater {
        model: root.model
        delegate: root.delegate
    }
}
