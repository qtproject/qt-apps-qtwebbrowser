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

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts


ToolButton {
    id: root
    implicitHeight: toolBarSize
    implicitWidth: toolBarSize

    property alias buttonText: label.text
    property alias textColor: label.color
    property alias textSize: label.font.pixelSize
    property string source: ""
    property real radius: 0.0
    property string color: uiColor
    property string highlightColor: buttonPressedColor
    Text {
        id: label
        color: "white"
        anchors.centerIn: parent
        font.family: defaultFontFamily
        font.pixelSize: 28
    }

    background: Rectangle {
        opacity: root.enabled ? 1.0 : 0.3
        color: root.pressed || root.checked ? root.highlightColor : root.color
        radius: root.radius
        Image {
            source: root.source
            width: Math.min(sourceSize.width, root.width)
            height: Math.min(sourceSize.height, root.height)
            anchors.centerIn: parent
        }
    }
}

