import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Window

MouseArea {
    property point pos
    onPressed: mouse => pos = Qt.point(mouse.x, mouse.y)
    onPositionChanged: mouse => {
        var diff = Qt.point(mouse.x - pos.x, mouse.y - pos.y)
        ApplicationWindow.window.x += diff.x
        ApplicationWindow.window.y += diff.y
    }
}
