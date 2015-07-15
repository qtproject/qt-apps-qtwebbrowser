import QtQuick 2.5
import QtQuick.Controls 1.5
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.3

import "assets"

ToolBar {
    id: root

    property alias addressBar: urlBar

    property Item webView: null

    height: toolBarHeight

    style: ToolBarStyle {
        background: Rectangle {
            color: uiColor
        }
    }

    RowLayout {
        anchors.fill: parent

        UIButton {
            id: backButton
            source: enabled ? "qrc:///previous" : "qrc:///previous_inactive"
            onClicked: webView.goBack()
            enabled: webView && webView.canGoBack
        }
        Rectangle {
            width: 1
            anchors {
                top: parent.top
                bottom: parent.bottom
            }
            color: uiBorderColor
        }
        UIButton {
            id: forwardButton
            source: enabled ? "qrc:///next" : "qrc:///next_inactive"
            onClicked: webView.goForward()
            enabled: webView && webView.canGoForward
        }
        Rectangle {
            width: 1
            anchors {
                top: parent.top
                bottom: parent.bottom
            }
            color: uiBorderColor
        }

        TextField {
            id: urlBar
            Layout.fillWidth: true
            text: webView.url
            UIButton {
                id: reloadButton
                source: webView && webView.loading ? "qrc:///stop" : "qrc:///refresh"
                height: parent.height - 15
                width: height
                color: "white"
                radius: width / 2
                highlightColor: buttonHighlightColor
                anchors {
                    rightMargin: 10
                    right: parent.right
                    verticalCenter: addressBar.verticalCenter;
                }
                onClicked: { webView.loading ? webView.stop() : webView.reload() }
            }
            style: TextFieldStyle {
                textColor: "black"
                font.family: "Helvetica"
                font.pointSize: 16
                selectionColor: uiSelectionColor
                selectedTextColor: "black"
                background: Rectangle {
                    implicitWidth: 200
                    implicitHeight: 50
                    border.color: "#3881ae"
                    border.width: 1
                }
                padding {
                    right: 20 + reloadButton.width
                    left: 10
                }
            }
            onAccepted: {
                webView.url = engine.fromUserInput(text)
                tabs.viewState = "page"
            }
        }
        Rectangle {
            width: 1
            anchors {
                top: parent.top
                bottom: parent.bottom
            }
            color: uiBorderColor
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
            color: uiBorderColor
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
        }
        Rectangle {
            width: 1
            anchors {
                top: parent.top
                bottom: parent.bottom
            }
            color: uiBorderColor
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
            color: uiBorderColor
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
            top: parent.bottom
            right: parent.right
            leftMargin: -parent.leftMargin
            rightMargin: -parent.rightMargin
        }
        style: ProgressBarStyle {
            background: Rectangle {
                color: uiBorderColor
            }
            progress: Rectangle {
                color: uiSelectionColor
            }
        }
        z: -2
        minimumValue: 0
        maximumValue: 100
        value: (webView && webView.loadProgress < 100) ? webView.loadProgress : 0
    }
}
