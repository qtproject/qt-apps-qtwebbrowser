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

#ifndef APPENGINE_H
#define APPENGINE_H

#include <QtCore/QEvent>
#include <QtCore/QFileInfo>
#include <QtCore/QSettings>
#include <QtCore/QUrl>
#include <QtGui/QColor>
#include <QtQuick/QQuickItemGrabResult>

namespace utils {
inline bool isTouchEvent(const QEvent* event)
{
    switch (event->type()) {
    case QEvent::TouchBegin:
    case QEvent::TouchUpdate:
    case QEvent::TouchEnd:
        return true;
    default:
        return false;
    }
}

inline bool isMouseEvent(const QEvent* event)
{
    switch (event->type()) {
    case QEvent::MouseButtonPress:
    case QEvent::MouseMove:
    case QEvent::MouseButtonRelease:
    case QEvent::MouseButtonDblClick:
        return true;
    default:
        return false;
    }
}

}

class AppEngine : public QObject {
    Q_OBJECT

    Q_PROPERTY(QString settingsPath READ settingsPath FINAL CONSTANT)
    Q_PROPERTY(QString initialUrl READ initialUrl FINAL CONSTANT)

public:
    AppEngine(QObject *parent = 0);

    QString settingsPath();
    QString initialUrl() const;

    Q_INVOKABLE bool isUrl(const QString& userInput);
    Q_INVOKABLE QUrl fromUserInput(const QString& userInput);
    Q_INVOKABLE QString domainFromString(const QString& urlString);
    Q_INVOKABLE QString fallbackColor();
    Q_INVOKABLE QString restoreSetting(const QString &name, const QString &defaultValue = QString());
    Q_INVOKABLE void saveSetting(const QString &name, const QString &value);

private:
    QSettings m_settings;
    QString m_initialUrl;
};

#endif // APPENGINE_H
