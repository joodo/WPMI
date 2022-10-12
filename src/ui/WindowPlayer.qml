pragma Singleton

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Window
import QtMultimedia
import Qt.labs.settings
import Qt5Compat.GraphicalEffects
import MaterialYou

ApplicationWindow {
    id: root

    property string movieID: ""

    onClosing: mediaPlayer.pause()

    function load(m3u8) {
        mediaPlayer.source = ""
        visible = true
        raise()
        // A promise
        if (m3u8.then) {
            m3u8.then(url => mediaPlayer.source = url)
        }
        // A string
        if (typeof m3u8 === "string") {
            mediaPlayer.source = m3u8
        }
    }

    width: 600; height: 480; minimumWidth: 480; minimumHeight: 300

    Rectangle {
        id: rectScreen
        anchors.fill: parent
        color: "black"

        MediaPlayer {
            id: mediaPlayer
            videoOutput: videoOutput; audioOutput: audioOutput
            onMediaStatusChanged: {
                if (mediaStatus === MediaPlayer.LoadedMedia) {
                    let history = Session.history.get(Session.historyIndexOf(root.movieID))
                    if (history && history.position < 1) {
                        mediaPlayer.position = Math.max(0, history.position * duration - 10 * 1000)
                    }

                    mediaPlayer.play()
                    timerHideCursor.start()
                    sliderGamma.value = 1
                }
            }
            onPlaybackStateChanged: {
                if (playbackState === MediaPlayer.PlayingState) {
                    Backend.setScreensaverEnabled(false)
                } else {
                    Backend.setScreensaverEnabled(true)
                }
            }
            onErrorOccurred: (err, errorString) => print(err, errorString)
        }
        Timer {
            running: mediaPlayer.playbackState === MediaPlayer.PlayingState
            interval: 1000; repeat: true
            onTriggered: {
                let historyIndex = Session.historyIndexOf(root.movieID)
                if (historyIndex < 0) return

                Session.history.setProperty(historyIndex, "position", mediaPlayer.position / mediaPlayer.duration)
            }
        }

        VideoOutput { id: videoOutput; anchors.fill: parent;
            layer.enabled: sliderGamma.value !== 1
            layer.effect: GammaAdjust {
                gamma: sliderGamma.value * sliderGamma.value
            }
        }
        AudioOutput { id: audioOutput }
        Settings { property alias volume: audioOutput.volume }
    }

    Item {
        id: loadingMask
        anchors.fill: parent
        Rectangle {
            anchors.fill: parent
            color: MaterialYou.color(MaterialYou.OnPrimary)
            opacity: 0.1
        }
        BusyIndicator {
            width: parent.width
            running: true
            anchors.centerIn: parent
        }
        opacity: !mediaPlayer.source ||
                 mediaPlayer.mediaStatus < MediaPlayer.BufferedMedia? 1: 0
        Behavior on opacity { NumberAnimation { duration: 500; easing.type: Easing.OutCubic } }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true

        onDoubleClicked: {
            root.visibility = (root.visibility === Window.FullScreen?
                                   Window.Windowed : Window.FullScreen)
            root.requestActivate()
        }

        onMouseXChanged: showCursor()
        onMouseYChanged: showCursor()
        onWheel: wheel => {
            audioOutput.volume -= wheel.angleDelta.y / 1500
            wheel.accepted = true
            timerHideVolumePopup.restart()
        }
    }

    PaneBlur {
        id: paneVolume
        x: 16; y: 16
        blurItem: rectScreen
        ColumnLayout {
            IconLabel {
                icon.source: "qrc:/volume.svg"
                icon.width: 36; icon.height: 36
                text: qsTr("Volume: %1%").arg(parseInt(audioOutput.volume*100))
                display: IconLabel.TextUnderIcon
                MaterialYou.fontRole: MaterialYou.LabelLarge
                MaterialYou.foregroundColor: MaterialYou.OnSurfaceVariant
            }
        }
        Timer { id: timerHideVolumePopup; interval: 1000 }
        states: [
            State {
                name: "show"
                when: timerHideVolumePopup.running
                PropertyChanges { paneVolume.opacity: 1 }
            },
            State {
                name: "hide"
                when: !timerHideVolumePopup.running
                PropertyChanges { paneVolume.opacity: 0 }
            }
        ]
        transitions: [ Transition {
                from: "show"
                to: "hide"
                NumberAnimation { property: "opacity"; duration: 250; easing.type: Easing.OutCubic }
            }]
    }

    function showCursor() {
        mouseArea.cursorShape = Qt.ArrowCursor
        if (!pane.hovered
                && !menu.visible
                && mediaPlayer.playbackState !== MediaPlayer.StoppedState) {
            timerHideCursor.restart()
        }
    }

    Timer {
        id: timerHideCursor
        interval: 2000
        repeat: false
        onTriggered: {
            mouseArea.cursorShape = Qt.BlankCursor
        }
    }

    PaneBlur {
        id: pane
        visible: mouseArea.cursorShape === Qt.ArrowCursor
        anchors { bottom: parent.bottom; horizontalCenter: parent.horizontalCenter }
        width: Math.min(600, Window.width - 72); height: 64
        MaterialYou.backgroundColor: MaterialYou.tintSurfaceColor(2)
        topPadding: 0; horizontalPadding: 16; bottomPadding: 8
        blurItem: rectScreen

        ColumnLayout {
            anchors.fill: parent
            spacing: 0
            Item {
                Layout.preferredHeight: 48; Layout.fillWidth: true
                IconLabel {
                    display: IconLabel.IconOnly
                    icon.source: "qrc:/volume.svg"
                    anchors.verticalCenter: parent.verticalCenter
                    MaterialYou.foregroundColor: MaterialYou.OnSurfaceVariant
                    icon.height: 16; icon.width: 16

                    Slider {
                        anchors.verticalCenter: parent.verticalCenter
                        x: 18
                        width: 100
                        value: audioOutput.volume
                        onMoved: audioOutput.volume = value
                    }
                }

                RowLayout {
                    anchors.centerIn: parent
                    ToolButton {
                        id: buttonReplay5
                        icon.height: 20; icon.width: 20
                        icon.source: "qrc:/replay_5.svg"
                        onClicked: mediaPlayer.position -= 5000
                    }
                    ToolButton {
                        visible: false
                        icon.source: "qrc:/fast_rewind.svg"
                        onPressed: mediaPlayer.playbackRate = -4
                        onReleased: mediaPlayer.playbackRate = 1
                    }

                    ToolButton {
                        id: buttonPlay
                        icon.width: 40; icon.height: 40
                        states: [
                            State {
                                when: mediaPlayer.playbackState === MediaPlayer.PlayingState
                                name: "pause"
                                PropertyChanges {
                                    buttonPlay.icon.source: "qrc:/pause.svg"
                                    buttonPlay.onClicked: mediaPlayer.pause()
                                }
                            },
                            State {
                                when: mediaPlayer.playbackState !== MediaPlayer.PlayingState
                                name: "play"
                                PropertyChanges {
                                    buttonPlay.icon.source: "qrc:/play.svg"
                                    buttonPlay.onClicked: mediaPlayer.play()
                                }
                            }
                        ]
                    }
                    ToolButton {
                        visible: false
                        icon.source: "qrc:/fast_forward.svg"
                        onPressed: mediaPlayer.playbackRate = 4
                        onReleased: mediaPlayer.playbackRate = 1
                    }
                    ToolButton {
                        id: buttonForward5
                        icon.height: 20; icon.width: 20
                        icon.source: "qrc:/forward_5.svg"
                        onClicked: mediaPlayer.position += 5000
                    }
                }

                RowLayout {
                    anchors { right: parent.right; top: parent.top; bottom: parent.bottom; rightMargin: -16 }
                    spacing: 0
                    ToolButton {
                        icon.source: "qrc:/list.svg"
                        icon.height: 20; icon.width: 20
                        onClicked: {
                            WindowMain.show()
                            WindowMain.raise()
                        }
                    }
                    ToolButton {
                        icon.source: "qrc:/more.svg"
                        icon.height: 20; icon.width: 20
                        Menu {
                            id: menu
                            onAboutToShow: timerHideCursor.stop()

                            MenuItem {
                                text: qsTr("Help")
                                icon.source: "qrc:/question_mark.svg"
                                onTriggered: dialogHelp.open()
                                Dialog {
                                    id: dialogHelp
                                    parent: root.contentItem
                                    title: qsTr("Usage")
                                    anchors.centerIn: parent
                                    modal: true
                                    Label {
                                        textFormat: Text.MarkdownText
                                        text: qsTr("**Double Click Screen**: Fullscreen\n\n**Space**: Play / Pause\n\n**Left / Right Arrow**: Replay / Forward 10 seconds\n\n**Up / Down Arrow, Mousewheel Scroll**: Volume Up / Down\n\n**Esc**: Quit Fullscreen")
                                    }
                                }
                            }

                            MenuItem {
                                text: qsTr("Copy m3u8")
                                onTriggered: Backend.copyStringToClipboard(mediaPlayer.source)
                                enabled: mediaPlayer.source.toString()
                                leftPadding: 56
                            }


                            MenuItem {
                                text: qsTr("Other devices")
                                enabled: mediaPlayer.source
                                icon.source: "qrc:/smartphone.svg"
                                onTriggered: dialogQRCode.open()
                                Dialog {
                                    id: dialogQRCode
                                    parent: root.contentItem
                                    anchors.centerIn: parent
                                    alignment: Dialog.AlignCenter
                                    title: qsTr("Watch on Web")
                                    modal: true
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
                                                    text = `https://joodo.github.io/WPMI/player.html?title=${encodeURIComponent(Window.window.title)}&url=${encodeURIComponent(mediaPlayer.source)}&position=${parseInt(mediaPlayer.position/1000)}`
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

                            MenuItem {
                                background: Item { implicitWidth: 200; implicitHeight: 48 }
                                icon.source: "qrc:/brightness.svg"
                                Slider {
                                    id: sliderGamma
                                    anchors.verticalCenter: parent.verticalCenter
                                    x: 48; width: 110
                                    from: 0.8; to: 1.2; value: 1
                                }
                                ToolButton {
                                    anchors {
                                        left: sliderGamma.right
                                        verticalCenter: parent.verticalCenter
                                    }
                                    implicitWidth: 36; implicitHeight: 36
                                    visible: sliderGamma.value !== 1
                                    icon.source: "qrc:/undo.svg"
                                    onClicked: sliderGamma.value = 1
                                }
                            }
                        }

                        onClicked: {
                            if (menu.visible) {
                                menu.close()
                            } else {
                                menu.x = pressX - menu.width; menu.y = pressY - menu.height
                                menu.open()
                            }
                        }
                    }
                }
            }
            RowLayout {
                Layout.fillWidth: true; Layout.fillHeight: true
                spacing: 4

                function msToTime(ms) {
                    let second = parseInt(ms/1000)
                    let hour = parseInt(second / 3600)
                    second -= hour * 3600
                    let minute = parseInt(second / 60)
                    second -= minute * 60

                    let re = hour>0? `${hour.toString().padStart(2, '0')}:` : ""
                    re += `${minute.toString().padStart(2, '0')}:${second.toString().padStart(2, '0')}`
                    return re
                }

                Label {
                    Layout.fillHeight: true; Layout.preferredWidth: 52
                    text: parent.msToTime(mediaPlayer.position)
                    MaterialYou.fontRole: MaterialYou.LabelSmall
                    MaterialYou.foregroundColor: MaterialYou.OnSurfaceVariant
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignRight
                }
                Item {
                    Layout.fillWidth: true; Layout.fillHeight: true
                    Layout.topMargin: -6; Layout.bottomMargin: -6

                    ProgressBar {
                        anchors.fill: parent
                        value: rectAnchor.x + rectAnchor.width / 2
                        to: parent.width
                        MaterialYou.backgroundColor: MaterialYou.tintSurfaceColor(3)
                        MaterialYou.radius: 10
                        opacity: 0.7
                    }
                    MouseArea {
                        id: mouseAreaProgressBar
                        property real hoveredMs: mouseX / width * mediaPlayer.duration
                        property bool playerJustPlayed
                        anchors.fill: parent
                        hoverEnabled: true
                        onMouseXChanged: pressed && (mediaPlayer.position = hoveredMs)
                        onPressed: {
                            playerJustPlayed = mediaPlayer.playbackState === MediaPlayer.PlayingState
                            mediaPlayer.pause()
                            mouseXChanged(null)
                        }
                        onReleased: playerJustPlayed && mediaPlayer.play()
                    }
                    Rectangle {
                        id: rectAnchor
                        anchors.verticalCenter: parent.verticalCenter
                        x: parent.width * mediaPlayer.position / mediaPlayer.duration - width / 2
                        z: 1
                        width: 4
                        radius: 4
                        height: 16
                        color: MaterialYou.color(MaterialYou.OnPrimary)
                    }
                    Label {
                        id: labelSeekHint
                        text: parent.parent.msToTime(mouseAreaProgressBar.hoveredMs)
                        y: -8; x: mouseAreaProgressBar.mouseX - width/2
                        visible: mouseAreaProgressBar.containsMouse
                        MaterialYou.fontRole: MaterialYou.LabelSmall
                        MaterialYou.foregroundColor: MaterialYou.OnSurfaceVariant
                    }
                }
                Label {
                    Layout.fillHeight: true; Layout.preferredWidth: 52
                    text: parent.msToTime(mediaPlayer.duration - mediaPlayer.position)
                    MaterialYou.fontRole: MaterialYou.LabelSmall
                    MaterialYou.foregroundColor: MaterialYou.OnSurfaceVariant
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignRight
                }
            }
        }

        hoverEnabled: true
        onHoveredChanged: if (hovered) timerHideCursor.stop()

        focus: true
        onFocusChanged: forceActiveFocus()
        Keys.onSpacePressed: { buttonPlay.clicked(); showCursor() }
        Keys.onLeftPressed: { buttonReplay5.clicked(); showCursor() }
        Keys.onRightPressed: { buttonForward5.clicked(); showCursor() }
        Keys.onUpPressed: { audioOutput.volume += 0.1; showCursor() }
        Keys.onDownPressed: { audioOutput.volume -= 0.1; showCursor() }
        Keys.onEscapePressed: root.visibility = Window.Windowed
    }
}
