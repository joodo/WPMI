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
            contentWidth: availableWidth
            // To show cards shadows
            Layout.leftMargin: -layout.anchors.margins; Layout.topMargin: -layout.anchors.topMargin
            GridLayout {
                id: layout
                // margins to show cards shadows
                anchors { left: parent.left; right: parent.right; top: parent.top; margins: 16; topMargin: 8 }
                columnSpacing: 12; rowSpacing: 12
                onWidthChanged: columns = Math.max(3, (width + rowSpacing) / (160 + rowSpacing))
                Repeater {
                    id: repeater
                    model: SingletonState.history
                    delegate: CardMoive {
                        Layout.fillWidth: true; Layout.alignment: Qt.AlignTop
                        property var movieData: SingletonState.movieCardData.get(movieID)
                        thumbSource: movieData.thumbSource
                        title: movieData.title
                        brief: `${movieData.country}   ${movieData.year}`
                        onClicked: mouse => {
                                       if (mouse.button === Qt.LeftButton) root.movieSelected(movieID)
                                       else contextMenu.popup()
                                   }

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
                Item {
                    Layout.columnSpan: parent.columns
                    Layout.preferredHeight: 16; Layout.fillWidth: true
                }
            }
        }
    }
}
