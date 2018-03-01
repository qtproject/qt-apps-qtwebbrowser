/****************************************************************************
**
** Copyright (C) 2016 The Qt Company Ltd.
** Contact: https://www.qt.io/licensing/
**
** This file is part of the Qt WebBrowser application.
**
** $QT_BEGIN_LICENSE:GPL$
** Commercial License Usage
** Licensees holding valid commercial Qt licenses may use this file in
** accordance with the commercial license agreement provided with the
** Software or, alternatively, in accordance with the terms contained in
** a written agreement between you and The Qt Company. For licensing terms
** and conditions see https://www.qt.io/terms-conditions. For further
** information use the contact form at https://www.qt.io/contact-us.
**
** GNU General Public License Usage
** Alternatively, this file may be used under the terms of the GNU
** General Public License version 3 or (at your option) any later version
** approved by the KDE Free Qt Foundation. The licenses are as published by
** the Free Software Foundation and appearing in the file LICENSE.GPL3
** included in the packaging of this file. Please review the following
** information to ensure the GNU General Public License requirements will
** be met: https://www.gnu.org/licenses/gpl-3.0.html.
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
        anchors {
            top: parent.top
            right: parent.right
            left: parent.left
        }
        Rectangle {
            width: childrenRect.width
            height: parent.height
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
            height: parent.height
            color: toolBarSeparatorColor
        }
        Rectangle {
            width: indicatorWidth
            height: parent.height
            color: toolBarFillColor
        }
        Rectangle {
            color: toolBarFillColor
            Layout.fillWidth: true
            height: parent.height
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
            height: parent.height
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
