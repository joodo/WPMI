import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import MaterialYou

RowLayout {
    Label {
        text: qsTr("Restart WPMI to apply this change.")
        MaterialYou.foregroundColor: MaterialYou.OnSurfaceVariant
        MaterialYou.fontRole: MaterialYou.LabelSmall
    }
    Label {
        text: qsTr("<a href='restart'>Restart Now</a>")
        onLinkActivated: Backend.restartApplication()
        MaterialYou.fontRole: MaterialYou.LabelSmall
        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.NoButton
            cursorShape: Qt.PointingHandCursor
        }
    }
}
