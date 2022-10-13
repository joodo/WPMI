import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Window
import MaterialYou

StackView {
    id: root

    initialItem: stackHistory

    FieldSearch {
        id: fieldSearch
        opacity: root.currentItem instanceof StackMovieDetail? 0 : 1
        visible: opacity !== 0
        z: 1
        width: 300
        anchors { right: parent.right; rightMargin: 16 }
        placeholderText: qsTr("Search movies...")
        onSearch: query => {
                      if (!stackSearch.visible) {
                          root.replace(stackSearch, { query })
                      } else {
                          stackSearch.query = query
                      }
                  }
    }

    StackHistory {
        id: stackHistory
        visible: false
        onMovieSelected: movieID => root.push(componentMovieDetail.createObject(stackLayout, { movieID }))
    }

    StackSearch {
        id: stackSearch
        visible: false
        onMovieSelected: movieID => root.push(componentMovieDetail.createObject(stackLayout, { movieID }))

        StackView.onViewChanged: if (StackView.view) Session.backableItemStack.append(this)
        StackView.onRemoved: Session.backableItemStack.remove(Session.backableItemStack.count - 1)
        function back() { root.replace(stackHistory) }
    }

    Component {
        id: componentMovieDetail
        StackMovieDetail {
            Component.onCompleted: Session.backableItemStack.append(this)
            StackView.onRemoved: Session.backableItemStack.remove(Session.backableItemStack.count - 1)
            function back() { root.pop() }
        }
    }

    replaceEnter: Transition {
        NumberAnimation { property: "opacity"; from: 0.0; to: 1.0; duration: 200; easing.type: Easing.OutCubic }
    }

    replaceExit: Transition {
        NumberAnimation { property: "opacity"; from: 1.0; to: 0.0; duration: 200; easing.type: Easing.OutCubic }
    }
}
