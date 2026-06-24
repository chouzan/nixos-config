import Quickshell
import Quickshell.Wayland
import QtQuick
import "../../config"

// A transparent overlay window sized to its content, with padding, optional
// keyboard focus, and hover tracking. Positioning is left to the consumer:
// anchor it directly, or use AnchoredPanel to center it under a bar widget.
//
// PanelWindow and its margins are created in C++ without complete qmltypes.
PanelWindow { // qmllint disable uncreatable-type
    id: panel

    readonly property int pad: Config.popupPad
    default property alias content: container.data
    property bool keyboardActive: false
    readonly property bool hovered: panelHover.hovered
    signal cancelRequested()

    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay

    implicitWidth: Math.max(container.childrenRect.width, 1) + panel.pad * 2
    implicitHeight: Math.max(container.childrenRect.height, 1) + panel.pad * 2

    Item {
        id: container
        x: panel.pad
        y: panel.pad
        width: container.childrenRect.width
        height: container.childrenRect.height
        focus: panel.keyboardActive && panel.visible

        Keys.onEscapePressed: panel.cancelRequested()
    }

    // HoverHandler, not a MouseArea — it tracks hover cooperatively without
    // consuming events or overriding the cursor for clickable content below.
    HoverHandler {
        id: panelHover
    }
}
