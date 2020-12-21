#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QStringView>
#include <QQmlProperty>
#include <iostream>
#include <QQmlContext>
#include <QQuickStyle>
#include <QtWebView>

#include "styletools.h"
#include "stringutils.h"


int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

    QGuiApplication app(argc, argv);
    app.setOrganizationName("Baconer");
    app.setOrganizationDomain("org.baconer");
    app.setApplicationName("Baconer Reddit Client");

    QtWebView::initialize();


    QQmlApplicationEngine engine;

    auto& stringUtils = StringUtils::getInstance();


    auto& styleTools = StyleTools::getInstance();
    styleTools.checkTheme();

    const QUrl url(QStringLiteral("qrc:/main.qml"));

    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);


    engine.rootContext()->setContextProperty("styleTools", &styleTools);
    engine.rootContext()->setContextProperty("stringUtils", &stringUtils);

    engine.load(url);

    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}
