import QtQuick 2.5
import QtQuick.Controls 1.5
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.3


ToolButton {
    id: root

    property string source
    property real radius: 0.0
    property string color: uiColor
    property string highlightColor: uiBorderColor
    style: ButtonStyle {
        background: Rectangle {
            implicitWidth: 60
            implicitHeight: 60
            color: root.pressed ? root.highlightColor : root.color
            radius: root.radius
            Image {
                source: root.source
                width: Math.min(50, parent.width)
                height: Math.min(50, parent.width)
                anchors.centerIn: parent
            }
        }
    }
}

