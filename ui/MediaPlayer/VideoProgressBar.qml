import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtMultimedia
import MaterialYou

RowLayout {
    property MediaPlayer mediaPlayer

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
            property bool isPlayerJustPlayed
            anchors.fill: parent
            hoverEnabled: true
            onMouseXChanged: pressed && (mediaPlayer.position = hoveredMs)
            onPressed: {
                isPlayerJustPlayed = mediaPlayer.playbackState === MediaPlayer.PlayingState
                mediaPlayer.pause()
                mouseXChanged(null)
            }
            onReleased: isPlayerJustPlayed && mediaPlayer.play()
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
