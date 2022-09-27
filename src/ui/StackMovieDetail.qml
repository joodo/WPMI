import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
import MaterialYou

Page {
    id: root

    property string movieID: ""
    property var _history: SingletonState.history.get(SingletonState.historyIndexOf(root.movieID))
    property var _movieListData: SingletonState.movieCardData.get(movieID)
    property var _movieDetailData: null
    //on_MovieDetailDataChanged: print(JSON.stringify(_movieDetailData))

    function renderMovieDetail(url) {
        const scriptIntercept = `
        const intercept = (urlmatch, callback) => {
        let send = XMLHttpRequest.prototype.send;
        XMLHttpRequest.prototype.send = function() {
        this.addEventListener('readystatechange', function() {
        if (this.responseURL.includes(urlmatch) && this.readyState === 4) {
        callback(this);
        }
        }, false);
        send.apply(this, arguments);
        };
        };

        intercept("https://www.dandanzan10.top/url.php", response => alert("m3u8: " + response.responseText))
        `
        const scriptGetPlaylists = `
        let r = [];
        let titleDOMs = document.querySelectorAll("div.playlists > header > dl > dt");
        let playlistDOMs = document.querySelectorAll("div.playlist");
        for (let i = 0; i < titleDOMs.length; i++) {
        let p = {
        name: titleDOMs[i].innerHTML,
        episodes: []
        };
        let as = playlistDOMs[i + 1].querySelectorAll("ul > li > a");
        for (let a of as) p.episodes.push({
        title: a.innerHTML,
        script: a.attributes["onclick"].value
        });
        if (p.episodes.length === 1 && p.episodes[0].title === "暂无资源") continue;
        r.push(p);
        }

        let re = {
        "playlists": r,
        "fullTitle": document.querySelector("h1.product-title").childNodes[0].nodeValue.trim(),
        "genre": document.querySelectorAll("div.product-excerpt > span")[2].querySelector("a").innerHTML,
        "director": document.querySelectorAll("div.product-excerpt > span")[0].querySelector("a").innerHTML,
        "alias": document.querySelectorAll("div.product-excerpt > span")[4].innerHTML,
        "description": document.querySelectorAll("div.product-excerpt > span")[5].innerHTML,
        };
        re;
        `

        return SingletonWebView.loadUrl(url)
        .then(() => SingletonWebView.runScript(scriptIntercept))
        .then(() => SingletonWebView.runScript(scriptGetPlaylists))
        .then(result => _movieDetailData = result)
        .catch(err => progressNetwork.retryWork = () => renderMovieDetail(url));
    }

    Component.onCompleted: {
        if (_movieListData && _movieListData.url) renderMovieDetail(_movieListData.url)
    }

    background: Item {}

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
                    text: SingletonState.movieCardData.get(root.movieID).title
                    MaterialYou.fontRole: MaterialYou.TitleLarge
                    wrapMode: Text.Wrap
                }
                Label {
                    visible: text
                    Layout.fillWidth: true
                    text: root._movieDetailData? root._movieDetailData.fullTitle.replace(labelTitle.text, "").trim() : ""
                    MaterialYou.fontRole: MaterialYou.TitleMedium
                    color: MaterialYou.color(MaterialYou.OnSurfaceVariant)
                    wrapMode: Text.Wrap
                }
                Label {
                    Layout.fillWidth: true; Layout.rightMargin: 32; Layout.topMargin: 8
                    text: root._movieDetailData? root._movieDetailData.description : ""
                    wrapMode: Text.Wrap
                }

                Item { Layout.preferredHeight: 12; Layout.fillWidth: true }

                ProgressNetwork { id: progressNetwork; Layout.fillHeight: false }
                Chip {
                    visible: progressNetwork.idle && comboBoxPlaylists.count===0
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
                        let index = SingletonState.historyIndexOf(root.movieID)
                        if (index < 0) return

                        currentIndex = SingletonState.history.get(index).playlistID
                    }
                }

                RowLayout {
                    visible: comboBoxPlaylists.count !== 0
                    Layout.fillWidth: true; Layout.topMargin: 12
                    spacing: 12

                    Flow {
                        Layout.fillWidth: true
                        spacing: 8
                        Repeater {
                            model: comboBoxPlaylists.currentValue
                            delegate: Button {
                                type: Button.Tonal
                                tonedRole: highlighted? MaterialYou.TertiaryContainer : MaterialYou.SecondaryContainer
                                text: modelData.title
                                      + (highlighted && root._history.position >= 0.01? qsTr(" (%1% Watched)").arg(parseInt(root._history.position*100)) : "")
                                height: 32
                                highlighted: (root._history
                                              && root._history.playlistID === comboBoxPlaylists.currentIndex
                                              && root._history.episodeID === index)

                                onClicked: {
                                    if (!modelData.script) return
                                    SingletonWebView.runScript(modelData.script)

                                    SingletonState.updateHistory({
                                                                     movieID: root.movieID,
                                                                     timestamp: Date.now(),
                                                                     playlistID: comboBoxPlaylists.currentIndex,
                                                                     episodeID: index,
                                                                     position: root._history? root._history.position : 0
                                                                 })

                                    SingletonWindowPlayer.title = `${SingletonState.movieCardData.get(root.movieID).title} - ${modelData.title}`
                                    SingletonWindowPlayer.movieID = root.movieID
                                    SingletonWindowPlayer.listenM3u8()
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
                        source: SingletonState.movieCardData.get(root.movieID).thumbSource
                    }

                    GridLayout {
                        visible: root._movieDetailData
                        Layout.fillWidth: true; Layout.margins: 16; Layout.topMargin: 12
                        columns: 2
                        columnSpacing: 8
                        Label {
                            Layout.alignment: Qt.AlignBaseline | Qt.AlignRight
                            visible: labelAlias.visible
                            MaterialYou.fontRole: MaterialYou.LabelMedium
                            text: qsTr("Alias")
                        }
                        Label {
                            id: labelAlias
                            visible: text
                            Layout.alignment: Qt.AlignBaseline; Layout.fillWidth: true
                            text: root._movieDetailData? root._movieDetailData.alias : ""
                            wrapMode: Text.Wrap
                        }

                        Label { Layout.alignment: Qt.AlignBaseline | Qt.AlignRight; text: qsTr("Director"); MaterialYou.fontRole: MaterialYou.LabelMedium }
                        Label { Layout.alignment: Qt.AlignBaseline; text: root._movieDetailData? root._movieDetailData.director : "" }

                        Label { Layout.alignment: Qt.AlignBaseline | Qt.AlignRight; text: qsTr("Year"); MaterialYou.fontRole: MaterialYou.LabelMedium }
                        Label { Layout.alignment: Qt.AlignBaseline; text: SingletonState.movieCardData.get(root.movieID).year }

                        Label { Layout.alignment: Qt.AlignBaseline | Qt.AlignRight; text: qsTr("Country"); MaterialYou.fontRole: MaterialYou.LabelMedium }
                        Label { Layout.alignment: Qt.AlignBaseline; text: SingletonState.movieCardData.get(root.movieID).country }

                        Label { Layout.alignment: Qt.AlignBaseline | Qt.AlignRight; text: qsTr("Genre"); MaterialYou.fontRole: MaterialYou.LabelMedium }
                        Label { Layout.alignment: Qt.AlignBaseline; text: root._movieDetailData? root._movieDetailData.genre : "" }

                        Item { Layout.preferredHeight: 1; Layout.preferredWidth: 1 }
                        Label {
                            text: `<a href='${SingletonState.movieCardData.get(root.movieID).url}'>` + qsTr("Original Website") + "</a>"
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
