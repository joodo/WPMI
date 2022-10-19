import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import MaterialYou

Page {
    id: root

    signal movieSelected(string movieID)

    property string next: ""

    function getResultFromSearch(url) {
        return siteDandanzan.dataService.search(url).then(r => JSON.parse(r));
    }

    property string query
    onQueryChanged: {
        progressNetwork.state = "loading"
        modelMovie.clear()
        const url = `https://${Settings.resourceServer}/so/${query}-${query}--.html`;
        getResultFromSearch(url)
        .then(result => {
                  if ("next" in result) next = result.next
                  Session.updateMovieCardDataFromList(result.result)
                  result.result.map(value => modelMovie.append({ movieID : value.movieID }))
                  progressNetwork.state = next? "loading" : "hide"
              })
        .catch(err => {
                   progressNetwork.retryWork = () => queryChanged()
                   progressNetwork.state = "failed"
               });
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
            progressNetwork.state = "loading"
            getResultFromSearch(url)
            .then(result => {
                      timerCooldown.start()
                      next = result.next
                      Session.updateMovieCardDataFromList(result.result)
                      result.result.map(value => modelMovie.append({ movieID : value.movieID }))
                      progressNetwork.state = "hide"
                  })
            .catch(err => {
                       progressNetwork.retryWork = () => getNextPage(url)
                       progressNetwork.state = "failed"
                   });
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
                    && (1-position) * contentHeight < progressNetwork.height) {
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

            ProgressNetwork {
                id: progressNetwork
                width: parent.width; height: 128
            }

            Item { width: parent.width; height: 16 }

            // animation will cause crash when scroll up from lots of card
            //move: Transition { NumberAnimation { properties: "x,y"; duration: 200; easing.type: Easing.OutCubic } }
        }
    }
}
