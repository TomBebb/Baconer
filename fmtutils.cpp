#include "fmtutils.h"
#include <QDateTime>

FmtUtils::FmtUtils(QObject *parent): QObject(parent)
{

}

QString FmtUtils::formatTimeUnit(uint amount, const QString& unit) const {
    return tr("%L1 %2 ago").arg(amount).arg(amount > 0 ? unit + "s" : unit);
}

QString FmtUtils::formatNum(int num, bool showSign) const {
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


QString FmtUtils::formatDate(QDateTime dateTime) const {
    const auto epoch = QDateTime::fromSecsSinceEpoch(0);
    const auto seconds = QDateTime::currentSecsSinceEpoch() - epoch.secsTo(dateTime);//QDateTime::currentDateTime().secsTo(dateTime);
    auto interval = seconds / 31536000;
    auto postfix = tr(" ago");

    if (interval > 1) {
        return formatTimeUnit(interval, "year");
    }
    interval = seconds / 2592000;
    if (interval > 1) {
        return formatTimeUnit(interval, "month");
    }
    interval = seconds / 86400;
    if (interval > 1) {
        return formatTimeUnit(interval, "day");
    }
    interval = seconds / 3600;
    if (interval > 1) {
        return formatTimeUnit(interval, "hour");
    }
    interval = seconds / 60;
    if (interval > 1) {
        return formatTimeUnit(interval, "min");
    }

    return formatTimeUnit(interval, "sec");
}
