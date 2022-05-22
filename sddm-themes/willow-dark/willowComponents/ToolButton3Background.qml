import QtQuick 2.6
import org.kde.plasma.core 2.0 as PlasmaCore

Item {
    id: buttonBackground
    //set this for a particular file
    property string sourceSvg

    //figure out how to allow specifying the colorgroup of the assets

    //set this for the file's padding (assuming it's even all around)
    property int padding

    //attempting to log in temporarily disables everything
    opacity: enabled ? 1 : 0.5

    PlasmaCore.FrameSvgItem {
        imagePath: sourceSvg
        prefix: "toolbutton-hover"
        visible: opacity > 0
//        opacity: buttonBackground.parent.hovered
        opacity: buttonBackground.parent.hovered || buttonBackground.parent.visualFocus
                 //|| buttonBackground.parent.checked
        anchors.fill: parent
        colorGroup: PlasmaCore.Theme.ComplementaryColorGroup
        Behavior on opacity {
            NumberAnimation {
                duration: PlasmaCore.Units.longDuration
                easing.type: Easing.OutCubic
            }
        }
    }

    PlasmaCore.FrameSvgItem {
        imagePath: sourceSvg
        prefix: "toolbutton-pressed"
        anchors.fill: parent
        visible: opacity > 0
        opacity: parent.parent.pressed
        colorGroup: PlasmaCore.Theme.ComplementaryColorGroup
        Behavior on opacity {
            NumberAnimation {
                duration: PlasmaCore.Units.longDuration
                easing.type: Easing.OutCubic
            }
        }
    }
}

//import QtQuick 2.8
//import org.kde.plasma.core 2.0 as PlasmaCore

//Rectangle {
//    id: background
//    required property color buttonColor

//    anchors.fill: parent
//    color: "transparent"

//    Rectangle {
//        id: buttonBackground
//        color: background.buttonColor
//        radius: 5 * PlasmaCore.Units.devicePixelRatio
//        anchors.fill: parent
//        opacity: parent.parent.hovered || parent.parent.visualFocus || parent.parent.checked ? 0.15 : 0
//    }
//    Rectangle {
//        anchors.fill: buttonBackground
//        radius: 5 * PlasmaCore.Units.devicePixelRatio
//        color: buttonBackground.color
//        opacity: parent.parent.pressed ? 0.15 : 0
//    }
//}
