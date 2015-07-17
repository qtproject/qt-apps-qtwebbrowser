import QtQuick 2.5
import QtQuick.Controls 1.5
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.3


ToolButton {
    id: root

    property string source: ""
    property real radius: 0.0
    property string color: uiColor
    property string highlightColor: uiBorderColor
    style: ButtonStyle {
        background: Rectangle {
            implicitWidth: Math.max(60, parent.width)
            implicitHeight: 60
            color: root.pressed ? root.highlightColor : root.color
            radius: root.radius
            Image {
                source: root.source
                height: Math.min(50, parent.width)
                anchors.centerIn: parent
            }
        }
    }
}

