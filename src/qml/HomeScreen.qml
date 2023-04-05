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
import WebBrowser
import "assets"

Rectangle {
    id: homeScreen

    property int padding: 60
    property int cellSize: width / 5 - padding
    property alias messageBox: messageBox
    property alias count: gridView.count
    property alias currentIndex: gridView.currentIndex

    function set(i) {
        var p = (i - i % gridViewPageItemCount) / gridViewPageItemCount
        gridView.contentX = p * gridView.page
    }

    state: "enabled"
    onStateChanged: {
        if (state == "enabled" && !gridView.count)
            messageBox.state = "empty"
    }

    signal add(string title, string url, string iconUrl, string fallbackColor)
    onAdd: {
        if (listModel.count === gridViewMaxBookmarks) {
            navigation.refresh()
            messageBox.state = "full"
            state = "enabled"
            homeScreen.forceActiveFocus()
            return
        }
        var icon = url.indexOf("qt.io") != -1 ? "assets/icons/qt.png" : iconUrl
        var element = { "title": title, "url": url, "iconUrl": icon, "fallbackColor": fallbackColor }
        listModel.append(element)
        set(listModel.count - 1)
    }

    signal remove(string url, int idx)
    onRemove: {
        var index = idx < 0 ? contains(url) : idx
        if (index < 0)
            return

        listModel.remove(index)
        gridView.forceLayout()
        navigation.refresh()
        if (!listModel.count)
            messageBox.state = "empty"
    }

    function get(index) {
        return listModel.get(index)
    }

    function contains(url) {
        for (var idx = 0; idx < listModel.count; ++idx) {
            if (listModel.get(idx).url === url)
                return idx;
        }
        return -1;
    }

    states: [
        State {
            name: "enabled"
            AnchorChanges {
                target: homeScreen
                anchors.top: navigation.bottom
            }
        },
        State {
            name: "disabled"
            AnchorChanges {
                target: homeScreen
                anchors.top: homeScreen.parent.bottom
            }
        },
        State {
            name: "edit"
        }
    ]

    transitions: Transition {
        AnchorAnimation { duration: animationDuration; easing.type : Easing.InSine }
    }

    ListModel {
        id: listModel
        property string defaultBookmarks: "[{\"fallbackColor\":\"#46a2da\",\"iconUrl\":\"assets/icons/qt.png\",\"title\":\"Qt - Home\",\"url\":\"http://www.qt.io/\"},{\"fallbackColor\":\"#18394c\",\"iconUrl\":\"http://www.topgear.com/sites/all/themes/custom/tg/apple-touch-icon-144x144.png\",\"title\":\"Top Gear\",\"url\":\"http://www.topgear.com/\"},{\"fallbackColor\":\"#46a2da\",\"iconUrl\":\"https://duckduckgo.com/assets/icons/meta/DDG-iOS-icon_152x152.png\",\"title\":\"DuckDuckGo\",\"url\":\"https://duckduckgo.com/\"},{\"fallbackColor\":\"#ff8c0a\",\"iconUrl\":\"http://s.blogsmithmedia.com/www.engadget.com/assets/images/favicon-160x160.png\",\"title\":\"Engadget | Technology News, Advice and Features\",\"url\":\"http://www.engadget.com/\"},{\"fallbackColor\":\"#ff8c0a\",\"iconUrl\":\"https://www.openstreetmap.org/assets/favicon-194x194-32cdac24b02b88e09f0639bb92c760b2.png\",\"title\":\"OpenStreetMap\",\"url\":\"https://www.openstreetmap.org/\"},{\"fallbackColor\":\"#5caa15\",\"iconUrl\":\"http://www.redditstatic.com/icon.png\",\"title\":\"reddit: the front page of the internet\",\"url\":\"http://www.reddit.com/\"}]"

        Component.onCompleted: {
            listModel.clear()
            var string = AppEngine.restoreSetting("bookmarks", defaultBookmarks)
            if (!string)
                return
            var list = JSON.parse(string)
            for (var i = 0; i < list.length; ++i) {
                listModel.append(list[i])
            }
            navigation.refresh()
        }
        Component.onDestruction: {
            var list = []
            for (var i = 0; i < listModel.count; ++i) {
                list[i] = listModel.get(i)
            }
            AppEngine.saveSetting("bookmarks", JSON.stringify(list))
        }
    }

    GridView {
        id: gridView

        onCountChanged: {
            if (!count)
                messageBox.state = "empty"
            else
                messageBox.state = "disabled"
        }

        property real dragStart: 0
        property real page: 4 * cellWidth

        anchors.fill: parent
        model: listModel
        cellWidth: homeScreen.cellSize + homeScreen.padding
        cellHeight: cellWidth
        flow: GridView.FlowTopToBottom
        boundsBehavior: Flickable.StopAtBounds
        maximumFlickVelocity: 0
        contentHeight: parent.height

        MouseArea {
            z: -1
            enabled: homeScreen.state == "edit"
            anchors.fill: parent
            onClicked: homeScreen.state = "enabled"
        }

        rightMargin: {
            var margin = (parent.width - 4 * gridView.cellWidth - homeScreen.padding) / 2
            var padding = gridView.page - Math.round(gridView.count % gridViewPageItemCount / 2) * gridView.cellWidth

            if (padding === gridView.page)
                return margin

            return margin + padding
        }

        anchors {
            topMargin: toolBarSize
            leftMargin: (parent.width - 4 * gridView.cellWidth + homeScreen.padding) / 2
        }

        Behavior on contentX {
            NumberAnimation { duration: 1.5 * animationDuration; easing.type : Easing.InSine}
        }

        function snapToPage() {
            if (dragging) {
                dragStart = contentX
                return
            }
            if (dragStart == 2 * page && contentX < 2 * page) {
                contentX = page
                return
            }
            if (dragStart == page) {
                if (contentX < page) {
                    contentX = 0
                    return
                }
                if (page < contentX) {
                    contentX = 2 * page
                    return
                }
            }
            if (dragStart == 0 && 0 < contentX) {
                contentX = page
                return
            }
            contentX = 0
        }

        onDraggingChanged: snapToPage()
        delegate: Rectangle {
            id: square
            property string iconColor: "#f6f6f6"
            width: homeScreen.cellSize
            height: width
            border.color: iconStrokeColor
            border.width: 1

            Rectangle {
                id: bg
                anchors {
                    horizontalCenter: parent.horizontalCenter
                    top: parent.top
                    margins: 1
                }
                state: "fallback"
                width: square.width - 2
                height: width
                states: [
                    State {
                        name: "fallback"
                        PropertyChanges {
                            target: square
                            color: fallbackColor
                        }
                        PropertyChanges {
                            target: bg
                            color: square.color
                        }
                    },
                    State {
                        name: "normal"
                        PropertyChanges {
                            target: square
                            color: iconColor
                        }
                        PropertyChanges {
                            target: bg
                            color: square.color
                        }
                    }
                ]

                Image {
                    id: icon
                    smooth: true
                    anchors {
                        top: parent.top
                        horizontalCenter: parent.horizontalCenter
                        topMargin: width < bg.width ? 15 : 0
                    }
                    width: {
                        if (!icon.sourceSize.width)
                            return 0
                        if (icon.sourceSize.width < 100)
                            return 32

                        return bg.width
                    }
                    height: width
                    source: iconUrl
                    onStatusChanged: {
                        switch (status) {
                        case Image.Null:
                        case Image.Loading:
                        case Image.Error:
                            bg.state = "fallback"
                            break
                        case Image.Ready:
                            bg.state = "normal"
                            break
                        }
                    }
                }
                Text {
                    function cleanup(string) {
                        var t = string.replace("-", " ")
                        .replace("|", " ").replace(",", " ")
                        .replace(/\s\s+/g, "\n")
                        return t
                    }

                    visible: icon.width != bg.width
                    text: cleanup(title)
                    font.family: defaultFontFamily
                    font.pixelSize: 18
                    color: bg.state == "fallback" ? "white" : "black"
                    anchors {
                        top: icon.bottom
                        bottom: parent.bottom
                        left: parent.left
                        right: parent.right
                        leftMargin: 15
                        rightMargin: 15
                        bottomMargin: 15
                    }
                    maximumLineCount: 3
                    elide: Text.ElideRight
                    wrapMode: Text.Wrap
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                }
            }

            Rectangle {
                id: overlay
                visible: opacity != 0.0
                anchors.fill: parent
                color: iconOverlayColor
                opacity: {
                    if (iconMouse.pressed) {
                        if (homeScreen.state != "edit")
                            return 0.1
                        return 0.4
                    }
                    if (homeScreen.state == "edit")
                        return 0.3
                    return 0.0
                }
            }
            MouseArea {
                id: iconMouse
                anchors.fill: parent
                onPressAndHold: {
                    if (homeScreen.state == "edit") {
                        homeScreen.state = "enabled"
                        return
                    }
                    homeScreen.state = "edit"
                }
                onClicked: {
                    if (homeScreen.state == "edit") {
                        homeScreen.state = "enabled"
                        return
                    }
                    navigation.load(url)
                }
            }
            Rectangle {
                enabled: homeScreen.state == "edit"
                opacity: enabled ? 1.0 : 0.0
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
                        if (deleteButton.pressed)
                            return 0.70
                        return 1.0
                    }
                    anchors {
                        top: parent.top
                        left: parent.left
                    }
                    source: "assets/icons/Btn_Delete.png"
                    MouseArea {
                        id: deleteButton
                        anchors.fill: parent
                        onClicked: {
                            mouse.accepted = true
                            remove(url, index)
                        }
                    }
                }
                Behavior on opacity {
                    NumberAnimation { duration: animationDuration }
                }
            }
        }
    }
    Rectangle {
        width: homeScreen.cellSize - homeScreen.padding / 2 - 10
        anchors {
            left: parent.left
            top: parent.top
            bottom: parent.bottom
        }
        MouseArea {
            enabled: homeScreen.state == "edit"
            anchors.fill: parent
            onClicked: homeScreen.state = "enabled"
        }
    }
    Rectangle {
        width: homeScreen.cellSize - homeScreen.padding / 2 - 10
        anchors {
            right: parent.right
            top: parent.top
            bottom: parent.bottom
        }
        MouseArea {
            enabled: homeScreen.state == "edit"
            anchors.fill: parent
            onClicked: homeScreen.state = "enabled"
        }
    }
    Row {
        id: pageIndicator
        spacing: 20
        anchors {
            bottomMargin: 40
            bottom: parent.bottom
            horizontalCenter: parent.horizontalCenter
        }
        Repeater {
            model: {
                var c = gridView.count % gridViewPageItemCount
                if (c > 0)
                    c = 1
                return Math.floor(gridView.count / gridViewPageItemCount) + c
            }
            delegate: Rectangle {
                property bool active: index * gridView.page <= gridView.contentX && gridView.contentX < (index + 1) * gridView.page
                width: 10
                height: width
                radius: width / 2
                color: !active ? inactivePagerColor : uiColor
                anchors.verticalCenter: parent.verticalCenter
                MouseArea {
                    anchors.fill: parent
                    onClicked: gridView.contentX = index * gridView.page
                }
            }
        }
    }

    Rectangle {
        id: messageBox
        color: "white"
        anchors.fill: parent

        Rectangle {
            id: error
            visible: messageBox.state != "empty"
            height: childrenRect.height
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
                topMargin: 50
            }
            Image {
                id: errorIcon
                source: "assets/icons/Error_Icon.png"
                anchors {
                    horizontalCenter: parent.horizontalCenter
                    top: parent.top
                }
            }
            Text {
                anchors {
                    topMargin: 30
                    top: errorIcon.bottom
                    horizontalCenter: parent.horizontalCenter
                }
                font.family: defaultFontFamily
                font.pixelSize: message.font.pixelSize
                text: "Oops!..."
                color: iconOverlayColor
            }
        }

        Text {
            id: message
            anchors {
                top: error.bottom
                horizontalCenter: parent.horizontalCenter
            }
            color: iconOverlayColor
            font.family: defaultFontFamily
            font.pixelSize: 28
            verticalAlignment: Text.AlignTop
            horizontalAlignment: Text.AlignHCenter
        }

        Rectangle {
            color: parent.color
            anchors {
                top: message.bottom
                bottom: parent.bottom
                left: parent.left
                right: parent.right
                bottomMargin: 70
            }
            UIButton {
                color: uiColor
                implicitWidth: 180
                implicitHeight: 70
                buttonText: "OK"
                visible: messageBox.state != "empty"
                anchors {
                    horizontalCenter: parent.horizontalCenter
                    bottom: parent.bottom
                }
                onClicked: {
                    if (messageBox.state == "tabsfull") {
                        homeScreen.state = "disabled"
                        tabView.viewState = "list"
                        return
                    }
                    if (messageBox.state == "full") {
                        messageBox.state = "disabled"
                        homeScreen.state = "edit"
                        return
                    }
                }
            }
        }

        state: "disabled"

        states: [
            State {
                name: "disabled"
                PropertyChanges {
                    target: messageBox
                    visible: false
                }
            },
            State {
                name: "empty"
                PropertyChanges {
                    target: message
                    text: qsTr("No bookmarks have been saved so far.")
                }
                PropertyChanges {
                    target: messageBox
                    color: emptyBackgroundColor
                    visible: true
                }
                PropertyChanges {
                    target: error
                    anchors.topMargin: 30
                }
                PropertyChanges {
                    target: navigation
                    state: "enabled"
                }
            },
            State {
                name: "full"
                PropertyChanges {
                    target: message
                    text: qsTr("24 bookmarks is the maximum limit.\nTo bookmark a new page you must delete a bookmark first.")
                }
                PropertyChanges {
                    target: messageBox
                    visible: true
                }
                PropertyChanges {
                    target: navigation
                    state: "enabled"
                }
            },
            State {
                name: "tabsfull"
                PropertyChanges {
                    target: message
                    text: qsTr("10 open tabs is the maximum limit.\nTo open a new tab you must close another one first.")
                }
                PropertyChanges {
                    target: messageBox
                    visible: true
                }
                PropertyChanges {
                    target: navigation
                    state: "enabled"
                }
            }
        ]
    }
}
