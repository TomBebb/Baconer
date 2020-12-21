#ifndef URLTOOLS_H
#define URLTOOLS_H

#include <QObject>
#include <QString>
#include <QUrl>
#include <QVariantMap>

#include "url.h"

class UrlUtils: public QObject
{
    Q_OBJECT

public:
    static UrlUtils& getInstance() {
        static UrlUtils instance;
        return instance;
    }
    explicit UrlUtils(QObject *parent = nullptr);

    Q_INVOKABLE url* parseUrl(const QString&) const;
    Q_INVOKABLE QString makeUrlParams(const QVariantMap&);
signals:
};

#endif // URLTOOLS_H
