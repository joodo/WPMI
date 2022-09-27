import QtQuick
import MaterialYou

Rectangle {
    property int colorRole: MaterialYou.Primary
    property int status: MaterialYou.Normal
    color: MaterialYou.color(colorRole)
    opacity: [0, 0.08, 0.12, 0.12, 0.16][status>4 || status<0? 0 : status]
    Behavior on opacity { NumberAnimation { duration: 500; easing.type: Easing.OutCubic }}
}
