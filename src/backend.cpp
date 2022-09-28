#include <QProcess>
#include <QStringList>
#include <QClipboard>
#include <QGuiApplication>
#include <QSettings>
#include <QDir>
#include <QJsonObject>
#include <QNetworkProxy>
#include <QNetworkProxyFactory>

#include "backend.h"
#include "platform.h"

Backend::Backend(QObject *parent)
    : QObject{parent}
{

}

int Backend::openVideo(const QString &url)
{
    (new QProcess(this))->start("/Applications/IINA.app/Contents/MacOS/IINA", QStringList(url));
    return 0;
    //return QProcess::execute();
}

int Backend::setScreensaverEnabled(bool enable)
{
    return Platform::setScreensaverEnabled(enable);
}

void Backend::copyStringToClipboard(const QString &text)
{
    qGuiApp->clipboard()->setText(text);
}

QJsonArray Backend::supportedLanguages() const
{
    QSettings settings;
    auto currentLang = settings.value("language").toString();

    QJsonArray array;
    QDir langDir(":/translations");
    for (const auto &filename : langDir.entryList(QDir::Files)) {
        QJsonObject object;
        auto code = filename.left(5);
        object["value"] = code;
        QLocale locale(code);
        object["text"] = QString("%1 (%2)").arg(locale.nativeLanguageName(), locale.nativeCountryName());

        if (code == currentLang) {
            array.prepend(object);
        } else {
            array.append(object);
        }
    }
    return array;
}

void Backend::setProxy(const QString &host)
{
    if (host == "[System]")
    {
        QNetworkProxyFactory::setUseSystemConfiguration(true);
        return;
    }

    QNetworkProxyFactory::setUseSystemConfiguration(false);

    if (host == "[None]")
    {
        QNetworkProxy::setApplicationProxy(QNetworkProxy::NoProxy);
        return;
    }

    auto list = host.split(":");
    auto h = list.at(0);
    auto p = list.length() > 1? list.at(1).toUInt(nullptr) : 0;
    auto proxy = QNetworkProxy(QNetworkProxy::HttpProxy, h, p);
    QNetworkProxy::setApplicationProxy(proxy);
}

void Backend::hideWindowTitleBar(QQuickWindow *window)
{
    Platform::hideTitleBar(window);
}

void Backend::restartApplication()
{
    qApp->quit();
    QProcess::startDetached(qApp->arguments()[0], qApp->arguments());
}
