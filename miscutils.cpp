#include "miscutils.h"

#include <QDebug>
#include <QStack>

MiscUtils::MiscUtils(QObject *parent) : QObject(parent)
{

}

bool MiscUtils::searchValuesFor(const QVariant& mapOrArray, const QString& needle, bool caseSensitive) const {
    auto sensitivity = caseSensitive ? Qt::CaseSensitive : Qt::CaseInsensitive;

    QStack<QVariant> values;
    values.push(mapOrArray);

    while (!values.isEmpty()) {
        auto curr = values.pop();

        if (curr.canConvert<QString>()) {
            auto haystack = curr.toString();
            if (haystack.contains(needle, sensitivity)) {
                return true;
            }
        } else if (curr.canConvert<QVariantMap>()) {
            auto currMap = curr.toMap();
            for (const auto& value: currMap.values()) {
                values.push(value);
            }
        } else if (curr.canConvert<QVariantList>()) {
            auto currList = curr.toList();
            for (const auto& value: currList) {
                values.push(value);
            }
        }
    }
    return false;
}
