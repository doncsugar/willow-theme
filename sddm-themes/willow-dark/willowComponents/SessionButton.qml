/*
    SPDX-FileCopyrightText: 2016 David Edmundson <davidedmundson@kde.org>

    SPDX-License-Identifier: LGPL-2.0-or-later
*/

import QtQuick 2.2

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents // Because PC3 ToolButton can't take a menu
//switch to 3 button if unsatisfied
import org.kde.plasma.components 3.0 as PlasmaComponents3


//import QtQuick.Controls 1.3 as QQC
import QtQuick.Controls 2.12 as QQC

//import "willowComponents"


WillowToolButton {
    id: root
    property int currentIndex: -1

    //doesn't exist in pc3 button?
//    implicitWidth: minimumWidth

//    visible: menu.items.length > 1
    //very hacky nonglobal way to handle this. Fix when you know how to tie the visibility of the button to the menu's state
    visible: sessionMenu.count > 1 && opacity != 0;
//    && loginScreenRoot.uiVisible == true

    //causes menu to disappear sooner than power menu for some reason
    //menu also closes even with mouse movement and the screen not locking
//    onVisibleChanged: sessionMenu.close();

    text: i18nd("plasma_lookandfeel_org.kde.lookandfeel", "Desktop Session: %1", instantiator.objectAt(currentIndex).contentItem.text || "")

    Component.onCompleted: {
        currentIndex = sessionModel.lastIndex
    }

    onClicked: sessionMenu.visible ? sessionMenu.close() : sessionMenu.open();
    Keys.onEnterPressed: sessionMenu.visible ? sessionMenu.close() : sessionMenu.open();
    Keys.onReturnPressed: sessionMenu.visible ? sessionMenu.close() : sessionMenu.open();

    activeFocusOnTab: true;
    focus: true;

    readonly property color menuForegroundColor: userColors.textColor
    readonly property color menuBackgroundColor: userColors.backgroundColor
    property var menuOpacity: lightView ? .8 : .6
    readonly property bool lightView: Math.max(userColors.backgroundColor.r,
                                                userColors.backgroundColor.g,
                                                userColors.backgroundColor.b) > 0.5
    PlasmaCore.ColorScope{
        id: userColors
        colorGroup: PlasmaCore.Theme.ViewColorGroup
    }

    WillowMenu {
        id: sessionMenu

        //hackily chaining to the lockscreen so the menu disappears with everything else
        opacity: root.opacity

        //why is there no code for the y being -height?

        //maybe I should just give it a colorscope
        backgroundColor: menuBackgroundColor
        foregroundColor: menuForegroundColor

        //how to replace with content size values?
        //this code assumes that the content will never exceed the button width
        //should use button's width or content, whichever larger
        implicitWidth: {
            var result = 0;
            for (var i = 0; i < sessionMenu.count; ++i) {
                var itemSize = sessionMenu.itemAt(i).contentItem.implicitWidth;
                result = Math.max(itemSize, result);
            }
            return Math.max((result + (sessionMenu.padding * 2) + 10), parent.width)
        }

        Instantiator {
            id: instantiator
            model: sessionModel
            onObjectAdded: sessionMenu.insertItem(index, object)
            onObjectRemoved: sessionMenu.removeItem( object )
            //uh, makes items with icons and text
            delegate: QQC.MenuItem {
                id: menuItem

                onTriggered: {
                    root.currentIndex = model.index
                }

              contentItem: PlasmaComponents.Label {
                  id: label
                  text: model.name
                  font: menuItem.font
                  //could replace with text color
                  color: menuForegroundColor
                  anchors {
                      fill: parent
                      topMargin: (softwareRendering ? 0.5 : 0) * PlasmaCore.Units.smallSpacing
                  }
                  style: softwareRendering ? Text.Outline : Text.Normal
                  styleColor: softwareRendering ? backgroundColor : "transparent" //no outline, doesn't matter
                  horizontalAlignment: Text.AlignHCenter
                  verticalAlignment: Text.AlignVCenter
                  elide: Text.ElideRight
              }
              //hover highlight for items
                background: Rectangle {
                    opacity: menuItem.highlighted ? .2 : 0
//                  radius: menuOutline.radius - (3 * PlasmaCore.Units.devicePixelRatio)
                    //this has no awareness of menuOutline, should fix
                    radius: Math.floor(8 * PlasmaCore.Units.devicePixelRatio) - Math.floor(3 * PlasmaCore.Units.devicePixelRatio)
                    //could replace with text color
                    color: menuForegroundColor
                }
            }
        }
    }

//    menu: QQC.Menu {
//        id: menu
//        style: BreezeMenuStyle {}
//        Instantiator {
//            id: instantiator
//            model: sessionModel
//            onObjectAdded: menu.insertItem(index, object)
//            onObjectRemoved: menu.removeItem( object )
//            delegate: QQC.MenuItem {
//                text: model.name
//                onTriggered: {
//                    root.currentIndex = model.index
//                }
//            }
//        }
//    }
}
