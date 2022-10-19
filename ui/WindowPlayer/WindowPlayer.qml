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
        keepCursor: pane.requestAlwaysShow
        Connections {
            target: rectScreen.player
            function onWatchedAt(position) {
                let historyIndex = Session.historyIndexOf(root.movieID)
                if (historyIndex < 0) return

                Session.history.setProperty(historyIndex, "position", position)
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.RightButton
        cursorShape: rectScreen.cursorVisible? Qt.ArrowCursor : Qt.BlankCursor
        onClicked: {
            menu.x = mouseX
            menu.y = mouseY
            menu.open()
        }

        Menu {
            id: menu

            modal: true
            dim: false

            MenuItem {
                text: qsTr("Help")
                icon.source: "qrc:/question_mark.svg"
                onTriggered: dialogHelp.open()
                Dialog {
                    id: dialogHelp
                    parent: root.contentItem
                    title: qsTr("Usage")
                    anchors.centerIn: parent
                    Label {
                        textFormat: Text.MarkdownText
                        text: qsTr("**Double Click**: Fullscreen\n\n**Space, Click**: Play / Pause\n\n**Left / Right Arrow**: Replay / Forward 5 seconds\n\n**Up / Down Arrow, Mousewheel Scroll**: Volume Up / Down\n\n**Esc**: Quit Fullscreen")
                    }
                }
            }

            MenuItem {
                text: qsTr("Copy m3u8")
                onTriggered: Backend.copyStringToClipboard(rectScreen.player.source)
                enabled: rectScreen.player.source.toString()
                leftPadding: 56
            }

            MenuItem {
                text: qsTr("Other devices")
                enabled: rectScreen.player.source
                icon.source: "qrc:/smartphone.svg"
                onTriggered: dialogQRCode.open()
                Dialog {
                    id: dialogQRCode
                    parent: root.contentItem
                    anchors.centerIn: parent
                    alignment: Dialog.AlignCenter
                    title: qsTr("Watch on Web")
                    ColumnLayout {
                        spacing: 8
                        Label {
                            Layout.preferredWidth: 250
                            text: qsTr("Visit link below to watch this video on any device's browser:")
                            wrapMode: Text.Wrap
                        }
                        Frame {
                            Layout.alignment: Qt.AlignHCenter
                            MaterialYou.backgroundColor: "transparent"
                            QRCode {
                                id: qrCode
                                width: 200; height: 200
                                background: "transparent"
                                foreground: MaterialYou.color(MaterialYou.OnSurface)
                                onVisibleChanged: {
                                    if (!visible) return;
                                    // Avoid property binding, cus mediaPlayer.position change all the time
                                    text = `https://joodo.github.io/WPMI/player.html?title=${encodeURIComponent(Window.window.title)}&url=${encodeURIComponent(rectScreen.player.source)}&position=${parseInt(rectScreen.player.position/1000)}`
                                }
                            }
                        }
                        Button {
                            Layout.alignment: Qt.AlignHCenter
                            text: timerButtonText.running? qsTr("Copied!") : qsTr("Copy to Clipboard")
                            Timer {
                                id: timerButtonText
                                interval: 1000
                            }
                            onClicked: {
                                Backend.copyStringToClipboard(qrCode.text)
                                timerButtonText.restart()
                            }
                        }
                    }
                }
            }
        }
    }

    PaneController {
        id: pane

        visible: rectScreen.cursorVisible
        mediaPlayer: rectScreen.player
        blurItem: rectScreen

        onShowRequested: rectScreen.state = "showCursor"

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
