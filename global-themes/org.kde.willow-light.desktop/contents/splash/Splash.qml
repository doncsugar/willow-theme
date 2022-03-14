/*
    SPDX-FileCopyrightText: 2014 Marco Martin <mart@kde.org>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick 2.5
import QtQuick.Window 2.2
import org.kde.plasma.core 2.0 as PlasmaCore

import QtGraphicalEffects 1.0

Rectangle {
    id: root
    //ideally shows set color if user isn't using a wallpaper
    color: (root.userPluginArray === "org.kde.color") ? Qt.rgba(colorRGB[0],colorRGB[1],colorRGB[2],colorRGB[3]) : "black"

    PlasmaCore.DataSource {
        id: executable
        engine: "executable"
        connectedSources: []
        onNewData: {
            var exitCode = data["exit code"]
            var exitStatus = data["exit status"]
            var stdout = data["stdout"]
            var stderr = data["stderr"]
            exited(sourceName, exitCode, exitStatus, stdout, stderr)
            disconnectSource(sourceName) // cmd finished
        }
        function exec(cmd) {
            connectSource(cmd)
        }
        signal exited(string command, int exitCode, int exitStatus, string stdout, string stderr)
    }
    property var wallpaperArray: ''
    property string wallpaperDir: ''
    //becomes an array of strings
    property var colorRGB: ''
    //whether they're using [color or image]
    property var userPluginArray: ''
    //all of this code does nothing
    property string checkWallpaper: "qdbus org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript 'var allDesktops = desktops();for (i=0;i<allDesktops.length;i++) {d = allDesktops[i];d.currentConfigGroup = Array(\"Wallpaper\", \"org.kde.image\", \"General\");print(d.readConfig(\"Image\"))}';"
    property string checkColor: "qdbus org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript 'var allDesktops = desktops();for (i=0;i<allDesktops.length;i++) {d = allDesktops[i];d.currentConfigGroup = Array(\"Wallpaper\", \"org.kde.color\", \"General\");print(d.readConfig(\"Color\"))}';"
    property string checkPlugin: "qdbus org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript 'var allDesktops = desktops();for (i=0;i<allDesktops.length;i++) {d = allDesktops[i];print(d.readConfig(\"wallpaperplugin\"))}';"
    property string setLink: ".local/share/plasma/look-and-feel/org.kde.willow.desktop/contents/splash/parsePaper.sh"

    Connections {
        target: executable
//         https://stackoverflow.com/questions/62297192/qml-connections-implicitly-defined-onfoo-properties-in-connections-are-deprecat
//check what qt version kubuntu is on
        onExited: {
            if (command === root.checkWallpaper) {
                var outputText = stdout.replace('\n', ' ').trim();
                root.wallpaperArray = outputText.split("file://");
                //get the first wallpaper after splitting by file://
                //remove %u if it gets added for some reason
                root.wallpaperDir = "file://" + root.wallpaperArray[1].replace('%u', '');
            }
            if (command === root.checkColor) {
                root.colorRGB = stdout.replace('\n', ' ').trim() + ",255";
                root.colorRGB = root.colorRGB.split(",");
            }
            if (command === root.checkPlugin) {
                var outputPlugin = stdout.replace('\n', ' ').trim();
                outputPlugin = outputPlugin.replace('\n', ' ').trim();
                outputPlugin = outputPlugin.split("org.");
                root.userPluginArray = "org." + outputPlugin[1];
            }
        }
    }

    Item {
        Component.onCompleted: {
            executable.exec(root.setLink);
            executable.exec(root.checkPlugin);
            executable.exec(root.checkColor);
            executable.exec(root.checkWallpaper);
        }
    }
    property int stage

    onStageChanged: {
        if (stage == 2) {
            introAnimation.running = true;
        } 
    }
    property int shellSpeed: 25000

    Image {
        id: wallpaper
        anchors.fill: parent
//         sourceSize.width: parent.width
//         sourceSize.height: parent.height
        //probably should match user's
        fillMode: Image.PreserveAspectCrop
        smooth: true;
        //wallpaperDir.includes("file") ? wallpaperDir : "wallpaper"
        //source: wallpaperDir !== "" ? wallpaperDir : "wallpaper"
        source: wallpaperDir.includes("file") ? wallpaperDir : "wallpaper"
        visible: !(root.userPluginArray === "org.kde.color") ? true : false
    }

    Image {
        id: plasmaShell
        //match SDDM/lockscreen avatar positioning
        property real size: PlasmaCore.Units.gridUnit * 8 * 2

        anchors.centerIn: parent

        source: "images/plasmaShell.svgz"

        sourceSize.width: size
        sourceSize.height: size
    }
    DropShadow {
        anchors.fill: plasmaShell
        source: plasmaShell
        cached: true;
        verticalOffset: 1
        radius: 8
        samples: 16
        color: "black"
        opacity: 0.2
        transparentBorder: true;
    }
    Image {
        id: plasmaElectronShadow
        //match SDDM/lockscreen avatar positioning
        property real size: PlasmaCore.Units.gridUnit * 8 * 2

        anchors.horizontalCenter: plasmaElectrons.horizontalCenter
        anchors.top: plasmaElectrons.top
        anchors.topMargin: 1


        source: "images/plasmaShadow.svgz"

        sourceSize.width: size
        sourceSize.height: size
        RotationAnimator on rotation {
            from: 0
            to: 360
            duration: shellSpeed
            loops: Animation.Infinite
            // Don't want it to animate at all if the user has disabled animations
            running: PlasmaCore.Units.longDuration > 1
        }
    }

    Image {
        id: plasmaElectrons
        //match SDDM/lockscreen avatar positioning
        property real size: PlasmaCore.Units.gridUnit * 8 * 2

        anchors.centerIn: parent

        source: "images/plasmaElectrons.svgz"

        sourceSize.width: size
        sourceSize.height: size
        RotationAnimator on rotation {
            from: 0
            to: 360
            duration: shellSpeed
            loops: Animation.Infinite
            // Don't want it to animate at all if the user has disabled animations
            running: PlasmaCore.Units.longDuration > 1
        }
    }

    Image {
        id: plasmaElectronsInnerShadow
        //match SDDM/lockscreen avatar positioning
        property real size: PlasmaCore.Units.gridUnit * 8 * 2

        anchors.horizontalCenter: plasmaElectronsInner.horizontalCenter
        anchors.top: plasmaElectronsInner.top
        anchors.topMargin: 1


        source: "images/plasmaShadowInner.svgz"

        sourceSize.width: size
        sourceSize.height: size
        RotationAnimator on rotation {
            from: 0
            to: -360
            duration: shellSpeed
            loops: Animation.Infinite
            // Don't want it to animate at all if the user has disabled animations
            running: PlasmaCore.Units.longDuration > 1
        }
    }
    Image {
        id: plasmaElectronsInner
        //match SDDM/lockscreen avatar positioning
        property real size: PlasmaCore.Units.gridUnit * 8 * 2

        anchors.centerIn: parent

        source: "images/plasmaElectronsInner.svgz"

        sourceSize.width: size
        sourceSize.height: size
        RotationAnimator on rotation {
            from: 0
            to: -360
            duration: shellSpeed
            loops: Animation.Infinite
            // Don't want it to animate at all if the user has disabled animations
            running: PlasmaCore.Units.longDuration > 1
        }
    }

    // TODO: port to PlasmaComponents3.BusyIndicator
    //Image {
        //id: busyIndicator
        ////in the middle of the remaining space
        //y: parent.height - (parent.height - plasmaShell.y) / 2 - height/2
        //anchors.horizontalCenter: parent.horizontalCenter
        //source: "images/busywidget.svgz"
        //sourceSize.height: PlasmaCore.Units.gridUnit * 2
        //sourceSize.width: PlasmaCore.Units.gridUnit * 2
        //RotationAnimator on rotation {
            //id: rotationAnimator
            //from: 0
            //to: 360
            //// Not using a standard duration value because we don't want the
            //// animation to spin faster or slower based on the user's animation
            //// scaling preferences; it doesn't make sense in this context
            //duration: 2000
            //loops: Animation.Infinite
            //// Don't want it to animate at all if the user has disabled animations
            //running: PlasmaCore.Units.longDuration > 1
        //}
    //}
    DropShadow {

        anchors.fill: logoText
        source: logoText
        verticalOffset: 1
        radius: 8
        samples: 16
        color: "black"
        opacity: 1
        transparentBorder: true;
    }
    Text {
        id: logoText
        color: "white"
//             font.bold: true;
        font.pixelSize: 18
        font.weight: Font.Normal
        // Work around Qt bug where NativeRendering breaks for non-integer scale factors
        // https://bugreports.qt.io/browse/QTBUG-67007
        renderType: Screen.devicePixelRatio % 1 !== 0 ? Text.QtRendering : Text.NativeRendering
        anchors.horizontalCenter: plasmaShell.horizontalCenter
        anchors.top: plasmaShell.bottom
        anchors.margins: PlasmaCore.Units.gridUnit
        text: i18ndc("plasma_lookandfeel_org.kde.lookandfeel", "This is the first text the user sees while starting in the splash screen, should be translated as something short, is a form that can be seen on a product. Plasma is the project name so shouldn't be translated.", "Plasma made by KDE")
    }


    Rectangle {
        id: overlay
        anchors.fill: parent
        color: "black"
    }

    OpacityAnimator {
        id: introAnimation
        running: false
        target: overlay
        from: 1
        to: 0
        duration: PlasmaCore.Units.veryLongDuration * 2
        easing.type: Easing.InOutQuad
    }
}
