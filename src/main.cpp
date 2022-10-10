#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QtWebEngineQuick>
#include <QNetworkProxyFactory>
#include <QSettings>
#include <QTranslator>
#include <QLocale>

#include "backend.h"
#include "httprequest.h"
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
    app.setApplicationVersion(APP_VERSION);


    // QML
    qmlRegisterUncreatableType<MaterialYou>("MaterialYou", 1, 0, "MaterialYou", "MaterialYou is an attached property");
    qmlRegisterType<HttpRequest>("WPMI.impl", 1, 0, "HttpRequestImpl");
    qmlRegisterSingletonType<HttpManager>("WPMI", 1, 0, "HttpManager", [](QQmlEngine *engine, QJSEngine *scriptEngine) -> QObject * {
        Q_UNUSED(engine)
        Q_UNUSED(scriptEngine)

        return HttpManager::instance();
    });

    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty("Backend", new Backend);
    engine.rootContext()->setContextProperty("LEANCLOUD_APP", qgetenv("LEANCLOUD_APP"));
    engine.rootContext()->setContextProperty("LEANCLOUD_KEY", qgetenv("LEANCLOUD_KEY"));
    engine.addImportPath("qrc:/");


    // Localization
    QSettings settings;
    auto langName = settings.value("language").toString();
    if (langName.isEmpty()) langName = QLocale::system().name();

    QTranslator translator;
    if (translator.load(langName, ":/i18n/")) {
        app.installTranslator(&translator);
    }

    QTranslator qtTranslator;
    if (qtTranslator.load("qtbase_" + langName, ":/translations/qt/")) {  // should copy from Qt dir manually
        app.installTranslator(&qtTranslator);
    }

    // QML
    const QUrl url(u"qrc:/Main.qml"_qs);
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);
    engine.load(url);

    return app.exec();
}
