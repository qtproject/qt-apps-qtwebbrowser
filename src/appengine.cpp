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

#include "appengine.h"

#include <QtCore/QDir>
#include <QtCore/QStandardPaths>
#include <QStringBuilder>
#include <QCoreApplication>

AppEngine::AppEngine(QObject *parent)
    : QObject(parent)
    , m_settings(QStandardPaths::writableLocation(QStandardPaths::AppDataLocation) % QDir::separator() % "settings.ini", QSettings::IniFormat, this)
{
    foreach (const QString &arg, QCoreApplication::arguments().mid(1)) {
        if (arg.startsWith('-'))
            continue;
        const QUrl url(arg);
        if (url.isValid()) {
            m_initialUrl = url.toString();
            break;
        }
    }
}

QString AppEngine::settingsPath()
{
    return m_settings.fileName();
}

QString AppEngine::initialUrl() const
{
    return m_initialUrl;
}

QUrl AppEngine::fromUserInput(const QString& userInput)
{
    QFileInfo fileInfo(userInput);
    if (fileInfo.exists())
        return QUrl::fromLocalFile(fileInfo.absoluteFilePath());
    return QUrl::fromUserInput(userInput);
}

bool AppEngine::isUrl(const QString& userInput)
{
    if (userInput.startsWith(QStringLiteral("www."))
            || userInput.startsWith(QStringLiteral("http"))
            || userInput.startsWith(QStringLiteral("ftp"))
            || userInput.contains(QStringLiteral("://"))
            || userInput.endsWith(QStringLiteral(".com")))
        return true;
    return false;
}

QString AppEngine::domainFromString(const QString& urlString)
{
    return QUrl::fromUserInput(urlString).host();
}

QString AppEngine::fallbackColor()
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

QString AppEngine::restoreSetting(const QString &name, const QString &defaultValue)
{
    return m_settings.value(name, defaultValue).toString();
}

void AppEngine::saveSetting(const QString &name, const QString &value)
{
    m_settings.setValue(name, value);
}

