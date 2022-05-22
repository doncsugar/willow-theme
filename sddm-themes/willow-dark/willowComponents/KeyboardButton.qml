import QtQuick 2.2

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents // Because PC3 ToolButton can't take a menu
import org.kde.plasma.components 3.0 as PlasmaComponents3

//import QtQuick.Controls 1.3 as QQC
import QtQuick.Controls 2.12 as QQC

//import "willowComponents"

WillowToolButton {
    id: keyboardButton

    property int currentIndex: -1

    //needed for using themes set in Main.qml
    required property string themeDirectory

    text: i18nd("plasma_lookandfeel_org.kde.lookandfeel", "Keyboard Layout: %1", instantiator.objectAt(currentIndex).shortName)
//    implicitWidth: minimumWidth

//    visible: menu.items.length > 1
    //very hacky nonglobal way to handle this. Fix when you know how to tie the visibility of the button to the menu's state
    visible: keyboardMenu.count > 1 && opacity != 0;

//             && loginScreenRoot.uiVisible == true;

    //causes menu to disappear sooner than power menu for some reason
    //menu also closes even with mouse movement and the screen not locking
//    onVisibleChanged: keyboardMenu.close();

    Component.onCompleted: currentIndex = Qt.binding(function() {return keyboard.currentLayout});

    onClicked: keyboardMenu.visible ? keyboardMenu.close() : keyboardMenu.open();
    Keys.onEnterPressed: keyboardMenu.visible ? keyboardMenu.close() : keyboardMenu.open();
    Keys.onReturnPressed: keyboardMenu.visible ? keyboardMenu.close() : keyboardMenu.open();

    readonly property color menuForegroundColor: userColors.textColor
    readonly property color menuBackgroundColor: userColors.backgroundColor
    property var menuOpacity: lightView ? .8 : .6
    readonly property bool lightView: Math.max(userColors.backgroundColor.r,
                                                userColors.backgroundColor.g,
                                                userColors.backgroundColor.b) > 0.5
    //check if color is being applied properly
    PlasmaCore.ColorScope{
        id: userColors
        colorGroup: PlasmaCore.Theme.ViewColorGroup
    }

    WillowMenu {
        id: keyboardMenu

        //hackily chaining to the lockscreen so the menu disappears with everything else
        opacity: keyboardButton.opacity

        y: -height
        //the 1 at the end is the outline. It should not change with scale. Need to see how this all adds up
        x: -keyboardMenu.padding - Math.round(10 * PlasmaCore.Units.devicePixelRatio) + Math.round(1 * PlasmaCore.Units.devicePixelRatio)

        //maybe I should just give it a colorscope
        backgroundColor: menuBackgroundColor
        foregroundColor: menuForegroundColor

        //this code needs to choose either button's width or content, whichever is greater
        implicitWidth: {
            var result = 0;
            for (var i = 0; i < keyboardMenu.count; ++i) {
                var itemSize = keyboardMenu.itemAt(i).contentItem.implicitWidth;
                result = Math.max(itemSize, result);
            }
            //makes result even, calcs with padding and content margins
            return 2 * Math.round(result / 2)
                    + (keyboardMenu.padding * 2)
                    + 2 * Math.round(10 * PlasmaCore.Units.devicePixelRatio);
        }

        Instantiator {
            id: instantiator
            model: keyboard.layouts
            onObjectAdded: keyboardMenu.insertItem(index, object)
            onObjectRemoved: keyboardMenu.removeItem( object )
            delegate: QQC.MenuItem {

                property string shortName: modelData.shortName
                onTriggered: {
                    keyboard.currentLayout = model.index
                }

                contentItem: PlasmaComponents.Label {
                    id: label
                    text: modelData.longName
                    font: parent.font
                    //could replace with text color
                    color: menuForegroundColor
                    anchors {
//                        fill: parent
//                        topMargin: (softwareRendering ? 0.5 : 0) * PlasmaCore.Units.smallSpacing
                        topMargin: (softwareRendering ? 1.5 : 1) * PlasmaCore.Units.smallSpacing
                        left: icon.right
                        margins: Math.floor(6 * PlasmaCore.Units.devicePixelRatio)
                        right: parent.right
                    }
                    style: softwareRendering ? Text.Outline : Text.Normal
                    styleColor: softwareRendering ? backgroundColor : "transparent" //no outline, doesn't matter
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    //probably not a good idea to elide the keyboard name
                    elide: Text.ElideRight
                }
                background: Rectangle {
                    opacity: parent.highlighted ? .2 : 0
//                  radius: menuOutline.radius - (3 * PlasmaCore.Units.devicePixelRatio)
//                    this has no awareness of menuOutline, should fix
                    radius: Math.floor(8 * PlasmaCore.Units.devicePixelRatio) - Math.floor(3 * PlasmaCore.Units.devicePixelRatio)
                    //could replace with text color
                    color: menuForegroundColor
                }
            }
//            delegate: QQC.MenuItem {
//                text: modelData.longName
//                property string shortName: modelData.shortName
//                onTriggered: {
//                    keyboard.currentLayout = model.index
//                }
//            }
        }
    }

//    menu: QQC.Menu {
//        id: keyboardMenu
//        style: BreezeMenuStyle {}
//        Instantiator {
//            id: instantiator
//            model: keyboard.layouts
//            onObjectAdded: keyboardMenu.insertItem(index, object)
//            onObjectRemoved: keyboardMenu.removeItem( object )
//            delegate: QQC.MenuItem {
//                text: modelData.longName
//                property string shortName: modelData.shortName
//                onTriggered: {
//                    keyboard.currentLayout = model.index
//                }
//            }
//        }
//    }
}
