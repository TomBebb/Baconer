#ifndef URLTOOLS_H
#define URLTOOLS_H

#include <QObject>
#include <QString>
#include <QUrl>

class URLTools: public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString userName READ userName WRITE setUserName NOTIFY userNameChanged)
    QML_ELEMENT
public:
    URLTools();
};

#endif // URLTOOLS_H
