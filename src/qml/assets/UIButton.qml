import QtQuick 2.5
import QtQuick.Controls 1.5
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.3


ToolButton {
    id: root
    implicitHeight: toolBarSize
    implicitWidth: toolBarSize

    property string source: ""
    property real radius: 0.0
    property string color: uiColor
    property string highlightColor: buttonHighlightColor
    style: ButtonStyle {
        background: Rectangle {
            opacity: root.enabled ? 1.0 : 0.3
            color: root.pressed ? root.highlightColor : root.color
            radius: root.radius
            Image {
                source: root.source
                width: Math.min(sourceSize.width, root.width)
                height: Math.min(sourceSize.height, root.height)
                anchors.centerIn: parent
            }
        }
    }
}

