#ifndef FMTUTILS_H
#define FMTUTILS_H

#include <QObject>
#include <QDateTime>

class FmtUtils: public QObject
{
    Q_OBJECT
public:

    static FmtUtils& getInstance() {
        static FmtUtils instance;
        return instance;
    }
    explicit FmtUtils(QObject *parent = nullptr);

    Q_INVOKABLE QString formatTimeUnit(uint amount, const QString& unit) const;
    Q_INVOKABLE QString formatNum(int, bool showSign = false) const;
    Q_INVOKABLE QString formatDate(QDateTime dateTime) const;
};

#endif // FMTUTILS_H
