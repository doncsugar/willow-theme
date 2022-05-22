import QtQuick 2.8
import org.kde.plasma.core 2.0 as PlasmaCore

Item {
    id: background
    required property color buttonColor

    //set this for the button's padding (assuming it's even all around)
    property int padding

    //attempting to log in temporarily disables everything
    opacity: enabled ? 1 : 0.5

    anchors.fill: parent

    Rectangle {
        id: buttonBackground
        color: background.buttonColor
        radius: 5 * PlasmaCore.Units.devicePixelRatio
        anchors.fill: parent
        opacity: parent.parent.hovered || parent.parent.visualFocus || parent.parent.checked ? 0.15 : 0
    }
    Rectangle {
        anchors.fill: buttonBackground
        radius: 5 * PlasmaCore.Units.devicePixelRatio
        color: buttonBackground.color
        opacity: parent.parent.pressed ? 0.15 : 0
    }
}
