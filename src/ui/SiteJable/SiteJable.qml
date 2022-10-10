import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import MaterialYou

Page {
    id: root

    signal movieSelected(string movieID)
    onMovieSelected: movieID => {
                         const movieData = Session.movieCardData.get(movieID)

                         WindowPlayer.title = movieData.title
                         WindowPlayer.load(getM3u8(movieData.url))
                     }

    property string next: ""
    property string previous: ""
    property string address
    onAddressChanged: {
        getResult(address)
        .then(result => {
                  next = result.next
                  previous = result.previous
                  Session.updateMovieCardDataFromList(result.result)
                  result.result.map(value => modelMovie.append({ movieID : value.movieID }))
              })
        .catch(err => progressNetwork.retryWork = () => addressChanged());
    }
    Component.onCompleted: address = "https://jable.tv/new-release/"

    function getM3u8(url) {
        const script = `
        let s = document.querySelectorAll("section > script")[1].innerHTML;
        s.substring(s.indexOf("http"), s.indexOf("m3u8")+4)
        `
        return SingletonWebView.loadUrl(url)
        .then(() => SingletonWebView.runScript(script));
    }

    function getResult(url) {
        const script = `
        let result = [];
        for (let e of document.querySelectorAll(".video-img-box.mb-e-20")) {
        let title = e.querySelector("h6>a").innerHTML;
        result.push({
        title: title.substring(title.indexOf(" ") + 1),
        thumbSource: e.querySelector("img").getAttribute("data-src"),
        url: e.querySelector("h6>a").href,
        movieID: (url => url.substring(24, url.lastIndexOf('/')))(e.querySelector("a").href),
        subtitle: e.querySelector(".sub-title").innerText,
        });
        }
        let nextElement = document.querySelector("span.active").parentNode.nextElementSibling;
        let next = nextElement? nextElement.querySelector("a").href : "";
        let previousElement = document.querySelector("span.active").parentNode.previousElementSibling;
        let previous = previousElement? previousElement.querySelector("a").href : "";
        let r = { result, next, previous };
        r;
        `
        return SingletonWebView.loadUrl(url)
        .then(() => SingletonWebView.runScript(script))
        .then(result => {
                  result.result.map(value => {
                                        let t = value.subtitle.split('\n')
                                        value.watched = t[0].replace(" ", "")
                                        value.hearted = t[1].replace(" ", "")
                                    })
                  return result
              });
    }

    background: Item {}
    leftPadding: 0

    ScrollView {
        id: scrollView
        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff; ScrollBar.vertical.policy: ScrollBar.AsNeeded
        // FIXME: why availableWidth cause binding loop?
        // contentWidth: availableWidth
        contentWidth: width
        // To show cards shadows
        anchors { fill: parent; topMargin: 24 - layout.anchors.topMargin; leftMargin: -layout.anchors.leftMargin }
        GridLayout {
            id: layout
            // margins to show cards shadows
            anchors { left: parent.left; right: parent.right; top: parent.top; margins: 16; topMargin: 8 }
            columnSpacing: 12; rowSpacing: 12
            onWidthChanged: columns = Math.max(3, (width + rowSpacing) / (320 + rowSpacing))
            Repeater {
                model: ListModel { id: modelMovie }
                delegate: CardMoive {
                    Layout.fillWidth: true; Layout.alignment: Qt.AlignTop
                    onLeftClicked: {
                        root.movieSelected(movieID)
                    }

                    property var movieData: Session.movieCardData.get(movieID)
                    thumbSource: movieData.thumbSource
                    title: movieData.title
                    brief: `${movieData.watched}   ♥${movieData.hearted}`
                }
            }

            Item {
                Layout.columnSpan: parent.columns
                Layout.preferredHeight: 64; Layout.fillWidth: true

                RowLayout {
                    anchors { horizontalCenter: parent.horizontalCenter; top: parent.top }
                    spacing: 32
                    function clearPage() {
                        root.next = ""
                        root.previous = ""
                        modelMovie.clear()
                        scrollView.ScrollBar.vertical.position = 0
                    }

                    Button {
                        text: qsTr("Previous")
                        visible: root.previous
                        type: Button.Outlined
                        onClicked: {
                            root.address = root.previous
                            parent.clearPage()
                        }
                    }
                    Button {
                        text: qsTr("Next")
                        visible: root.next
                        onClicked: {
                            root.address = root.next
                            parent.clearPage()
                        }
                    }
                }
            }

            ProgressNetwork {
                id: progressNetwork
                Layout.columnSpan: parent.columns
                Layout.alignment: Qt.AlignHCenter
            }
        }
    }
}
