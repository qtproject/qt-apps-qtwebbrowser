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
import QtWebEngine 1.1
import QtWebEngine.experimental 1.0

import QtQuick.Controls 1.0
import QtQuick.Controls.Styles 1.0
import QtQuick.Layouts 1.0
import QtQuick.Window 2.1
import QtQuick.Controls.Private 1.0
import Qt.labs.settings 1.0
import QtQuick.Dialogs 1.2

import "assets"

Item {
    id: browserWindow

    property Item currentWebView: {
        return tabs.get(tabs.currentIndex) ? tabs.get(tabs.currentIndex).item.webView : null
    }

    property int toolBarHeight: 70
    property string uiColor: "#46a2da"
    property string uiBorderColor: "#7ebde5"
    property string buttonHighlightColor: "#e6e6e6"
    property string uiSelectionColor: "#fad84a"

    property int animationDuration: 200
    property int velocityThreshold: 500
    property int velocityY: 0
    property real touchY: 0
    property real touchReference: 0
    property bool touchGesture: false

    width: 1024
    height: 600
    visible: true
/*
    Settings {
        id : appSettings
        property alias autoLoadImages: loadImages.checked;
        property alias javaScriptEnabled: javaScriptEnabled.checked;
        property alias errorPageEnabled: errorPageEnabled.checked;
        property alias pluginsEnabled: pluginsEnabled.checked;
    }
*/
    Action {
        shortcut: "Ctrl+D"
        onTriggered: {
            downloadView.visible = !downloadView.visible
        }
    }

    Action {
        id: focus
        shortcut: "Ctrl+L"
        onTriggered: {
            navigation.addressBar.forceActiveFocus();
            navigation.addressBar.selectAll();
        }
    }
    Action {
        shortcut: "Ctrl+R"
        onTriggered: {
            if (currentWebView)
                currentWebView.reload()
        }
    }
    Action {
        id: newTabAction
        shortcut: "Ctrl+T"
        onTriggered: {
            tabs.createEmptyTab()
            navigation.addressBar.forceActiveFocus();
            navigation.addressBar.selectAll();
            tabs.makeCurrent(tabs.count - 1)
        }
    }
    Action {
        shortcut: "Ctrl+W"
        onTriggered: tabs.remove(tabs.currentIndex)
    }


    ToolBar {
        id: tabEditBar

        height: toolBarHeight

        style: ToolBarStyle {
            background: Rectangle {
                color: uiColor
            }
        }

        anchors {
            left: parent.left
            right: parent.right
            top: navigation.top
        }

        visible: opacity != 0.0
        opacity: tabs.viewState == "list" ? 1.0 : 0.0

        RowLayout {
            anchors.fill: parent
            UIButton {
                id: newTabButton
                source: "qrc:///newtab"
                onClicked: newTabAction.trigger()
            }
            Rectangle {
                width: 1
                anchors {
                    top: parent.top
                    bottom: parent.bottom
                }
                color: uiBorderColor
            }
            Rectangle {
                width: 50
                anchors {
                    top: parent.top
                    bottom: parent.bottom
                }
                color: uiColor
            }
            Rectangle {
                color: uiColor
                Layout.fillWidth: true
                anchors {
                    top: parent.top
                    bottom: parent.bottom
                }
                Rectangle {
                    color: "transparent"
                    border.color: "white"
                    border.width: 2
                    width: 40
                    height: 30
                    anchors.centerIn: parent
                    Text {
                        anchors.centerIn: parent
                        text: tabs.count
                        color: "white"
                        font.family: "Sans"
                        font.pixelSize: 20
                    }
                }
            }
            Rectangle {
                width: 1
                anchors {
                    top: parent.top
                    bottom: parent.bottom
                }
                color: uiBorderColor
            }
            UIButton {
                id:doneButton
                source: "qrc:///done"
                width: 120
                onClicked: {
                    tabs.viewState = "page"
                }
            }
        }
    }
    NavigationBar {
        id: navigation

        Behavior on y {
            NumberAnimation { duration: animationDuration }
        }

        y: {
            var diff = touchReference - touchY

            if (velocityY > velocityThreshold) {
                if (diff > 0)
                    return -toolBarHeight
                else
                    return 0
            }

            if (!touchGesture || diff == 0) {
                if (y < -toolBarHeight / 2)
                    return -toolBarHeight
                else
                    return 0
            }

            if (diff > toolBarHeight)
                return -toolBarHeight

            if (diff > 0) {
                if (y == -toolBarHeight)
                    return -toolBarHeight
                return -diff
            }

            // diff < 0

            if (y == 0)
                return 0

            diff = Math.abs(diff)
            if (diff >= toolBarHeight)
                return 0

            return -toolBarHeight + diff
        }

        anchors {
            left: parent.left
            right: parent.right
        }
    }
    PageView {
        id: tabs

        anchors {
            top: navigation.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }

        Component.onCompleted: {
            var tab = createEmptyTab()
            navigation.webView = tab.webView
            tab.webView.url = engine.fromUserInput("qt.io")
        }
        onCurrentIndexChanged: {
            if (!tabs.get(tabs.currentIndex))
                return
            navigation.webView = tabs.get(tabs.currentIndex).item.webView
        }
    }

    QtObject{
        id: acceptedCertificates

        property var acceptedUrls : []

        function shouldAutoAccept(certificateError){
            var domain = engine.domainFromString(certificateError.url)
            return acceptedUrls.indexOf(domain) >= 0
        }
    }

    MessageDialog {
        id: sslDialog

        property var certErrors: []
        icon: StandardIcon.Warning
        standardButtons: StandardButton.No | StandardButton.Yes
        title: "Server's certificate not trusted"
        text: "Do you wish to continue?"
        detailedText: "If you wish so, you may continue with an unverified certificate. " +
                      "Accepting an unverified certificate means " +
                      "you may not be connected with the host you tried to connect to.\n" +
                      "Do you wish to override the security check and continue?"
        onYes: {
            var cert = certErrors.shift()
            var domain = engine.domainFromString(cert.url)
            acceptedCertificates.acceptedUrls.push(domain)
            cert.ignoreCertificateError()
            presentError()
        }
        onNo: reject()
        onRejected: reject()

        function reject(){
            certErrors.shift().rejectCertificate()
            presentError()
        }
        function enqueue(error){
            certErrors.push(error)
            presentError()
        }
        function presentError(){
            visible = certErrors.length > 0
        }
    }
}
