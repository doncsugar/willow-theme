/*
    SPDX-FileCopyrightText: 2016 David Edmundson <davidedmundson@kde.org>

    SPDX-License-Identifier: LGPL-2.0-or-later
*/

import QtQuick 2.8

import QtQuick.Layouts 1.1
import QtQuick.Controls 1.1
import QtQuick.Controls 2.12 as QQC2
import QtGraphicalEffects 1.0

import org.kde.plasma.core 2.0 as PlasmaCore

import org.kde.plasma.components 2.0 as PlasmaComponents2

import org.kde.plasma.components 3.0 as PlasmaComponents3
import org.kde.plasma.extras 2.0 as PlasmaExtras

import "components"

// TODO: Once SDDM 0.19 is released and we are setting the font size using the
// SDDM KCM's syncing feature, remove the `config.fontSize` overrides here and
// the fontSize properties in various components, because the theme's default
// font size will be correctly propagated to the login screen

PlasmaCore.ColorScope {
    id: root

    // If we're using software rendering, draw outlines instead of shadows
    // See https://bugs.kde.org/show_bug.cgi?id=398317
    readonly property bool softwareRendering: GraphicsInfo.api === GraphicsInfo.Software

    colorGroup: PlasmaCore.Theme.ComplementaryColorGroup
    readonly property bool lightBackground: Math.max(PlasmaCore.ColorScope.backgroundColor.r, PlasmaCore.ColorScope.backgroundColor.g, PlasmaCore.ColorScope.backgroundColor.b) > 0.5

    width: 1600
    height: 900

    property string notificationMessage

    LayoutMirroring.enabled: Qt.application.layoutDirection === Qt.RightToLeft
    LayoutMirroring.childrenInherit: true

    PlasmaCore.DataSource {
        id: keystateSource
        engine: "keystate"
        connectedSources: "Caps Lock"
    }

    Item {
        id: wallpaper
        anchors.fill: parent
        Repeater {
            model: screenModel

            Background {
                x: geometry.x; y: geometry.y; width: geometry.width; height: geometry.height
                sceneBackgroundType: config.type
                sceneBackgroundColor: config.color
                sceneBackgroundImage: config.background
            }
        }
    }

    MouseArea {
        id: loginScreenRoot
        anchors.fill: parent

        property bool uiVisible: true
        property bool blockUI: mainStack.depth > 1 || userListComponent.mainPasswordBox.text.length > 0 || inputPanel.keyboardActive || config.type !== "image"

        hoverEnabled: true
        drag.filterChildren: true
        onPressed: uiVisible = true;
        onPositionChanged: uiVisible = true;
        onUiVisibleChanged: {
            if (blockUI) {
                fadeoutTimer.running = false;
            } else if (uiVisible) {
                fadeoutTimer.restart();
            }
        }
        onBlockUIChanged: {
            if (blockUI) {
                fadeoutTimer.running = false;
                uiVisible = true;
            } else {
                fadeoutTimer.restart();
            }
        }

        Keys.onPressed: {
            uiVisible = true;
            event.accepted = false;
        }

        //takes one full minute for the ui to disappear
        Timer {
            id: fadeoutTimer
            running: true
            interval: 60000
            onTriggered: {
                if (!loginScreenRoot.blockUI) {
                    loginScreenRoot.uiVisible = false;
                }
            }
        }
        WallpaperFader {
            visible: config.type === "image"
            anchors.fill: parent
            state: loginScreenRoot.uiVisible ? "on" : "off"
            source: wallpaper
            mainStack: mainStack
            footer: footer
            clock: clock
        }

        DropShadow {
            id: clockShadow
            anchors.fill: clock
            source: clock
            visible: !softwareRendering
            horizontalOffset: 1
            verticalOffset: 1
            radius: 6
            samples: 14
            spread: 0.3
                                          // Soften the color a bit so it doesn't look so stark against light backgrounds
            color: root.lightBackground ? Qt.rgba(PlasmaCore.ColorScope.backgroundColor.r,
                                                  PlasmaCore.ColorScope.backgroundColor.g,
                                                  PlasmaCore.ColorScope.backgroundColor.b,
                                                  0.6)
                                        : "black" // black matches Breeze window decoration and desktopcontainment
            Behavior on opacity {
                OpacityAnimator {
                    duration: PlasmaCore.Units.veryLongDuration * 2
                    easing.type: Easing.InOutQuad
                }
            }
        }

        Clock {
            id: clock
            property Item shadow: clockShadow
            visible: y > 0
            anchors.horizontalCenter: parent.horizontalCenter
            y: (userListComponent.userList.y + mainStack.y)/2 - height/2
            Layout.alignment: Qt.AlignBaseline
        }

        QQC2.StackView {
            id: mainStack
            anchors {
                left: parent.left
                right: parent.right
            }
            height: root.height + PlasmaCore.Units.gridUnit * 3

            // If true (depends on the style and environment variables), hover events are always accepted
            // and propagation stopped. This means the parent MouseArea won't get them and the UI won't be shown.
            // Disable capturing those events while the UI is hidden to avoid that, while still passing events otherwise.
            // One issue is that while the UI is visible, mouse activity won't keep resetting the timer, but when it
            // finally expires, the next event should immediately set uiVisible = true again.
            hoverEnabled: loginScreenRoot.uiVisible ? undefined : false

            focus: true //StackView is an implicit focus scope, so we need to give this focus so the item inside will have it

            Timer {
                //SDDM has a bug in 0.13 where even though we set the focus on the right item within the window, the window doesn't have focus
                //it is fixed in 6d5b36b28907b16280ff78995fef764bb0c573db which will be 0.14
                //we need to call "window->activate()" *After* it's been shown. We can't control that in QML so we use a shoddy timer
                //it's been this way for all Plasma 5.x without a huge problem
                running: true
                repeat: false
                interval: 200
                onTriggered: mainStack.forceActiveFocus()
            }

            initialItem: Login {
                id: userListComponent
                userListModel: userModel
                loginScreenUiVisible: loginScreenRoot.uiVisible
                userListCurrentIndex: userModel.lastIndex >= 0 ? userModel.lastIndex : 0
                lastUserName: userModel.lastUser
                showUserList: {
                    if ( !userListModel.hasOwnProperty("count")
                    || !userListModel.hasOwnProperty("disableAvatarsThreshold"))
                        return (userList.y + mainStack.y) > 0

                    if ( userListModel.count === 0 ) return false

                    if ( userListModel.hasOwnProperty("containsAllUsers") && !userListModel.containsAllUsers ) return false

                    return userListModel.count <= userListModel.disableAvatarsThreshold && (userList.y + mainStack.y) > 0
                }

                notificationMessage: {
                    var text = ""
                    if (keystateSource.data["Caps Lock"]["Locked"]) {
                        text += i18nd("plasma_lookandfeel_org.kde.lookandfeel","Caps Lock is on")
                        if (root.notificationMessage) {
                            text += " • "
                        }
                    }
                    text += root.notificationMessage
                    return text
                }

                actionItems: [
//                     ActionButton {
//                         iconSource: "system-suspend"
//                         text: i18ndc("plasma_lookandfeel_org.kde.lookandfeel","Suspend to RAM","Sleep")
//                         fontSize: parseInt(config.fontSize) + 1
//                         onClicked: sddm.suspend()
//                         enabled: sddm.canSuspend
//                         visible: !inputPanel.keyboardActive
//                     },
//                     ActionButton {
//                         iconSource: "system-reboot"
//                         text: i18nd("plasma_lookandfeel_org.kde.lookandfeel","Restart")
//                         fontSize: parseInt(config.fontSize) + 1
//                         onClicked: sddm.reboot()
//                         enabled: sddm.canReboot
//                         visible: !inputPanel.keyboardActive
//                     },
//                     ActionButton {
//                         iconSource: "system-shutdown"
//                         text: i18nd("plasma_lookandfeel_org.kde.lookandfeel","Shut Down")
//                         fontSize: parseInt(config.fontSize) + 1
//                         onClicked: sddm.powerOff()
//                         enabled: sddm.canPowerOff
//                         visible: !inputPanel.keyboardActive
//                     },
                    ActionButton {
                        iconSource: "system-user-prompt"
                        text: i18ndc("plasma_lookandfeel_org.kde.lookandfeel", "For switching to a username and password prompt", "Other…")
                        fontSize: parseInt(config.fontSize) + 1
                        onClicked: mainStack.push(userPromptComponent)
                        enabled: true
                        visible: !userListComponent.showUsernamePrompt && !inputPanel.keyboardActive
                    }]

                onLoginRequest: {
                    root.notificationMessage = ""
                    sddm.login(username, password, sessionButton.currentIndex)
                }
            }

            Behavior on opacity {
                OpacityAnimator {
                    duration: PlasmaCore.Units.longDuration
                }
            }

            readonly property real zoomFactor: 3

            popEnter: Transition {
                ScaleAnimator {
                    from: mainStack.zoomFactor
                    to: 1
                    duration: PlasmaCore.Units.longDuration * (mainStack.zoomFactor / 2)
                    easing.type: Easing.OutCubic
                }
                OpacityAnimator {
                    from: 0
                    to: 1
                    duration: PlasmaCore.Units.longDuration * (mainStack.zoomFactor / 2)
                    easing.type: Easing.OutCubic
                }
            }

            popExit: Transition {
                ScaleAnimator {
                    from: 1
                    to: 0
                    duration: PlasmaCore.Units.longDuration * (mainStack.zoomFactor / 2)
                    easing.type: Easing.OutCubic
                }
                OpacityAnimator {
                    from: 1
                    to: 0
                    duration: PlasmaCore.Units.longDuration * (mainStack.zoomFactor / 2)
                    easing.type: Easing.OutCubic
                }
            }

            pushEnter: Transition {
                ScaleAnimator {
                    from: 0
                    to: 1
                    duration: PlasmaCore.Units.longDuration * (mainStack.zoomFactor / 2)
                    easing.type: Easing.OutCubic
                }
                OpacityAnimator {
                    from: 0
                    to: 1
                    duration: PlasmaCore.Units.longDuration * (mainStack.zoomFactor / 2)
                    easing.type: Easing.OutCubic
                }
            }

            pushExit: Transition {
                ScaleAnimator {
                    from: 1
                    to: mainStack.zoomFactor
                    duration: PlasmaCore.Units.longDuration * (mainStack.zoomFactor / 2)
                    easing.type: Easing.OutCubic
                }
                OpacityAnimator {
                    from: 1
                    to: 0
                    duration: PlasmaCore.Units.longDuration * (mainStack.zoomFactor / 2)
                    easing.type: Easing.OutCubic
                }
            }
        }

        Loader {
            id: inputPanel
            state: "hidden"
            property bool keyboardActive: item ? item.active : false
            onKeyboardActiveChanged: {
                if (keyboardActive) {
                    state = "visible"
                    // Otherwise the password field loses focus and virtual keyboard
                    // keystrokes get eaten
                    userListComponent.mainPasswordBox.forceActiveFocus();
                } else {
                    state = "hidden";
                }
            }

            source: Qt.platform.pluginName.includes("wayland") ? "components/VirtualKeyboard_wayland.qml" : "components/VirtualKeyboard.qml"
            anchors {
                left: parent.left
                right: parent.right
            }

            function showHide() {
                state = state == "hidden" ? "visible" : "hidden";
            }

            states: [
                State {
                    name: "visible"
                    PropertyChanges {
                        target: mainStack
                        y: Math.min(0, root.height - inputPanel.height - userListComponent.visibleBoundary)
                    }
                    PropertyChanges {
                        target: inputPanel
                        y: root.height - inputPanel.height
                        opacity: 1
                    }
                },
                State {
                    name: "hidden"
                    PropertyChanges {
                        target: mainStack
                        y: 0
                    }
                    PropertyChanges {
                        target: inputPanel
                        y: root.height - root.height/4
                        opacity: 0
                    }
                }
            ]
            transitions: [
                Transition {
                    from: "hidden"
                    to: "visible"
                    SequentialAnimation {
                        ScriptAction {
                            script: {
                                inputPanel.item.activated = true;
                                Qt.inputMethod.show();
                            }
                        }
                        ParallelAnimation {
                            NumberAnimation {
                                target: mainStack
                                property: "y"
                                duration: PlasmaCore.Units.longDuration
                                easing.type: Easing.InOutQuad
                            }
                            NumberAnimation {
                                target: inputPanel
                                property: "y"
                                duration: PlasmaCore.Units.longDuration
                                easing.type: Easing.OutQuad
                            }
                            OpacityAnimator {
                                target: inputPanel
                                duration: PlasmaCore.Units.longDuration
                                easing.type: Easing.OutQuad
                            }
                        }
                    }
                },
                Transition {
                    from: "visible"
                    to: "hidden"
                    SequentialAnimation {
                        ParallelAnimation {
                            NumberAnimation {
                                target: mainStack
                                property: "y"
                                duration: PlasmaCore.Units.longDuration
                                easing.type: Easing.InOutQuad
                            }
                            NumberAnimation {
                                target: inputPanel
                                property: "y"
                                duration: PlasmaCore.Units.longDuration
                                easing.type: Easing.InQuad
                            }
                            OpacityAnimator {
                                target: inputPanel
                                duration: PlasmaCore.Units.longDuration
                                easing.type: Easing.InQuad
                            }
                        }
                        ScriptAction {
                            script: {
                                inputPanel.item.activated = false;
                                Qt.inputMethod.hide();
                            }
                        }
                    }
                }
            ]
        }


        Component {
            id: userPromptComponent
            Login {
                showUsernamePrompt: true
                notificationMessage: root.notificationMessage
                loginScreenUiVisible: loginScreenRoot.uiVisible
                fontSize: parseInt(config.fontSize) + 2

                // using a model rather than a QObject list to avoid QTBUG-75900
                userListModel: ListModel {
                    ListElement {
                        name: ""
                        iconSource: ""
                    }
                    Component.onCompleted: {
                        // as we can't bind inside ListElement
                        setProperty(0, "name", i18nd("plasma_lookandfeel_org.kde.lookandfeel", "Type in Username and Password"));
                    }
                }

                onLoginRequest: {
                    root.notificationMessage = ""
                    sddm.login(username, password, sessionButton.currentIndex)
                }

                actionItems: [
                    //ActionButton {
                        //iconSource: "system-suspend"
                        //text: i18ndc("plasma_lookandfeel_org.kde.lookandfeel","Suspend to RAM","Sleep")
                        //fontSize: parseInt(config.fontSize) + 1
                        //onClicked: sddm.suspend()
                        //enabled: sddm.canSuspend
                        //visible: !inputPanel.keyboardActive
                    //},
                    //ActionButton {
                        //iconSource: "system-reboot"
                        //text: i18nd("plasma_lookandfeel_org.kde.lookandfeel","Restart")
                        //fontSize: parseInt(config.fontSize) + 1
                        //onClicked: sddm.reboot()
                        //enabled: sddm.canReboot
                        //visible: !inputPanel.keyboardActive
                    //},
                    //ActionButton {
                        //iconSource: "system-shutdown"
                        //text: i18nd("plasma_lookandfeel_org.kde.lookandfeel","Shut Down")
                        //fontSize: parseInt(config.fontSize) + 1
                        //onClicked: sddm.powerOff()
                        //enabled: sddm.canPowerOff
                        //visible: !inputPanel.keyboardActive
                    //},
                    ActionButton {
                        iconSource: "system-user-list"
                        text: i18nd("plasma_lookandfeel_org.kde.lookandfeel","List Users")
                        fontSize: parseInt(config.fontSize) + 1
                        onClicked: mainStack.pop()
                        visible: !inputPanel.keyboardActive
                    }
                ]
            }
        }

        DropShadow {
            id: logoShadow
            anchors.fill: logo
            source: logo
            visible: !softwareRendering && config.showlogo == "shown"
            horizontalOffset: 1
            verticalOffset: 1
            radius: 6
            samples: 14
            spread: 0.3
                                          // Soften the color a bit so it doesn't look so stark against light backgrounds
            color: root.lightBackground ? Qt.rgba(PlasmaCore.ColorScope.backgroundColor.r,
                                                  PlasmaCore.ColorScope.backgroundColor.g,
                                                  PlasmaCore.ColorScope.backgroundColor.b,
                                                  0.6)
                                        : "black" // black matches Breeze window decoration and desktopcontainment
            opacity: loginScreenRoot.uiVisible ? 0 : 1
            Behavior on opacity {
                //OpacityAnimator when starting from 0 is buggy (it shows one frame with opacity 1)"
                NumberAnimation {
                    duration: PlasmaCore.Units.longDuration
                    easing.type: Easing.InOutQuad
                }
            }
        }

        Image {
            id: logo
            visible: config.showlogo == "shown"
            source: config.logo
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: footer.top
            anchors.bottomMargin: PlasmaCore.Units.largeSpacing
            asynchronous: true
            sourceSize.height: height
            opacity: loginScreenRoot.uiVisible ? 0 : 1
            fillMode: Image.PreserveAspectFit
            height: Math.round(PlasmaCore.Units.gridUnit * 3.5)
            Behavior on opacity {
                // OpacityAnimator when starting from 0 is buggy (it shows one frame with opacity 1)"
                NumberAnimation {
                    duration: PlasmaCore.Units.longDuration
                    easing.type: Easing.InOutQuad
                }
            }
        }

        //Footer
        RowLayout {
            id: footer
            anchors {
                bottom: parent.bottom
                left: parent.left
                right: parent.right
                margins: PlasmaCore.Units.smallSpacing
            }

            Behavior on opacity {
                OpacityAnimator {
                    duration: PlasmaCore.Units.longDuration
                }
            }

            PlasmaComponents2.ToolButton {
                text: i18ndc("plasma_lookandfeel_org.kde.lookandfeel", "Button to show/hide virtual keyboard", "Virtual Keyboard")
                font.pointSize: config.fontSize
                iconSource: inputPanel.keyboardActive ? "/usr/share/sddm/themes/willow-light/WillowLightSDDM/icons/input-keyboard-virtual-on.svgz" : "/usr/share/sddm/themes/willow-light/WillowLightSDDM/icons/input-keyboard-virtual-off.svgz"
                onClicked: inputPanel.showHide()
                visible: inputPanel.status == Loader.Ready

                //added to align with buttons
                Layout.alignment: Qt.AlignBottom
            }

            KeyboardButton {
                font.pointSize: config.fontSize

                //added to align with buttons
                Layout.alignment: Qt.AlignBottom
            }

            SessionButton {
                id: sessionButton
                font.pointSize: config.fontSize

                //added to align with buttons
                Layout.alignment: Qt.AlignBottom
            }

            Item {
                Layout.fillWidth: true
            }

            Battery {
                fontSize: config.fontSize

                //added to align with power button
                Layout.alignment: Qt.AlignVCenter
            }

            Item {
                //probably takes up the full width
                // Layout.alignment: Qt.AlignTop

                id: powerMenuButton
                //not sure what adding 2 does here, but it feels right
                implicitHeight: (PlasmaCore.Units.gridUnit * 2) + 2
                width: height
                //icon for the button
                PlasmaCore.IconItem {
                    id: icon
                    source: "system-shutdown"
                    anchors.centerIn: parent

                    width: parent.width
                    height: width
                    colorGroup: PlasmaCore.ColorScope.colorGroup
                }
                //replicating ActionButton, without label
                Rectangle {
                    anchors.centerIn: icon
                    width: icon.width
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
                    anchors.fill: icon
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

//                 PowerMenu {
//                     id: menu
//                     menuOpacity: colorsForMenu.menuOpacity
//                     backgroundColor: colorsForMenu.backgroundColor
//                     foregroundColor: colorsForMenu.foregroundColor
//                 }
                PlasmaCore.ColorScope{
                    colorGroup: PlasmaCore.Theme.ViewColorGroup

                    QQC2.Menu {
                        id: menu
                        //idk the 5 is for like the button or something
                        //x: (implicitWidth/2) + padding + 5
                        y: -height

                        readonly property bool lightView: Math.max(PlasmaCore.ColorScope.backgroundColor.r, PlasmaCore.ColorScope.backgroundColor.g, PlasmaCore.ColorScope.backgroundColor.b) > 0.5
                        property color backgroundColor: PlasmaCore.ColorScope.backgroundColor
                        property color foregroundColor: PlasmaCore.ColorScope.textColor
                        property var menuOpacity: lightView ? .8 : .6

                        enter: Transition {
                            NumberAnimation {property: "opacity"; from: 0.0; to: 1.0; duration: 100}
                        }
                        exit: Transition {
                            NumberAnimation {property: "opacity"; from: 1.0; to: 0.0}
                        }
                        implicitWidth: 144
                        padding: 14

                        QQC2.Action {
                            icon.name: "system-shutdown"
                            text: i18nd("plasma_lookandfeel_org.kde.lookandfeel", "Shut Down")
                            enabled: sddm.canPowerOff
                            onTriggered: {
                            //commented out because SDDM may not need it.
                            //implement a proper delay on input
//                                 loginScreenRoot.uiVisible = false;
//                                 loginScreenRoot.hoverEnabled = false;
//                                 reviveLock.start()
                                sddm.powerOff()
                            }
                        }
                        QQC2.Action {
                            icon.name: "system-reboot"
                            text: i18nd("plasma_lookandfeel_org.kde.lookandfeel", "Restart")
                            enabled: sddm.canReboot
                            onTriggered: {
//                                 loginScreenRoot.uiVisible = false;
//                                 loginScreenRoot.hoverEnabled = false;
//                                 reviveLock.start()
                                sddm.reboot()
                            }
                        }
                        QQC2.MenuSeparator {
                            implicitHeight: 10
                            visible: false
                        }
                        QQC2.Action {
                            icon.name: "system-suspend"
                            text: i18nd("plasma_lookandfeel_org.kde.lookandfeel", "Sleep")
                            enabled: sddm.canSuspend
                            onTriggered: {
//                                 loginScreenRoot.uiVisible = false;
//                                 loginScreenRoot.hoverEnabled = false;
//                                 reviveLock.start()
                                sddm.suspend()
                            }
                        }
//                         //makes lockscreen usable again incase a program blocks logout
//                         Timer {
//                             id: reviveLock
//                             //value is arbitrary. It could be 15 or higher, whichever feels right
//                             interval: 10000
//                             running: false
//                             repeat: false
//                             onTriggered: {
//                                 loginScreenRoot.hoverEnabled = true;
//                             }
//
//                         }

                        delegate: QQC2.MenuItem {
                            id: menuItem
                            implicitHeight: 36
                            //visible: enabled

                            PlasmaCore.IconItem {
                                id: icon

                                source: action.icon.name
                                anchors.left: parent.left
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.margins: 6

                                width: 22
                                height: width

                                //does not inherit properly for some reason, so added this
                                colorGroup: PlasmaCore.Theme.ViewColorGroup

                            }

                            contentItem: PlasmaComponents3.Label {
                                id: label
                                text: menuItem.text
                                font: menuItem.font
                                //could replace with text color
                                color: foregroundColor
                                anchors {
                                    topMargin: (softwareRendering ? 1.5 : 1) * PlasmaCore.Units.smallSpacing
                                    left: icon.right
                                    margins: 6
                                    right: parent.right
                                }
                                style: softwareRendering ? Text.Outline : Text.Normal
                                styleColor: softwareRendering ? backgroundColor : "transparent" //no outline, doesn't matter
                                horizontalAlignment: Text.AlignLeft
                                verticalAlignment: Text.AlignVCenter
                                elide: Text.ElideRight
                            }
                            //hover highlight for items
                            background: Rectangle {
                                opacity: menuItem.highlighted ? .2 : 0
                                radius: menuOutline.radius - 3
                                //could replace with text color
                                color: foregroundColor
                            }
                        }


                    //menu appearance
                        background: Item {
                            id: menuBox
                            layer.enabled: true
                            clip: true
                            opacity: menu.menuOpacity

                            //might want to flip this to have outline +1 instead of -1 on menu
                            Rectangle {
                                id: menuOutline
                                anchors.fill: parent
                                anchors.margins: 10
                                radius: 8
                                color: "transparent"
                                opacity: 0.25
                                //could replace with text color
                                border.color: menu.foregroundColor
                                clip: true
                            }
                            Rectangle {
                                id: menuBackground
                                anchors.fill: menuOutline
                                anchors.margins: 1
                                radius: menuOutline.radius - 1
                                //could replace with background color
                                color: menu.backgroundColor
                                opacity: 1
                            }
                            DropShadow {
                                id: shadow
                                anchors.fill: menuBackground
                                source: menuBackground
                                verticalOffset: 5
                                //this value should probably be connected to margins
                                radius: 10
                                samples: 16
                                color: "black"
                                opacity: 0.3
                                transparentBorder: true
                                z: menuBackground.z - 1
                            }
                        }
                    }
                }
                //PlasmaCore.ColorScope {
                    //id: colorsForMenu
                    //colorGroup: PlasmaCore.Theme.ViewColorGroup
                    ////replace with actual code sometime
                    //readonly property bool lightView: Math.max(PlasmaCore.ColorScope.backgroundColor.r, PlasmaCore.ColorScope.backgroundColor.g, PlasmaCore.ColorScope.backgroundColor.b) > 0.5
                    //property color backgroundColor: PlasmaCore.ColorScope.backgroundColor
                    //property color foregroundColor: PlasmaCore.ColorScope.textColor
                    //property var menuOpacity: lightView ? .8 : .6
                //}
            }
        }
    }

    Connections {
        target: sddm
        function onLoginFailed() {
            notificationMessage = i18nd("plasma_lookandfeel_org.kde.lookandfeel", "Login Failed")
            footer.enabled = true
            mainStack.enabled = true
            userListComponent.userList.opacity = 1
        }
        function onLoginSucceeded() {
            //note SDDM will kill the greeter at some random point after this
            //there is no certainty any transition will finish, it depends on the time it
            //takes to complete the init
            mainStack.opacity = 0
            footer.opacity = 0
        }
    }

    onNotificationMessageChanged: {
        if (notificationMessage) {
            notificationResetTimer.start();
        }
    }

    Timer {
        id: notificationResetTimer
        interval: 3000
        onTriggered: notificationMessage = ""
    }
}
