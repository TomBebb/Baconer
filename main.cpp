#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QStringView>
#include <QQmlProperty>
#include <iostream>
#include <QQmlContext>
#include <QQuickStyle>
#include <QtWebView>

#include "styletools.h"


int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

    QGuiApplication app(argc, argv);
    app.setOrganizationName("Baconer");
    app.setOrganizationDomain("org.baconer");
    app.setApplicationName("Baconer Reddit Client");

    QtWebView::initialize();


    QQmlApplicationEngine engine;

    const QUrl url(QStringLiteral("qrc:/main.qml"));

    auto styleTools = new StyleTools(nullptr);
    styleTools->checkTheme();


    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);


    engine.load(url);

    if (engine.rootObjects().isEmpty())
        return -1;

    engine.rootContext()->setContextProperty("styleTools", styleTools);

    return app.exec();
}
