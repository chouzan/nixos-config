import Quickshell.Hyprland
import Quickshell.Wayland
import QtQuick
import "../../config"

// The click-menu popup shared by widgets that have a menu: a Panel anchored
// under the widget, keyboard focus on demand, and a HyprlandFocusGrab that
// closes it on an outside click. Set `target`, `name`, and `open` (the widget's
// menuVisible); handle `dismissed` to clear it. Menu content goes in the
// default slot. Replaces the per-widget menu Panel + focus-grab boilerplate.
AnchoredPanel {
    id: root

    property string name: ""
    property bool open: false
    signal dismissed()

    visible: root.open
    keyboardActive: root.open
    anchors.top: true
    // PanelWindow's grouped margins lack complete tooling metadata.
    // qmllint disable unqualified unresolved-type
    margins.top: Config.barHeight + Config.popupGap - root.pad
    // qmllint enable unqualified unresolved-type
    WlrLayershell.namespace: "quickshell:" + root.name + "-menu"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

    onCancelRequested: root.dismissed()

    HyprlandFocusGrab {
        active: root.open
        windows: [root]
        onCleared: root.dismissed()
    }
}
