import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.2

import "assets"

ToolBar {
    id: root

    property alias addressBar: urlBar
    property Item webView: null

    onWebViewChanged: {

    }

    visible: opacity != 0.0
    opacity: tabView.viewState == "page" ? 1.0 : 0.0

    function load(url) {
        webView.url = url
        homeScreen.state = "disabled"
    }

    function refresh() {
        if (urlBar.text == "")
            bookmarksButton.bookmarked = false
        else
            bookmarksButton.bookmarked = homeScreen.contains(urlBar.text) !== -1
    }

    state: "enabled"

    style: ToolBarStyle {
        background: Rectangle {
            color: uiColor
            implicitHeight: toolBarSize + 3
        }
        padding {
            left: 0
            right: 0
            top: 0
            bottom: 0
        }
    }

    Behavior on y {
        NumberAnimation { duration: animationDuration }
    }

    states: [
        State {
            name: "enabled"
            PropertyChanges {
                target: root
                y: 0
            }
        },
        State {
            name: "tracking"
            PropertyChanges {
                target: root
                y: {
                    var diff = touchReference - touchY

                    if (velocityY > velocityThreshold) {
                        if (diff > 0)
                            return -root.height
                        else
                            return 0
                    }

                    if (!touchGesture || diff == 0) {
                        if (y < -root.height / 2)
                            return -root.height
                        else
                            return 0
                    }

                    if (diff > root.height)
                        return -root.height

                    if (diff > 0) {
                        if (y == -root.height)
                            return -root.height
                        return -diff
                    }

                    // diff < 0

                    if (y == 0)
                        return 0

                    diff = Math.abs(diff)
                    if (diff >= root.height)
                        return 0

                    return -root.height + diff
                }
            }
        },
        State {
            name: "disabled"
            PropertyChanges {
                target: root
                y: -root.height
            }
        }
    ]

    RowLayout {
        height: toolBarSize
        anchors {
            top: parent.top
            right: parent.right
            left: parent.left
        }
        spacing: 0

        UIButton {
            id: backButton
            source: "qrc:///back"
            color: uiColor
            highlightColor: buttonPressedColor
            onClicked: webView.goBack()
            enabled: webView && webView.canGoBack
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
            id: forwardButton
            source: "qrc:///forward"
            color: uiColor
            highlightColor: buttonPressedColor
            onClicked: webView.goForward()
            enabled: webView && webView.canGoForward
        }
        Rectangle {
            width: 1
            anchors {
                top: parent.top
                bottom: parent.bottom
            }
            color: uiSeparatorColor
        }
        Rectangle {
            Layout.fillWidth: true
            implicitWidth: 10
            anchors {
                top: parent.top
                bottom: parent.bottom
            }
            color: uiColor
        }
        TextField {
            id: urlBar
            Layout.fillWidth: true
            text: webView ? webView.url : ""
            activeFocusOnPress: true
            inputMethodHints: Qt.ImhUrlCharactersOnly | Qt.ImhNoPredictiveText | Qt.ImhNoAutoUppercase | Qt.ImhPreferLowercase
            placeholderText: qsTr("Search or type a URL")

            onActiveFocusChanged: {
                if (activeFocus) {
                    urlBar.selectAll()
                    root.state = "enabled"
                    homeScreen.state = "disabled"
                    urlDropDown.state = "enabled"
                } else {
                    urlDropDown.state = "disabled"
                    root.state = "tracking"
                }
            }

            UIButton {
                id: reloadButton
                state: cancelButton.visible ? "edit" : "load"
                states: [
                    State {
                        name: "load"
                        PropertyChanges {
                            target: reloadButton
                            source: webView && webView.loading ? "qrc:///stop" : "qrc:///refresh"
                            height: 54
                        }
                    },
                    State {
                        name: "edit"
                        PropertyChanges {
                            target: reloadButton
                            source: "qrc:///stop"
                            height: 45
                            visible: urlBar.text != ""
                        }
                    }
                ]
                height: 54
                width: height
                color: "transparent"
                highlightColor: "#eeeeee"
                radius: width / 2
                anchors {
                    rightMargin: 1
                    right: parent.right
                    verticalCenter: addressBar.verticalCenter;
                }
                onClicked: {
                    if (state == "load") {
                        webView.loading ? webView.stop() : webView.reload()
                        webView.forceActiveFocus()
                        return
                    }
                    urlBar.selectAll()
                    urlBar.remove(urlBar.selectionStart, urlBar.selectionEnd)
                }
            }
            style: TextFieldStyle {
                textColor: "black"
                font.family: defaultFontFamily
                font.pixelSize: 28
                selectionColor: uiHighlightColor
                selectedTextColor: "black"
                placeholderTextColor: placeholderColor
                background: Rectangle {
                    implicitWidth: 514
                    implicitHeight: 56
                    border.color: settingsView.privateBrowsingEnabled ? "black" : textFieldStrokeColor
                    border.width: 1
                }
                padding {
                    left: 15
                    right: reloadButton.width
                }
            }
            onAccepted: {
                webView.url = engine.fromUserInput(text)
                homeScreen.state = "disabled"
                tabView.viewState = "page"
            }

            onTextChanged: refresh()
            onEditingFinished: {
                selectAll()
                webView.forceActiveFocus()
            }
        }
        Rectangle {
            visible: !cancelButton.visible
            Layout.fillWidth: true
            implicitWidth: 10
            anchors {
                top: parent.top
                bottom: parent.bottom
            }
            color: uiColor
        }

        UIButton {
            id: cancelButton
            color: uiColor
            visible: urlDropDown.state === "enabled"
            highlightColor: buttonPressedColor
            Text {
                color: "white"
                anchors.centerIn: parent
                text: "Cancel"
                font.family: defaultFontFamily
                font.pixelSize: 28
            }
            implicitWidth: 120
            onClicked: {
                urlDropDown.state = "disabled"
                webView.forceActiveFocus()
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
            id: homeButton
            source: "qrc:///home"
            color: uiColor
            highlightColor: buttonPressedColor
            onClicked: {
                if (homeScreen.state == "disabled" || homeScreen.state == "edit") {
                    homeScreen.messageBox.state = "disabled"
                    homeScreen.state = "enabled"
                    homeScreen.forceActiveFocus()
                } else if (homeScreen.state != "disabled") {
                    homeScreen.state = "disabled"
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
            id: pageViewButton
            source: "qrc:///tabs"
            color: uiColor
            highlightColor: buttonPressedColor
            onClicked: {
                if (tabView.viewState == "list") {
                    tabView.viewState = "page"
                } else {
                    tabView.get(tabView.currentIndex).item.webView.takeSnapshot()
                    homeScreen.state = "disabled"
                    tabView.viewState = "list"
                }
            }
            Text {
                anchors {
                    centerIn: parent
                    verticalCenterOffset: 4
                }

                text: tabView.count
                font.family: defaultFontFamily
                font.pixelSize: 16
                font.weight: Font.DemiBold
                color: "white"
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
            id: bookmarksButton
            color: uiColor
            highlightColor: buttonPressedColor
            enabled: urlBar.text != "" && !settingsView.privateBrowsingEnabled
            property bool bookmarked: false
            source: bookmarked ? "qrc:///star_checked" : "qrc:///star"
            onClicked: {
                if (!webView)
                    return
                var icon = webView.loading ? "" : webView.icon
                var idx = homeScreen.contains(webView.url.toString())
                if (idx !== -1) {
                    homeScreen.remove("", idx)
                    return
                }
                var count = homeScreen.count
                homeScreen.add(webView.title, webView.url, icon, engine.fallbackColor())
                if (count < homeScreen.count)
                    bookmarked = true
            }
            Component.onCompleted: refresh()
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
            id: settingsButton
            source: "qrc:///settings"
            color: uiColor
            highlightColor: buttonPressedColor
            onClicked: {
                settingsView.state = "enabled"
            }
        }
    }
    ProgressBar {
        id: progressBar
        height: 3
        anchors {
            left: parent.left
            bottom: parent.bottom
            right: parent.right
            leftMargin: -10
            rightMargin: -10
        }
        style: ProgressBarStyle {
            background: Rectangle {
                height: 3
                color: "#e4e4e4"
            }
            progress: Rectangle {
                color: settingsView.privateBrowsingEnabled ? "#46a2da" : "#317198"
            }
        }
        minimumValue: 0
        maximumValue: 100
        value: (webView && webView.loadProgress < 100) ? webView.loadProgress : 0
    }
}
