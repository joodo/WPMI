import QtQuick
import QtQuick.Templates as T
import MaterialYou

T.ApplicationWindow {
    id: window

    MaterialYou.backgroundColor: MaterialYou.Background
    color: MaterialYou.backgroundColor

    background: MouseArea {
        onClicked: forceActiveFocus()
    }
}
