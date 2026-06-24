import QtQuick
import "../../config"

// Model-driven counterpart to ScrollList, sharing its wheel handling and
// scrollbar. Backed by a ListView so rows are created and destroyed per model
// change rather than rebuilt wholesale, which also lets rows animate as they
// arrive and leave. Give it a model that mutates in place; assigning a new
// array resets the view and skips those transitions.
Item {
    id: root

    property alias model: list.model
    property alias delegate: list.delegate
    property alias spacing: list.spacing
    property alias stepPixels: scrollArea.stepPixels
    property alias glideDuration: scrollArea.glideDuration

    readonly property alias flickable: list
    readonly property alias contentHeight: list.contentHeight
    readonly property alias count: list.count

    ListView {
        id: list
        anchors.fill: parent
        spacing: 6
        clip: true
        boundsBehavior: Flickable.StopAtBounds
        cacheBuffer: 0

        // Rows fade rather than scale, which would squash their text, and every
        // motion follows the direction the list reflows in: the arriving row
        // settles downwards into the gap opening for it, and the leaving row
        // travels up with the rows closing the gap behind it, so it is never
        // sitting still while they slide through it. All three share a duration
        // and easing so the row and the gap move as one.
        add: Transition {
            NumberAnimation {
                property: "opacity"
                from: 0
                to: 1
                duration: Config.animMedium
                easing.type: Easing.OutCubic
            }
        }

        // Rows below an added or removed one slide instead of jumping.
        displaced: Transition {
            NumberAnimation {
                property: "y"
                duration: Config.animMedium
                easing.type: Easing.OutCubic
            }
        }

        remove: Transition {
            id: removeTransition

            ParallelAnimation {
                NumberAnimation {
                    property: "opacity"
                    to: 0
                    duration: Config.animMedium
                    easing.type: Easing.OutCubic
                }

                NumberAnimation {
                    property: "y"
                    to: removeTransition.ViewTransition.item.y - removeTransition.ViewTransition.item.height
                    duration: Config.animMedium
                    easing.type: Easing.OutCubic
                }
            }
        }
    }

    ScrollArea {
        id: scrollArea
        flickable: list
    }
}
