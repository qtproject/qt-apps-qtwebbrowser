import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.2

import "assets"

ToolBar {
    id: root

    property alias addressBar: urlBar
    property string color: settingsView.privateBrowsingEnabled ? "#777f8c" : uiColor
    property string separatorColor: settingsView.privateBrowsingEnabled ? placeholderColor : uiSeparatorColor
    property string highlightColor: settingsView.privateBrowsingEnabled ? iconOverlayColor : buttonPressedColor
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
            color: root.color
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
            color: root.color
            highlightColor: root.highlightColor
            onClicked: webView.goBack()
            enabled: webView && webView.canGoBack
        }
        Rectangle {
            width: 1
            anchors {
                top: parent.top
                bottom: parent.bottom
            }
            color: root.separatorColor
        }
        UIButton {
            id: forwardButton
            source: "qrc:///forward"
            color: root.color
            highlightColor: root.highlightColor
            onClicked: webView.goForward()
            enabled: webView && webView.canGoForward
        }
        Rectangle {
            width: 1
            anchors {
                top: parent.top
                bottom: parent.bottom
            }
            color: root.separatorColor
        }
        Rectangle {
            Layout.fillWidth: true
            implicitWidth: 10
            anchors {
                top: parent.top
                bottom: parent.bottom
            }
            color: root.color
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
                    border.color: settingsView.privateBrowsingEnabled ? iconOverlayColor : textFieldStrokeColor
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
            color: root.color
        }
        Rectangle {
            width: 1
            anchors {
                top: parent.top
                bottom: parent.bottom
            }
            color: root.separatorColor
        }
        UIButton {
            id: homeButton
            source: "qrc:///home"
            color: root.color
            highlightColor: root.highlightColor
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
            color: root.separatorColor
        }
        UIButton {
            id: pageViewButton
            source: "qrc:///tabs"
            color: root.color
            highlightColor: root.highlightColor
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
            color: root.separatorColor
        }
        UIButton {
            id: bookmarksButton
            color: root.color
            highlightColor: root.highlightColor
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
            color: root.separatorColor
        }
        UIButton {
            id: settingsButton
            source: "qrc:///settings"
            color: root.color
            highlightColor: root.highlightColor
            onClicked: {
                tabView.interactive = false
                settingsView.state = "enabled"
            }
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
                color: root.separatorColor
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
