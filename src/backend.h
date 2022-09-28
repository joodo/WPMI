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

signals:
};

#endif // BACKEND_H
