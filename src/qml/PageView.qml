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
import QtWebEngine 1.3
import QtWebEngine.experimental 1.0
import QtQuick.Controls 1.5
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0

Rectangle {
    id: root
    property int animationDuration: 200
    property int tabDisplacement: 50
    property int itemWidth: root.width / 2
    property int itemHeight: root.height / 2 - 50

    property bool interactive: true

    property string background: "#83bfe5"

    property alias currentIndex: pathView.currentIndex
    property alias count: pathView.count

    property string viewState: "page"

    Component {
        id: tabComponent
        Item {
            id: tabItem
            property alias webView: webEngineView
            property alias title: webEngineView.title

            property var image: QtObject {
                property string imageUrl: "qrc:///icon"
                property string url: "about:blank"
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

                anchors {
                    fill: parent
                    top: permBar.bottom
                }

                function takeSnapshot() {
                    console.log("takeSnapshot")
                    if (tabItem.image.url == webEngineView.url)
                        return

                    tabItem.image.url = webEngineView.url
                    blur.grabToImage(function(result) {
                        tabItem.image.imageUrl = result.url;
                        console.log("takeSnapshot("+result.url+")")
                    });
                }

/*
                settings.autoLoadImages: appSettings.autoLoadImages
                settings.javascriptEnabled: appSettings.javaScriptEnabled
                settings.errorPageEnabled: appSettings.errorPageEnabled
                settings.pluginsEnabled: appSettings.pluginsEnabled
*/
                onCertificateError: {
                    if (!acceptedCertificates.shouldAutoAccept(error)){
                        error.defer()
                        sslDialog.enqueue(error)
                    } else{
                        error.ignoreCertificateError()
                    }
                }

                onNewViewRequested: {
                    var tab
                    if (!request.userInitiated)
                        print("Warning: Blocked a popup window.")
                    else if (request.destination == WebEngineView.NewViewInTab) {
                        tab = tabs.createEmptyTab()
                        tabs.currentIndex = tabs.count - 1
                        request.openIn(tab.webView)
                    } else if (request.destination == WebEngineView.NewViewInBackgroundTab) {
                        tab = tabs.createEmptyTab()
                        request.openIn(tab.webView)
                    } else if (request.destination == WebEngineView.NewViewInDialog) {
                        var dialog = engine.rootWindow.newDialog()
                        request.openIn(dialog.currentWebView)
                    } else {
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
            }

            Desaturate {
                id: desaturate
                visible: desaturation != 0.0
                anchors.fill: webEngineView
                source: webEngineView
                desaturation: root.interactive ? 0.0 : 1.0

                Behavior on desaturation {
                    NumberAnimation { duration: animationDuration }
                }
            }

            FastBlur {
                id: blur
                visible: radius != 0.0
                anchors.fill: desaturate
                source: desaturate
                radius: desaturate.desaturation * 25
            }

            MouseArea {
                anchors.fill: parent
                enabled: !root.interactive

                onWheel: wheel.accepted = true
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
                        iconSource: "qrc:///previous"
                        onClicked: webEngineView.findText(findTextField.text, WebEngineView.FindBackward)
                    }
                    ToolButton {
                        id: findForwardButton
                        iconSource: "qrc:///next"
                        onClicked: webEngineView.findText(findTextField.text)
                    }
                    ToolButton {
                        id: findCancelButton
                        iconSource: "qrc:///stop"
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
        return tab
    }

    function add(component) {
        var element = {"item": null }
        element.item = component.createObject(root, { "width": root.width, "height": root.height })

        if (element.item == null) {
            console.log("PageView::add(): Error creating object");
            return
        }

        element.item.webView.profile = engine.rootWindow.defaultProfile()
        element.item.webView.url = "about:blank"
        listModel.append(element)

        pathView.positionViewAtIndex(listModel.count - 1, PathView.SnapPosition)

        return element.item
    }

    function remove(index) {
        listModel.remove(index)
        if (listModel.count == 0)
            engine.rootWindow.close()
    }

    function get(index) {
        return listModel.get(index)
    }

    Component {
        id: delegate

        Rectangle {
            id: wrapper

            property real visibility: 1.0
            property bool isCurrentItem: PathView.isCurrentItem

            visible: visibility != 0.0
            state: isCurrentItem ? root.viewState : "list"

            states: [
                State {
                    name: "page"
                    PropertyChanges { target: wrapper; width: root.width; height: root.height; visibility: 0.0 }
                    PropertyChanges { target: pathView; interactive: false; }
                    PropertyChanges { target: item; opacity: 1.0; visible: visibility < 0.1; z: 5 }
                },
                State {
                    name: "list"
                    PropertyChanges { target: wrapper; width: itemWidth; height: itemHeight; visibility: 1.0 }
                    PropertyChanges { target: pathView; interactive: true; }
                    PropertyChanges { target: item; opacity: 0.0; visible: opacity != 0.0 }
                }
            ]

            transitions: Transition {
                ParallelAnimation {
                    PropertyAnimation { property: "visibility"; duration: animationDuration }
                    PropertyAnimation { properties: "x,y"; duration: animationDuration }
                    PropertyAnimation { properties: "width,height"; duration: animationDuration}
                }
            }

            width: itemWidth; height: itemHeight
            scale: isCurrentItem ? 1 : 0.5
            z: isCurrentItem ? 1 : 0

            function indexForPosition(x, y) {
                var pos = pathView.mapFromItem(wrapper, x, y)
                return pathView.indexAt(pos.x, pos.y)
            }

            function itemForPosition(x, y) {
                var pos = pathView.mapFromItem(wrapper, x, y)
                return pathView.itemAt(pos.x, pos.y)
            }

            MouseArea {
                anchors.fill: wrapper
                onClicked: {
                    var index = indexForPosition(mouse.x, mouse.y)
                    var distance = Math.abs(pathView.currentIndex - index)

                    if (index < 0)
                        return

                    if (index == pathView.currentIndex) {
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

                    if (distance > 1) {
                        pathView.positionViewAtIndex(index, PathView.SnapPosition)
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

            Column {
                anchors.fill: wrapper
                Rectangle {
                    color: background

                    Image {
                        smooth: true
                        source: item.image.imageUrl
                        anchors.fill: parent
                    }

                    anchors.horizontalCenter: parent.horizontalCenter
                    width: wrapper.width
                    height: wrapper.height
                    Rectangle {
                        visible: wrapper.isCurrentItem && !pathView.moving
                        width: 45
                        height: 45
                        radius: width / 2
                        color: closeButton.pressed ? buttonHighlightColor : "white"
                        border.width: 1
                        border.color: "black"
                        anchors {
                            horizontalCenter: parent.right
                            verticalCenter: parent.top
                        }
                        Image {
                            anchors.fill: parent
                            source: "qrc:///close"
                            MouseArea {
                                id: closeButton
                                anchors.fill: parent
                                onClicked: {
                                    var index = indexForPosition(mouse.x, mouse.y)
                                    itemForPosition(mouse.x, mouse.y).visible = false
                                    remove(index)
                                }
                            }
                        }
                    }
                }
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: item.title
                    font.pointSize: 12
                    color: wrapper.isCurrentItem ? "black" : uiColor
                }
            }
            Behavior on scale {
                NumberAnimation { duration: animationDuration }
            }
        }
    }

    PathView {
        id: pathView
        pathItemCount: 5
        anchors.fill: parent
        model: listModel
        delegate: delegate
        preferredHighlightBegin: 0.5
        preferredHighlightEnd: 0.5

        snapMode: PathView.SnapToItem

        focus: interactive

        Rectangle {
            color: background
            anchors.fill: parent
        }

        path: Path {
            id: path
            startX: -tabDisplacement; startY: root.height / 2 - tabDisplacement - 25
            PathCurve { x: 0; y: root.height / 2 - tabDisplacement }
            PathCurve { x: root.width / 4; y: root.height / 2 - tabDisplacement / 2 }
            PathCurve { x: root.width / 2; y: root.height / 2 }
            PathCurve { x: 3/4 * root.width; y: root.height / 2 - tabDisplacement / 2 }
            PathCurve { x: root.width; y: root.height / 2 - tabDisplacement }
            PathCurve { x: root.width + tabDisplacement; y: root.height / 2 - tabDisplacement - 25 }
        }

        Keys.onLeftPressed: decrementCurrentIndex()
        Keys.onRightPressed: incrementCurrentIndex()
    }
}
