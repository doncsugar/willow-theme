import QtQuick 2.8

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents3


import QtQuick.Controls 2.12

PlasmaComponents3.AbstractButton {
    id: root

    property string themeDirectory

    property int iconSize
    //this value effectively controls the height of the button. Set your buttons to
    //the same size so they look consistent
    property int baseIconSize: Math.round(16 * PlasmaCore.Units.devicePixelRatio)
    //uses a full path, file must be svgz
    property string iconPath
    //if full path not present, uses the name of an icon in the theme's icons/
    property string iconName
    //if path not present, selects button from theme's widgets/
    property string backgroundPath

    property int backgroundPadding

    contentItem: Row {
        spacing: parent.background.padding
        padding: parent.background.padding
        Item {
            //this item prevents the button from becoming too big because the icon is >16 (e.g. 22)
            width: iconSize ? baseIconSize : 0
            height: width
            anchors.verticalCenter: parent.verticalCenter

            AdaptiveIcon {
                width: root.iconSize
                height: width
                anchors.centerIn: parent

                source: root.iconPath ? root.iconPath : root.themeDirectory + "icons/" + root.iconName + ".svgz"
                color: PlasmaCore.ColorScope.textColor
            }
        }

        Label {
            text: root.text
            font: root.font
            verticalAlignment: Text.AlignVCenter
            color: PlasmaCore.ColorScope.textColor
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    background: ToolButton3Background {
        sourceSvg: backgroundPath ? backgroundPath : root.themeDirectory + "widgets/" + "button" + ".svgz"
        property int padding: root.backgroundPadding
    }
}
