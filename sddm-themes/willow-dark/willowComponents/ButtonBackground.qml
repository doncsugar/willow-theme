import QtQuick 2.6
import org.kde.plasma.core 2.0 as PlasmaCore

Item {
    id: buttonBackground
    //set this for a particular file
    property string sourceSvg

    //set this for the file's padding (assuming it's even all around)
    property int padding

    //attempting to log in temporarily disables everything
    opacity: enabled ? 1 : 0.5

    PlasmaCore.FrameSvgItem {
        imagePath: sourceSvg
        prefix: "normal"
        anchors.fill: parent

        PlasmaCore.FrameSvgItem {
            imagePath: sourceSvg
            prefix: "hover"
            visible: opacity > 0
            opacity: buttonBackground.parent.hovered
            anchors.fill: parent
            Behavior on opacity {
                NumberAnimation {
                    duration: PlasmaCore.Units.longDuration
                    easing.type: Easing.OutCubic
                }
            }
        }
    }

    PlasmaCore.FrameSvgItem {
        imagePath: sourceSvg
        prefix: "pressed"
        anchors.fill: parent
        visible: opacity > 0
        opacity: buttonBackground.parent.visualFocus || buttonBackground.parent.activeFocus
        Behavior on opacity {
            NumberAnimation {
                duration: PlasmaCore.Units.longDuration
                easing.type: Easing.OutCubic
            }
        }
    }
}
