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

import QtQuick 2.1
import QtQuick.Controls 1.0
import QtWebEngine 1.1
import QtQuick.Layouts 1.0

import "assets"

Rectangle {
    property var requestedFeature;
    property url securityOrigin;
    property WebEngineView view;

    id: permissionBar
    visible: false
    height: 50

    onRequestedFeatureChanged: {
        message.text = securityOrigin + " wants to access " + message.textForFeature(requestedFeature);
    }


    RowLayout {
        spacing: 0
        anchors {
            fill: permissionBar
        }
        Rectangle {
            color: uiColor
            anchors {
                top: parent.top
                bottom: parent.bottom
            }
            Layout.fillWidth: true

            Text {
                id: message
                width: parent.width
                elide: Text.ElideRight
                horizontalAlignment: Text.AlignHCenter
                anchors {
                    leftMargin: 15
                    rightMargin: 15
                    verticalCenter: parent.verticalCenter
                    horizontalCenter: parent.horizontalCenter
                }
                font.family: defaultFontFamily
                font.pixelSize: 20
                color: "white"
                function textForFeature(feature) {
                    if (feature === WebEngineView.MediaAudioCapture)
                        return "your microphone"
                    if (feature === WebEngineView.MediaVideoCapture)
                        return "your camera"
                    if (feature === WebEngineView.MediaAudioVideoCapture)
                        return "your camera and microphone"
                    if (feature === WebEngineView.Geolocation)
                        return "your position"
                }
            }
        }
        Rectangle {
            width: 1
            anchors {
                top: parent.top
                bottom: parent.bottom
            }
            color: uiSeparatorColor
        }

        UIButton {
            id: acceptButton
            implicitHeight: permissionBar.height
            implicitWidth: toolBarSize
            buttonText: "Accept"
            textSize: 18
            Layout.alignment: Qt.AlignRight
            onClicked: {
                view.grantFeaturePermission(securityOrigin, requestedFeature, true);
                permissionBar.visible = false;
            }
        }
        Rectangle {
            width: 1
            anchors {
                top: parent.top
                bottom: parent.bottom
            }
            color: uiSeparatorColor
        }

        UIButton {
            buttonText: "Deny"
            textSize: 18
            implicitHeight: permissionBar.height
            implicitWidth: toolBarSize
            Layout.alignment: Qt.AlignRight
            onClicked: {
                view.grantFeaturePermission(securityOrigin, requestedFeature, false);
                permissionBar.visible = false
            }
        }
    }
}
