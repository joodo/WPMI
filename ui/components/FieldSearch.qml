import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import MaterialYou

Pane {
    id: root
    height: 40
    padding: 0

    signal search(string query)

    property alias placeholderText: textPlaceholder.text

    RowLayout {
        anchors.fill: parent
        spacing: 0

        ToolButton {
            id: buttonSearch
            Layout.alignment: Qt.AlignVCenter
            MaterialYou.radius: 0
            icon.source: "qrc:/search.svg"
            onClicked: textEdit.accepted()
        }

        TextInput {
            id: textEdit
            Layout.fillWidth: true
            Layout.fillHeight: true
            verticalAlignment: Text.AlignVCenter
            font.pointSize: 16
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
            MaterialYou.radius: 0
            onClicked: {
                textEdit.clear()
                textEdit.focus = true
            }
            visible: textEdit.text !== ""
        }

        layer.enabled: true
        layer.effect: OpacityMask {
            maskSource: Rectangle {
                width: root.width; height: root.height
                radius: root.MaterialYou.radius
            }
        }
    }

    Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
}
