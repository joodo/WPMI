import QtQuick

MouseArea {
    property point pos
    onPressed: mouse => {
                   forceActiveFocus()  // No business with dragging, for focus behavior
                   pos = Qt.point(mouse.x, mouse.y)
               }
    onPositionChanged: mouse => {
                           if (!pressed) return
                           const diff = Qt.point(mouse.x - pos.x, mouse.y - pos.y)
                           Window.window.x += diff.x
                           Window.window.y += diff.y
                       }
}
