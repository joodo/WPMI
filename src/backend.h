#ifndef BACKEND_H
#define BACKEND_H

#include <QObject>
#include <QJsonArray>

class Backend : public QObject
{
    Q_OBJECT
public:
    explicit Backend(QObject *parent = nullptr);
    Q_INVOKABLE int openVideo(const QString& url);
    Q_INVOKABLE int setScreensaverEnabled(bool enable);
    Q_INVOKABLE void copyStringToClipboard(const QString& text);
    Q_INVOKABLE void openWebsiteInBrowser(const QString& url);
    Q_INVOKABLE QJsonArray supportedLanguages() const;
    Q_INVOKABLE void setProxy(const QString& host);

signals:
};

#endif // BACKEND_H
