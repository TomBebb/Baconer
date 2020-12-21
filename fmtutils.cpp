#include "fmtutils.h"

FmtUtils::FmtUtils(QObject *parent): QObject(parent)
{

}

QString FmtUtils::pluralize(uint amount, const QString& unit) {
    return tr("%L1 %2").arg(amount).arg(amount > 0 ? unit + "s" : unit);
}

QString FmtUtils::formatNum(int num, bool showSign) {
    bool isNeg = num < 0;
    if (isNeg) {
        showSign = true;
        num = -num;
    }
    auto sign = "";
    if (showSign)
        sign = isNeg ? "-" : "+";

    if (num < 1000)
        return tr("%1%L2")
                .arg(sign)
                .arg(num);

    if (num < 1000000)
        return tr("%1%L2K")
                .arg(sign)
                .arg(num / 1000);

    return tr("%%1L2M")
            .arg(sign)
            .arg(num / 1000000);
}
