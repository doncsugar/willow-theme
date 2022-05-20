import QtQuick 2.6
import QtGraphicalEffects 1.0

Item {

    property alias source: icon.source
    property alias color: overlay.color

    Image {
        id: icon
        opacity: 0
        anchors.fill: parent
        sourceSize: Qt.size(parent.width, parent.height)
    }
    ColorOverlay {
        id: overlay
        anchors.fill: icon
        source: icon
    }
}
