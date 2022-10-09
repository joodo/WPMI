pragma Singleton

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtWebEngine

WebEngineView {
    id: root

    signal m3u8Intercepted(string m3u8)
    onM3u8Intercepted: m3u8 => _m3u8Resolver && _m3u8Resolver(m3u8)

    Component.onCompleted: {
        const scriptIntercept = `
        const intercept = (urlmatch, callback) => {
        let send = XMLHttpRequest.prototype.send;
        XMLHttpRequest.prototype.send = function() {
        this.addEventListener('readystatechange', function() {
        if (this.responseURL.includes(urlmatch) && this.readyState === 4) {
        callback(this);
        }
        }, false);
        send.apply(this, arguments);
        };
        };

        intercept("https://www.dandanzan10.top/url.php", response => alert("m3u8: " + response.responseText))
        `
        const m3u8Injection = WebEngine.script()
        m3u8Injection.name = "m3u8"
        m3u8Injection.injectionPoint = WebEngineScript.Defered
        m3u8Injection.sourceCode = scriptIntercept
        m3u8Injection.worldId = WebEngineScript.MainWorld
        root.userScripts.insert(m3u8Injection)
    }

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

    property var _m3u8Resolver
    function waitM3u8() {
        return new Promise(resolve => {
                               _m3u8Resolver = resolve
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
        interval: 5000; running: false; repeat: false
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
    onJavaScriptConsoleMessage: (level, message, lineNumber, sourceID) => level > 0? print(level, message, lineNumber, sourceID) : ""

    settings {
        autoLoadIconsForPage: false
        autoLoadImages: false
        printElementBackgrounds: false
        localContentCanAccessRemoteUrls: true
    }
}
