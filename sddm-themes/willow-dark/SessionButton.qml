/*
    SPDX-FileCopyrightText: 2016 David Edmundson <davidedmundson@kde.org>

    SPDX-License-Identifier: LGPL-2.0-or-later
*/

import QtQuick 2.2

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents // Because PC3 ToolButton can't take a menu

import QtQuick.Controls 1.3 as QQC

PlasmaComponents.ToolButton {
    id: root
    property int currentIndex: -1

    implicitWidth: minimumWidth

    visible: menu.items.length > 1

    text: i18nd("plasma_lookandfeel_org.kde.lookandfeel", "Desktop Session: %1", instantiator.objectAt(currentIndex).text || "")

    Component.onCompleted: {
        currentIndex = sessionModel.lastIndex
    }

    menu: QQC.Menu {
        id: menu
        style: BreezeMenuStyle {}
        Instantiator {
            id: instantiator
            model: sessionModel
            onObjectAdded: menu.insertItem(index, object)
            onObjectRemoved: menu.removeItem( object )
            delegate: QQC.MenuItem {
                text: model.name
                onTriggered: {
                    root.currentIndex = model.index
                }
            }
        }
    }
}
