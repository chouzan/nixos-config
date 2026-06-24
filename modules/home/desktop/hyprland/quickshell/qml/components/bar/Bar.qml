import Quickshell
import Quickshell.Wayland
import QtQuick
import "../../config"

Scope {
    id: root

    // Single full-screen panel renders the entire frame
    Variants {
        model: Quickshell.screens

        // PanelWindow is created in C++ without complete tooling metadata.
        PanelWindow { // qmllint disable uncreatable-type
            id: frameWindow

            required property var modelData
            screen: frameWindow.modelData

            anchors {
                top: true
                bottom: true
                left: true
                right: true
            }

            color: "transparent"
            exclusionMode: ExclusionMode.Ignore

            mask: Region {
                item: barBg
                Region { item: leftBorder }
                Region { item: rightBorder }
                Region { item: bottomBar }
                Region { item: topLeftCorner }
                Region { item: topRightCorner }
                Region { item: bottomLeftCorner }
                Region { item: bottomRightCorner }
            }

            WlrLayershell.namespace: "quickshell:frame"

            Rectangle {
                id: barBg
                anchors {
                    top: parent.top
                    left: parent.left
                    right: parent.right
                }
                height: Config.barHeight
                color: Theme.background
            }

            BarContent {
                screen: frameWindow.modelData
                anchors {
                    fill: barBg
                    leftMargin: Config.frameWidth
                    rightMargin: Config.frameWidth
                }
            }

            Rectangle {
                id: leftBorder
                anchors.left: parent.left
                y: Config.barHeight + Config.frameRadius
                width: Config.frameWidth
                height: parent.height - y - Config.frameWidth - Config.frameRadius
                color: Theme.background
            }

            Rectangle {
                id: rightBorder
                anchors.right: parent.right
                y: Config.barHeight + Config.frameRadius
                width: Config.frameWidth
                height: parent.height - y - Config.frameWidth - Config.frameRadius
                color: Theme.background
            }

            Rectangle {
                id: bottomBar
                anchors {
                    bottom: parent.bottom
                    left: parent.left
                    right: parent.right
                }
                height: Config.frameWidth
                color: Theme.background
            }

            FrameCorner {
                id: topLeftCorner
                anchors {
                    left: parent.left
                    top: barBg.bottom
                }
                position: "topLeft"
                frameColor: Theme.background
            }

            FrameCorner {
                id: topRightCorner
                anchors {
                    right: parent.right
                    top: barBg.bottom
                }
                position: "topRight"
                frameColor: Theme.background
            }

            FrameCorner {
                id: bottomLeftCorner
                anchors {
                    left: parent.left
                    bottom: bottomBar.top
                }
                position: "bottomLeft"
                frameColor: Theme.background
            }

            FrameCorner {
                id: bottomRightCorner
                anchors {
                    right: parent.right
                    bottom: bottomBar.top
                }
                position: "bottomRight"
                frameColor: Theme.background
            }
        }
    }

    // Invisible spacers for exclusive zones
    Variants {
        model: Quickshell.screens

        PanelWindow { // qmllint disable uncreatable-type
            required property var modelData
            screen: modelData

            anchors {
                top: true
                left: true
                right: true
            }

            implicitHeight: Config.barHeight
            exclusionMode: ExclusionMode.Normal
            exclusiveZone: Config.barHeight
            color: "transparent"
            mask: Region {}

            WlrLayershell.namespace: "quickshell:spacer-top"
        }
    }

    Variants {
        model: Quickshell.screens

        PanelWindow { // qmllint disable uncreatable-type
            required property var modelData
            screen: modelData

            anchors {
                bottom: true
                left: true
                right: true
            }

            implicitHeight: Config.frameWidth
            exclusionMode: ExclusionMode.Normal
            exclusiveZone: Config.frameWidth
            color: "transparent"
            mask: Region {}

            WlrLayershell.namespace: "quickshell:spacer-bottom"
        }
    }

    Variants {
        model: Quickshell.screens

        PanelWindow { // qmllint disable uncreatable-type
            required property var modelData
            screen: modelData

            anchors {
                top: true
                bottom: true
                left: true
            }

            implicitWidth: Config.frameWidth
            exclusionMode: ExclusionMode.Normal
            exclusiveZone: Config.frameWidth
            color: "transparent"
            mask: Region {}

            WlrLayershell.namespace: "quickshell:spacer-left"
        }
    }

    Variants {
        model: Quickshell.screens

        PanelWindow { // qmllint disable uncreatable-type
            required property var modelData
            screen: modelData

            anchors {
                top: true
                bottom: true
                right: true
            }

            implicitWidth: Config.frameWidth
            exclusionMode: ExclusionMode.Normal
            exclusiveZone: Config.frameWidth
            color: "transparent"
            mask: Region {}

            WlrLayershell.namespace: "quickshell:spacer-right"
        }
    }
}
