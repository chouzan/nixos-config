import QtQuick
import "../../config"

// A label/value row for the "Details" reveal in a device list item.
// Fixed label column on the left, value fills the rest (wraps for long
// values like a D-Bus path). Set mono for identifiers (MAC, path).
Row {
    id: root

    property string key: ""
    property string value: ""
    property int labelWidth: 56
    property bool mono: false

    width: parent ? parent.width : 200
    spacing: 6

    Text {
        width: root.labelWidth
        text: root.key
        color: Theme.textSecondary
        font.pixelSize: Config.fontSizeSmall
        font.family: Config.fontFamily
        renderType: Text.NativeRendering
    }

    Text {
        width: root.width - root.labelWidth - root.spacing
        text: root.value
        color: Theme.textPrimary
        font.pixelSize: Config.fontSizeSmall
        font.family: root.mono ? Config.fontFamilyMono : Config.fontFamily
        wrapMode: Text.WrapAnywhere
        renderType: Text.NativeRendering
    }
}
