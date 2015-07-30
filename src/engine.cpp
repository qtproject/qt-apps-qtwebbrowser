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

#include "engine.h"

QUrl Engine::fromUserInput(const QString& userInput)
{
    QFileInfo fileInfo(userInput);
    if (fileInfo.exists())
        return QUrl::fromLocalFile(fileInfo.absoluteFilePath());
    return QUrl::fromUserInput(userInput);
}

QString Engine::domainFromString(const QString& urlString)
{
    return QUrl::fromUserInput(urlString).host();
}

QString Engine::randomColor()
{
    QColor color(utils::randomColor(), utils::randomColor(), utils::randomColor());
    return color.name();
}

QString Engine::colorForIcon(QQuickItemGrabResult *result)
{
    QImage image = result->image();
    int hue = 0;
    int saturation = 0;
    int value = 0;
    for (int i = 0, width = image.width(); i < width; ++i) {
        int skip = 0;
        int h = 0;
        int s = 0;
        int v = 0;
        for (int j = 0, height = image.height(); j < height; ++j) {
            const QColor color(QColor(image.pixel(i, j)).toHsv());
            if (color.alpha() < 127) {
                ++skip;
                continue;
            }

            h += color.hsvHue();
            s += color.hsvSaturation();
            v += color.value();
        }
        int count = image.height() - skip + 1;
        hue = h / count;
        saturation = s / count;
        value = v / count;
    }
    return QColor::fromHsv(hue, saturation, value).name();
}

QString Engine::oppositeColor(const QString &color)
{
    const QColor c(QColor(color).toHsv());
    return QColor::fromHsv(c.hue(), c.saturation(), c.value() < 127 ? 255 : c.value() - 100).name();
}
