pragma Singleton

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtWebEngine

WebEngineView {
    id: root

    signal m3u8Intercepted(string m3u8)

    function loadUrl(url) {
        if ("rejecter" in _loadPromise) _loadPromise.rejecter()
        _loadPromise = { resolver: null, rejecter: null }
        return new Promise((resolve, reject) => {
                               _loadPromise.resolver = resolve
                               _loadPromise.rejecter = reject
                               // prevent loadProgress keeps 100
                               _nextUrl = url
                               root.url = "about:blank"
                           })
    }

    function runScript(script) {
        return new Promise(resolve => runJavaScript(script, result => resolve(result)))
    }

    property var _loadPromise: ({})
    property string _nextUrl: ""

    url: "about:blank"

    anchors.fill: parent

    property int loadStatus
    onLoadingChanged: loadingInfo => {
        loadStatus = loadingInfo.status
        // print("info", loadingInfo.status, loadProgress)
        if (loadingInfo.status === WebEngineView.LoadFailedStatus) {
            if ("rejecter" in _loadPromise) _loadPromise.rejecter(loadingInfo)
            return
        }
        if (loadingInfo.status === WebEngineView.LoadSucceededStatus) {
            if (_nextUrl) {
                url = _nextUrl
                _nextUrl = ""
                timerTimeOut.restart()
            }
        }
    }
    Timer {
        id: timerTimeOut
        interval: 3000; running: false; repeat: false
        onTriggered: {
            // print("Stop!!")
            root.stop()
            if ("rejecter" in _loadPromise) _loadPromise.rejecter("Time out")
        }
    }
    onLoadProgressChanged: {
        timerTimeOut.restart()
        if (loadProgress === 100) {
            timerTimeOut.stop()
            // print("state", loadStatus)
            if (!_nextUrl && "resolver" in _loadPromise) timerResolve.start()
        }
    }
    // When load failed, loadProgress === 100 triggered before loadingInfo.status === WebEngineView.LoadFailedStatus, so put 100ms delay
    Timer {
        id: timerResolve
        interval: 100; running: false; repeat: false
        onTriggered: _loadPromise.resolver()
    }

    onJavaScriptDialogRequested: request => {
        if (!request.message.startsWith("m3u8: ")) {
            request.accepted = false
            return
        }

        request.accepted = true
        request.dialogAccept()

        let m3u8 = request.message.slice("m3u8: ".length)
        m3u8Intercepted(m3u8)
    }
    //onJavaScriptConsoleMessage: (level, message, lineNumber, sourceID) => print(level, message, lineNumber, sourceID)
}
