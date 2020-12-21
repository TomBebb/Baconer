#include "urlutils.h"
#include <QDebug>
#include <QRegularExpression>
#include <QUrl>

UrlUtils::UrlUtils(QObject *parent) : QObject(parent)
{
}


url* UrlUtils::parseUrl(const QString& pUrl) const {
    static QRegularExpression hashArgRegex("(?:^|&|;)([^=]+)=([^&|;]+)");
    static QRegularExpression urlArgRegex("(?:\\?|&|;)([^=]+)=([^&|;]+)");

    QVariantMap args, hashArgs;

    const auto hashParts = pUrl.split('#');
    QString urlNoArgs = hashParts[0];
    if (hashParts.size() >= 2) {
        const auto hashData = hashParts[1];

        auto hashArgIter = hashArgRegex.globalMatch(hashData);

        while (hashArgIter.hasNext()) {
            auto match = hashArgIter.next();
            hashArgs.insert(match.captured(1), match.captured(2));

        }
    }

    auto urlArgIter = urlArgRegex.globalMatch(urlNoArgs);
    while (urlArgIter.hasNext()) {
        auto match = urlArgIter.next();
        args.insert(match.captured(1), match.captured(2));
    }

    return new url(pUrl, urlNoArgs, args, hashArgs);
}



QString UrlUtils::makeUrlParams(const QVariantMap& params) {

    QString url;
    url.reserve(params.size() * 8);
    for (const auto &name: params.keys()) {
        const auto& value = params[name];
        url.append(QUrl::fromPercentEncoding(name.toUtf8()));
        url.append('=');
        url.append(QUrl::fromPercentEncoding(value.toString().toUtf8()));
        url.append('&');
    }
    return url;
}
