/****************************************************************************
**
** Copyright (C) 2015 The Qt Company Ltd.
** Contact: http://www.qt.io/licensing/
**
** This file is part of the QtBrowser project.
**
** $QT_BEGIN_LICENSE:GPL$
** Commercial License Usage
** Licensees holding valid commercial Qt licenses may use this file in
** accordance with the commercial license agreement provided with the
** Software or, alternatively, in accordance with the terms contained in
** a written agreement between you and The Qt Company. For licensing terms
** and conditions see http://www.qt.io/terms-conditions. For further
** information use the contact form at http://www.qt.io/contact-us.
**
** GNU General Public License Usage
** Alternatively, this file may be used under the terms of the GNU
** General Public License version 2 as published by the Free Software
** Foundation and appearing in the file LICENSE.GPLv2 included in the
** packaging of this file. Please review the following information to
** ensure the GNU General Public License version 2 requirements
** will be met: http://www.gnu.org/licenses/old-licenses/gpl-2.0.html.
**
** GNU General Public License Usage
** Alternatively, this file may be used under the terms of the GNU
** General Public License version 3.0 as published by the Free Software
** Foundation and appearing in the file LICENSE.GPL included in the
** packaging of this file. Please review the following information to
** ensure the GNU General Public License version 3.0 requirements will be
** met: http://www.gnu.org/copyleft/gpl.html.
**
**
** $QT_END_LICENSE$
**
****************************************************************************/

import QtQuick 2.5
import QtQuick.Layouts 1.0
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import Qt.labs.settings 1.0

Rectangle {
    id: root

    property bool autoLoadImages: get(0)
    property bool javaScriptDisabled: get(1)
    property bool httpDiskCacheEnabled: get(2)
    property bool pluginsEnabled: get(3)
    property bool privateBrowsingEnabled: get(4)

    property var defaultValues: [{ "name": "Auto Load Images", "active": true },
        { "name": "Disable JavaScript", "active": false },
        { "name": "Enable HTTP Disk Cache", "active": true },
        { "name": "Enable Plugins", "active": false },
        { "name": "Private Browsing", "active": false }]

    function get(index) {
        var elem = listModel.get(index)
        if (!elem)
            return defaultValues[index].active
        return elem.active
    }

    state: "enabled"

    states: [
        State {
            name: "enabled"
            AnchorChanges {
                target: root
                anchors.top: navigation.bottom
            }
            PropertyChanges {
                target: settingsToolBar
                opacity: 1.0
            }
        },
        State {
            name: "disabled"
            AnchorChanges {
                target: root
                anchors.top: root.parent.bottom
            }
            PropertyChanges {
                target: settingsToolBar
                opacity: 0.0
            }
        }
    ]

    transitions: Transition {
        AnchorAnimation { duration: animationDuration; easing.type : Easing.InSine }
    }

    ListModel {
        id: listModel
    }

    ListView {
        id: listView
        leftMargin: 230
        rightMargin: leftMargin
        anchors.fill: parent
        model: listModel
        delegate: Rectangle {
            height: 100
            width: 560
            Text {
                anchors.verticalCenter: parent.verticalCenter
                font.family: defaultFontFamily
                font.pixelSize: 28
                text: name
                color: tch.checked ? "black" : "#929495"
            }
            Rectangle {
                anchors {
                    right: parent.right
                    verticalCenter: parent.verticalCenter
                }
                Switch {
                    id: tch
                    anchors.centerIn: parent
                    checked: active
                    onClicked: {
                        listModel.get(index).active = checked
                        listView.save()
                    }
                    style: SwitchStyle {
                        handle: Rectangle {
                            width: 42
                            height: 42
                            radius: height / 2
                            color: "white"
                            border.color: control.checked ? "#5caa14" : "#9b9b9b"
                            border.width: 1
                        }

                        groove: Rectangle {
                            implicitWidth: 72
                            height: 42
                            radius: height / 2
                            border.color: control.checked ? "#5caa14" : "#9b9b9b"
                            color: control.checked ? "#5cff14" : "white"
                            border.width: 1
                        }
                    }
                }
            }
        }
        function save() {
            var list = []
            for (var i = 0; i < listModel.count; ++i) {
                var elem = listModel.get(i)
                list[i] = { "name": elem.name, "active": elem.active }
            }

            if (!list.length)
                return

            engine.saveSetting("settings", JSON.stringify(list))
        }

        Component.onCompleted: {
            var string = engine.restoreSetting("settings", JSON.stringify(defaultValues))
            var list = JSON.parse(string)
            for (var i = 0; i < list.length; ++i) {
                var elem = list[i]
                listModel.append({ "name": elem.name, "active": elem.active })
            }
            listView.forceLayout()
        }
        Component.onDestruction: save()
    }
}
