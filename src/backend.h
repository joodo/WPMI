#ifndef BACKEND_H
#define BACKEND_H

#include <QObject>
#include <QJsonArray>
#include <QQuickWindow>

class Backend : public QObject
{
    Q_OBJECT
public:
    explicit Backend(QObject *parent = nullptr);
    Q_INVOKABLE int openVideo(const QString& url);
    Q_INVOKABLE int setScreensaverEnabled(bool enable);
    Q_INVOKABLE void copyStringToClipboard(const QString& text);
    Q_INVOKABLE QJsonArray supportedLanguages() const;
    Q_INVOKABLE void setProxy(const QString& host);
    Q_INVOKABLE void hideWindowTitleBar(QQuickWindow* window);
    Q_INVOKABLE void restartApplication();
    Q_INVOKABLE QString getPngText(const QString& filepath) const;

    Q_INVOKABLE QString localFileFromUrl(const QUrl& url) const;
    Q_INVOKABLE bool removeFile(const QString& path) const;
    Q_INVOKABLE bool moveFile(const QString& path, const QString& newPath) const;
    Q_INVOKABLE bool writeFile(const QString& path, const QString& content) const;
    Q_INVOKABLE bool setFilePermissions(const QString& path, int permissions) const;
    Q_INVOKABLE QString readFile(const QString& path) const;
    Q_INVOKABLE QString fileDirPath(const QString& path) const;

signals:
};

#endif // BACKEND_H
