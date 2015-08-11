/****************************************************************************
**
** Copyright (C) 2015 The Qt Company Ltd.
** Contact: http://www.qt.io/licensing/
**
** This file is part of the QtBrowser project.
**
** $QT_BEGIN_LICENSE:GPL$
** Commercial License Usage
** Licensees holding valid commercial Qt licenses may use this file in
** accordance with the commercial license agreement provided with the
** Software or, alternatively, in accordance with the terms contained in
** a written agreement between you and The Qt Company. For licensing terms
** and conditions see http://www.qt.io/terms-conditions. For further
** information use the contact form at http://www.qt.io/contact-us.
**
** GNU General Public License Usage
** Alternatively, this file may be used under the terms of the GNU
** General Public License version 2 as published by the Free Software
** Foundation and appearing in the file LICENSE.GPLv2 included in the
** packaging of this file. Please review the following information to
** ensure the GNU General Public License version 2 requirements
** will be met: http://www.gnu.org/licenses/old-licenses/gpl-2.0.html.
**
** GNU General Public License Usage
** Alternatively, this file may be used under the terms of the GNU
** General Public License version 3.0 as published by the Free Software
** Foundation and appearing in the file LICENSE.GPL included in the
** packaging of this file. Please review the following information to
** ensure the GNU General Public License version 3.0 requirements will be
** met: http://www.gnu.org/copyleft/gpl.html.
**
**
** $QT_END_LICENSE$
**
****************************************************************************/

import QtQuick 2.5
import QtQuick.Controls 1.0
import QtQuick.Controls.Styles 1.0
import QtQuick.Layouts 1.0

ToolBar {
    id: root

    property alias title: titleBox.text
    property alias source: toolBarButton.source
    property alias indicator: indicatorText.text

    property int indicatorWidth: 40
    property int indicatorHeight: 32

    signal optionClicked()
    signal doneClicked()

    height: navigation.height

    style: ToolBarStyle {
        background: Rectangle {
            color: toolBarFillColor
        }
        padding {
            left: 0
            right: 0
            top: 0
            bottom: 0
        }
    }

    RowLayout {
        spacing: 0
        height: toolBarSize
        anchors.fill: parent
        Rectangle {
            width: childrenRect.width
            anchors {
                left: parent.left
                top: parent.top
                bottom: parent.bottom
            }
            color: toolBarFillColor
            Text {
                id: titleBox
                visible: root.title !== ""
                anchors {
                    leftMargin: visible ? 30 : 0
                    left: parent.left
                    verticalCenter: parent.verticalCenter
                }
                color: "white"
                font.pixelSize: 28
                font.family: defaultFontFamily
            }
            Rectangle {
                visible: toolBarButton.visible && titleBox.visible
                width: 1
                anchors {
                    top: parent.top
                    bottom: parent.bottom
                }
                color: toolBarSeparatorColor
            }
            UIButton {
                id: toolBarButton
                visible: root.source !== ""
                color: toolBarFillColor
                Component.onCompleted: toolBarButton.clicked.connect(root.optionClicked)
                anchors.left: titleBox.right
            }
        }
        Rectangle {
            visible: toolBarButton.visible
            width: 1
            anchors {
                top: parent.top
                bottom: parent.bottom
            }
            color: toolBarSeparatorColor
        }
        Rectangle {
            width: indicatorWidth
            anchors {
                top: parent.top
                bottom: parent.bottom
            }
            color: toolBarFillColor
        }
        Rectangle {
            color: toolBarFillColor
            Layout.fillWidth: true
            anchors {
                top: parent.top
                bottom: parent.bottom
            }
            Rectangle {
                visible: root.indicator !== ""
                color: "transparent"
                border.color: "white"
                border.width: 2
                width: indicatorWidth
                height: indicatorHeight
                anchors.centerIn: parent
                Text {
                    id: indicatorText
                    anchors.centerIn: parent
                    color: "white"
                    font.family: defaultFontFamily
                    font.pixelSize: 20
                }
            }
        }
        Rectangle {
            width: 1
            anchors {
                top: parent.top
                bottom: parent.bottom
            }
            color: toolBarSeparatorColor
        }
        UIButton {
            id: doneButton
            color: toolBarFillColor
            buttonText: "Done"
            implicitWidth: 120
            Component.onCompleted: doneButton.clicked.connect(root.doneClicked)
        }
    }
}
