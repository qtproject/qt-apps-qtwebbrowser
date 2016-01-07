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

#ifndef NAVIGATIONHISTORYPROXYMODEL_H
#define NAVIGATIONHISTORYPROXYMODEL_H

#include <QObject>
#include <QAbstractItemModel>
#include <QSortFilterProxyModel>

class NavigationHistoryProxyModel : public QSortFilterProxyModel
{
    Q_OBJECT

    Q_PROPERTY(QAbstractItemModel * target READ sourceModel WRITE setSourceModel)
    Q_PROPERTY(QString searchString READ searchString WRITE setSearchString NOTIFY searchStringChanged)
    Q_PROPERTY(bool enabled READ enabled WRITE setEnabled NOTIFY enabledChanged)

public:
    explicit NavigationHistoryProxyModel(QObject *parent = 0);


    bool filterAcceptsRow(int sourceRow, const QModelIndex &sourceParent) const override;

    bool enabled() const { return dynamicSortFilter(); }
    void setEnabled(bool enabled);

    void setTarget(QAbstractItemModel *t);

    QString searchString() const ;
    void setSearchString(const QString &pattern);

signals:
    void searchStringChanged();
    void enabledChanged();

private:
    QString m_searchString;
};

#endif // NAVIGATIONHISTORYPROXYMODEL_H
