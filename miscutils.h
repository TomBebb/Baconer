#ifndef MISCUTILS_H
#define MISCUTILS_H

#include <QObject>
#include <QVariantMap>

class MiscUtils : public QObject
{
    Q_OBJECT
public:
    static MiscUtils& getInstance() {
        static MiscUtils instance;
        return instance;
    }
    explicit MiscUtils(QObject *parent = nullptr);

    Q_INVOKABLE bool searchValuesFor(const QVariant& mapOrArray, const QString& text, bool caseSensitive = true) const;

signals:

};

#endif // MISCUTILS_H
