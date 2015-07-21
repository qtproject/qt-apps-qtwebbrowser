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
import QtWebEngine 1.3
import QtWebEngine.experimental 1.0
import QtQuick.Controls 1.5
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0

import io.qt.browser 1.0

Rectangle {
    id: root

    property int itemWidth: root.width * 0.6
    property int itemHeight: root.height * 0.6

    property int viewWidth: root.width - (2 * 50)

    property bool interactive: true

    property string background: "#62b0e0"

    property alias currentIndex: pathView.currentIndex
    property alias count: pathView.count

    property string viewState: "page"

    property QtObject otrProfile: WebEngineProfile {
        offTheRecord: true
    }

    property QtObject defaultProfile: WebEngineProfile {
        storageName: "YABProfile"
        offTheRecord: false
    }

    Component {
        id: tabComponent
        Item {
            id: tabItem
            property alias webView: webEngineView
            property alias title: webEngineView.title

            property var image: QtObject {
                property var snapshot: null
                property string url: "about:blank"
            }

            visible: opacity != 0.0

            Behavior on opacity {
                NumberAnimation { duration: animationDuration }
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

                profile: defaultProfile

                function takeSnapshot() {
                    if (tabItem.image.url == webEngineView.url || tabItem.opacity != 1.0)
                        return

                    tabItem.image.url = webEngineView.url
                    webEngineView.grabToImage(function(result) {
                        tabItem.image.snapshot = result;
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
                        pathView.positionViewAtIndex(tabs.count - 1, PathView.Center)
                        request.openIn(tab.webView)
                    } else if (request.destination == WebEngineView.NewViewInBackgroundTab) {
                        var index = pathView.currentIndex
                        tab = tabs.createEmptyTab()
                        request.openIn(tab.webView)
                        pathView.positionViewAtIndex(index, PathView.Center)
                    } else if (request.destination == WebEngineView.NewViewInDialog) {
                        var dialog = tabs.createEmptyTab()
                        request.openIn(dialog.webView)
                    } else {
                        var window = tabs.createEmptyTab()
                        request.openIn(window.webView)
                    }
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

            TouchTracker {
                id: tracker

                target: webEngineView
                anchors.fill: parent
                onTouchYChanged: browserWindow.touchY = tracker.touchY
                onYVelocityChanged: browserWindow.velocityY = yVelocity
                onTouchBegin: {
                    browserWindow.touchY = tracker.touchY
                    browserWindow.velocityY = yVelocity
                    browserWindow.touchReference = tracker.touchY
                    browserWindow.touchGesture = true
                }
                onTouchEnd: {
                    browserWindow.velocityY = yVelocity
                    browserWindow.touchGesture = false
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
                        width: 20
                        height: 20
                        iconSource: "qrc:///back"
                        onClicked: webEngineView.findText(findTextField.text, WebEngineView.FindBackward)
                    }
                    ToolButton {
                        id: findForwardButton
                        width: 20
                        height: 20
                        iconSource: "qrc:///forward"
                        onClicked: webEngineView.findText(findTextField.text)
                    }
                    ToolButton {
                        id: findCancelButton
                        width: 20
                        height: 20
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

    function makeCurrent(index) {
        pathView.positionViewAtIndex(index, PathView.Center)
    }

    function createEmptyTab() {
        if (listModel.count == 10)
            return null
        var tab = add(tabComponent)
        return tab
    }

    function add(component) {
        var element = {"item": null }
        element.item = component.createObject(root, { "width": root.width, "height": root.height, "opacity": 0.0 })

        if (element.item == null) {
            console.log("PageView::add(): Error creating object");
            return
        }

        element.item.webView.url = "about:blank"
        element.index = listModel.count
        listModel.append(element)
        return element.item
    }

    function remove(index) {
        pathView.interactive = false
        // Update indices of remaining items
        for (var idx = index + 1; idx < listModel.count; ++idx)
            listModel.get(idx).index -= 1

        listModel.remove(index)
        pathView.interactive = true
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

            parent: item

            property real visibility: 0.0
            property bool isCurrentItem: PathView.isCurrentItem

            visible: visibility != 0.0
            state: isCurrentItem ? root.viewState : "list"

            states: [
                State {
                    name: "page"
                    PropertyChanges { target: wrapper; width: root.width; height: root.height; visibility: 0.0 }
                    PropertyChanges { target: pathView; interactive: false }
                    PropertyChanges { target: item; opacity: 1.0;  }
                },
                State {
                    name: "list"
                    PropertyChanges { target: wrapper; width: itemWidth; height: itemHeight; visibility: 1.0 }
                    PropertyChanges { target: pathView; interactive: true }
                    PropertyChanges { target: item; }
                }
            ]

            transitions: Transition {
                ParallelAnimation {
                    PropertyAnimation { property: "visibility"; duration: animationDuration; easing.type : Easing.InQuad }
                    PropertyAnimation { properties: "x,y"; duration: animationDuration; easing.type : Easing.OutQuad }
                    PropertyAnimation { properties: "width,height"; duration: animationDuration; easing.type : Easing.OutQuad }
                }
            }

            width: itemWidth; height: itemHeight
            scale: pathView.moving ? 0.65 : PathView.itemScale
            z: PathView.itemZ

            MouseArea {
                enabled: pathView.interactive
                anchors.fill: wrapper
                onClicked: {
                    mouse.accepted = true
                    if (index < 0)
                        return

                    if (index == pathView.currentIndex) {
                        if (root.viewState == "list")
                            root.viewState = "page"
                        return
                    }
                    pathView.currentIndex = index
                }
            }

            Rectangle {
                color: background

                DropShadow {
                    visible: wrapper.visibility == 1.0
                    anchors.fill: snapshot
                    radius: 50
                    verticalOffset: 5
                    horizontalOffset: 0
                    samples: radius * 2
                    color: Qt.rgba(0, 0, 0, 0.5)
                    source: snapshot
                }

                Image {
                    id: snapshot
                    source: {
                        if (!item.image.snapshot)
                            return "qrc:///about"
                        return item.image.snapshot.url
                    }
                    anchors.fill: parent
                    Rectangle {
                        enabled: wrapper.isCurrentItem && !pathView.moving && !pathView.flicking && wrapper.visibility == 1.0
                        opacity: enabled ? 1.0 : 0.0
                        visible: opacity != 0.0
                        width: image.sourceSize.width
                        height: image.sourceSize.height - 2
                        radius: width / 2
                        color: "darkgrey"
                        anchors {
                            horizontalCenter: parent.right
                            verticalCenter: parent.top
                        }
                        Image {
                            id: image
                            opacity: {
                                if (closeButton.pressed)
                                    return 0.70
                                return 1.0
                            }
                            anchors {
                                top: parent.top
                                left: parent.left
                            }
                            source: "qrc:///delete"
                            MouseArea {
                                id: closeButton
                                anchors.fill: parent
                                onClicked: {
                                    mouse.accepted = true
                                    remove(pathView.currentIndex)
                                }
                            }
                        }
                        Behavior on opacity {
                            NumberAnimation { duration: animationDuration }
                        }
                    }
                }

                anchors.fill: wrapper
            }

            Text {
                anchors {
                    top: parent.bottom
                    horizontalCenter: parent.horizontalCenter
                }
                horizontalAlignment: Text.AlignHCenter
                width: parent.width
                elide: Text.ElideRight
                text: item.title
                font.pointSize: 10
                font.family: "Monospace"
                color: "#464749"
                visible: wrapper.isCurrentItem
            }
            Behavior on scale {
                NumberAnimation { duration: animationDuration }
            }
        }
    }

    Rectangle {
        color: background
        anchors.fill: parent
    }

    PathView {
        id: pathView
        pathItemCount: 5
        anchors.fill: parent
        model: listModel
        delegate: delegate
        highlightMoveDuration: animationDuration
        flickDeceleration: animationDuration / 2
        preferredHighlightBegin: 0.5
        preferredHighlightEnd: 0.5

        dragMargin: itemHeight

        snapMode: PathView.SnapToItem

        property bool fewTabs: count < 3
        property int offset: 10
        property int margin: {
            if (fewTabs)
                return viewWidth / 4
            if (count == 4)
                return 2 * toolBarSize
            return toolBarSize
        }

        focus: interactive

        path: Path {
            id: path
            startX: pathView.margin ; startY: root.height / 2
            PathAttribute { name: "itemScale"; value: pathView.fewTabs ? 0.5 : 0.2 }
            PathAttribute { name: "itemZ"; value: 0 }
            PathLine { relativeX: viewWidth / 6 - 10; y: root.height / 2 }
            PathAttribute { name: "itemScale"; value: 0.30 }
            PathAttribute { name: "itemZ"; value: 3 }
            PathLine { x: viewWidth / 2; y: root.height / 2 }
            PathAttribute { name: "itemScale"; value: 1.0 }
            PathAttribute { name: "itemZ"; value: 6 }
            PathLine { x: root.width - pathView.margin - viewWidth / 6 + 10; y: root.height / 2 }
            PathAttribute { name: "itemScale"; value: 0.40 }
            PathAttribute { name: "itemZ"; value: 4 }
            PathLine { x: root.width - pathView.margin; y: root.height / 2 }
            PathAttribute { name: "itemScale"; value: pathView.fewTabs ? 0.3 : 0.15 }
            PathAttribute { name: "itemZ"; value: 2 }
        }

        Keys.onLeftPressed: decrementCurrentIndex()
        Keys.onRightPressed: incrementCurrentIndex()
    }
}
