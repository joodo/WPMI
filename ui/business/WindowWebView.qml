import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtWebEngine 1.10
import QtQuick.Window

Window {
    id: root

    signal m3u8Intercepted(string m3u8)

    property alias loadProgress: webEngineView.loadProgress

    function loadUrl(url) {
        if (_loadPromise) _loadPromise.rejecter()
        _loadPromise = { resolver: null, rejecter: null }
        return new Promise((resolve, reject) => {
                               _loadPromise.resolver = resolve
                               _loadPromise.rejecter = reject
                               webEngineView.url = url
                           })
    }

    function runScript(script) {
        return new Promise((resolve, reject) => webEngineView.runJavaScript(script, result => resolve(result)))
    }

    property var _loadPromise

    WebEngineView {
        id: webEngineView

        anchors.fill: parent
        onLoadingChanged: loadingInfo => {
                              if (loadingInfo.status === WebEngineView.LoadFailedStatus) {
                                  //print(loadingInfo.errorString)
                                  return
                              }
                              if (loadingInfo.status === WebEngineView.LoadSucceededStatus) {
                                  //if(onLoadFinished instanceof Function) onLoadFinished()
                              }
                          }
        onJavaScriptDialogRequested: request => {
                                         if (!request.message.startsWith("m3u8: ")) {
                                             request.accepted = false
                                             return
                                         }

                                         request.accepted = true
                                         request.dialogAccept()

                                         let m3u8 = request.message.slice("m3u8: ".length)
                                         windowWebView.m3u8Intercepted(m3u8)
                                     }
        onLoadProgressChanged: {
            //runJavaScript("document.querySelectorAll('div.lists-content > ul > li')[0].innerHTML", result => print(loadProgress, result))
            if (loadProgress === 100) {
                root._loadPromise.resolver()
            }
        }
        //onJavaScriptConsoleMessage: (level, message, lineNumber, sourceID) => print(level, message, lineNumber, sourceID)
    }
}
