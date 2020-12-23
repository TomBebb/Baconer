#include "styletools.h"
#include <QQuickStyle>
#include <QSettings>
#include <iostream>
#include <QDebug>
#include <QRegularExpression>


StyleTools::StyleTools ( QObject *parent ) : QObject ( parent )
{
    qInfo() << "StyleTools created";
}

void StyleTools::checkTheme()
{
    const auto theme = getTheme();
    qInfo() << "Theme loaded: " << theme;
    QQuickStyle::setStyle ( theme );
}

void StyleTools::setTheme ( QString styleName )
{
    qInfo() << "Theme saved: " << styleName;
    QSettings settings;
    settings.setValue ( "theme", QVariant ( styleName ) );
    themeName = styleName;
}

QString StyleTools::getTheme()
{
    if ( themeName.length() ) {
        return themeName;
    }

    QSettings settings;
    QString def = "Material";
    QString themeValue = settings.value ( "theme", def ).toString();
    if ( themeValue.length() == 0 ) {
        themeValue = def;
    }
    return themeName = themeValue;
}

QStringList StyleTools::getThemes()
{
    return QQuickStyle::availableStyles()
           .filter ( QRegularExpression ( "^[A-Z][a-z]+$" ) );
}
