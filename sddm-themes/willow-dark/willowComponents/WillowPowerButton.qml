import QtQuick 2.8

import QtQuick.Controls 2.12 as QQC2
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents3

//this should be an item when not debugging
Item {
    //used to select icons
    required property string themeDirectory

    id: powerMenuButton

    //used to close menu when the chained opacity hits 0
    visible: opacity != 0;
    onVisibleChanged: menu.close();

    //checks which icon is being loaded, then adds in old margins (~11px)
    implicitHeight: Math.round( ( (powerIcon.visible ? 31 : 32) + (2 * 11) ) * PlasmaCore.Units.devicePixelRatio)
    width: height

    //icon for the button
    AdaptiveIcon {
        id: powerIcon

        anchors.centerIn: parent

        //if 31, will reduce to next smallest scale
        //hardcoded because you can't change icons (yet?)
        width: Math.round(31 * PlasmaCore.Units.devicePixelRatio)
        height: width

        source: themeDirectory + "icons/" + "system-shutdown-willow.svgz"
        color: PlasmaCore.ColorScope.textColor
    }

    //replicating ActionButton, without label
    Rectangle {
        id: iconButton
        anchors.centerIn: powerIcon
        width: powerIcon.width + Math.floor(PlasmaCore.Units.smallSpacing * 2)
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

        onClicked: menu.visible ? menu.close() : menu.open()

        activeFocusOnTab: true;
        Keys.onReturnPressed: menu.visible ? menu.close() : menu.open();
        Keys.onEnterPressed: menu.visible ? menu.close() : menu.open();

        onPositionChanged: fadeoutTimer.restart();
        anchors.fill: parent
    }


        WillowMenu {
            id: menu

            opacity: parent.opacity

            //chaining the parent's directory in
            iconPath: themeDirectory + "icons/"

            QQC2.Action {
                icon.name: "system-shutdown"
                text: i18nd("plasma_lookandfeel_org.kde.lookandfeel", "Shut Down")
                enabled: sddm.canPowerOff
                onTriggered: {
                //commented out because SDDM may not need it.
                //implement a proper delay on input
//                  loginScreenRoot.uiVisible = false;
//                  loginScreenRoot.hoverEnabled = false;
//                  reviveLock.start()
                    sddm.powerOff()
                }
            }
            QQC2.Action {
                icon.name: "system-reboot"
                text: i18nd("plasma_lookandfeel_org.kde.lookandfeel", "Restart")
                enabled: sddm.canReboot
                onTriggered: {
        //          loginScreenRoot.uiVisible = false;
        //          loginScreenRoot.hoverEnabled = false;
        //          reviveLock.start()
                    sddm.reboot()
                }
            }
            QQC2.MenuSeparator {
                implicitHeight: Math.floor(10 * PlasmaCore.Units.devicePixelRatio)
                visible: false
            }
            QQC2.Action {
                icon.name: "system-suspend"
                text: i18nd("plasma_lookandfeel_org.kde.lookandfeel", "Sleep")
                enabled: sddm.canSuspend
                onTriggered: {
                //disabling the reviveLock code is a bad call because it forgets edge cases of users switching
        //          loginScreenRoot.uiVisible = false;
        //          loginScreenRoot.hoverEnabled = false;
        //          reviveLock.start()
                    sddm.suspend()
                }
            }
        }

}
