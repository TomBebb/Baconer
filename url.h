#ifndef URL_H
#define URL_H

#include <QObject>
#include <QVariantMap>
#include <QQmlPropertyMap>

class url: public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString fullUrl READ fullUrl)
    Q_PROPERTY(QString urlWithoutArgs READ urlWithoutArgs)
    Q_PROPERTY(QVariantMap args READ args)
    Q_PROPERTY(QVariantMap hashArgs READ hashArgs)
public:
    url(QString fullUrl, QString urlWithoutArgs, QVariantMap args, QVariantMap hashArgs);

    const QString& fullUrl() const ;
    const QString& urlWithoutArgs() const ;
    const QVariantMap& args() const ;
    const QVariantMap& hashArgs() const ;

private:
    const QString m_fullUrl;
    const QString m_urlWithoutArgs;
    const QVariantMap m_args;
    const QVariantMap m_hashArgs;

};

#endif // URL_H
