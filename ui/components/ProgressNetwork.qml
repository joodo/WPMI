import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import MaterialYou

RowLayout {
    id: root

    property var retryWork: null
    property string text: ""

    spacing: 16

    Item { Layout.fillWidth: true; Layout.preferredHeight: 1 }

    BusyIndicator {
        id: progressBar
        Layout.alignment: Qt.AlignVCenter
    }

    Label {
        id: label
        Layout.alignment: Qt.AlignVCenter
        verticalAlignment: Text.AlignVCenter
    }

    Chip {
        id: buttonRetry
        Layout.alignment: Qt.AlignVCenter
        text: qsTr("Retry")
        MaterialYou.foregroundColor: MaterialYou.Error
        onClicked: root.retryWork()
    }

    Item { Layout.fillWidth: true; Layout.preferredHeight: 1 }

    state: "loading"
    states: [
        State {
            name: "loading"
            PropertyChanges {
                root.visible: true
                progressBar.visible: true
                buttonRetry.visible: false
                label.text: root.text || qsTr("Loading...")
                label.MaterialYou.foregroundColor: MaterialYou.OnSurfaceVariant
            }
        },
        State {
            name: "failed"
            PropertyChanges {
                root.visible: true
                progressBar.visible: false
                buttonRetry.visible: true
                label.text: root.text || qsTr("Can't seem to load right now.")
                label.MaterialYou.foregroundColor: MaterialYou.Error
            }
        },
        State {
            name: "hide"
            PropertyChanges {
                root.visible: false
            }
        }
    ]
}
