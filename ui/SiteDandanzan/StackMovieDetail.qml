import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
import Qt.labs.settings
import MaterialYou

Page {
    id: root

    property string movieID: ""
    property var _history: Session.history.get(Session.historyIndexOf(root.movieID))
    property var _movieListData: Session.movieCardData.get(movieID)
    property var _movieDetailData: null

    function renderMovieDetail(url) {
        progressNetwork.state = "loading"
        return siteDandanzan.dataService.detail(url)
        .then(result => {
                  _movieDetailData = JSON.parse(result)
                  progressNetwork.state = "hide"
              })
        .catch(err => {
                   progressNetwork.retryWork = () => renderMovieDetail(url)
                   progressNetwork.state = "failed"
               });
    }

    Component.onCompleted: {
        if (_movieListData?.url) renderMovieDetail(_movieListData.url)
    }

    background: Item {}

    DialogRoom {
        id: dialogRoom
        anchors.fill: parent
    }

    ScrollView {
        anchors { fill: parent; topMargin: 8 }
        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff; ScrollBar.vertical.policy: ScrollBar.AsNeeded
        rightPadding: 16
        contentWidth: availableWidth; contentHeight: layout.implicitHeight + 16
        RowLayout {
            id: layout
            anchors { left: parent.left; right: parent.right; leftMargin: 8 }
            spacing: 16
            ColumnLayout {
                Layout.fillWidth: true; Layout.alignment: Qt.AlignTop
                spacing: 0

                Label {
                    id: labelTitle
                    Layout.fillWidth: true
                    text: Session.movieCardData.get(root.movieID).title
                    MaterialYou.fontRole: MaterialYou.TitleLarge
                    wrapMode: Text.Wrap
                }
                Label {
                    visible: text
                    Layout.fillWidth: true
                    text: root._movieDetailData? root._movieDetailData.oTitle : ""
                    MaterialYou.fontRole: MaterialYou.TitleMedium
                    color: MaterialYou.color(MaterialYou.OnSurfaceVariant)
                    wrapMode: Text.Wrap
                }
                Label {
                    Layout.fillWidth: true; Layout.rightMargin: 32; Layout.topMargin: 8
                    text: root._movieDetailData? root._movieDetailData.description : ""
                    wrapMode: Text.Wrap
                }

                Item { Layout.preferredHeight: 16; Layout.fillWidth: true }

                ProgressNetwork { id: progressNetwork }

                Chip {
                    visible: !progressNetwork.visible && comboBoxPlaylists.count===0
                    text: qsTr("No Resources")
                    enabled: false
                }

                ComboBox {
                    id: comboBoxPlaylists
                    visible: count > 0
                    model: root._movieDetailData? root._movieDetailData.playlists : null
                    implicitHeight: 32
                    textRole: "name"
                    valueRole: "episodes"
                    popup.MaterialYou.backgroundColor: MaterialYou.Surface
                    onModelChanged: {
                        let index = Session.historyIndexOf(root.movieID)
                        if (index < 0) return

                        currentIndex = Session.history.get(index).playlistID
                    }
                }

                Item { Layout.preferredHeight: 12; Layout.fillWidth: true }

                Flow {
                    Layout.fillWidth: true
                    spacing: 8
                    Repeater {
                        model: comboBoxPlaylists.currentValue
                        delegate: Button {
                            id: buttonEpisode
                            type: Button.Tonal
                            tonedRole: highlighted? MaterialYou.TertiaryContainer : MaterialYou.SecondaryContainer
                            height: 32
                            highlighted: (root._history
                                          && root._history.playlistID === comboBoxPlaylists.currentIndex
                                          && root._history.episodeID === index) ? true : false

                            states: [
                                State {
                                    name: "macos"
                                    when: Qt.platform.os === "osx"
                                    PropertyChanges {
                                        target: buttonEpisode
                                        text: modelData.title
                                              + (highlighted? qsTr(" (%1% Watched)").arg(parseInt(root._history.position*100)) : "")
                                        onClicked: {
                                            if (!modelData.script) return

                                            Session.updateHistory({
                                                                      movieID: root.movieID,
                                                                      timestamp: Date.now(),
                                                                      playlistID: comboBoxPlaylists.currentIndex,
                                                                      episodeID: index,
                                                                      position: highlighted && root._history? root._history.position : 0
                                                                  })

                                            WindowPlayer.title = `${Session.movieCardData.get(root.movieID).title} - ${modelData.title}`
                                            WindowPlayer.movieID = root.movieID
                                            WindowPlayer.load(siteDandanzan.dataService.getM3u8(modelData.script))
                                        }
                                    }
                                },
                                State {
                                    name: "windows"
                                    when: Qt.platform.os === "windows"
                                    PropertyChanges {
                                        target: buttonEpisode
                                        text: modelData.title
                                        onClicked: {
                                            if (!modelData.script) return
                                            siteDandanzan.dataService.getM3u8(modelData.script)
                                            .then(source => {
                                                      const title = `${Session.movieCardData.get(root.movieID).title} - ${modelData.title}`
                                                      Qt.openUrlExternally(`https://joodo.github.io/WPMI/player.html?title=${encodeURIComponent(title)}&url=${encodeURIComponent(source)}`)
                                                  });

                                            Session.updateHistory({
                                                                      movieID: root.movieID,
                                                                      timestamp: Date.now(),
                                                                      playlistID: comboBoxPlaylists.currentIndex,
                                                                      episodeID: index,
                                                                  })
                                        }
                                    }
                                }
                            ]

                            MouseArea {
                                anchors.fill: parent
                                acceptedButtons: Qt.RightButton
                                onClicked: menuEpisode.popup()
                                Menu {
                                    id: menuEpisode
                                    MenuItem {
                                        text: qsTr("Watch together")
                                        onClicked: {
                                            const roomName = `${Session.movieCardData.get(root.movieID).title} - ${modelData.title}`
                                            dialogRoom.create(roomName, siteDandanzan.dataService.getM3u8(modelData.script))
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            Pane {
                id: pane
                Layout.alignment: Qt.AlignTop; Layout.preferredWidth: image.Layout.preferredWidth
                padding: 0
                layer.enabled: true
                layer.effect: OpacityMask {
                    maskSource: Rectangle {
                        width: pane.width; height: pane.height
                        radius: pane.MaterialYou.radius
                    }
                }
                ColumnLayout {
                    anchors { left: parent.left; right: parent.right }
                    spacing: 8
                    Image {
                        id: image
                        Layout.preferredWidth: 250
                        Layout.preferredHeight: width / sourceSize.width * sourceSize.height
                        Layout.alignment: Qt.AlignTop
                        source: Session.movieCardData.get(root.movieID).thumbSource
                    }

                    GridLayout {
                        visible: root._movieDetailData
                        Layout.fillWidth: true
                        Layout.margins: 16; Layout.topMargin: 12
                        columns: 2
                        columnSpacing: 8

                        Repeater {
                            model: [
                                qsTr("Alias"),
                                qsTr("Director"),
                                qsTr("Year"),
                                qsTr("Country"),
                                qsTr("Genre"),
                            ]

                            Label {
                                visible: repeaterValue.model[index]
                                Layout.row: index; Layout.column: 0
                                Layout.alignment: Qt.AlignBaseline | Qt.AlignRight
                                MaterialYou.fontRole: MaterialYou.LabelMedium
                                text: modelData
                            }
                        }

                        Repeater {
                            id: repeaterValue
                            model: root._movieDetailData? [
                                                              root._movieDetailData.alias,
                                                              root._movieDetailData.director,
                                                              Session.movieCardData.get(root.movieID).year,
                                                              Session.movieCardData.get(root.movieID).country,
                                                              root._movieDetailData.genre,
                                                          ] : ["", "", "", "", ""]
                            Label {
                                visible: text
                                Layout.row: index; Layout.column: 1
                                Layout.alignment: Qt.AlignBaseline; Layout.fillWidth: true
                                Layout.rightMargin: 16
                                text: modelData
                                wrapMode: Text.Wrap
                            }
                        }

                        Label {
                            Layout.row: 5; Layout.column: 1
                            text: `<a href='${Session.movieCardData.get(root.movieID).url}'>` + qsTr("Original Website") + "</a>"
                            onLinkActivated: Qt.openUrlExternally(link)
                            MouseArea {
                                anchors.fill: parent
                                acceptedButtons: Qt.NoButton
                                cursorShape: Qt.PointingHandCursor
                            }
                        }
                    }
                }
            }
        }
    }
}
