#include "stringutils.h"
#include <QDebug>
#include <QRegularExpression>
#include <QRandomGenerator>

StringUtils::StringUtils ( QObject *parent ) : QObject ( parent )
{
}


QString StringUtils::decodeHtml ( QString raw )
{
    return raw
           .replace ( "&amp;", "&" )
           .replace ( "&lt;", "<" )
           .replace ( "&gt;", ">" );
}
QChar StringUtils::charAt ( const QString& text, int index )
{
    return text[index];
}

bool StringUtils::isUpper ( QChar ch )
{
    return ch.isUpper();
}


bool StringUtils::isLower ( QChar ch )
{
    return ch.isLower();
}
bool StringUtils::startsWith ( const QString& str, const QString& prefix )
{
    return str.startsWith ( prefix );
}

bool StringUtils::endsWith ( const QString& str, const QString& postfix )
{
    return str.endsWith ( postfix );
}

bool StringUtils::isNonEmptyString ( QVariant txt )
{
    if ( !txt.canConvert<bool>() ) {
        return false;
    }
    return txt.value<QString>().length() > 0;
}

QString StringUtils::tidyDesc ( const QString& txt, uint len )
{

    auto text = decodeHtml ( txt );
    QRegularExpressionMatch newlineMatch;
    text.indexOf ( QRegularExpression ( "[\r\n]" ), 0, &newlineMatch );
    if ( newlineMatch.hasMatch() ) {
        text = text.left ( newlineMatch.capturedStart() );
    }


    if ( ( uint ) text.length() > len ) {
        text = text.left ( len - 3 ) + "...";
    }
    return text;
}

QString StringUtils::randomString ( uint len )
{
    static QString chars = "abcdefghijklmnopqrstuvqxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    QString result = "";
    auto rng = QRandomGenerator::global();
    result.reserve ( len );
    for ( uint i = 0; i < len; i++ ) {
        result.append ( chars.at ( rng->bounded ( chars.length() ) ) );
    }
    qDebug() << "string w/ " << len << " chars generated: " << result;
    return result;
}

bool StringUtils::isValidFlair(const QString& flairText) {
    if (flairText.length() == 0)
        return false;
    return flairText.at(0) != ':' && flairText.at(flairText.length() - 1) != ':';
}
