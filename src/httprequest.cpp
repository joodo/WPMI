#include <QJsonDocument>
#include <QMetaEnum>

#include "httprequest.h"

#include <QDebug>

void HttpRequest::send(const QString& method)
{
    if (m_reply) m_reply->abort();

    m_reply = HttpManager::instance()->sendCustomRequest(m_request, method.toUtf8());

    connect(m_reply, &QNetworkReply::downloadProgress, this, [=](qint64 bytesReceived, qint64 bytesTotal) {
        m_totalSize = bytesTotal;
        m_loadedSize = bytesReceived;
    });
    connect(m_reply, &QNetworkReply::uploadProgress, this, [=](qint64 bytesReceived, qint64 bytesTotal) {
        m_totalSize = bytesTotal;
        m_loadedSize = bytesReceived;
    });
    connect(m_reply, &QNetworkReply::metaDataChanged, this, [=] {
        auto typeString = m_reply->header(QNetworkRequest::ContentTypeHeader).toString();
        m_responseDataType = parseTypeString(typeString);

        if (willDownload())
        {
            m_saveFile.setFileName(getDownloadFilePath());
            if (!m_saveFile.open(QIODevice::WriteOnly | QIODeviceBase::NewOnly))
            {
                emit errored("Cannot save download file.");
                m_reply->abort();
            }
        }
    });
    connect(m_reply, &QNetworkReply::bytesWritten, this, [=](qint64 bytes) {
        qDebug() << "got" << bytes;
    });
    connect(m_reply, &QNetworkReply::readyRead, this, [=] {
        if (willDownload())
        {
            m_saveFile.write(m_reply->readAll());
        }
    });
    connect(m_reply, &QNetworkReply::errorOccurred, this, [=] {
        auto enumType = QMetaEnum::fromType<QNetworkReply::NetworkError>();
        emit errored(QString("%1: %2").arg(enumType.valueToKey(m_reply->error()), m_reply->errorString()));
    });
    connect(m_reply, &QNetworkReply::finished, this, [=] {
        if (m_reply->error() == QNetworkReply::NoError)
        {
            if (willDownload())
            {
                m_saveFile.close();
                m_responseData = m_saveFile.fileName();
            }
            else
            {
                switch (m_responseDataType)
                {
                case HttpRequest::Json:
                    m_responseData = QJsonDocument::fromJson(m_reply->readAll()).toVariant();
                    break;
                case HttpRequest::Text:
                    m_responseData = (QString)m_reply->readAll();
                    break;
                case HttpRequest::Blob:
                    m_responseData = m_reply->readAll();
                    break;
                }
            }

            emit this->finished(m_responseData);
        }
        else
        {
            if (m_saveFile.isOpen())
            {
                m_saveFile.close();
                m_saveFile.remove();
            }
        }

        m_reply->deleteLater();
    });
}

void HttpRequest::abort()
{
    if (m_reply)
    {
        m_reply->abort();
    }
}

HttpRequest::HttpRequest(QObject *parent)
    : QObject{parent}
{
    m_progress.setBinding([&] { return m_totalSize>0? (qreal)m_loadedSize / m_totalSize : 0; });
}

HttpRequest::~HttpRequest()
{
    if (m_saveFile.isOpen())
    {
        m_saveFile.close();
        m_saveFile.remove();
    }
}

int HttpRequest::totalSize() const
{
    return m_totalSize;
}

int HttpRequest::loadedSize() const
{
    return m_loadedSize;
}

qreal HttpRequest::progress() const
{
    return m_progress;
}

const QVariant &HttpRequest::responseData() const
{
    return m_responseData;
}

HttpRequest::DataType HttpRequest::parseTypeString(const QString &typeString)
{
    if (typeString.contains("json"))
    {
        return HttpRequest::Json;
    }

    if (typeString.startsWith("text/") || typeString.contains("xml") || typeString.contains("html"))
    {
        return HttpRequest::Text;
    }

    return HttpRequest::Blob;
}

const QString HttpRequest::getDownloadFilePath()
{
    auto filename = m_downloadFileName;
    if (filename.isEmpty())
    {
        filename = m_request.url().fileName();
    }

    auto insertPosition = filename.lastIndexOf('.');
    if (insertPosition < 0) insertPosition = filename.length();
    filename.insert(insertPosition, "%1");

    auto dir = QDir(m_downloadDir);
    QFileInfo fileInfo(dir, filename.arg(""));
    for (int i = 1; fileInfo.exists(); i++)
    {
        fileInfo.setFile(dir, filename.arg("_%1").arg(i));
    }
    return fileInfo.absoluteFilePath();
}

bool HttpRequest::willDownload()
{
    return m_downloadStrategy == HttpRequest::DownloadAll
           || (m_downloadStrategy == HttpRequest::DownloadBlob
               && m_responseDataType == HttpRequest::Blob);
}

const QUrl HttpRequest::url() const
{
    return m_request.url();
}

void HttpRequest::setUrl(const QUrl &newUrl)
{
    if (m_request.url() == newUrl)
        return;
    m_request.setUrl(newUrl);
    emit urlChanged();
}

HttpRequest::DataType HttpRequest::responseDataType()
{
    return m_responseDataType;
}

HttpManager* HttpManager::m_this = nullptr;

HttpManager *HttpManager::instance()
{
    if (m_this == nullptr)
    {
        m_this = new HttpManager();
    }
    return m_this;
}

int HttpManager::timeout() const
{
    return transferTimeout();
}

void HttpManager::setTimeout(int newTimeout)
{
    if (transferTimeout() == newTimeout)
        return;
    setTransferTimeout(newTimeout);
    emit timeoutChanged();
}
