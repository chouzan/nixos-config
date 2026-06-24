pragma Singleton
import Quickshell
import QtQuick

Singleton {
    id: theme

    // Base16 colors (substituted by Nix)
    readonly property color base00: "@base00@"
    readonly property color base01: "@base01@"
    readonly property color base02: "@base02@"
    readonly property color base03: "@base03@"
    readonly property color base04: "@base04@"
    readonly property color base05: "@base05@"
    readonly property color base06: "@base06@"
    readonly property color base07: "@base07@"
    readonly property color base08: "@base08@"
    readonly property color base09: "@base09@"
    readonly property color base0A: "@base0A@"
    readonly property color base0B: "@base0B@"
    readonly property color base0C: "@base0C@"
    readonly property color base0D: "@base0D@"
    readonly property color base0E: "@base0E@"
    readonly property color base0F: "@base0F@"

    // Opacity
    readonly property real backgroundOpacity: 1.0

    // Semantic colors
    readonly property color background: Qt.rgba(base00.r, base00.g, base00.b, backgroundOpacity)
    readonly property color surface: base01
    readonly property color surfaceHover: base02
    readonly property color primary: base0D
    readonly property color onPrimary: base00
    readonly property color textBright: base07
    readonly property color textPrimary: base05
    readonly property color textSecondary: base04
    readonly property color accent: base0E
    readonly property color success: base0B
    readonly property color warning: base0A
    readonly property color error: base08
}
