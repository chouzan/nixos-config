import Quickshell.Wayland
import QtQuick
import "../../config"

// Shared hover-info popup for bar widgets: a Panel anchored under the widget,
// holding a WidgetInfo card. Consumers set `target`, `title`, `open` (usually a
// HoverTrigger's infoVisible), and `suppressed` (e.g. while the widget's menu
// is open); the info rows go in the default slot. Replaces the per-widget
// Panel + WidgetInfo boilerplate.
AnchoredPanel {
    id: root

    property string title: ""
    property string name: root.title.toLowerCase().replace(/ /g, "")
    property bool open: false
    property bool suppressed: false

    default property alias infoContent: info.content

    visible: (root.open || root.hovered) && !root.suppressed
    anchors.top: true
    // PanelWindow's grouped margins lack complete tooling metadata.
    // qmllint disable unqualified unresolved-type
    margins.top: Config.barHeight + Config.popupGap - root.pad
    // qmllint enable unqualified unresolved-type
    WlrLayershell.namespace: "quickshell:" + root.name + "-info"

    WidgetInfo {
        id: info
        title: root.title
    }
}
