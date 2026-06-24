import QtQuick
import "../../config"

// A Panel centered under a bar widget, clamped to stay inside the screen frame.
// Use this when the popup belongs to a widget; use Panel directly for overlays
// positioned by their own anchors, such as toasts and OSDs.
Panel {
    id: root

    // The widget this popup points at. Its horizontal center defines the
    // popup's position, so it is required rather than optional.
    required property Item target

    readonly property real _posX: {
        if (!root.visible)
            return 0;
        return root.target.mapToItem(null, root.target.width / 2, 0).x;
    }

    // The target is anchored inside a full-width bar window, so its root item
    // spans the screen this popup belongs to.
    readonly property int _screenW: {
        var item = root.target;
        while (item.parent)
            item = item.parent;
        return item.width;
    }

    readonly property int _edgeMargin: Config.frameWidth + Config.popupGap - root.pad

    anchors.left: true

    // PanelWindow's grouped margins lack complete tooling metadata.
    // qmllint disable unqualified unresolved-type
    margins.left: {
        // qmllint enable unqualified unresolved-type
        if (root._posX === 0 || root.implicitWidth <= 1)
            return 0;
        var popupW = root.implicitWidth;
        var centered = root._posX - popupW / 2;
        var minLeft = root._edgeMargin;
        var maxLeft = root._screenW - root._edgeMargin - popupW;
        return Math.max(minLeft, Math.min(centered, maxLeft));
    }
}
