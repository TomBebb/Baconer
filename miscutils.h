#ifndef MISCUTILS_H
#define MISCUTILS_H

#include <QObject>

class MiscUtils : public QObject
{
    Q_OBJECT
public:
    static MiscUtils& getInstance() {
        static MiscUtils instance;
        return instance;
    }
    explicit MiscUtils(QObject *parent = nullptr);

    Q_INVOKABLE

signals:

};

#endif // MISCUTILS_H
