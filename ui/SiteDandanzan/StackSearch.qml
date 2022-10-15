import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import MaterialYou

Page {
    id: root

    signal movieSelected(string movieID)

    property string next: ""

    function getResultFromSearch(url) {
        const script = `
        let result = [];
        for (let e of document.querySelectorAll('div.lists-content > ul > li')) result.push({
        title: e.querySelector("h2 > a").innerHTML,
        thumbSource: e.querySelector("img").src,
        year: e.querySelectorAll("div.countrie > span")[0].innerHTML,
        country: e.querySelectorAll("div.countrie > span")[1].innerHTML,
        rate: e.querySelector("footer > span.rate").innerHTML,
        url: e.querySelector("a").href,
        movieID: (url => url.substring(url.lastIndexOf("/") + 1, url.lastIndexOf(".")))(e.querySelector("a").href)
        });
        let e = document.querySelector("li.next-page > a");
        next = e? e.href : "";
        let r = { result, next };
        r;
        `
        return SingletonWebView.loadUrl(url).then(() => SingletonWebView.runScript(script))
    }

    property string query
    onQueryChanged: {
        modelMovie.clear()
        const url = `https://${Settings.resourceServer}/so/${query}-${query}--.html`;
        getResultFromSearch(url)
        .then(result => {
                  if ("next" in result) next = result.next
                  Session.updateMovieCardDataFromList(result.result)
                  result.result.map(value => modelMovie.append({ movieID : value.movieID }))
              })
        .catch(err => progressNetwork.retryWork = () => queryChanged());
    }

    background: null
    leftPadding: -16

    header: RowLayout {
        spacing: 8
        height: 48
        Label {
            text: qsTr("Search")
            MaterialYou.fontRole: MaterialYou.HeadlineMedium
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

        function getNextPage(url) {
            getResultFromSearch(url)
            .then(result => {
                      timerCooldown.start()
                      next = result.next
                      Session.updateMovieCardDataFromList(result.result)
                      result.result.map(value => modelMovie.append({ movieID : value.movieID }))
                  })
            .catch(err => progressNetwork.retryWork = () => getNextPage(url));
        }

        anchors {
            top: parent.top
            bottom: parent.bottom
        }

        Timer {
            interval: 500
            repeat: true
            running: visible
            triggeredOnStart: true
            onTriggered: scrollView.width = scrollView.parent.width
        }

        ScrollBar.vertical.onPositionChanged: {
            const position = ScrollBar.vertical.position + ScrollBar.vertical.visualSize
            if (root.next && !timerCooldown.running
                    && (1-position) * contentHeight < progressNetwork.parent.height) {
                getNextPage(root.next)
                root.next = ""
            }
        }
        Timer {
            id: timerCooldown
            interval: 1000
            repeat: false
            running: false
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
                model: ListModel { id: modelMovie }
                delegate: CardMoive {
                    width: layout.cellWidth
                    onLeftClicked: {
                        root.movieSelected(movieID)
                    }

                    property var movieData: Session.movieCardData.get(movieID)
                    thumbSource: movieData.thumbSource
                    title: movieData.title
                    brief: `${movieData.country}   ${movieData.year}`
                }
            }
            Item {
                width: parent.width; height: 128

                ProgressNetwork {
                    id: progressNetwork
                    anchors.centerIn: parent
                }
            }

            Item { width: parent.width; height: 16 }

            move: Transition { NumberAnimation { properties: "x,y"; duration: 200; easing.type: Easing.OutCubic } }
        }
    }
}
