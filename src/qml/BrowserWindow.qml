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

    property alias currentWebView: tabs.currentWebView
    property int visibility: Window.Windowed
    property int previousVisibility: Window.Windowed

    property string uiColor: "#46a1da"
    property string uiSelectionColor: "#fad84a"
    property string uiBorderColor: "#377fac"

    property QtObject otrProfile: WebEngineProfile {
        offTheRecord: true
    }

    property bool isFullScreen: visibility == Window.FullScreen
    onIsFullScreenChanged: {
        // This is for the case where the system forces us to leave fullscreen.
        if (currentWebView && !isFullScreen) {
            currentWebView.state = ""
            if (currentWebView.isFullScreen)
                currentWebView.fullScreenCancelled()
        }
    }

    height: 600
    width: 800
    visible: true

    Settings {
        id : appSettings
        property alias autoLoadImages: loadImages.checked;
        property alias javaScriptEnabled: javaScriptEnabled.checked;
        property alias errorPageEnabled: errorPageEnabled.checked;
        property alias pluginsEnabled: pluginsEnabled.checked;
    }

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
            addressBar.forceActiveFocus();
            addressBar.selectAll();
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
        shortcut: "Ctrl+T"
        onTriggered: {
            tabs.createEmptyTab()
            tabs.currentIndex = tabs.count - 1
            addressBar.forceActiveFocus();
            addressBar.selectAll();
        }
    }
    Action {
        shortcut: "Ctrl+W"
        onTriggered: {
            if (tabs.count == 1)
                browserWindow.close()
            else
                tabs.remove(tabs.currentIndex)
        }
    }

    Action {
        shortcut: "Escape"
        onTriggered: {
            if (browserWindow.isFullScreen)
                browserWindow.visibility = browserWindow.previousVisibility
        }
    }

    ToolBar {
        id: navigationBar

        style: ToolBarStyle {
            padding {
                left: 8
                right: 8
                top: 3
                bottom: 3
            }
            background: Rectangle {
                implicitWidth: 100
                implicitHeight: 50
                color: "#46a1da"
            }
        }

        RowLayout {
            anchors.fill: parent;

            UIButton {
                id: backButton
                source: "qrc:///previous.png"
                color: uiColor
                onClicked: tabs.currentWebView.goBack()
                enabled: tabs.currentWebView && tabs.currentWebView.canGoBack
            }

            UIButton {
                id: forwardButton
                source: "qrc:///next.png"
                color: uiColor
                onClicked: tabs.currentWebView.goForward()
                enabled: tabs.currentWebView && tabs.currentWebView.canGoForward
            }


            TextField {
                id: addressBar
                UIButton {
                    id: reloadButton
                    source: currentWebView && currentWebView.loading ? "qrc:///stop.png" : "qrc:///refresh.png"
                    anchors {
                        rightMargin: 10
                        right: parent.right
                        verticalCenter: addressBar.verticalCenter;
                    }
                    onClicked: currentWebView.loading ? currentWebView.stop() : currentWebView.reload()
                }
                style: TextFieldStyle {
                    textColor: "black"
                    font.family: "Helvetica"
                    font.pointSize: 18
                    selectionColor: uiSelectionColor
                    background: Rectangle {
                        implicitWidth: 200
                        implicitHeight: 40
                        border.color: uiBorderColor
                        border.width: 1
                    }
                    padding {
                        right: 10
                        left: 10
                    }
                }
                focus: true
                Layout.fillWidth: true
                text: tabs.currentWebView ? tabs.currentWebView.url : "about:blank"
                onAccepted: {
                    console.log("WEBVIEW "+ tabs.get(tabs.currentIndex).item.webView.url)
                    tabs.get(tabs.currentIndex).item.webView.url = engine.fromUserInput(text)
                    tabs.viewState = "page"
                }
            }

            UIButton {
                id: pageViewButton
                source: "qrc:///tabs.png"
                color: uiColor
                onClicked: {
                    if (tabs.viewState == "list") {
                        tabs.viewState = "page"
                    } else {
                        tabs.viewState = "list"
                    }
                    console.log("BUTTON  " + tabs.viewState)
                }
            }

            ToolButton {
                id: settingsMenuButton
                menu: Menu {
                    MenuItem {
                        id: loadImages
                        text: "Autoload images"
                        checkable: true
                        checked: true
                    }
                    MenuItem {
                        id: javaScriptEnabled
                        text: "JavaScript On"
                        checkable: true
                        checked: true
                    }
                    MenuItem {
                        id: errorPageEnabled
                        text: "ErrorPage On"
                        checkable: true
                        checked: true
                    }
                    MenuItem {
                        id: pluginsEnabled
                        text: "Plugins On"
                        checkable: true
                        checked: true
                    }
                    MenuItem {
                        id: offTheRecordEnabled
                        text: "Off The Record"
                        checkable: true
                        checked: currentWebView ? currentWebView.profile.offTheRecord : true
                        onToggled: currentWebView.profile = (checked ? otrProfile : engine.rootWindow.defaultProfile());
                    }
                    MenuItem {
                        id: httpDiskCacheEnabled
                        text: "HTTP Disk Cache"
                        checkable: currentWebView && !currentWebView.profile.offTheRecord
                        checked: currentWebView && (currentWebView.profile.httpCacheType == WebEngineProfile.DiskHttpCache)
                        onToggled: currentWebView.profile.httpCacheType = checked ? WebEngineProfile.DiskHttpCache : WebEngineProfile.MemoryHttpCache;
                    }
                }
            }
        }
        ProgressBar {
            id: progressBar
            height: 3
            anchors {
                left: parent.left
                top: parent.bottom
                right: parent.right
                leftMargin: -parent.leftMargin
                rightMargin: -parent.rightMargin
            }
            style: ProgressBarStyle {
                background: Item {}
            }
            z: -2;
            minimumValue: 0
            maximumValue: 100
            value: (currentWebView && currentWebView.loadProgress < 100) ? currentWebView.loadProgress : 0
        }
    }

    PageView {
        id: tabs

        itemWidth: browserWindow.width / 2
        itemHeight: browserWindow.height / 2

        anchors {
            top: navigationBar.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }

        Component.onCompleted: {
            var tab = createEmptyTab()
            tab.webView.url = "about:blank"
        }
    }

    QtObject{
        id:acceptedCertificates

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
