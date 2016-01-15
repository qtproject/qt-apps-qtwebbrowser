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

#ifndef TOUCHTRACKER_H
#define TOUCHTRACKER_H

#include <QObject>
#include <QQuickItem>

class TouchTracker : public QQuickItem
{
    Q_OBJECT
    Q_PROPERTY(qreal touchX READ touchX NOTIFY touchChanged)
    Q_PROPERTY(qreal touchY READ touchY NOTIFY touchChanged)
    Q_PROPERTY(int xVelocity READ xVelocity NOTIFY velocityChanged)
    Q_PROPERTY(int yVelocity READ yVelocity NOTIFY velocityChanged)
    Q_PROPERTY(bool blockEvents READ blockEvents WRITE setBlockEvents NOTIFY blockEventsChanged)
    Q_PROPERTY(QQuickItem* target READ target WRITE setTarget NOTIFY targetChanged)

    struct PositionInfo
    {
        QPointF pos;
        qint64 ts;
        qreal x() const { return pos.x(); }
        qreal y() const { return pos.y(); }
    };

public:
    TouchTracker(QQuickItem *parent = 0);

    qreal touchX() const;
    qreal touchY() const;
    int xVelocity() const;
    int yVelocity() const;
    QQuickItem* target() const;
    bool blockEvents() const;
    void setBlockEvents(bool shouldBlock);
    void setTarget(QQuickItem * target);

signals:
    void touchChanged();
    void blockEventsChanged();
    void targetChanged();
    void touchBegin();
    void touchEnd();
    void velocityChanged();
    void scrollDirectionChanged();

protected:
    bool eventFilter(QObject *obj, QEvent *event);
    void touchEvent(QTouchEvent *event) override;

private:
    bool m_blockEvents;
    int m_diff;
    int m_previousY;
    PositionInfo m_startPoint;
    PositionInfo m_currentPoint;
    QQuickItem *m_target;
    QQuickItem *m_delegate;
};

#endif // TOUCHTRACKER_H
