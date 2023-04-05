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

import QtQuick
import QtWebEngine
import QtQuick.Controls
import QtQuick.Layouts
import Qt.labs.platform


import "assets"
import WebBrowser 1.0
import "Utils.js" as Utils

Item {
    id: browserWindow

    property Item currentWebView: {
        return tabView.get(tabView.currentIndex) ? tabView.get(tabView.currentIndex).item.webView : null
    }

    property string googleSearchQuery: "https://www.google.com/search?sourceid=qtbrowser&ie=UTF-8&q="

    property int toolBarSize: 80
    property string uiColor: settingsView.privateBrowsingEnabled ? "#26282a" : "#46a2da"
    property string uiSeparatorColor: settingsView.privateBrowsingEnabled ? "#717273" : "#7ebee5"
    property string toolBarSeparatorColor: settingsView.privateBrowsingEnabled ? "#929495" : "#a3d1ed"
    property string toolBarFillColor: settingsView.privateBrowsingEnabled ? "#46484a" : uiSeparatorColor
    property string buttonPressedColor: settingsView.privateBrowsingEnabled ? "#3b3c3e" : "#3f91c4"
    property string emptyBackgroundColor: "#e4e4e4"
    property string uiHighlightColor: "#fddd5c"
    property string inactivePagerColor: "#bcbdbe"
    property string textFieldStrokeColor: "#3882ae"
    property string placeholderColor: "#a0a1a2"
    property string iconOverlayColor: "#0e202c"
    property string iconStrokeColor: "#d6d6d6"
    property string defaultFontFamily: "Open Sans"

    property int gridViewPageItemCount: 8
    property int gridViewMaxBookmarks: 3 * gridViewPageItemCount
    property int tabViewMaxTabs: 10
    property int animationDuration: 200
    property int velocityThreshold: 400
    property int velocityY: 0
    property real touchY: 0
    property real touchReference: 0
    property bool touchGesture: false

    width: 1024
    height: 600
    visible: true

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
            navigation.addressBar.forceActiveFocus()
        }
    }
    Action {
        id: newTabAction
        shortcut: "Ctrl+T"
        onTriggered: {
            tabView.get(tabView.currentIndex).item.webView.takeSnapshot()
            var tab = tabView.createEmptyTab()

            if (!tab)
                return

            navigation.addressBar.selectAll();
            tabView.makeCurrent(tabView.count - 1)
            navigation.addressBar.forceActiveFocus()
        }
    }
    Action {
        shortcut: "Ctrl+W"
        onTriggered: tabView.remove(tabView.currentIndex)
    }

    UIToolBar {
        id: tabEditToolBar

        source: "icons/Btn_Add.png"
        indicator: tabView.count

        anchors {
            left: parent.left
            right: parent.right
            top: navigation.top
        }

        visible: opacity != 0.0
        opacity: tabView.viewState == "list" ? 1.0 : 0.0
        onDoneClicked: tabView.viewState = "page"
        onOptionClicked: newTabAction.trigger()
    }

    UIToolBar {
        id: settingsToolBar
        z: 5
        title: qsTr("Settings")
        visible: opacity != 0.0

        anchors {
            left: parent.left
            right: parent.right
            top: navigation.top
        }

        onDoneClicked: {
            settingsView.save()
            settingsView.state = "disabled"
        }
    }

    UIToolBar {
        id: fullScreenBar
        z: 6
        title: qsTr("Leave Full Screen Mode")
        visible: opacity != 0.0
        opacity: tabView.viewState === "fullscreen" ? 1.0 : 0.0
        anchors {
            left: parent.left
            right: parent.right
            top: navigation.top
        }
        onDoneClicked: {
            navigation.webView.triggerWebAction(WebEngineView.ExitFullScreen);
        }
    }

    NavigationBar {
        id: navigation

        anchors {
            left: parent.left
            right: parent.right
        }
    }

    PageView {
        id: tabView
        interactive: {
            if (sslDialog.visible || homeScreen.state != "disabled" || urlDropDown.state == "enabled" || settingsView.state == "enabled")
                return false
            return true
        }

        anchors {
            top: navigation.bottom
            left: parent.left
            right: parent.right
        }

        height: inputPanel.y

        Component.onCompleted: {
            var tab = createEmptyTab()

            if (!tab)
                return

            navigation.webView = tab.webView
            var url = AppEngine.initialUrl

            navigation.load();
        }
        onCurrentIndexChanged: {
            if (!tabView.get(tabView.currentIndex))
                return
            navigation.webView = tabView.get(tabView.currentIndex).item.webView
        }
    }

    QtObject{
        id: acceptedCertificates

        property var acceptedUrls : []

        function shouldAutoAccept(certificateError){
            var domain = AppEngine.domainFromString(certificateError.url)
            return acceptedUrls.indexOf(domain) >= 0
        }
    }

    MessageDialog {
        id: sslDialog

        property var certErrors: []
        property var currentError: null
        visible: certErrors.length > 0
        buttons: MessageDialog.No | MessageDialog.Yes
        title: "Server's certificate not trusted"
        text: "Do you wish to continue?"
        detailedText: "If you wish so, you may continue with an unverified certificate. " +
                      "Accepting an unverified certificate means " +
                      "you may not be connected with the host you tried to connect to.\n" +
                      "Do you wish to override the security check and continue?"
        onYesClicked: {
            var cert = certErrors.shift()
            var domain = AppEngine.domainFromString(cert.url)
            acceptedCertificates.acceptedUrls.push(domain)
            cert.ignoreCertificateError()
            presentError()
        }
        onNoClicked: reject()
        onRejected: reject()

        function reject(){
            certErrors.shift().rejectCertificate()
            presentError()
        }
        function enqueue(error){
            currentError = error
            certErrors.push(error)
            presentError()
        }
        function presentError(){
            informativeText = "SSL error from URL\n\n" + currentError.url + "\n\n" + currentError.description + "\n"
        }
    }

    Rectangle {
        id: urlDropDown
        color: "white"
        visible: navigation.visible

        property string searchString: navigation.addressBar.text

        anchors {
            left: parent.left
            right: parent.right
            top: navigation.bottom
        }

        state: "disabled"

        states: [
            State {
                name: "enabled"
                PropertyChanges {
                    target: urlDropDown
                    height: browserWindow.height - toolBarSize - 3
                }
            },
            State {
                name: "disabled"
                PropertyChanges {
                    target: urlDropDown
                    height: 0
                }
            }
        ]

        Rectangle {
            anchors.fill: parent
            color: emptyBackgroundColor
        }

        SearchProxyModel {
            id: proxy
            target: navigation.webView.history.items
            searchString: urlDropDown.searchString
            enabled: urlDropDown.state == "enabled"
        }

        ListView {
            id: historyList
            property int remainingHeight: Math.min((historyList.count + 1) * toolBarSize, inputPanel.y - toolBarSize - 3)
            model: proxy
            clip: true
            boundsBehavior: Flickable.StopAtBounds
            footerPositioning: ListView.InlineFooter
            visible: urlDropDown.state == "enabled"

            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
            }
            height: remainingHeight
            delegate: Rectangle {
                id: wrapper
                width: historyList.width
                height: toolBarSize

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        if (!url)
                            return
                        navigation.webView.url = url
                        navigation.webView.forceActiveFocus()
                    }
                }

                Column {
                    width: parent.width - 60
                    height: parent.height
                    anchors {
                        verticalCenter: parent.verticalCenter
                        horizontalCenter: parent.horizontalCenter
                    }
                    Text {
                        property string highlightTitle: title ? title : ""
                        height: wrapper.height / 2
                        width: parent.width
                        elide: Text.ElideRight
                        verticalAlignment: Text.AlignBottom
                        anchors{
                            leftMargin: 30
                            rightMargin: 30
                        }
                        id: titleLabel
                        font.family: defaultFontFamily
                        font.pixelSize: 23
                        color: "black"
                        text: Utils.highlight(highlightTitle, urlDropDown.searchString)
                    }
                    Text {
                        property string highlightUrl: url ? url : ""
                        height: wrapper.height / 2 - 1
                        width: parent.width
                        elide: Text.ElideRight
                        verticalAlignment: Text.AlignTop
                        font.family: defaultFontFamily
                        font.pixelSize: 23
                        color: uiColor
                        text: Utils.highlight(highlightUrl, urlDropDown.searchString)
                    }
                    Rectangle {
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: historyList.width
                        height: 1
                        color: iconStrokeColor
                    }
                }
            }
            footer: Rectangle {
                z: 5
                width: historyList.width
                height: toolBarSize
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        var string = urlDropDown.searchString
                        var constructedUrl = ""
                        if (AppEngine.isUrl(string)) {
                            constructedUrl = AppEngine.fromUserInput(string)
                        } else {
                            constructedUrl = AppEngine.fromUserInput(googleSearchQuery + string)
                        }
                        navigation.webView.url = constructedUrl
                        navigation.webView.forceActiveFocus()
                    }
                }
                Row {
                    height: parent.height
                    Rectangle {
                        id: searchIcon
                        height: parent.height
                        width: height
                        color: "transparent"
                        Image {
                            anchors.centerIn: parent
                            source: "assets/icons/Btn_Search.png"
                        }
                    }
                    Text {
                        id: searchText
                        height: parent.height
                        width: historyList.width - searchIcon.width - 30
                        elide: Text.ElideRight
                        text: urlDropDown.searchString
                        verticalAlignment: Text.AlignVCenter
                        font.family: defaultFontFamily
                        font.pixelSize: 23
                        color: "black"
                    }
                }
            }
        }

        transitions: Transition {
            PropertyAnimation { property: "height"; duration: animationDuration; easing.type : Easing.InSine }
        }
    }

    HomeScreen {
        id: homeScreen
        height: parent.height - toolBarSize
        anchors {
            top: navigation.bottom
            left: parent.left
            right: parent.right
        }
    }

    SettingsView {
        id: settingsView
        height: parent.height - toolBarSize
        anchors {
            top: navigation.bottom
            left: parent.left
            right: parent.right
        }
    }
}
