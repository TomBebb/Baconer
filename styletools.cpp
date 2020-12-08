#include "styletools.h"
#include <QQuickStyle>
#include <QSettings>
#include <iostream>

StyleTools::StyleTools(QObject *parent) : QObject(parent)
{

}

void StyleTools::checkTheme()
{
    const auto theme = getTheme();
    std::cout << "Theme loaded: " << theme.toStdString() << std::endl;
    QQuickStyle::setStyle(theme);
}

void StyleTools::setTheme(QString styleName)
{
    std::cout << "Theme saved: " << styleName.toStdString() << std::endl;
    QSettings settings;
    settings.setValue("theme", QVariant(styleName));
    themeName = styleName;
}

QString StyleTools::getTheme()
{
    if (themeName.length())
        return themeName;
    QSettings settings;
    QString def = "Material";
    QString themeValue = settings.value("theme", QVariant(def)).toString();
    if (themeValue.length() == 0) {
        themeValue = def;
    }
    return themeName = themeValue;
}

QStringList StyleTools::getThemes()
{
    return QQuickStyle::availableStyles();
}
