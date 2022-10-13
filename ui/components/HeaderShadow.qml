import QtQuick
import QtQuick.Controls
import MaterialYou

Item {
    width: Window.width
    height: 100
    clip: true
    Pane {
        MaterialYou.elevation: 4
        MaterialYou.radius: 2
        height: 10
        y: -height
        width: parent.width
    }
}
