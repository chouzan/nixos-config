import QtQuick
import QtQuick.Layouts
import "../../config"
import "../../services"
import "../base"

// Per-monitor view over the shared SystemMetrics singleton.
Item {
    id: root

    property bool compact: false

    // A fullscreen window covers the bar, so the gauges are hidden. While
    // occluded this view drops its SystemMetrics reference, pausing the shared
    // poll once every monitor's gauge is covered.
    property bool occluded: false

    property bool _active: false

    function _sync() {
        var want = !root.occluded;
        if (want && !root._active) {
            SystemMetrics.acquire();
            root._active = true;
        } else if (!want && root._active) {
            SystemMetrics.release();
            root._active = false;
        }
    }

    onOccludedChanged: root._sync()
    Component.onCompleted: root._sync()
    Component.onDestruction: if (root._active)
        SystemMetrics.release()

    readonly property color cpuColor: SystemMetrics.cpuUsage >= 0.90 ? Theme.error : SystemMetrics.cpuUsage >= 0.75 ? Theme.warning : Theme.textPrimary
    readonly property color ramColor: SystemMetrics.ramUsage >= 0.95 ? Theme.error : SystemMetrics.ramUsage >= 0.85 ? Theme.warning : Theme.textPrimary
    readonly property color gpuColor: SystemMetrics.gpuUsage >= 0.90 ? Theme.error : SystemMetrics.gpuUsage >= 0.75 ? Theme.warning : Theme.textPrimary
    readonly property color gpuTempColor: SystemMetrics.gpuTempMilli >= 85000 ? Theme.error : SystemMetrics.gpuTempMilli >= 70000 ? Theme.warning : Theme.textPrimary

    function formatGB(bytes) {
        return (bytes / 1073741824).toFixed(1);
    }

    function formatGB_KB(kb) {
        return (kb / 1048576).toFixed(1);
    }

    readonly property real _barWidth: Math.max(cpuRow.width, gpuRow.width, ramRow.width)

    readonly property int innerIconSize: Config.iconSize - 4
    readonly property int ringSize: innerIconSize + 10

    implicitWidth: gaugeRow.implicitWidth
    implicitHeight: parent ? parent.height : 30

    // Reserve the widest percentage so the info popup doesn't resize as a value
    // crosses single/double/triple digits.
    TextMetrics {
        id: pctMetrics
        font: Config.tnumFont(Config.fontSize)
        text: "100%"
    }

    RowLayout {
        id: gaugeRow
        anchors.verticalCenter: parent.verticalCenter
        spacing: 6

        GaugeRing {
            visible: !root.compact
            ringSize: root.ringSize
            progress: SystemMetrics.cpuUsage
            ringColor: root.cpuColor
            animated: true
            Layout.alignment: Qt.AlignVCenter

            SvgIcon {
                anchors.centerIn: parent
                icon: "cpu-duotone.svg"
                color: root.cpuColor
                size: root.innerIconSize
            }
        }

        GaugeRing {
            visible: !root.compact
            ringSize: root.ringSize
            progress: SystemMetrics.gpuUsage
            ringColor: root.gpuColor
            animated: true
            Layout.alignment: Qt.AlignVCenter

            SvgIcon {
                anchors.centerIn: parent
                icon: "graphics-card-duotone.svg"
                color: root.gpuColor
                size: root.innerIconSize
            }
        }

        GaugeRing {
            ringSize: root.ringSize
            progress: SystemMetrics.ramUsage
            ringColor: root.ramColor
            animated: true
            Layout.alignment: Qt.AlignVCenter

            SvgIcon {
                anchors.centerIn: parent
                icon: "memory-duotone.svg"
                color: root.ramColor
                size: root.innerIconSize
            }
        }
    }

    HoverTrigger {
        id: hover
        acceptedButtons: Qt.NoButton
    }

    InfoPopup {
        target: root
        title: "System"
        open: hover.infoVisible

        Column {
            spacing: 4

            Row {
                id: cpuRow
                spacing: 8

                SvgIcon {
                    icon: "cpu-duotone.svg"
                    color: root.cpuColor
                    size: Config.fontSize
                    anchors.verticalCenter: parent.verticalCenter
                }

                Text {
                    text: "CPU"
                    color: Theme.textPrimary
                    font.pixelSize: Config.fontSize
                    font.family: Config.fontFamily
                    renderType: Text.NativeRendering
                }

                Text {
                    text: Math.round(SystemMetrics.cpuUsage * 100) + "%"
                    color: root.cpuColor
                    width: pctMetrics.width
                    horizontalAlignment: Text.AlignRight
                    font: Config.tnumFont(Config.fontSize)
                    renderType: Text.NativeRendering
                }
            }

            ProgressBar {
                width: root._barWidth
                value: SystemMetrics.cpuUsage
                fillColor: root.cpuColor
                animated: true
            }
        }

        Item { width: 1; height: 4 }

        Column {
            spacing: 4

            Row {
                id: gpuRow
                spacing: 8

                SvgIcon {
                    icon: "graphics-card-duotone.svg"
                    color: root.gpuColor
                    size: Config.fontSize
                    anchors.verticalCenter: parent.verticalCenter
                }

                Text {
                    text: "GPU"
                    color: Theme.textPrimary
                    font.pixelSize: Config.fontSize
                    font.family: Config.fontFamily
                    renderType: Text.NativeRendering
                }

                Text {
                    text: Math.round(SystemMetrics.gpuUsage * 100) + "%"
                    color: root.gpuColor
                    width: pctMetrics.width
                    horizontalAlignment: Text.AlignRight
                    font: Config.tnumFont(Config.fontSize)
                    renderType: Text.NativeRendering
                }

                Text {
                    visible: SystemMetrics.gpuTempMilli > 0
                    text: Math.round(SystemMetrics.gpuTempMilli / 1000) + "°C"
                    color: root.gpuTempColor
                    font: Config.tnumFont(Config.fontSize)
                    renderType: Text.NativeRendering
                }
            }

            ProgressBar {
                width: root._barWidth
                value: SystemMetrics.gpuUsage
                fillColor: root.gpuColor
                animated: true
            }

            Text {
                visible: SystemMetrics.vramTotal > 0
                text: "VRAM  " + root.formatGB(SystemMetrics.vramUsed) + " / " + root.formatGB(SystemMetrics.vramTotal) + " GB"
                color: Theme.textSecondary
                font.pixelSize: Config.fontSizeSmall
                font.family: Config.fontFamily
                renderType: Text.NativeRendering
            }
        }

        Item { width: 1; height: 4 }

        Column {
            spacing: 4

            Row {
                id: ramRow
                spacing: 8

                SvgIcon {
                    icon: "memory-duotone.svg"
                    color: root.ramColor
                    size: Config.fontSize
                    anchors.verticalCenter: parent.verticalCenter
                }

                Text {
                    text: "RAM"
                    color: Theme.textPrimary
                    font.pixelSize: Config.fontSize
                    font.family: Config.fontFamily
                    renderType: Text.NativeRendering
                }

                Text {
                    text: Math.round(SystemMetrics.ramUsage * 100) + "%"
                    color: root.ramColor
                    width: pctMetrics.width
                    horizontalAlignment: Text.AlignRight
                    font: Config.tnumFont(Config.fontSize)
                    renderType: Text.NativeRendering
                }
            }

            ProgressBar {
                width: root._barWidth
                value: SystemMetrics.ramUsage
                fillColor: root.ramColor
                animated: true
            }

            Text {
                visible: SystemMetrics.ramTotalKB > 0
                text: root.formatGB_KB(SystemMetrics.ramTotalKB - SystemMetrics.ramAvailKB) + " / " + root.formatGB_KB(SystemMetrics.ramTotalKB) + " GB"
                color: Theme.textSecondary
                font.pixelSize: Config.fontSizeSmall
                font.family: Config.fontFamily
                renderType: Text.NativeRendering
            }
        }
    }
}
