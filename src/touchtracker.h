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

protected:
    bool eventFilter(QObject *obj, QEvent *event);
    void touchEvent(QTouchEvent *event) override;

private:
    bool m_blockEvents;
    PositionInfo m_startPoint;
    PositionInfo m_currentPoint;
    QQuickItem *m_target;
    QQuickItem *m_delegate;
};

#endif // TOUCHTRACKER_H
