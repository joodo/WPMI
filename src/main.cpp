#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QtWebEngineQuick>
#include <QNetworkProxyFactory>
#include <QSettings>
#include <QTranslator>
#include <QLocale>

#include "backend.h"
#include "platform.h"
#include "ui/MaterialYou/materialyou.h"

#include <QDebug>

int main(int argc, char *argv[])
{
    // For eggy's stupid macBook
    qputenv("QT_ENABLE_GLYPH_CACHE_WORKAROUND", "1");

    QtWebEngineQuick::initialize();

    QGuiApplication app(argc, argv);
    app.setOrganizationName("Joodo");
    app.setOrganizationDomain("https://github.com/joodo/WPMI");
    app.setApplicationName("WPMI");


    // QML
    qmlRegisterUncreatableType<MaterialYou>("MaterialYou", 1, 0, "MaterialYou", "MaterialYou is an attached property");

    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty("Backend", new Backend);
    engine.rootContext()->setContextProperty("APP_VERSION", APP_VERSION);
    engine.addImportPath("qrc:/");


    // Localization
    QTranslator translator;
    QSettings settings;
    auto langName = settings.value("language").toString();
    if (langName.isEmpty()) langName = QLocale::system().name();
    if (translator.load(langName, QM_FILES_RESOURCE_PREFIX)) {
        app.installTranslator(&translator);
    }

    // QML
    const QUrl url(u"qrc:/Main.qml"_qs);
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);
    engine.load(url);

#ifdef Q_OS_MACOS
    // Hide window title bar under macOS
    const auto rootObject = engine.rootObjects().constFirst();
    const auto window = rootObject->property("mainWindow").value<QQuickWindow*>();
    Platform::hideTitleBar(window);

    // Fix Chinese characters have no effect by bold enabled
    // https://bugreports.qt.io/browse/QTBUG-106880
    // QGuiApplication::setFont(QFont("STHeiti"));
#endif

    return app.exec();
}
