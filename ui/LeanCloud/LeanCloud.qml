pragma Singleton

import QtWebEngine
import QtQuick

WebEngineView {
    url: "qrc:/LeanCloud.html"
    anchors.fill: parent

    property var _resolvers: new Map()
    onJavaScriptDialogRequested: request => {
        if (!request.message.startsWith("[Callback]")) {
            request.accepted = false
            return
        }

        request.accepted = true
        request.dialogAccept()

        const commapos = request.message.indexOf(",")
        const callbackId = parseInt(request.message.substring("[Callback]".length, commapos))
        const value = request.message.substring(commapos + 1)
        _resolvers.get(callbackId)(value)
        _resolvers.delete(callbackId)
    }

    function init() {
        runJavaScript(`init("${LEANCLOUD_APP}", "${LEANCLOUD_KEY}");`)
    }

    function createRoom(userName, roomTitle, videoUrl) {
        const callbackId = Date.now()
        runJavaScript(`createRoom("${userName}", "${roomTitle}", "${videoUrl}")
                      .then(result => alert("[Callback]${callbackId}," + result));`)
        return new Promise(resolve => _resolvers.set(callbackId, resolve))
    }

    onLoadingChanged: info => {
        if (info.status === WebEngineView.LoadSucceededStatus) {
            init()
        }
    }
}
