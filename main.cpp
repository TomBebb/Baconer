#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QStringView>
#include <QQuickStyle>
#include <QQmlProperty>
#include <iostream>


int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

    QGuiApplication app(argc, argv);
    app.setOrganizationName("Baconer");
    app.setOrganizationDomain("org.baconer");
    app.setApplicationName("Baconer");



    QQmlApplicationEngine engine;
    QPM_INIT(engine);
    const QUrl url(QStringLiteral("qrc:/main.qml"));
    QQuickStyle::setStyle("Material");

    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);
    engine.load(url);
    if (engine.rootObjects().isEmpty())
        return -1;

    auto settingsPage = engine.rootObjects()[0]->findChild<QObject*>("settingsPage");

    std::cout << "Settings page: " << QQmlProperty::read(settingsPage, "example").toString().toStdString() << std::endl;

    auto styleOptions = QQuickStyle::stylePathList();
    QMetaObject::invokeMethod(settingsPage, "loadThemes", Q_ARG(QStringList, styleOptions));

    return app.exec();
}
