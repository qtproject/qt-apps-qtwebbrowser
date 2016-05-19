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
