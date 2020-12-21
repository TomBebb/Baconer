#include "fmtutils.h"

FmtUtils::FmtUtils(QObject *parent): QObject(parent)
{

}

QString FmtUtils::pluralize(uint amount, const QString& unit) {
    return tr("%L1 %2").arg(amount).arg(amount > 0 ? unit + "s" : unit);
}
