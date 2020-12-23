#include "url.h"
#include <QRegularExpression>
#include <QDebug>

url::url ( QString fullUrl, QString urlWithoutArgs, QVariantMap args, QVariantMap hashArgs ) : m_fullUrl ( fullUrl ), m_urlWithoutArgs ( urlWithoutArgs ), m_args ( args ), m_hashArgs ( hashArgs )
{

}

const QString& url::fullUrl() const
{
    return m_fullUrl;
}

const QString& url::urlWithoutArgs() const
{
    return m_fullUrl;
}

const QVariantMap& url::args() const
{
    return m_args;
}
const QVariantMap& url::hashArgs() const
{
    return m_hashArgs;
}
