import QtQuick 2.5
import QtQuick.Controls 1.5
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.3


ToolButton {
    id: root

    property string source;
    property string color: "white"
    style: ButtonStyle {
        background: Rectangle {
            implicitWidth: 40
            implicitHeight: 40
            color: root.color
            Image {
                source: root.source
                anchors.fill: parent
            }
        }
    }
}

