pragma Singleton
import Quickshell
import QtQuick

Singleton {
    id: config

    // Bar dimensions
    readonly property int barHeight: 54
    readonly property int frameWidth: 11
    readonly property int frameRadius: 11
    readonly property int barRadius: 18
    readonly property int groupPadding: 8
    readonly property int groupMargin: 9
    readonly property int groupSpacing: 4
    readonly property int widgetSpacing: 8
    readonly property int popupGap: 20
    readonly property int popupRadius: 10
    readonly property int popupPad: 2

    // Fonts (families substituted by Nix, sizes derived from base)
    readonly property string fontFamily: "@fontFamily@"
    readonly property string fontFamilyMono: "@fontFamilyMono@"
    readonly property int fontSizeBase: @fontSizeBase@
    readonly property int fontSize: fontSizeBase + 6
    readonly property int fontSizeSmall: fontSizeBase + 4
    readonly property int iconSize: fontSizeBase + 9

    // Tabular-figures font (fixed-width digits) for clocks, gauges, and any
    // numeric readout so digits don't jitter. Optional letterSpacing.
    function tnumFont(pixelSize, letterSpacing) {
        return Qt.font({
            family: config.fontFamily,
            pixelSize: pixelSize,
            features: { "tnum": 1 },
            letterSpacing: letterSpacing || 0
        });
    }

    // Assets live beside the configuration root. Resolved here rather than in
    // each consumer, so moving a component between directories cannot break it.
    readonly property url iconRoot: Qt.resolvedUrl("../assets/icons/")

    // Paths (substituted by Nix)
    readonly property string whereAmI: "@whereAmI@"

    // Animation durations (ms)
    readonly property int animShort: 150
    readonly property int animMedium: 200
    readonly property int animLong: 400
    readonly property int animPause: 2000

    // Hover-info reveal (ms). The first popup waits `hoverDelay` so sweeping
    // the pointer across the bar reveals nothing. While another popup is
    // already up, or was up within `hoverWarmGrace`, the next one waits only
    // `hoverWarmDelay` — long enough to still ignore a sweep.
    readonly property int hoverDelay: 1000
    readonly property int hoverWarmDelay: 150
    readonly property int hoverWarmGrace: 500
}
