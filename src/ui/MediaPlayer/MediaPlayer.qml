pragma Singleton

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Window
import QtMultimedia as Multimedia
import Qt.labs.settings
import Qt5Compat.GraphicalEffects
import MaterialYou


Rectangle {
    id: root


    signal watchedAt(int durationMs)


    property real gamma: 1
    property real volume: 1


    function load(m3u8) {
        mediaPlayer.source = ""
        Window.window.visible = true
        Window.window.raise()

        // A promise
        if (m3u8.then) {
            m3u8.then(url => mediaPlayer.source = url)
        }
        // A string
        if (typeof m3u8 === "string") {
            mediaPlayer.source = m3u8
        }

        return new Promise((resolve, reject) => {
                               mediaPlayer.playbackStateChanged.bind(() => {
                                                                         if (mediaStatus === MediaPlayer.LoadedMedia) {
                                                                             resolve()
                                                                         }
                                                                     })
                               mediaPlayer.errorOccurred.bind((err, errString) => resolve(errString))
                           })
    }

    function play() { mediaPlayer.play() }
    function pause() { mediaPlayer.pause() }

    onVisibleChanged: !visible && mediaPlayer.pause()


    color: "black"

    Multimedia.MediaPlayer {
        id: mediaPlayer
        videoOutput: videoOutput
        audioOutput: Multimedia.AudioOutput { volume: root.volume }
        onSourceChanged: root.gamma = 1
        onPlaybackStateChanged: {
            if (playbackState === MediaPlayer.PlayingState) {
                Backend.setScreensaverEnabled(false)
            } else {
                Backend.setScreensaverEnabled(true)
            }
        }
        onErrorOccurred: (err, errorString) => console.error(err, errorString)
    }
    Multimedia.VideoOutput {
        id: videoOutput
        anchors.fill: parent
        layer.enabled: sliderGamma.value !== 1
        layer.effect: GammaAdjust {
            gamma: root.gamma
        }
    }
    Timer {
        running: mediaPlayer.playbackState === MediaPlayer.PlayingState
        interval: 1000; repeat: true
        onTriggered: root.watchedAt(mediaPlayer.position)
    }

    Settings { property alias volume: root.volume }


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
        anchors.fill: parent
        hoverEnabled: true
        onDoubleClicked: {
            Window.window.visibility = (root.visibility === Window.FullScreen?
                                   Window.Windowed : Window.FullScreen)
            Window.window.requestActivate()
        }
        onWheel: wheel => {
            root.volume -= wheel.angleDelta.y / 1500
            wheel.accepted = true
            timerHideVolumePopup.restart()
        }
    }

    PaneBlur {
        id: paneVolume
        x: 16; y: 16
        blurItem: root
        ColumnLayout {
            IconLabel {
                icon.source: "qrc:/volume.svg"
                icon.width: 36; icon.height: 36
                text: qsTr("Volume: %1%").arg(parseInt(root.volume*100))
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
