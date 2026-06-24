import QtQuick
import "../../config"

// Muted small label heading a group of rows in a popup menu
// (Output/Input, Connected/Available/Saved, …). Caller sets `text`.
Text {
    color: Theme.textSecondary
    font.pixelSize: Config.fontSizeSmall
    font.family: Config.fontFamily
    renderType: Text.NativeRendering
}
