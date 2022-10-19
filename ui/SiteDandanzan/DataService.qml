import QtQuick
import QtWebEngine

WebEngineView {
    url: "qrc:/Dandanzan.html"

    property var _resolvers: new Map()
    onJavaScriptConsoleMessage: (level, message) => {
                                    if (level === WebEngineView.WarningMessageLevel) {
                                        if (message.startsWith("[Resolve]")) {
                                            const commapos = message.indexOf(",")
                                            const callbackId = parseInt(message.substring("[Resolve]".length, commapos))
                                            const value = message.substring(commapos + 1)
                                            _resolvers.get(callbackId)?.resolve(value)
                                            _resolvers.delete(callbackId)
                                        } else if (message.startsWith("[Reject]")) {
                                            const commapos = message.indexOf(",")
                                            const callbackId = parseInt(message.substring("[Reject]".length, commapos))
                                            const value = message.substring(commapos + 1)
                                            _resolvers.get(callbackId)?.reject(value)
                                            _resolvers.delete(callbackId)
                                        } else {
                                            print(level, message)
                                        }
                                    } else {
                                        print(level, message)
                                    }
                                }
    function runScript(script) {
        const callbackId = Date.now()
        runJavaScript(script +
                      `.then(result => console.warn("[Resolve]${callbackId}," + result))
                      .catch(err => console.warn("[Reject]${callbackId}," + err));`)
        return new Promise((resolve, reject) => _resolvers.set(callbackId, { resolve, reject }))
    }

    function search(url) {
        return runScript(`search("${url}")`)
    }

    function detail(url) {
        return runScript(`detail("${url}")`)
    }

    function getM3u8(url) {
        return runScript(`getM3u8("https://${Settings.resourceServer}/url.php", "${url}")`)
    }
}
