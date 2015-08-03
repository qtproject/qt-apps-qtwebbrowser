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

#include <QtCore/QDir>
#include <QtCore/QStandardPaths>
#include <QStringBuilder>

Engine::Engine(QObject *parent)
    : QObject(parent)
    , m_bookmarks(QStandardPaths::writableLocation(QStandardPaths::AppDataLocation) % QDir::separator() % "bookmarks.ini", QSettings::IniFormat, this)
{
}

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

QString Engine::fallbackColor()
{
    static QList<QString> colors = QList<QString>() << QStringLiteral("#46a2da")
                                                    << QStringLiteral("#18394c")
                                                    << QStringLiteral("#ff8c0a")
                                                    << QStringLiteral("#5caa15");
    static int index = -1;
    if (++index == colors.count())
        index = 0;
    return colors[index];
}

QString Engine::restoreBookmarks()
{
    return m_bookmarks.value("bookmarks").toString();
}

void Engine::saveBookmarks(const QString & list)
{
    m_bookmarks.setValue("bookmarks", list);
}
