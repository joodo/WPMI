import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Window
import MaterialYou

StackView {
    id: root

    property bool backable: depth>1 || stackLayout.currentIndex>0
    function back() {
        if (depth > 1) {
            pop()
        } else if (stackLayout.currentIndex > 0) {
            stackLayout.currentIndex -= 1
        }
    }

    initialItem: Page {
        MaterialYou.backgroundColor: "transparent"
        header: Control {
            implicitHeight: fieldSearch.implicitHeight
            HandlerWindowDrag {
                z: -1
                anchors.fill: parent
            }
            FieldSearch {
                id: fieldSearch
                width: Math.min(parent.width - parent.rightPadding, 300)
                placeholderText: qsTr("Search movies...")
                onSearch: query => {
                              stackLayout.currentIndex = 1
                              stackSearch.query = query
                          }
            }
        }

        StackLayout {
            id: stackLayout
            anchors.fill: parent
            StackHistory {
                id: stackHistory
                onMovieSelected: movieID => root.push(componentMovieDetail.createObject(stackLayout, { movieID }))
            }

            StackSearch {
                id: stackSearch
                onMovieSelected: movieID => root.push(componentMovieDetail.createObject(stackLayout, { movieID }))
            }
        }
    }

    Component {
        id: componentMovieDetail
        StackMovieDetail {
            StackView.onRemoved: destroy()
        }
    }
}
