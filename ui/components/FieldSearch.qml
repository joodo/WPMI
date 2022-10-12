import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import MaterialYou

Pane {
    id: root
    height: 48
    padding: 0

    signal search(string query)

    property alias placeholderText: textPlaceholder.text

    //MaterialYou.backgroundColor: MaterialYou.tintSurfaceColor(2)

    RowLayout {
        anchors.fill: parent
        spacing: 0

        ToolButton {
            id: buttonSearch
            Layout.alignment: Qt.AlignVCenter
            icon.source: "qrc:/search.svg"
            onClicked: textEdit.accepted()
        }

        TextInput {
            id: textEdit
            Layout.fillWidth: true
            Layout.fillHeight: true
            verticalAlignment: Text.AlignVCenter
            color: MaterialYou.color(MaterialYou.OnSurface)
            selectionColor: MaterialYou.color(MaterialYou.PrimaryContainer)
            selectByMouse: true
            onAccepted: {
                if (text === "") return
                focus = false
                root.search(textEdit.text)
            }
            MaterialYou.fontRole: MaterialYou.TitleMedium
            clip: true

            Text {
                id: textPlaceholder
                visible: textEdit.text === "" && !textEdit.activeFocus
                anchors.verticalCenter: parent.verticalCenter
                color: MaterialYou.color(MaterialYou.OnSurfaceVariant)
            }

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.NoButton
                cursorShape: Qt.IBeamCursor
            }
        }

        ToolButton {
            Layout.alignment: Qt.AlignVCenter
            icon.source: "qrc:/backspace.svg"
            onClicked: {
                textEdit.clear()
                textEdit.focus = true
            }
            visible: textEdit.text !== ""
        }
    }
}
