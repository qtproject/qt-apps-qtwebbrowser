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
import Qt5Compat.GraphicalEffects

import WebBrowser 1.0
import "assets"

Rectangle {
    id: root

    property int itemWidth: browserWindow.width / 2
    property int itemHeight: browserWindow.height / 2

    property bool interactive: true

    property alias currentIndex: pathView.currentIndex
    property alias count: pathView.count

    property string viewState: "page"

    onViewStateChanged: {
        if (viewState == "page" || viewState == "fullscreen")
            homeScreen.state = "disabled"
    }

    property QtObject otrProfile: WebEngineProfile {
        offTheRecord: true
    }

    property QtObject defaultProfile: WebEngineProfile {
        storageName: "YABProfile"
        offTheRecord: false
    }

    Component {
        id: tabComponent
        Rectangle {
            id: tabItem
            property alias webView: webEngineView
            property alias title: webEngineView.title

            property var image: QtObject {
                property var grabberUrl: null
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

                profile: settingsView.privateBrowsingEnabled ? otrProfile : defaultProfile
                enabled: root.interactive

                function takeSnapshot() {
                    if (webEngineView.url == "" || webEngineView.url == "about:blank") {
                        tabItem.image.url = "about:blank"
                        tabItem.image.grabberUrl = null
                        return
                    }

                    if (tabItem.image.url === webEngineView.url || tabItem.opacity != 1.0)
                        return

                    tabItem.image.url = webEngineView.url
                    webEngineView.grabToImage(function(result) {
                        tabItem.image.grabberUrl = result.url;
                    });
                }

                // Trigger a refresh to check if the new url is bookmarked.
                onUrlChanged: navigation.refresh()

                settings.autoLoadImages: settingsView.autoLoadImages
                settings.javascriptEnabled: !settingsView.javaScriptDisabled
                settings.pluginsEnabled: settingsView.pluginsEnabled

                onLoadingChanged: {
                    if (loading)
                        navigation.state = "enabled"
                }

                onCertificateError: {
                    if (!acceptedCertificates.shouldAutoAccept(error)){
                        error.defer()
                        sslDialog.enqueue(error)
                    } else{
                        error.ignoreCertificateError()
                    }
                }

                onNewWindowRequested: {
                    webEngineView.takeSnapshot()
                    var tab
                    if (!request.userInitiated) {
                        print("Warning: Blocked a popup window.")
                        return
                    }

                    tab = tabView.createEmptyTab()

                    if (!tab)
                        return

                    if (request.destination == WebEngineView.NewViewInTab) {
                        pathView.positionViewAtIndex(tabView.count - 1, PathView.Center)
                        request.openIn(tab.webView)
                    } else if (request.destination == WebEngineView.NewViewInBackgroundTab) {
                        var index = pathView.currentIndex
                        request.openIn(tab.webView)
                        pathView.positionViewAtIndex(index, PathView.Center)
                    } else if (request.destination == WebEngineView.NewViewInDialog) {
                        request.openIn(tab.webView)
                    } else {
                        request.openIn(tab.webView)
                    }
                }

                onFeaturePermissionRequested: {
                    permBar.securityOrigin = securityOrigin;
                    permBar.requestedFeature = feature;
                    permBar.visible = true;
                }

                onFullScreenRequested: {
                    if (request.toggleOn)
                        viewState = "fullscreen"
                    else
                        viewState = "page"
                    request.accept()
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
                enabled: root.interactive
                target: webEngineView
                anchors.fill: parent
                onTouchYChanged: browserWindow.touchY = tracker.touchY
                onYVelocityChanged: browserWindow.velocityY = yVelocity
                onTouchBegin: {
                    browserWindow.touchY = tracker.touchY
                    browserWindow.velocityY = yVelocity
                    browserWindow.touchReference = tracker.touchY
                    browserWindow.touchGesture = true
                    navigation.state = "tracking"
                }
                onTouchEnd: {
                    browserWindow.velocityY = yVelocity
                    browserWindow.touchGesture = false
                    navigation.state = "tracking"
                }
                onScrollDirectionChanged: {
                    browserWindow.velocityY = 0
                    browserWindow.touchReference = tracker.touchY
                }
            }

            Rectangle {
                opacity: {
                    if (inputPanel.state === "visible")
                        return 0.0
                    if (webEngineView.url == "" || webEngineView.url == "about:blank")
                        return 1.0
                    return 0.0
                }
                anchors.fill: parent
                visible: opacity != 0.0
                color: "white"
                Image {
                    id: placeholder
                    y: placeholder.height - navigation.y
                    anchors.horizontalCenter: parent.horizontalCenter
                    source: "assets/icons/AppLogoColor.png"
                }
                Text {
                    id: label
                    anchors {
                        top: placeholder.bottom
                        topMargin: 20
                        horizontalCenter: placeholder.horizontalCenter
                    }
                    font.family: defaultFontFamily
                    font.pixelSize: 28
                    color: uiColor
                    text: "Qt WebBrowser"
                }

                Behavior on opacity {
                    NumberAnimation { duration: animationDuration }
                }
            }

            Rectangle {
                id: findBar
                anchors {
                    right: webEngineView.right
                    left: webEngineView.left
                    top: webEngineView.top
                }
                height: toolBarSize / 2 + 10
                visible: false
                color: uiColor

                RowLayout {
                    spacing: 0
                    anchors.fill: parent
                    Rectangle {
                        width: 5
                        height: parent.height
                        color: uiColor
                    }
                    TextField {
                        id: findTextField
                        Layout.fillWidth: true
                        onAccepted: {
                            webEngineView.findText(text)
                        }

                        color: "black"
                        font.family: defaultFontFamily
                        font.pixelSize: 28
                        selectionColor: uiHighlightColor
                        selectedTextColor: "black"
                        placeholderTextColor: placeholderColor
                        background: Rectangle {
                            implicitWidth: 514
                            implicitHeight: toolBarSize / 2
                            border.color: textFieldStrokeColor
                            border.width: 1
                        }
                    }
                    Rectangle {
                        width: 5
                        height: parent.height
                        color: uiColor
                    }
                    Rectangle {
                        width: 1
                        height: parent.height
                        color: uiSeparatorColor
                    }
                    UIButton {
                        id: findBackwardButton
                        icon.source: "assets/icons/Btn_Back.png"
                        implicitHeight: parent.height
                        onClicked: webEngineView.findText(findTextField.text, WebEngineView.FindBackward)
                    }
                    Rectangle {
                        width: 1
                        height: parent.height
                        color: uiSeparatorColor
                    }
                    UIButton {
                        id: findForwardButton
                        icon.source: "assets/icons/Btn_Forward.png"
                        implicitHeight: parent.height
                        onClicked: webEngineView.findText(findTextField.text)
                    }
                    Rectangle {
                        width: 1
                        height: parent.height
                        color: uiSeparatorColor
                    }
                    UIButton {
                        id: findCancelButton
                        icon.source: "assets/icons/Btn_Clear.png"
                        implicitHeight: parent.height
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
        viewState = "list"
        pathView.positionViewAtIndex(index, PathView.Center)
        viewState = "page"
    }

    function createEmptyTab() {
        var tab = add(tabComponent)
        return tab
    }

    function add(component) {
        if (listModel.count === tabViewMaxTabs) {
            homeScreen.messageBox.state = "tabsfull"
            homeScreen.state = "enabled"
            homeScreen.forceActiveFocus()
            return null
        }

        var element = {"item": null }
        element.item = component.createObject(root, { "width": root.width, "height": root.height, "opacity": 0.0 })

        if (element.item === null) {
            console.log("PageView::add(): Error creating object");
            return
        }

        listModel.append(element)
        return element.item
    }

    function remove(index) {
        pathView.interactive = false
        pathView.currentItem.state = ""
        pathView.currentItem.visible = false
        listModel.remove(index)
        pathView.decrementCurrentIndex()
        pathView.interactive = true
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

            visible: PathView.onPath && visibility != 0.0
            state: isCurrentItem ? root.viewState : "list"

            Behavior on scale {
                NumberAnimation { duration: animationDuration }
            }

            states: [
                State {
                    name: "page"
                    PropertyChanges { target: wrapper; width: root.width; height: root.height; visibility: 0.0 }
                    PropertyChanges { target: pathView; interactive: false }
                    PropertyChanges { target: item; opacity: 1.0 }
                    PropertyChanges { target: navigation; state: "enabled" }
                },
                State {
                    name: "list"
                    PropertyChanges { target: wrapper; width: itemWidth; height: itemHeight; visibility: 1.0 }
                    PropertyChanges { target: pathView; interactive: true }
                    PropertyChanges { target: item; opacity: 0.0 }
                },
                State {
                    name: "fullscreen"
                    PropertyChanges { target: wrapper; width: root.width; height: root.height; visibility: 0.0 }
                    PropertyChanges { target: pathView; interactive: false }
                    PropertyChanges { target: item; opacity: 1.0 }
                    PropertyChanges { target: navigation; state: "disabled" }
                }
            ]

            transitions: Transition {
                ParallelAnimation {
                    PropertyAnimation { property: "visibility"; duration: animationDuration; easing.type : Easing.InSine }
                    PropertyAnimation { properties: "x,y"; duration: animationDuration; easing.type: Easing.InSine }
                    PropertyAnimation { properties: "width,height"; duration: animationDuration; easing.type: Easing.InSine }
                }
            }

            width: itemWidth; height: itemHeight
            scale: {
                if (pathView.count == 1)
                    return 1.0
                if (pathView.count < 4)
                    return isCurrentItem ? 1.0 : 0.5

                if (isCurrentItem)
                    return 1.0

                var index1 = pathView.currentIndex - 2
                var index2 = pathView.currentIndex - 1
                var index4 = (pathView.currentIndex + 1) % pathView.count
                var index5 = (pathView.currentIndex + 2) % pathView.count

                if (index1 < 0)
                    index1 = pathView.count + index1
                if (index2 < 0)
                    index2 = pathView.count + index2

                switch (index) {
                case index1 :
                    return 0.25
                case index2:
                    return 0.5
                case index4:
                    return 0.5
                case index5:
                    return 0.25
                }

                return 0.25
            }
            z: PathView.itemZ

            MouseArea {
                enabled: pathView.interactive
                anchors.fill: wrapper
                onClicked: mouse => {
                    mouse.accepted = true
                    if (index < 0)
                        return

                    if (index === pathView.currentIndex) {
                        if (root.viewState == "list")
                            root.viewState = "page"
                        return
                    }
                    pathView.currentIndex = index
                }
            }
            Rectangle {
                id: shadow
                visible: false
                property real size: 24
                anchors {
                    top: parent.top
                    topMargin: 9
                    horizontalCenter: parent.horizontalCenter
                }
                color: iconOverlayColor
                radius: size / 2
                width: snapshot.width
                height: snapshot.height
            }

            GaussianBlur {
                anchors.fill: shadow
                source: shadow
                radius: shadow.size
                samples: shadow.size * 2
                opacity: 0.3
                transparentBorder: true
                visible: wrapper.visibility == 1.0
            }

            Rectangle {
                id: snapshot
                color: uiColor

                Image {
                    source: {
                        if (!item.image.grabberUrl)
                            return "assets/icons/about_blank.png"
                        return item.image.grabberUrl
                    }
                    anchors.fill: parent
                    Rectangle {
                        enabled: index === pathView.currentIndex && !pathView.moving && !pathView.flicking && wrapper.visibility == 1.0
                        opacity: enabled ? 1.0 : 0.0
                        visible: wrapper.visibility == 1.0 && listModel.count > 1
                        width: image.sourceSize.width
                        height: image.sourceSize.height - 2
                        radius: width / 2
                        color: iconOverlayColor
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
                            source: "assets/icons/Btn_Delete.png"
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
                            NumberAnimation { duration: animationDuration / 2 }
                        }
                    }
                }
                anchors.fill: wrapper
            }

            Text {
                anchors {
                    topMargin: -25
                    top: parent.top
                    horizontalCenter: parent.horizontalCenter
                }
                horizontalAlignment: Text.AlignHCenter
                width: parent.width - image.width
                elide: Text.ElideRight
                text: item.title
                font.pixelSize: 16
                font.family: defaultFontFamily
                color: settingsView.privateBrowsingEnabled ? "white" : "#0B508C"
                visible: wrapper.isCurrentItem && wrapper.visibility == 1.0
            }
        }
    }

    Rectangle {
        color: uiColor
        anchors.fill: parent
    }

    PathView {
        id: pathView
        pathItemCount: 5
        anchors.fill: parent
        model: listModel
        delegate: delegate
        highlightMoveDuration: animationDuration
        highlightRangeMode: PathView.StrictlyEnforceRange
        snapMode: PathView.SnapToItem
        preferredHighlightBegin: 0.5
        preferredHighlightEnd: 0.5

        dragMargin: itemHeight

        focus: pathView.interactive

        property real offset: 30

        property real margin: {
            if (count == 2)
                return root.width / 4 - offset
            if (count == 3)
                return root.width / 8 + offset
            if (count == 4)
                return root.width / 8 - offset

            return offset
        }

        property real middle: {
            if (currentItem)
                return (pathView.height / 2) - (currentItem.visibility * 50)
            return (pathView.height / 2 - 50)
        }

        path: Path {
            startX: pathView.margin
            startY: pathView.middle

            PathPercent { value: 0.0 }
            PathAttribute { name: "itemZ"; value: 0 }
            PathLine {
                x: (pathView.width - itemWidth) / 2 + 106
                y: pathView.middle
            }
            PathPercent { value: 0.49 }
            PathAttribute { name: "itemZ"; value: 6 }

            PathLine { relativeX: 0; relativeY: 0 }

            PathLine {
                x: (pathView.width - itemWidth) / 2 + itemWidth - 106
                y: pathView.middle
            }
            PathPercent { value: 0.51 }

            PathLine { relativeX: 0; relativeY: 0 }

            PathAttribute { name: "itemZ"; value: 4 }
            PathLine {
                x: pathView.width - pathView.margin
                y: pathView.middle
            }
            PathPercent { value: 1 }
            PathAttribute { name: "itemZ"; value: 2 }
        }

        Keys.onLeftPressed: decrementCurrentIndex()
        Keys.onRightPressed: incrementCurrentIndex()
    }
}
