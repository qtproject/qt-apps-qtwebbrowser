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
    opacity: tabs.viewState == "page" ? 1.0 : 0.0

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
            text: webView.url
            activeFocusOnPress: true
            placeholderText: qsTr("Search or type a URL")
            focus: !webView.focus

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
                font.pointSize: 28
                selectionColor: uiSelectionColor
                selectedTextColor: "black"
                placeholderTextColor: "#a0a1a2"
                background: Rectangle {
                    implicitWidth: 514
                    implicitHeight: 56
                    border.color: "#3881ae"
                    border.width: 1
                }
                padding {
                    left: 15
                    right: reloadButton.width
                }
            }
            onAccepted: {
                webView.url = engine.fromUserInput(text)
                tabs.viewState = "page"
            }
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
                console.log("Home clicked")
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
                if (tabs.viewState == "list") {
                    tabs.viewState = "page"
                } else {
                    tabs.get(tabs.currentIndex).item.webView.takeSnapshot()
                    tabs.viewState = "list"
                }
            }
            Text {
                anchors {
                    centerIn: parent
                    verticalCenterOffset: 4
                }

                text: tabs.count
                font.family: defaultFontFamily
                font.pointSize: 16
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
                console.log("Bookmarks clicked")
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
            id: settingsButton
            source: "qrc:///settings"
            checkable: true
            checked: false
            onClicked: tabs.interactive = !checked
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
                color: uiSelectionColor
            }
        }
        minimumValue: 0
        maximumValue: 100
        value: (webView && webView.loadProgress < 100) ? webView.loadProgress : 0
    }
}
