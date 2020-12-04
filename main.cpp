#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QStringView>

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
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);
    engine.load(url);

    return app.exec();
}
