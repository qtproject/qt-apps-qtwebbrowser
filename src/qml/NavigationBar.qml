import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.2

import "assets"

ToolBar {
    id: root

    property alias addressBar: urlBar
    property Item webView: null

    visible: opacity != 0.0
    opacity: tabView.viewState == "page" ? 1.0 : 0.0

    function load(url) {
        webView.url = url
        homeScreen.state = "disabled"
    }

    function refresh() {
        bookmarksButton.enabled = homeScreen.contains(urlBar.text) === -1
    }

    state: "enabled"

    style: ToolBarStyle {
        background: Rectangle {
            color: uiColor
            implicitHeight: toolBarSize
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
                            return -toolBarSize
                        else
                            return 0
                    }

                    if (!touchGesture || diff == 0) {
                        if (y < -toolBarSize / 2)
                            return -toolBarSize
                        else
                            return 0
                    }

                    if (diff > toolBarSize)
                        return -toolBarSize

                    if (diff > 0) {
                        if (y == -toolBarSize)
                            return -toolBarSize
                        return -diff
                    }

                    // diff < 0

                    if (y == 0)
                        return 0

                    diff = Math.abs(diff)
                    if (diff >= toolBarSize)
                        return 0

                    return -toolBarSize + diff
                }
            }
        },
        State {
            name: "disabled"
            PropertyChanges {
                target: root
                y: -toolBarSize
            }
        }
    ]

    RowLayout {
        height: toolBarSize - 2
        anchors {
            top: parent.top
            right: parent.right
            left: parent.left
        }
        spacing: 0

        UIButton {
            id: backButton
            source: "qrc:///back"
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
            placeholderText: qsTr("Search or type a URL")
            focus: false

            onActiveFocusChanged: {
                if (activeFocus)
                    root.state = "enabled"
                else
                    root.state = "tracking"
            }

            UIButton {
                id: reloadButton
                source: webView && webView.loading ? "qrc:///stop" : "qrc:///refresh"
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
                onClicked: { webView.loading ? webView.stop() : webView.reload() }
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
                    border.color: textFieldStrokeColor
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
            onEditingFinished: selectAll()
            onFocusChanged: {
                if (focus) {
                    forceActiveFocus()
                    selectAll()
                } else {
                    urlBar.cursorPosition = 0
                    deselect()
                }
            }
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
            onClicked: {
                if (homeScreen.state == "disabled" || homeScreen.state == "edit") {
                    homeScreen.messageBox.state = "disabled"
                    homeScreen.state = "enabled"
                } else if (homeScreen.state != "disabled")
                    homeScreen.state = "disabled"
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
            source: "qrc:///star"
            onClicked: {
                if (!webView)
                    return
                var icon = webView.loading ? "" : webView.icon
                homeScreen.add(webView.title, webView.url, icon, engine.fallbackColor())
                enabled = false
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
            checkable: true
            checked: false
            onClicked: tabView.interactive = !checked
        }
    }
    ProgressBar {
        id: progressBar
        height: 2
        anchors {
            left: parent.left
            bottom: parent.bottom
            right: parent.right
            leftMargin: -10
            rightMargin: -10
        }
        style: ProgressBarStyle {
            background: Rectangle {
                height: 1
                color: uiSeparatorColor
            }
            progress: Rectangle {
                color: uiHighlightColor
            }
        }
        minimumValue: 0
        maximumValue: 100
        value: (webView && webView.loadProgress < 100) ? webView.loadProgress : 0
    }
}
