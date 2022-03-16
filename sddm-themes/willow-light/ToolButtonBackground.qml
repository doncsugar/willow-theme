import QtQuick 2.6
import org.kde.plasma.core 2.0 as PlasmaCore

Item {
    id: toolButtonBackground
    //set this for a particular file
    property string sourceSvg

    //set this for the file's padding (assuming it's even all around)
    property int padding

    //attempting to log in temporarily disables everything
    opacity: enabled ? 1 : 0.5

    PlasmaCore.FrameSvgItem {
        id: surfaceNormal
        anchors.fill: parent
        imagePath: toolButtonBackground.sourceSvg
        prefix: "toolbutton-hover"
        enabledBorders: "AllBorders"
    }
    PlasmaCore.FrameSvgItem {
        id: surfacePressed
        anchors.fill: parent
        imagePath: toolButtonBackground.sourceSvg
        prefix: "toolbutton-pressed"
        enabledBorders: surfaceNormal.enabledBorders
        opacity: 0
    }
    //don't feel like adding focus state, so focus is defined like a hover
    state: (control.pressed || control.checked ? "pressed" : (style.controlHovered || control.activeFocus ? "hover" : "normal"))

    states: [
        State { name: "normal"
            PropertyChanges {
                target: surfaceNormal
                opacity: 0
            }
            PropertyChanges {
                target: surfacePressed
                opacity: 0
            }
        },
        State { name: "hover"
            PropertyChanges {
                target: surfaceNormal
                opacity: 1
            }
            PropertyChanges {
                target: surfacePressed
                opacity: 0
            }
        },
        State { name: "pressed"
                PropertyChanges {
                    target: surfaceNormal
                    opacity: 0
                }
                PropertyChanges {
                    target: surfacePressed
                    opacity: 1
                }
        }
    ]

    transitions: [
        Transition {
            //Cross fade from pressed to normal
            ParallelAnimation {
                NumberAnimation { target: surfaceNormal; property: "opacity"; duration: PlasmaCore.Units.shortDuration }
                NumberAnimation { target: surfacePressed; property: "opacity"; duration: PlasmaCore.Units.shortDuration }
            }
        }
    ]
}
