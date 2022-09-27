pragma Singleton

import QtQuick
import Qt.labs.settings

QtObject {
    id: root

    readonly property ListModel history: ListModel {}  // key: movieID; value: movieID, timestamp, playlistID, episodeID
    function historyIndexOf(movieID) {
        for (let i = 0; i < history.count; i++) {
            if (history.get(i).movieID === movieID)
                return i
        }
        return -1
    }
    function updateHistory(newHistory) {
        let p = historyIndexOf(newHistory.movieID)
        if (p < 0) {
            history.insert(0, newHistory)
        } else {
            history.move(p, 0, 1)
            history.set(0, newHistory)
        }
    }

    readonly property var movieCardData: new Map()  // key: movieID; value: movieID, title, thumbSource, year, country, rate, url
    function updateMovieCardDataFromList(dataList) {
        dataList.map(value => movieCardData.set(value.movieID, value))
    }


    Component.onCompleted: {
        const storageState = JSON.parse(settings.state)
        storageState.historyList.map(value => history.append(value))
        storageState.movieCardDataList.map(value => value && movieCardData.set(value.movieID, value))
    }
    Component.onDestruction: {
        let historyList = []
        let movieCardDataList = []
        for (let i = 0; i < history.count; i++) {
            historyList.push(history.get(i))
            movieCardDataList.push(movieCardData.get(history.get(i).movieID))
        }
        settings.state = JSON.stringify({ historyList, movieCardDataList })
    }

    property var settings: Settings {
        property string state: ""
    }
}
