#ifndef HTTPREQUEST_H
#define HTTPREQUEST_H

#include <QJSValue>
#include <QBindable>
#include <QNetworkRequest>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QDir>
#include <QFile>
#include <QPointer>
#include <QQmlEngine>

class HttpRequest : public QObject
{
    Q_OBJECT

    Q_PROPERTY(HttpRequest::DownloadStrategy downloadStrategy MEMBER m_downloadStrategy NOTIFY downloadStrategyChanged)
    Q_PROPERTY(QString downloadDir MEMBER m_downloadDir NOTIFY downloadDirChanged)
    Q_PROPERTY(QString downloadFileName MEMBER m_downloadFileName NOTIFY downloadFileNameChanged)

    Q_PROPERTY(QUrl url READ url WRITE setUrl NOTIFY urlChanged)

    Q_PROPERTY(int totalSize READ totalSize NOTIFY totalSizeChanged)
    Q_PROPERTY(int loadedSize READ loadedSize NOTIFY loadedSizeChanged)
    Q_PROPERTY(qreal progress
               READ progress
               NOTIFY progressChanged
               // for qml, "BINDABLE bindableProgress" is replace for NOTIFY.
               // if no need bindableProgress() method, this is no need
               // BINDABLE bindableProgress
               )

    Q_PROPERTY(DataType responseDataType READ responseDataType NOTIFY responseDataTypeChanged)
    Q_PROPERTY(QVariant responseData READ responseData NOTIFY responseDataChanged)

public:
    enum DataType {
        Text,
        Json,
        Blob,
    };
    Q_ENUM(DataType)

    /*!
     * DownloadBlob
     *
     * Download if content is blob, set file path as responseData; else save content to responseData derectly.
     *
     * DownloadAll
     *
     * Download all to file, set file path as responseData.
     *
     * NoDownload
     *
     * Save all content to responseData.
     */
    enum DownloadStrategy {
        DownloadBlob,
        DownloadAll,
        NoDownload,
    };
    Q_ENUM(DownloadStrategy)

signals:
    void finished(QVariant response);
    void errored(QString reason);

    void downloadStrategyChanged();
    void downloadDirChanged();
    void urlChanged();

    void totalSizeChanged();
    void loadedSizeChanged();
    void progressChanged();

    void responseDataChanged();
    void responseDataTypeChanged();

    void downloadFileNameChanged();

public:
    Q_INVOKABLE void send(const QString& method);
    Q_INVOKABLE void abort();

public:
    explicit HttpRequest(QObject *parent = nullptr);
    ~HttpRequest();

    const QUrl url() const;
    void setUrl(const QUrl &newUrl);

    int totalSize() const;
    int loadedSize() const;
    qreal progress() const;
    // for c++ other classes, as m_progress is private
    // if you don't want bind it with other c++ class, no needed
    // QBindable<qreal> bindableProgress() { return &m_progress; }

    DataType responseDataType();
    const QVariant &responseData() const;

private:
    DataType parseTypeString(const QString& typeString);
    const QString getDownloadFilePath();
    bool willDownload();

private:
    QNetworkRequest m_request;
    QPointer<QNetworkReply> m_reply;

    HttpRequest::DownloadStrategy m_downloadStrategy = DownloadStrategy::DownloadBlob;
    QString m_downloadDir;
    QString m_downloadFileName;

    Q_OBJECT_BINDABLE_PROPERTY(HttpRequest, int, m_totalSize, &HttpRequest::totalSizeChanged)
    Q_OBJECT_BINDABLE_PROPERTY(HttpRequest, int, m_loadedSize, &HttpRequest::loadedSizeChanged)
    // for c++. Needn't care about emit change signal
    Q_OBJECT_BINDABLE_PROPERTY(HttpRequest, qreal, m_progress, &HttpRequest::progressChanged)
    QFile m_saveFile;

    Q_OBJECT_BINDABLE_PROPERTY(HttpRequest, QVariant, m_responseData, &HttpRequest::responseDataChanged)
    Q_OBJECT_BINDABLE_PROPERTY(HttpRequest, DataType, m_responseDataType, &HttpRequest::responseDataTypeChanged)
};

class HttpManager : public QNetworkAccessManager
{
    Q_OBJECT
    Q_PROPERTY(int timeout READ timeout WRITE setTimeout NOTIFY timeoutChanged)

public:
    static HttpManager* instance();

    int timeout() const;
    void setTimeout(int newTimeout);

signals:
    void timeoutChanged();

private:
    static HttpManager* m_this;
};

#endif // HTTPREQUEST_H
