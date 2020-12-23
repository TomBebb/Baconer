#ifndef STRINGUTILS_H
#define STRINGUTILS_H

#include <QObject>
#include <QVariant>

class StringUtils : public QObject {
    Q_OBJECT
    public:
    static StringUtils& getInstance() {
        static StringUtils instance;
        return instance;
    }
    explicit StringUtils ( QObject *parent = nullptr );
    public slots:
    QString decodeHtml ( QString text );
    QChar charAt ( const QString& text, int index );

    bool isUpper ( QChar ch );
    bool isLower ( QChar ch );
    bool startsWith ( const QString& str, const QString& prefix );
    bool endsWith ( const QString& str, const QString& postfix );
    bool isNonEmptyString ( QVariant str );
    QString tidyDesc ( const QString& txt, uint len = 255 );
    QString randomString ( uint len = 20 );
   
    bool isValidFlair(const QString& flairText);
    signals:
};

#endif // STRINGUTILS_H
