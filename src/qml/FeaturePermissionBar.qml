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
            height: parent.height
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
            height: parent.height
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
            height: parent.height
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
