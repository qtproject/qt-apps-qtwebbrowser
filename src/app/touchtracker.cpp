/****************************************************************************
**
** Copyright (C) 2016 The Qt Company Ltd.
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

#include "touchtracker.h"

#include <QDateTime>

#include "engine.h"

using namespace utils;

TouchTracker::TouchTracker(QQuickItem *parent)
    : QQuickItem(parent)
    , m_blockEvents(false)
    , m_diff(0)
    , m_previousY(0)
    , m_target(0)
    , m_delegate(0)
{
    m_startPoint.ts = 0;
    m_currentPoint.ts = 0;
}

QQuickItem *TouchTracker::target() const
{
    return m_target;
}

void TouchTracker::setTarget(QQuickItem * target)
{
    m_target = target;
    emit targetChanged();
}

int TouchTracker::xVelocity() const
{
    qreal pos = qAbs(m_startPoint.x() - m_currentPoint.x());
    qreal time = qAbs(m_startPoint.ts - m_currentPoint.ts);
    return pos / time * 1000;
}

int TouchTracker::yVelocity() const
{
    qreal pos = qAbs(m_startPoint.y() - m_currentPoint.y());
    qreal time = qAbs(m_startPoint.ts - m_currentPoint.ts);
    return pos / time * 1000;
}


qreal TouchTracker::touchX() const
{
    return m_currentPoint.x();
}

qreal TouchTracker::touchY() const
{
    return m_currentPoint.y();
}

bool TouchTracker::blockEvents() const
{
    return m_blockEvents;
}

void TouchTracker::setBlockEvents(bool shouldBlock)
{
    if (m_blockEvents == shouldBlock)
        return;
    m_blockEvents = shouldBlock;
    emit blockEventsChanged();
}

bool TouchTracker::eventFilter(QObject *obj, QEvent *event)
{
    if (obj != m_delegate)
        return QQuickItem::eventFilter(obj, event);

    if (event->type() == QEvent::Wheel)
        return m_blockEvents;

    if (!isTouchEvent(event))
        return QQuickItem::eventFilter(obj, event);

    const QTouchEvent *touch = static_cast<QTouchEvent*>(event);
    const QList<QTouchEvent::TouchPoint> &points = touch->touchPoints();
    m_previousY = m_currentPoint.y();
    m_currentPoint.pos = m_target->mapToScene(points.at(0).pos());
    m_currentPoint.ts = QDateTime::currentMSecsSinceEpoch();
    int currentDiff = m_previousY - m_currentPoint.y();

    if ((currentDiff > 0 && m_diff < 0) || (currentDiff < 0 && m_diff > 0))
        emit scrollDirectionChanged();

    m_diff = currentDiff;

    emit touchChanged();
    emit velocityChanged();

    if (event->type() ==  QEvent::TouchEnd)
        emit touchEnd();

    return m_blockEvents;
}

void TouchTracker::touchEvent(QTouchEvent * event)
{
    if (!m_target) {
        if (!m_blockEvents)
            QQuickItem::touchEvent(event);

        return;
    }

    event->setAccepted(false);

    const QList<QTouchEvent::TouchPoint> &points = event->touchPoints();
    m_currentPoint.pos = m_target->mapToScene(points.at(0).pos());
    m_currentPoint.ts = QDateTime::currentMSecsSinceEpoch();

    if (event->type() ==  QEvent::TouchBegin) {
        m_startPoint = m_currentPoint;
        emit touchBegin();
    }

    emit touchChanged();

    // We have to find the delegate to be able to filter
    // events from the WebEngineView.
    // This is a hack and should preferably be made easier
    // with the API in some way.
    QQuickItem *child = m_target->childAt(m_currentPoint.x(), m_currentPoint.y());
    if (child && m_delegate != child) {
        child->installEventFilter(this);
        m_delegate = child;
    }
}
