import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Window
import MaterialYou

StackView {
    id: root

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

                StackLayout.onIsCurrentItemChanged: {
                    if (StackLayout.isCurrentItem) {
                        SingletonState.backableItemStack.append(this)
                    } else {
                        SingletonState.backableItemStack.remove(SingletonState.backableItemStack.count - 1)
                    }
                }
                function back() {
                    stackLayout.currentIndex -= 1
                }
            }
        }
    }

    Component {
        id: componentMovieDetail
        StackMovieDetail {
            StackView.onActivated: SingletonState.backableItemStack.append(this)
            StackView.onDeactivated: SingletonState.backableItemStack.remove(SingletonState.backableItemStack.count - 1)
            function back() {
                root.pop()
            }
        }
    }
}
