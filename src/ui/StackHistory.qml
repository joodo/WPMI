import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Qt.labs.settings
import MaterialYou

Pane {
    id: root
    signal movieSelected(string movieID)
    signal search(var query)

    background: Item {}
    padding: 0


    ColumnLayout {
        anchors.fill: parent

        RowLayout {
            spacing: 8
            Layout.topMargin: 32
            Label {
                Layout.alignment: Qt.AlignBaseline
                text: qsTr("Last Watched")
                MaterialYou.fontRole: MaterialYou.TitleLarge
                color: MaterialYou.color(MaterialYou.OnSurfaceVariant)
            }
            Button {
                Layout.alignment: Qt.AlignBaseline
                text: qsTr("Clear")
                flat: true
                onClicked: dialogConfirmClearHistory.open()
                Dialog {
                    id: dialogConfirmClearHistory
                    title: qsTr("Clear history?")
                    standardButtons: Dialog.Ok | Dialog.Cancel
                    modal: true

                    Label {
                        MaterialYou.foregroundColor: MaterialYou.OnSurfaceVariant
                        text: qsTr("This will clean all porn you've watched. It's nice to be reborn.")
                    }

                    onAccepted: SingletonState.history.clear()
                }
            }
        }

        ScrollView {
            Layout.fillHeight: true; Layout.fillWidth: true
            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff; ScrollBar.vertical.policy: ScrollBar.AsNeeded
            // To show cards shadows
            Layout.leftMargin: -flow.anchors.margins; Layout.topMargin: -flow.anchors.topMargin; Layout.bottomMargin: -flow.anchors.topMargin
            contentWidth: availableWidth; contentHeight: flow.implicitHeight + 3*flow.anchors.margins
            Flow {
                id: flow
                property int _rowCount
                // margins to show cards shadows
                anchors { left: parent.left; right: parent.right; top: parent.top; margins: 16; topMargin: 8 }
                spacing: 12
                onWidthChanged: _rowCount = Math.max(4, (width + spacing) / (180 + spacing))
                Repeater {
                    id: repeater
                    model: SingletonState.history
                    delegate: CardMoive {
                        onClicked: mouse => {
                                       if (mouse.button === Qt.LeftButton) root.movieSelected(movieID)
                                       else contextMenu.popup()
                                   }

                        movieData: SingletonState.movieCardData.get(movieID)
                        width: (flow.width - (flow._rowCount-1)*flow.spacing) / flow._rowCount
                        Menu {
                            id: contextMenu
                            MaterialYou.backgroundColor: MaterialYou.tintSurfaceColor(4)
                            MenuItem {
                                text: qsTr("Remove")
                                onTriggered: SingletonState.history.remove(index)
                            }
                        }
                    }
                }
            }
        }
    }
}
