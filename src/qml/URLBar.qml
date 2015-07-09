import QtQuick 2.5
import QtQuick.Controls 1.5
import QtQuick.Controls.Styles 1.2

import "assets"

TextField {
    id: addressBar
    UIButton {
        id: reloadButton
        source: currentWebView && currentWebView.loading ? "qrc:///stop.png" : "qrc:///refresh.png"
        height: parent.height - 5
        width: implicitWidth - 5
        anchors {
            rightMargin: 10
            right: parent.right
            verticalCenter: addressBar.verticalCenter;
        }
        onClicked: currentWebView.loading ? currentWebView.stop() : currentWebView.reload()
    }
    style: TextFieldStyle {
        textColor: "black"
        font.family: "Helvetica"
        font.pointSize: 16
        selectionColor: uiSelectionColor
        selectedTextColor: "black"
        background: Rectangle {
            implicitWidth: 200
            implicitHeight: 40
            border.color: uiBorderColor
            border.width: 1
        }
        padding {
            right: 10
            left: 10
        }
    }
}
