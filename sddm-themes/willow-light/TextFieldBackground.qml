import QtQuick 2.6
import org.kde.plasma.core 2.0 as PlasmaCore

Item {
    id: textFieldBackground
    //set this for a particular file
    property string sourceSvg

    //set this for the file's padding (assuming it's even all around)
    property int padding

    PlasmaCore.FrameSvgItem {
        imagePath: sourceSvg
        prefix: "base"
        anchors.fill: parent

        PlasmaCore.FrameSvgItem {
            imagePath: sourceSvg
            prefix: "hover"
            visible: opacity > 0
            opacity: textFieldBackground.parent.hovered
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
        prefix: "focus"
        anchors.fill: parent
        visible: opacity > 0
        opacity: textFieldBackground.parent.visualFocus || textFieldBackground.parent.activeFocus
        Behavior on opacity {
            NumberAnimation {
                duration: PlasmaCore.Units.longDuration
                easing.type: Easing.OutCubic
            }
        }
    }
}
