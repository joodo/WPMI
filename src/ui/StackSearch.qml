import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Qt.labs.settings
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
        const url = `https://${settings.value("resourceServer")}/so/${query}-${query}--.html`;
        print(url)
        getResultFromSearch(url)
        .then(result => {
                  if ("next" in result) next = result.next
                  SingletonState.updateMovieCardDataFromList(result.result)
                  result.result.map(value => modelMovie.append({ movieID : value.movieID }))
              })
        .catch(err => progressNetwork.retryWork = () => queryChanged());
    }

    background: Item {}
    leftPadding: 0

    ScrollView {
        function getNextPage(url) {
            getResultFromSearch(url)
            .then(result => {
                      timerCooldown.start()
                      next = result.next
                      SingletonState.updateMovieCardDataFromList(result.result)
                      result.result.map(value => modelMovie.append({ movieID : value.movieID }))
                  })
            .catch(err => progressNetwork.retryWork = () => getNextPage(url));
        }

        ScrollBar.vertical.onPositionChanged: {
            const position = ScrollBar.vertical.position + ScrollBar.vertical.visualSize
            if (!timerCooldown.running && (1-position) * contentHeight < 50 && root.next) {
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
        // To show cards shadows
        anchors { fill: parent; topMargin: 12; leftMargin: -layout.anchors.margins }
        contentWidth: availableWidth; contentHeight: layout.implicitHeight + 3*layout.anchors.margins
        ColumnLayout {
            id: layout
            spacing: 12
            // margins to show cards shadows
            anchors { left: parent.left; right: parent.right; top: parent.top; margins: 16; topMargin: 12 }
            Flow {
                id: flow
                property int _rowCount
                Layout.fillWidth: true
                spacing: 12
                onWidthChanged: _rowCount = Math.max(4, (width + spacing) / (180 + spacing))
                Repeater {
                    model: ListModel { id: modelMovie }
                    delegate: CardMoive {
                        onClicked: mouse => {
                                       if (mouse.button === Qt.LeftButton) root.movieSelected(movieID)
                                   }

                        movieData: SingletonState.movieCardData.get(movieID)
                        width: (flow.width - (flow._rowCount-1)*flow.spacing) / flow._rowCount
                    }
                }
            }
            ProgressNetwork {
                id: progressNetwork
                Layout.alignment: Qt.AlignHCenter
            }
        }
    }

    Settings { id: settings }
}
