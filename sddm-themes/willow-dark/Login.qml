import "components"

import QtQuick 2.0
import QtQuick.Layouts 1.2

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents3

SessionManagementScreen {
    id: root
    property Item mainPasswordBox: passwordBox

    property bool showUsernamePrompt: !showUserList

    property string lastUserName
    property bool loginScreenUiVisible: false

    //the y position that should be ensured visible when the on screen keyboard is visible
    property int visibleBoundary: mapFromItem(loginButton, 0, 0).y
    onHeightChanged: visibleBoundary = mapFromItem(loginButton, 0, 0).y + loginButton.height + PlasmaCore.Units.smallSpacing

    property int fontSize: parseInt(config.fontSize) + 2

    signal loginRequest(string username, string password)

    onShowUsernamePromptChanged: {
        if (!showUsernamePrompt) {
            lastUserName = ""
        }
    }

    /*
    * Login has been requested with the following username and password
    * If username field is visible, it will be taken from that, otherwise from the "name" property of the currentIndex
    */
    function startLogin() {
        var username = showUsernamePrompt ? userNameInput.text : userList.selectedUser
        var password = passwordBox.text

        footer.enabled = false
        mainStack.enabled = false
        userListComponent.userList.opacity = 0.5

        //this is partly because it looks nicer
        //but more importantly it works round a Qt bug that can trigger if the app is closed with a TextField focused
        //DAVE REPORT THE FRICKING THING AND PUT A LINK
        loginButton.forceActiveFocus();
        loginRequest(username, password);
    }

    PlasmaComponents3.TextField {
        id: userNameInput
        font.pointSize: fontSize + 1
        Layout.fillWidth: true

        text: lastUserName

        color: "white"

        visible: showUsernamePrompt
        focus: showUsernamePrompt && !lastUserName //if there's a username prompt it gets focus first, otherwise password does
        placeholderText: i18nd("plasma_lookandfeel_org.kde.lookandfeel", "Username")

        onAccepted:
            if (root.loginScreenUiVisible) {
                passwordBox.forceActiveFocus()
            }
        background: TextFieldBackground {
            sourceSvg: "/usr/share/sddm/themes/willow-dark/WillowDarkSDDM/widgets/lineedit.svgz"
            property int padding: 8
        }

        leftPadding: background.padding
        topPadding: background.padding
        rightPadding: background.padding
        bottomPadding: background.padding
        ////leftPadding: (true ? background.margins.left : 0) + (control.mirrored ? inlineButtonRow.width : 0)
        ////topPadding: true ? background.margins.top : 0
        ////rightPadding: (true ? background.margins.right : 0) + (control.mirrored ? 0 : inlineButtonRow.width)
        ////bottomPadding: true ? background.margins.bottom : 0
    }

    RowLayout {
        Layout.fillWidth: true

        PlasmaComponents3.TextField {
            id: passwordBox
            font.pointSize: fontSize + 1
            Layout.fillWidth: true

            color: "white"

            placeholderText: i18nd("plasma_lookandfeel_org.kde.lookandfeel", "Password")
            focus: !showUsernamePrompt || lastUserName
            echoMode: TextInput.Password
            revealPasswordButtonShown: false // Disabled whilst SDDM does not have the breeze icon set loaded

            onAccepted: {
                if (root.loginScreenUiVisible) {
                    startLogin();
                }
            }

            background: TextFieldBackground {
                sourceSvg: "/usr/share/sddm/themes/willow-dark/WillowDarkSDDM/widgets/lineedit.svgz"
                property int padding: 8
            }

            leftPadding: background.padding
            topPadding: background.padding
            rightPadding: background.padding
            bottomPadding: background.padding

            visible: root.showUsernamePrompt || userList.currentItem.needsPassword

            Keys.onEscapePressed: {
                mainStack.currentItem.forceActiveFocus();
            }

            //if empty and left or right is pressed change selection in user switch
            //this cannot be in keys.onLeftPressed as then it doesn't reach the password box
            Keys.onPressed: {
                if (event.key === Qt.Key_Left && !text) {
                    userList.decrementCurrentIndex();
                    event.accepted = true
                }
                if (event.key === Qt.Key_Right && !text) {
                    userList.incrementCurrentIndex();
                    event.accepted = true
                }
            }

            Connections {
                target: sddm
                function onLoginFailed() {
                    passwordBox.selectAll()
                    passwordBox.forceActiveFocus()
                }
            }
        }

        PlasmaComponents3.Button {
            id: loginButton
            Accessible.name: i18nd("plasma_lookandfeel_org.kde.lookandfeel", "Log In")
            Layout.preferredHeight: passwordBox.implicitHeight
            Layout.preferredWidth: text.length == 0 ? loginButton.Layout.preferredHeight : -1

            PlasmaCore.SvgItem {
                opacity: parent.enabled ? 1 : 0.6
                svg: PlasmaCore.Svg { imagePath: "/usr/share/sddm/themes/willow-dark/WillowDarkSDDM/icons/go.svgz" }
                elementId: loginButton.text.length == 0 ? (root.LayoutMirroring.enabled ? "go-previous" : "go-next") : ""
                anchors.centerIn: parent
            }

            text: root.showUsernamePrompt || userList.currentItem.needsPassword ? "" : i18n("Log In")
            onClicked: startLogin();

            background: ButtonBackground {
                sourceSvg: "/usr/share/sddm/themes/willow-dark/WillowDarkSDDM/widgets/button.svgz"
                property int padding: 8
            }

            leftPadding: background.padding
            topPadding: background.padding
            rightPadding: background.padding
            bottomPadding: background.padding
        }
    }
}
