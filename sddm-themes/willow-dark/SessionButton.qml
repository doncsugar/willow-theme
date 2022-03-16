
/*
    SPDX-FileCopyrightText: 2016 David Edmundson <davidedmundson@kde.org>

    SPDX-License-Identifier: LGPL-2.0-or-later
*/

//import QtQuick 2.2
import QtQuick 2.6

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents // Because PC3 ToolButton can't take a menu

import QtQuick.Controls.Styles.Plasma 2.0 as Styles

//import QtQuick.Controls 1.3 as QQC
import QtQuick.Controls 2.12 as QQC

//added for shadow
import QtGraphicalEffects 1.0

PlasmaComponents.ToolButton {
    id: root
    property int currentIndex: -1

    implicitWidth: minimumWidth

    visible: menu.count > 1

    text: i18nd("plasma_lookandfeel_org.kde.lookandfeel", "Desktop Session: %1", instantiator.objectAt(currentIndex).contentItem.text || "")

    Component.onCompleted: {
        currentIndex = sessionModel.lastIndex
    }

    onClicked: menu.visible ? menu.close() : menu.open();
    Keys.onEnterPressed: menu.visible ? menu.close() : menu.open();
    Keys.onReturnPressed: menu.visible ? menu.close() : menu.open();

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
        colorGroup: PlasmaCore.Theme.ColorGroup
    }

    style: Styles.ToolButtonStyle {
        id: style
        background: ToolButtonBackground {
            sourceSvg: "/usr/share/sddm/themes/willow-dark/WillowDarkSDDM/widgets/button.svgz"
            property int padding: 8
        }
    }

    QQC.Menu {
        id: menu
        y: -height

        enter: Transition {
            NumberAnimation {property: "opacity"; from: 0.0; to: 1.0; duration: 100}
        }
        exit: Transition {
            NumberAnimation {property: "opacity"; from: 1.0; to: 0.0}
        }

        //how to replace with content size values?
        implicitWidth: {
            var result = 0;
            for (var i = 0; i < menu.count; ++i) {
                var itemSize = menu.itemAt(i).contentItem.implicitWidth;
                result = Math.max(itemSize, result);
            }
            return Math.max((result + (menu.padding * 2) + 10), parent.width)
        }
        //this value is connected to blur radius
        padding: 14

        Instantiator {
            id: instantiator
            model: sessionModel
            onObjectAdded: menu.insertItem(index, object)
            onObjectRemoved: menu.removeItem( object )
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
                  radius: menuOutline.radius - 3
                  //could replace with text color
                  color: menuForegroundColor
              }
            }
        }

        background: Item {
            id: menuBox
            layer.enabled: true
            clip: true
            //menuOpacity
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
                border.color: menuForegroundColor
                clip: true
            }
            Rectangle {
                id: menuBackground
                anchors.fill: menuOutline
                anchors.margins: 1
                radius: menuOutline.radius - 1
                //could replace with background color
                color: root.menuBackgroundColor
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
