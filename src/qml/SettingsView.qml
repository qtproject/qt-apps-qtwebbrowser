/****************************************************************************
**
** Copyright (C) 2016 The Qt Company Ltd.
** Contact: https://www.qt.io/licensing/
**
** This file is part of the Qt WebBrowser application.
**
** $QT_BEGIN_LICENSE:GPL$
** Commercial License Usage
** Licensees holding valid commercial Qt licenses may use this file in
** accordance with the commercial license agreement provided with the
** Software or, alternatively, in accordance with the terms contained in
** a written agreement between you and The Qt Company. For licensing terms
** and conditions see https://www.qt.io/terms-conditions. For further
** information use the contact form at https://www.qt.io/contact-us.
**
** GNU General Public License Usage
** Alternatively, this file may be used under the terms of the GNU
** General Public License version 3 or (at your option) any later version
** approved by the KDE Free Qt Foundation. The licenses are as published by
** the Free Software Foundation and appearing in the file LICENSE.GPL3
** included in the packaging of this file. Please review the following
** information to ensure the GNU General Public License requirements will
** be met: https://www.gnu.org/licenses/gpl-3.0.html.
**
** $QT_END_LICENSE$
**
****************************************************************************/

import QtQuick 2.5
import QtQuick.Layouts 1.0
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import Qt.labs.settings 1.0

import WebBrowser 1.0
Rectangle {
    id: root

    property bool privateBrowsingEnabled: appSettings[0].active
    property bool httpDiskCacheEnabled: appSettings[1].active
    property bool autoLoadImages: appSettings[2].active
    property bool javaScriptDisabled: appSettings[3].active
    // property bool pluginsEnabled: appSettings[4].active

    property var appSettings: [
        { "name": "Private Browsing",       "active": false, "notify": function(v) { privateBrowsingEnabled = v; } },
        { "name": "Enable HTTP Disk Cache", "active": true,  "notify": function(v) { httpDiskCacheEnabled = v; } },
        { "name": "Auto Load Images",       "active": true,  "notify": function(v) { autoLoadImages = v; } },
        { "name": "Disable JavaScript",     "active": false, "notify": function(v) { javaScriptDisabled = v; } },
//        { "name": "Enable Plugins",         "active": false, "notify": function(v) { pluginsEnabled = v; } }
    ]

    function save() {
        for (var i = 0; i < appSettings.length; ++i) {
            var setting = appSettings[i]

            listModel.get(i).active = setting.active
            // Do not persist private browsing mode
            if (setting.name === "Private Browsing")
                continue
            AppEngine.saveSetting(setting.name, setting.active)
        }
    }

    state: "disabled"

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
        anchors.fill: parent
        model: listModel
        delegate: Rectangle {
            height: 100
            width: 560
            anchors.horizontalCenter: parent.horizontalCenter
            Text {
                anchors.verticalCenter: parent.verticalCenter
                font.family: defaultFontFamily
                font.pixelSize: 28
                text: name
                color: sw.enabled ? "black" : "#929495"
            }
            Rectangle {
                anchors {
                    right: parent.right
                    verticalCenter: parent.verticalCenter
                }
                Switch {
                    id: sw
                    enabled: {
                        var ok = appSettings[index].name.indexOf("Disk Cache") < 0
                        return ok || !privateBrowsingEnabled
                    }
                    anchors.centerIn: parent
                    checked: {
                        if (enabled)
                            return active
                        return false
                    }
                    onClicked: {
                        var setting = appSettings[index]
                        setting.active = checked
                        setting.notify(checked)
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

        Component.onCompleted: {
            for (var i = 0; i < appSettings.length; ++i) {
                var setting = appSettings[i]
                var active = JSON.parse(AppEngine.restoreSetting(setting.name, setting.active))
                if (setting.active !== active) {
                    setting.active = active
                    setting.notify(active)
                }
                listModel.append(setting)
            }
            listView.forceLayout()
        }
        Component.onDestruction: root.save()
    }
}
