import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtMultimedia
import Qt5Compat.GraphicalEffects
import MaterialYou

Rectangle {
    id: root

    property alias player: mediaPlayer

    color: "black"


    // User interact
    property bool keepCursor: false
    readonly property bool _keepCursor: keepCursor || mediaPlayer.playbackState === MediaPlayer.StoppedState
    property bool cursorVisible: true

    states: [
        State {
            name: "keepCursor"
            when: _keepCursor
            PropertyChanges { root.cursorVisible: true }
        },
        State {
            name: "showCursor"
            PropertyChanges { root.cursorVisible: true }
        },
        State {
            name: "hideCursor"
            when: !_keepCursor
        }
    ]
    transitions: [
        Transition {
            to: "showCursor"
            onRunningChanged: !running && !_keepCursor && (root.state = "hideCursor")
        },
        Transition {
            to: "hideCursor"
            SequentialAnimation {
                PauseAnimation { duration: 2450 }
                PropertyAction { target: root; property: "cursorVisible"; value: false }
            }
        }
    ]

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: root.cursorVisible? Qt.ArrowCursor : Qt.BlankCursor

        // Window Dragging
        property point pos
        property point windowPos
        onPressed: mouse => {
                       windowPos = Qt.point(Window.window.x, Window.window.y)
                       pos = Qt.point(mouse.x, mouse.y)
                   }
        onPositionChanged: mouse => {
                               root.state = "showCursor"

                               if (!pressed) return
                               const delta = Qt.point(mouse.x - pos.x, mouse.y - pos.y)
                               Window.window.x += delta.x
                               Window.window.y += delta.y
                           }

        onClicked: {
            // Distinguish single click and drag
            if (Math.hypot(Window.window.x-windowPos.x, Window.window.y-windowPos.y) < 4) {
                // Distinguish single and double click
                timerSingleClick.restart()
            }
        }
        Timer {
            id: timerSingleClick
            interval: Qt.styleHints.mouseDoubleClickInterval
            onTriggered: mediaPlayer.playbackState === MediaPlayer.PlayingState?
                             mediaPlayer.pause() : mediaPlayer.play()
        }

        // Solve mouse focus problem if use double click directly
        property bool _isDoubleClick: false
        onDoubleClicked: {
            timerSingleClick.stop()
            _isDoubleClick = true
        }
        onReleased: {
            // Will active when a double click release
            if (_isDoubleClick) {
                Window.window.visibility = (Window.window.visibility === Window.FullScreen?
                                                Window.Windowed : Window.FullScreen)
                _isDoubleClick = false
            }
        }

        onWheel: wheel => {
                     audioOutput.volume -= wheel.angleDelta.y / 1500
                     wheel.accepted = true
                     paneVolume.state = "show"
                 }
    }


    // Player
    MediaPlayer {
        id: mediaPlayer

        signal watchedAt(real position)

        property real gamma: 1

        property var _resolver
        property var _rejecter

        function loadSource(source) {
            this.source = source
            return new Promise((resolve, reject) => {
                                   _resolver = resolve
                                   _rejecter = reject
                               })
        }

        onMediaStatusChanged: {
            if (mediaStatus === MediaPlayer.LoadedMedia) {
                if (_resolver) _resolver()
                mediaPlayer.play()
                gamma = 1
            }
        }
        onErrorOccurred: (err, errorString) => {
                             if (_rejecter) _rejecter(errorString)
                             console.error(err, errorString)
                         }

        onPlaybackStateChanged: {
            if (playbackState === MediaPlayer.PlayingState) {
                Backend.setScreensaverEnabled(false)
            } else {
                Backend.setScreensaverEnabled(true)
            }
        }

        videoOutput: videoOutput; audioOutput: audioOutput
    }

    VideoOutput {
        id: videoOutput
        anchors.fill: parent;
        layer.enabled: mediaPlayer.gamma !== 1
        layer.effect: GammaAdjust {
            gamma: mediaPlayer.gamma
        }
    }

    AudioOutput { id: audioOutput }
    TrivialSettings { property alias volume: audioOutput.volume }

    Timer {
        running: mediaPlayer.playbackState === MediaPlayer.PlayingState
        interval: 1000; repeat: true
        onTriggered: mediaPlayer.watchedAt(mediaPlayer.position / mediaPlayer.duration)
    }


    // Loading mask
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


    // Volume Indicator
    Pane {
        id: paneVolume
        x: 16; y: 16

        IconLabel {
            icon.source: "qrc:/volume.svg"
            icon.width: 36; icon.height: 36
            text: qsTr("Volume: %1%").arg(parseInt(audioOutput.volume*100))
            display: IconLabel.TextUnderIcon
            MaterialYou.fontRole: MaterialYou.LabelLarge
            MaterialYou.foregroundColor: MaterialYou.OnSurfaceVariant
        }

        state: "hide"
        states: [
            State {
                name: "show"
                PropertyChanges { paneVolume.opacity: 1 }
            },
            State {
                name: "hide"
                PropertyChanges { paneVolume.opacity: 0 }
            }
        ]
        transitions: [
            Transition {
                to: "show"
                onRunningChanged: !running && (paneVolume.state = "hide")
            },
            Transition {
                from: "show"
                to: "hide"
                SequentialAnimation {
                    PauseAnimation { duration: 1000 }
                    NumberAnimation { property: "opacity"; duration: 250; easing.type: Easing.OutCubic }
                }
            }
        ]

        background: Rectangle {
            color: paneVolume.MaterialYou.backgroundColor
            radius: paneVolume.MaterialYou.radius
            opacity: 0.7
        }
    }
}
