#ifndef URLTOOLS_H
#define URLTOOLS_H

#include <QObject>
#include <QString>
#include <QUrl>

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
public slots:


    url* parseUrl(const QString&) const;
signals:
};

#endif // URLTOOLS_H
