import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtMultimedia
import Qt.labs.settings
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
            PropertyChanges {
                target: root
                cursorVisible: true
            }
        },
        State {
            name: "showCursor"
            PropertyChanges {
                target: root
                cursorVisible: true
            }
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

        onDoubleClicked: {
            Window.window.visibility = (Window.window.visibility === Window.FullScreen?
                                   Window.Windowed : Window.FullScreen)
        }

        onMouseXChanged: root.state = "showCursor"
        onMouseYChanged: root.state = "showCursor"
        onWheel: wheel => {
            audioOutput.volume -= wheel.angleDelta.y / 1500
            wheel.accepted = true
            timerHideVolumePopup.restart()
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
    Settings { property alias volume: audioOutput.volume }

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

    PaneBlur {
        id: paneVolume
        x: 16; y: 16
        blurItem: root
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
}
