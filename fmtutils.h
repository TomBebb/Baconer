#ifndef FMTUTILS_H
#define FMTUTILS_H

#include <QObject>

class FmtUtils: public QObject
{
public:
    Q_OBJECT

public:
    static FmtUtils& getInstance() {
        static FmtUtils instance;
        return instance;
    }
    explicit FmtUtils(QObject *parent = nullptr);

    Q_INVOKABLE QString pluralize(uint amount, const QString& unit);
    Q_INVOKABLE QString formatNum(int, bool showSign = false);
};

#endif // FMTUTILS_H
