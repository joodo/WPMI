import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
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
                Window.window.snackbar?.toast(qsTr("History was cleared."), qsTr("Undo"))
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

        anchors { top: parent.top; bottom: parent.bottom }
        Timer {
            interval: 500
            repeat: true
            running: visible
            triggeredOnStart: true
            onTriggered: scrollView.width = scrollView.parent.width
        }

        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff; ScrollBar.vertical.policy: ScrollBar.AsNeeded
        contentWidth: availableWidth
        Flow {
            id: layout
            anchors { left: parent.left; right: parent.right; top: parent.top; margins: 16 }
            spacing: 12

            property int columns: Math.max(3, (width + spacing) / (160 + spacing))
            property real cellWidth: (width - (columns - 1) * spacing) / columns
            Repeater {
                id: repeater
                model: Session.history
                delegate: CardMoive {
                    width: layout.cellWidth

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
                                Window.window.snackbar?.toast(qsTr("%1 was removed.").arg(movieData.title),
                                                              qsTr("Undo")).catch(() => Session.history.insert(myIndex, JSON.parse(myData)))
                            }
                        }
                    }
                }
            }
            Item { width: parent.width; height: 16 }

            // DUMMY: Wait for singleton model load finish, avoid anime shake
            Timer { interval: 500; running: true; onTriggered: parent.move.animations[0].duration = 200 }
            add: Transition { NumberAnimation { property: "opacity"; from: 0; to: 1.0; duration: 200 } }
            move: Transition { NumberAnimation { properties: "x,y"; duration: 0; easing.type: Easing.OutCubic } }
            populate: move
        }
    }
}
