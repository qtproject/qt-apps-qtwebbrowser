#include "touchtracker.h"

#include <QDateTime>

#include "utils.h"

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
