import QtQuick 2.8
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.12 as QQC2
import QtGraphicalEffects 1.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents3

QQC2.Menu {
    id: menu


    //idk the 5 is for like the button or something
    //x: (implicitWidth/2) + padding + 5
    y: -height

    required property string iconPath

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

    //how to replace with content size values?
    implicitWidth: Math.floor(145 * PlasmaCore.Units.devicePixelRatio)
    //this value is connected to blur radius
    padding: Math.floor(14 * PlasmaCore.Units.devicePixelRatio)

    delegate: QQC2.MenuItem {
        id: menuItem
        implicitHeight: Math.floor(36 * PlasmaCore.Units.devicePixelRatio)
        //hides items that aren't enabled
        //commented out because our actions are static
//      height: !!enabled * implicitHeight
        //visible: enabled
        PlasmaCore.SvgItem {
            id: icon

            opacity: enabled ? 1 : 0.6

            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            anchors.margins: Math.floor(6 * PlasmaCore.Units.devicePixelRatio)

            width: Math.floor(22  * PlasmaCore.Units.devicePixelRatio)
            height: width

            svg: PlasmaCore.Svg {
                //is it possible to use iconItem with an absolute path?
//                imagePath: "/usr/share/sddm/themes/willow-light/WillowLightSDDM/icons/" + action.icon.name + ".svgz"
                imagePath: menu.iconPath + action.icon.name + ".svgz"
            }

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
                margins: Math.floor(6 * PlasmaCore.Units.devicePixelRatio)
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
            radius: menuOutline.radius - (3 * PlasmaCore.Units.devicePixelRatio)
            //could replace with text color
            color: foregroundColor
        }
    }


//menu appearance
    background: Item {
        id: menuBox
        layer.enabled: true
        clip: true
        //hackily chaining to the lockscreen so the menu disappears with everything else
        opacity: menu.menuOpacity

        //might want to flip this to have outline +1 instead of -1 on menu
        Rectangle {
            id: menuOutline
            anchors.fill: parent
            anchors.margins: Math.floor(10 * PlasmaCore.Units.devicePixelRatio)
            radius: Math.floor(8 * PlasmaCore.Units.devicePixelRatio)
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
            verticalOffset: Math.floor(5 * PlasmaCore.Units.devicePixelRatio)
            //this value should probably be connected to margins
            radius: Math.floor(10 * PlasmaCore.Units.devicePixelRatio)
            //can't help but feel like this needs to change with scaling
            samples: Math.floor(16 * PlasmaCore.Units.devicePixelRatio)
            color: "black"
            opacity: 0.3
            transparentBorder: true
            z: menuBackground.z - 1
        }
    }
}
