#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QStringView>
#include <QQmlProperty>
#include <iostream>
#include <QQmlContext>
#include <QQuickStyle>
#include <QtWebView>

#include "fmtutils.h"
#include "styletools.h"
#include "stringutils.h"
#include "url.h"
#include "urlutils.h"
#include "miscutils.h"


int main(int argc, char *argv[])
{

    qmlRegisterAnonymousType<url>("Baconer", 1);
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

    QGuiApplication app(argc, argv);
    app.setOrganizationName("Baconer");
    app.setOrganizationDomain("org.baconer");
    app.setApplicationName("Baconer Reddit Client");

    QtWebView::initialize();


    QQmlApplicationEngine engine;

    auto& stringUtils = StringUtils::getInstance();
    auto& fmtUtils = FmtUtils::getInstance();
    auto& urlUtils = UrlUtils::getInstance();
    auto& miscUtils = MiscUtils::getInstance();
    auto& styleTools = StyleTools::getInstance();

    styleTools.checkTheme();

    const QUrl url(QStringLiteral("qrc:/main.qml"));

    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);

    engine.rootContext()->setContextProperty("styleTools", &styleTools);
    engine.rootContext()->setContextProperty("fmtUtils", &fmtUtils);
    engine.rootContext()->setContextProperty("stringUtils", &stringUtils);
    engine.rootContext()->setContextProperty("miscUtils", &miscUtils);
    engine.rootContext()->setContextProperty("urlUtils", &urlUtils);

    engine.load(url);

    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}
