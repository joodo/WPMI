pragma Singleton

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Window
import QtMultimedia
import Qt.labs.settings
import MaterialYou

ApplicationWindow {
    id: root

    property string movieID: ""

    onClosing: rectScreen.player.pause()

    function load(m3u8) {
        rectScreen.player.source = ""
        visible = true
        raise()

        let p
        // A promise
        if (m3u8.then) {
            p = m3u8.then(url => rectScreen.player.loadSource(url))
        }
        // A string
        if (typeof m3u8 === "string") {
            p = rectScreen.player.loadSource(url)
        }
        p.then(() => {
                   let history = Session.history.get(Session.historyIndexOf(root.movieID))
                   if (history && history.position < 1) {
                       rectScreen.player.position = Math.max(0, history.position * rectScreen.player.duration - 10 * 1000)
                   }
               })
    }

    width: 600; height: 480; minimumWidth: 480; minimumHeight: 300

    RectScreen {
        id: rectScreen
        anchors.fill: parent
        keepCursor: pane.interacting
        Connections {
            target: rectScreen.player
            function onWatchedAt(position) {
                let historyIndex = Session.historyIndexOf(root.movieID)
                if (historyIndex < 0) return

                Session.history.setProperty(historyIndex, "position", position)
            }
        }
    }

    PaneController {
        id: pane

        visible: rectScreen.cursorVisible
        mediaPlayer: rectScreen.player
        blurItem: rectScreen

        width: Math.min(600, Window.width - 72)
        height: 64

        anchors {
            bottom: parent.bottom
            horizontalCenter: parent.horizontalCenter
        }

        topPadding: 0
        bottomPadding: 8
        horizontalPadding: 16
    }
}
