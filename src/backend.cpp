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
    QDir langDir(":/i18n/");
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

QString Backend::getPngText(const QString &filepath) const
{
    auto file = QFile(filepath);
    if (!file.open(QIODevice::ReadOnly))
    {
        qErrnoWarning("Cannot open file");
        return "";
    }

    auto header = file.read(8);
    if (header != "\x89\x50\x4E\x47\x0D\x0A\x1A\x0A")
    {
        qErrnoWarning("Invalid header");
        file.close();
        return "";
    }

    while (!file.atEnd())
    {
        auto length = file.read(4).toHex().toULong(nullptr, 16);
        auto chunkType = (QString)file.read(4);
        auto content = file.read(length);
        auto crc = file.read(4);
        Q_UNUSED(crc);

        if (chunkType.toUpper() == "TEXT")
        {
            file.close();
            return content;
        }
    }

    file.close();
    return "";
}

QString Backend::localFileFromUrl(const QUrl &url) const
{
    return url.toLocalFile();
}

bool Backend::removeFile(const QString &path) const
{
    return QFile::remove(path);
}

bool Backend::moveFile(const QString &path, const QString &newPath) const
{
    return QFile::rename(path, newPath);
}

bool Backend::writeFile(const QString &path, const QString &content) const
{
    auto file = QFile(path);
    if (!file.open(QIODevice::WriteOnly | QIODevice::Text)) return false;

    bool result = true;
    if (file.write(content.toUtf8()) < 0) result = false;
    file.close();
    return result;
}

bool Backend::setFilePermissions(const QString &path, int permissions) const
{
    return QFile(path).setPermissions((QFileDevice::Permissions)permissions);
}

QString Backend::readFile(const QString &path) const
{
    auto file = QFile(path);
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) return "";

    auto result = file.readAll();
    file.close();
    return result;
}

QString Backend::fileDirPath(const QString &path) const
{
    return QFileInfo(path).absolutePath();
}
