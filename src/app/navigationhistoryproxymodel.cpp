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

#include "navigationhistoryproxymodel.h"

NavigationHistoryProxyModel::NavigationHistoryProxyModel(QObject *parent)
    : QSortFilterProxyModel(parent)
{

}

bool NavigationHistoryProxyModel::filterAcceptsRow(int sourceRow, const QModelIndex &sourceParent) const
{
    QModelIndex index = sourceModel()->index(sourceRow, 0, sourceParent);

    // Use UrlRole and TitleRole instead of DisplayRole
    return (sourceModel()->data(index, Qt::UserRole + 1).toString().contains(filterRegExp())
            || sourceModel()->data(index, Qt::UserRole + 2).toString().contains(filterRegExp()));
}

void NavigationHistoryProxyModel::setEnabled(bool enabled)
{
    if (dynamicSortFilter() == enabled)
        return;
    setDynamicSortFilter(enabled);
    emit enabledChanged();
}

QString NavigationHistoryProxyModel::searchString() const
{
    return m_searchString;
}

void NavigationHistoryProxyModel::setSearchString(const QString &pattern)
{
    if (m_searchString == pattern)
        return;

    m_searchString = pattern;
    setFilterRegExp(QRegExp(pattern, Qt::CaseInsensitive, QRegExp::FixedString));
    emit searchStringChanged();
}
