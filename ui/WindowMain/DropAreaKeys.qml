import QtQuick
import QtQuick.Controls
import QtMultimedia
import MaterialYou

DropArea {
    id: root

    signal unlocked()

    keys: ["text/uri-list"]
    onEntered: {}
    onDropped: drop => {
                   const path = Backend.localFileFromUrl(drop.urls[0].toString())
                   if (path.endsWith(".png")) {
                       if (Backend.getPngText(path) === "sweetsweetdream") {
                           root.unlocked()
                           sound.play()
                       }
                   }
               }

    MediaPlayer {
        id: sound
        source: "qrc:/celebration.wav"
        audioOutput: AudioOutput {}
    }

    Rectangle {
        visible: parent.containsDrag
        anchors.fill: parent
        color: MaterialYou.color(MaterialYou.Primary)
        opacity: 0.2
    }
}
