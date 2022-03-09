
import QtQuick 2.8
import QtQuick.Controls 2.15
import QtGraphicalEffects 1.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents3

Menu {
    id: menu
    property var menuOpacity
    property color backgroundColor
    property color foregroundColor

    property string currentAction

    //used for logouts
    PlasmaCore.DataSource {
            id: executable
            engine: "executable"
            connectedSources: []
            property var callbacks: ({})
            onNewData: {
                var stdout = data["stdout"]

                if (callbacks[sourceName] !== undefined) {
                    callbacks[sourceName](stdout);
                }

                exited(sourceName, stdout)
                disconnectSource(sourceName) // exec finished
            }

            function exec(cmd, onNewDataCallback) {
                if (onNewDataCallback !== undefined){
                    callbacks[cmd] = onNewDataCallback
                }
                connectSource(cmd)
            }
            signal exited(string sourceName, string stdout)
    }

    //how to replace with content size values?
    implicitWidth: 145
    //this value is connected to blur radius
    padding: 14

    //items in menu list

    Action {
        icon.name: "system-shutdown"
        text: i18nd("plasma_lookandfeel_org.kde.lookandfeel", "Shut Down")
        onTriggered: {
            lockScreenRoot.uiVisible = false;
            lockScreenRoot.hoverEnabled = false;
            currentAction = "shutdown";
            actionDelay.start();
        }
    }
    Action {
        icon.name: "system-reboot"
        text: i18nd("plasma_lookandfeel_org.kde.lookandfeel", "Restart")
        onTriggered: {
            lockScreenRoot.uiVisible = false;
            lockScreenRoot.hoverEnabled = false;
            currentAction = "reboot";
            actionDelay.start();
        }
    }
    //I really don't like seeing hibernate unless I can use it
    MenuSeparator {
        implicitHeight: 10
        height: implicitHeight * root.suspendToDiskSupported
        visible: false
        enabled: root.suspendToDiskSupported
    }
    Action {
        icon.name: "system-suspend-hibernate"
        text: i18nd("plasma_lookandfeel_org.kde.lookandfeel", "Hibernate")
        enabled: root.suspendToDiskSupported
        onTriggered: {
            lockScreenRoot.uiVisible = false;
            lockScreenRoot.hoverEnabled = false;
            currentAction = "hibernate";
            actionDelay.start();
        }
    }
    MenuSeparator {
        implicitHeight: 10
        visible: false
    }
    Action {
        icon.name: "system-suspend"
        text: i18nd("plasma_lookandfeel_org.kde.lookandfeel", "Sleep")
        enabled: root.suspendToRamSupported
        onTriggered: {
            lockScreenRoot.uiVisible = false;
            lockScreenRoot.hoverEnabled = false;
            currentAction = "sleep";
            actionDelay.start();
        }
    }

    Timer {
        id: actionDelay
        //feels right on my machine
        interval: 3000
        running: false
        repeat: false
        onTriggered: {
            switch (currentAction) {
                case "sleep":
                    //unsure which is better to use
                    //qdbus org.kde.Solid.PowerManagement /org/freedesktop/PowerManagement Suspend
//                    executable.exec("qdbus local.org_kde_powerdevil /org/kde/Solid/PowerManagement/Actions/SuspendSession suspendToRam");
                    root.suspendToRam();
                    break;
                case "reboot":
                    executable.exec("qdbus org.kde.ksmserver /KSMServer logout 0 1 2");
                    break;
                case "shutdown":
                    executable.exec("qdbus org.kde.ksmserver /KSMServer logout 0 2 2");
                    break;
                case "hibernate":
                    root.suspendToDisk()
                    break;
            }
            reviveLock.start();
        }
    }

    //makes lockscreen usable again incase a program blocks logout
    Timer {
        id: reviveLock
        //value is arbitrary. It could be 15 or higher, whichever feels right
        interval: 10000
        running: false
        repeat: false
        onTriggered: {
            lockScreenRoot.hoverEnabled = true;
        }

    }
    //uh, makes items with icons and text
    delegate: MenuItem {
        id: menuItem
        implicitHeight: 36
        //hides items that aren't enabled
        height: !!enabled * implicitHeight
        //make it reset timer so it doesn't time out while using menu
        //and highlighting different things
        PlasmaCore.IconItem {
            id: icon
            //hides icon
            visible: enabled

            source: action.icon.name
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            anchors.margins: 6

            width: 22
            height: width

            //does not inherit properly for some reason, so added this
            colorGroup: PlasmaCore.Theme.ViewColorGroup

            // active: mouseArea.containsMouse || root.activeFocus
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
        opacity: menuOpacity

        //might want to flip this to have outline +1 instead of -1 on menu
        Rectangle {
            id: menuOutline
            anchors.fill: parent
            anchors.margins: 10
            radius: 8
            color: "transparent"
            opacity: 0.25
            //could replace with text color
            border.color: foregroundColor
            clip: true
        }
        Rectangle {
            id: menuBackground
            anchors.fill: menuOutline
            anchors.margins: 1
            radius: menuOutline.radius - 1
            //could replace with background color
            color: backgroundColor
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
