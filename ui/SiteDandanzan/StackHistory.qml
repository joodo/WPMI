import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Qt.labs.settings
import MaterialYou

Page {
    id: root
    signal movieSelected(string movieID)

    leftPadding: -16

    background: null

    header: RowLayout {
        spacing: 8
        height: 48
        Label {
            Layout.alignment: Qt.AlignBaseline
            text: qsTr("Last Watched")
            MaterialYou.fontRole: MaterialYou.HeadlineMedium
        }
        Button {
            Layout.alignment: Qt.AlignBaseline
            text: qsTr("Clear")
            flat: true
            onClicked: {
                let historys = []
                for (let i = 0; i < Session.history.count; i++) {
                    historys.push(JSON.stringify(Session.history.get(i)))
                }

                Session.history.clear()
                Window.window.toast?.(qsTr("History was cleared."), qsTr("Undo"))
                .catch(() => historys.map(value => Session.history.append(JSON.parse(value))));
            }
        }
        HandlerWindowDrag {
            Layout.fillHeight: true
            Layout.fillWidth: true
        }
    }

    HeaderShadow {
        z: 10
        x: -40
        opacity: scrollView.contentItem.contentY / 56
    }

    ScrollView {
        id: scrollView
        anchors.fill: parent
        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff; ScrollBar.vertical.policy: ScrollBar.AsNeeded
        contentWidth: availableWidth
        GridLayout {
            id: layout
            anchors { left: parent.left; right: parent.right; top: parent.top; margins: 16 }
            columnSpacing: 12; rowSpacing: 12
            onWidthChanged: columns = Math.max(3, (width + rowSpacing) / (160 + rowSpacing))
            Repeater {
                id: repeater
                model: Session.history
                delegate: CardMoive {
                    Layout.fillWidth: true; Layout.alignment: Qt.AlignTop
                    property var movieData: Session.movieCardData.get(movieID)
                    thumbSource: movieData.thumbSource
                    title: movieData.title
                    brief: `${movieData.country}   ${movieData.year}`
                    onLeftClicked: root.movieSelected(movieID)
                    onRightClicked: contextMenu.popup()

                    Menu {
                        id: contextMenu
                        MaterialYou.backgroundColor: MaterialYou.tintSurfaceColor(4)
                        MenuItem {
                            text: qsTr("Remove")
                            onTriggered: {
                                const myData = JSON.stringify(Session.history.get(index))
                                const myIndex = index
                                Session.history.remove(index)
                                Window.window.toast?.(qsTr("%1 was removed.").arg(movieData.title),
                                                      qsTr("Undo")).catch(() => Session.history.insert(myIndex, JSON.parse(myData)))
                            }
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
