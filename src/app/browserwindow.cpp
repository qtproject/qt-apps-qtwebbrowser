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

#include "browserwindow.h"

#include <QList>
#include <QQmlContext>
#include <QQmlEngine>
#include <QQuickItem>
#include <QRectF>
#include <QUrl>
#include <QVariant>

#include "engine.h"

void BrowserWindow::ensureProfileInstance()
{
    if (m_lazyProfileInstance)
        return;
    QQmlComponent *component =  new QQmlComponent(engine(), this);

    component->setData(
                QByteArrayLiteral("import QtQuick 2.0\n"
                                  "import QtWebEngine 1.1\n"
                                  "WebEngineProfile {\n"
                                  "  storageName: \"YABProfile\"\n"
                                  "}")
                , QUrl());
    m_lazyProfileInstance = component->create(engine()->rootContext());
    Q_ASSERT(m_lazyProfileInstance);
    QQmlEngine::setObjectOwnership(m_lazyProfileInstance, QQmlEngine::JavaScriptOwnership);
}

QObject *BrowserWindow::defaultProfile()
{
    ensureProfileInstance();
    return m_lazyProfileInstance;
}

BrowserWindow::BrowserWindow(QWindow *)
    : m_lazyProfileInstance(0)
{
    setTitle("Yet Another Browser");
    setFlags(Qt::Window | Qt::WindowTitleHint);
    setResizeMode(QQuickView::SizeRootObjectToView);
    setColor(Qt::black);

    engine()->rootContext()->setContextProperty("WebEngine", new Engine(this));
    setSource(QUrl("qrc:///qml/BrowserWindow.qml"));
}

BrowserWindow::~BrowserWindow()
{
}

void BrowserWindow::updateVisualMockTouchPoints(const QList<QTouchEvent::TouchPoint>& touchPoints)
{
    if (touchPoints.isEmpty()) {
        // Hide all touch indicator items.
        foreach (QQuickItem* item, m_activeMockComponents.values())
            item->setProperty("pressed", false);

        return;
    }

    foreach (const QTouchEvent::TouchPoint& touchPoint, touchPoints) {
        QQuickItem* mockTouchPointItem = m_activeMockComponents.value(touchPoint.id());

        if (!mockTouchPointItem) {
            QQmlComponent touchMockPointComponent(engine(), QUrl("qrc:///qml/MockTouchPoint.qml"));
            mockTouchPointItem = qobject_cast<QQuickItem*>(touchMockPointComponent.create());
            Q_ASSERT(mockTouchPointItem);
            m_activeMockComponents.insert(touchPoint.id(), mockTouchPointItem);
            mockTouchPointItem->setProperty("pointId", QVariant(touchPoint.id()));
            mockTouchPointItem->setParent(rootObject());
            mockTouchPointItem->setParentItem(rootObject());
        }

        QRectF touchRect = touchPoint.rect();
        mockTouchPointItem->setX(touchRect.center().x());
        mockTouchPointItem->setY(touchRect.center().y());
        mockTouchPointItem->setWidth(touchRect.width());
        mockTouchPointItem->setHeight(touchRect.height());
        mockTouchPointItem->setProperty("pressed", QVariant(touchPoint.state() != Qt::TouchPointReleased));
    }
}
