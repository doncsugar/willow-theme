import QtQuick 2.8

import QtQuick.Controls 2.12 as QQC2
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents3

Item {

    id: powerMenuButton

    //checks which icon is being loaded, then adds in old margins (~11px)
    implicitHeight: Math.round( ( (powerIcon.visible ? 31 : 32) + (2 * 11) ) * PlasmaCore.Units.devicePixelRatio)
    width: height


    //icon for the button
    PlasmaCore.SvgItem {
        id: powerIcon

        anchors.centerIn: parent
    //                  questionably hacky code to load in willow's special icon when
    //                  using its theme and use the regular theme icon when not
        visible: naturalSize.width === 31

        //this code functions differently from iconItem. Need hidpi display to test which is best
        width: Math.round(31 * PlasmaCore.Units.devicePixelRatio)
        height: width

        //the name of the custom icon
        elementId: "system-shutdown-willow"
        svg: PlasmaCore.Svg {
            //this is where the 31px icon is stored in Willow
            imagePath: "icons/system"
            colorGroup: PlasmaCore.Theme.ComplementaryColorGroup
        }
    }
    //if the odd pixel icon is not detected, this shows instead
    PlasmaCore.IconItem {
        id: powerIconBackup
        source: "system-shutdown"
        usesPlasmaTheme: true;
        colorGroup: PlasmaCore.Theme.ComplementaryColorGroup
        visible: !powerIcon.visible
        anchors.centerIn: parent
        width: Math.round(32 * PlasmaCore.Units.devicePixelRatio)
        height: width
    }

    //replicating ActionButton, without label
    Rectangle {
        id: iconButton
        //chooses icon in use
        anchors.centerIn: powerIcon.visible ? powerIcon : powerIconBackup
        //scales to the size of the icon in use
        width: (powerIcon.visible ? powerIcon.width : powerIconBackup.width) + Math.floor(PlasmaCore.Units.smallSpacing * 2)
        height: width
        radius: width / 2
        scale: mouseArea.containsPress ? 1 : 0
        color: PlasmaCore.ColorScope.textColor
        opacity: 0.15
        Behavior on scale {
                PropertyAnimation {
                    duration: PlasmaCore.Units.shortDuration
                    easing.type: Easing.InOutQuart
                }
        }
    }
    Rectangle {
        anchors.fill: iconButton
        radius: width / 2
        color: PlasmaCore.ColorScope.textColor
        opacity: mouseArea.containsMouse || mouseArea.activeFocus ? .15 : 0
        Behavior on opacity {
                PropertyAnimation {
                    duration: PlasmaCore.Units.shortDuration
                    easing.type: Easing.InOutQuart
                }
        }
    }
    MouseArea {
        id: mouseArea
        hoverEnabled: true
        //unsure why I can't use ternary to switch open and close. May be timing related?
        onClicked: menu.visible ? menu.close() : menu.open();

        activeFocusOnTab: true;
        Keys.onReturnPressed: menu.visible ? menu.close() : menu.open();
        Keys.onEnterPressed: menu.visible ? menu.close() : menu.open();

        onPositionChanged: fadeoutTimer.restart();
        anchors.fill: parent
    }
}
