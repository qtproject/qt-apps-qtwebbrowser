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

import QtQuick 2.0
import QtWebEngine 1.2
import QtWebEngine.experimental 1.0
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0

Rectangle {
    id: root
    property int animationDuration: 200
    property int tabDisplacement: 100
    property int itemWidth: root.width / 2
    property int itemHeight: root.height / 2

    property alias currentIndex: pathView.currentIndex
    property alias count: pathView.count
    property Item currentWebView: {
        console.log(count)
        return get(currentIndex) ? get(currentIndex).item.webView : null
    }


    property string viewState: "page"

    Component {
        id: tabComponent
        Item {
            id: tabItem
            property alias webView: webEngineView
            property alias title: webEngineView.title

            property var image: QtObject {
                property string imageUrl: "qrc:///busy.png"
                property string url: "about:blank"
            }

            function grabImage() {
                if (image.url == webEngineView.url)
                    return

                image.url = webEngineView.url
                webEngineView.grabToImage(function(result) {
                    image.imageUrl = result.url;
                    console.log("grabImage("+result.url+")")
                });
            }

            visible: opacity != 0.0

            Behavior on opacity {
                NumberAnimation { duration: animationDuration / 4; easing.type: Easing.InQuad}
            }

            anchors.fill: parent

            Action {
                shortcut: "Ctrl+F"
                onTriggered: {
                    findBar.visible = !findBar.visible
                    if (findBar.visible) {
                        findTextField.forceActiveFocus()
                    }
                }
            }
            FeaturePermissionBar {
                id: permBar
                view: webEngineView
                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top
                }
                z: 3
            }

            WebEngineView {
                id: webEngineView

                //visible: parent.visible

                anchors {
                    fill: parent
                    top: permBar.bottom
                }

//                settings.autoLoadImages: appSettings.autoLoadImages
//                settings.javascriptEnabled: appSettings.javaScriptEnabled
//                settings.errorPageEnabled: appSettings.errorPageEnabled
//                settings.pluginsEnabled: appSettings.pluginsEnabled

                onCertificateError: {
                    if (!acceptedCertificates.shouldAutoAccept(error)){
                        error.defer()
                        sslDialog.enqueue(error)
                    } else{
                        error.ignoreCertificateError()
                    }
                }

                onNewViewRequested: {
                    if (!request.userInitiated)
                        print("Warning: Blocked a popup window.")
                    else if (request.destination == WebEngineView.NewViewInTab) {
                        var tab = tabs.createEmptyTab()
                        tabs.currentIndex = tabs.count - 1
                        console.log("newWindow inTab")
                        request.openIn(tab.webView)
                    } else if (request.destination == WebEngineView.NewViewInBackgroundTab) {
                        var tab = tabs.createEmptyTab()
                        console.log("newWindow inBackTab")
                        request.openIn(tab.webView)
                    } else if (request.destination == WebEngineView.NewViewInDialog) {
                        var dialog = engine.rootWindow.newDialog()
                        request.openIn(dialog.currentWebView)
                    } else {
                        console.log("newWindow BLA")
                        var window = engine.rootWindow.newWindow()
                        request.openIn(window.currentWebView)
                    }
                }

                onFullScreenRequested: {
                    if (request.toggleOn) {
                        webEngineView.state = "FullScreen"
                        browserWindow.previousVisibility = browserWindow.visibility
                        browserWindow.showFullScreen()
                    } else {
                        webEngineView.state = ""
                        browserWindow.visibility = browserWindow.previousVisibility
                    }
                    request.accept()
                }

                onFeaturePermissionRequested: {
                    permBar.securityOrigin = securityOrigin;
                    permBar.requestedFeature = feature;
                    permBar.visible = true;
                }

                onLoadingChanged: {
                    if (!loading && visible)
                        grabImage()
                }
            }

            Rectangle {
                id: findBar
                anchors.top: webEngineView.top
                anchors.right: webEngineView.right
                width: 240
                height: 35
                border.color: "lightgray"
                border.width: 1
                radius: 5
                visible: false
                color: "gray"

                RowLayout {
                    anchors.centerIn: findBar
                    TextField {
                        id: findTextField
                        onAccepted: {
                            webEngineView.findText(text)
                        }
                    }
                    ToolButton {
                        id: findBackwardButton
                        iconSource: "qrc:///previous.png"
                        onClicked: webEngineView.findText(findTextField.text, WebEngineView.FindBackward)
                    }
                    ToolButton {
                        id: findForwardButton
                        iconSource: "qrc:///next.png"
                        onClicked: webEngineView.findText(findTextField.text)
                    }
                    ToolButton {
                        id: findCancelButton
                        iconSource: "qrc:///stop.png"
                        onClicked: findBar.visible = false
                    }
                }
            }
        }
    }

    ListModel {
        id: listModel
    }

    function createEmptyTab() {
        var tab = add(tabComponent)
        //timer.running = true
        return tab
    }

    function add(component) {
        var element = {"item": null }
        element.item = component.createObject(root, { "anchors.top": root.top, "anchors.left": root.left, "width": root.width, "height": root.height })

        if (element.item == null) {
            // Error Handling
            console.log("Error creating object");
            return
        }

        element.item.webView.profile = engine.rootWindow.defaultProfile()
        element.item.webView.url = "about:blank"
        element.index = listModel.count
        listModel.append(element)

        console.log("index " + element.index)
        return element.item
    }

    function remove(index) {
        listModel.remove(index)
    }

    function get(index) {
        return listModel.get(index)
    }

    Component {
        id: delegate

        Rectangle {
            id: wrapper

            state: index == pathView.currentIndex ? root.viewState : "list"

            property real visibility: 1.0

            visible: visibility != 0.0

            onStateChanged: {
                console.log("WRAPPER " + state)
            }

            states: [
                State {
                    name: "page"
                    PropertyChanges { target: wrapper; x: 0; y: 0; width: root.width; height: root.height; color: "grey"; visibility: 0.0 }
                    PropertyChanges { target: pathView; interactive: false }
                    PropertyChanges { target: item; opacity: 1.0; visible: visibility < 0.1; z: 5 }
                },
                State {
                    name: "list"
                    PropertyChanges { target: wrapper; width: itemWidth; height: itemHeight; color: "white"; visibility: 1.0 }
                    PropertyChanges { target: pathView; interactive: true }
                    PropertyChanges { target: item; opacity: 0.0; visible: opacity != 0.0 }
                }
            ]

            transitions: Transition {
                SequentialAnimation {
                    ParallelAnimation {
                        ColorAnimation { property: "color"; duration: animationDuration }
                        PropertyAnimation { properties: "x,y"; duration: animationDuration }
                        PropertyAnimation { properties: "width,height"; duration: animationDuration; easing.type: Easing.OutQuad }
                        PropertyAnimation { properties: "visibility"; duration: animationDuration; easing.type: Easing.OutQuad }
                    }
                }
            }

            width: itemWidth; height: itemHeight
            scale: PathView.isCurrentItem ? 1 : 0.5
            z: PathView.isCurrentItem ? 1 : 0

            Column {
                anchors.fill: wrapper
                Rectangle {
                    color: "#83bfe5"


                    Image {
                        smooth: false
                        source: item.image.imageUrl
                        anchors.fill: parent
                    }

                    anchors.horizontalCenter: parent.horizontalCenter
                    width: wrapper.width
                    height: wrapper.height
                }
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: item.title
                    font.pointSize: 12
                    color: wrapper.PathView.isCurrentItem ? uiBorderColor : uiColor
                }
            }
            MouseArea {
                anchors.fill: wrapper
                onClicked: {
                    var pos = pathView.mapFromItem(wrapper, mouse.x, mouse.y)
                    var index = pathView.indexAt(pos.x, pos.y)

                    if (index < 0)
                        return

                    if (index === pathView.currentIndex) {
                        if (root.viewState == "list")
                            root.viewState = "page"
                        return
                    }

                    if (pathView.currentIndex == 0 && index === pathView.count - 1) {
                        pathView.decrementCurrentIndex()
                        return
                    }

                    if (pathView.currentIndex == pathView.count - 1 && index == 0) {
                        pathView.incrementCurrentIndex()
                        return
                    }

                    if (pathView.currentIndex > index) {
                            pathView.decrementCurrentIndex()
                        return
                    }

                    if (pathView.currentIndex < index) {
                            pathView.incrementCurrentIndex()
                        return
                    }
                }
            }
            Behavior on scale {
                NumberAnimation { duration: animationDuration }
            }
        }
    }

    PathView {
        id: pathView
        pathItemCount: 3
        anchors.fill: parent
        model: listModel
        delegate: delegate
        preferredHighlightBegin: 0.5
        preferredHighlightEnd: 0.5

        path: Path {
            id: path
            startX: 0 - itemWidth / 4; startY: root.height / 2 - tabDisplacement
            //PathLine { x: root.width; y: root.height / 2 }
            PathCurve { x: root.width / 4; y: root.height / 2 - tabDisplacement / 2 }
            PathCurve { x: root.width / 2; y: root.height / 2 }
            PathCurve { x: 3/4 * root.width; y: root.height / 2 - tabDisplacement / 2 }
            PathCurve { x: root.width + itemWidth / 4; y: root.height / 2 - tabDisplacement }
        }

        focus: true
        Keys.onLeftPressed: decrementCurrentIndex()
        Keys.onRightPressed: incrementCurrentIndex()
    }
}
