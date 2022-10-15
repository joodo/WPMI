import QtQuick
import QtQuick.Controls
import MaterialYou

Snackbar {
    id: snackbar

    function toast(text: string, actionText: string): Promise {
        return new Promise((resolve, reject) => {
                               snackbar.queue.push({
                                                       text,
                                                       actionText,
                                                       resolve,
                                                       reject
                                                   })
                               if (!snackbar.visible) {
                                   snackbar.next()
                               }
                           })
    }

    property var queue: []
    property var resolver
    property var rejecter
    function next() {
        if (queue.length === 0) return
        const message = queue.shift()
        text = message.text
        actionText = message.actionText
        resolver = message.resolve
        rejecter = message.reject

        show()
    }
    onActionTriggered: rejecter?.()
    onHidden: {
        resolver?.()
        next()
    }
}
