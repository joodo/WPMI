import QtQuick
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
import MaterialYou

Pane {
    id: pane
    property Item blurItem
    background: Item {
        id: itemBackground
        ShaderEffectSource {
            id: effectSource
            sourceItem: pane.blurItem
            anchors.fill: parent
            sourceRect: Qt.rect(pane.x, pane.y, pane.width, pane.height)
            visible: false
        }
        FastBlur {
            id: effectBlur
            radius: 30
            source: effectSource
            anchors.fill: parent
            visible: false
        }
        OpacityMask {
            source: effectBlur
            anchors.fill: parent
            maskSource: Rectangle {
                width: pane.width; height: pane.height
                radius: pane.MaterialYou.radius
            }
        }
        Rectangle {
            anchors.fill: parent
            color: pane.MaterialYou.backgroundColor
            radius: pane.MaterialYou.radius
            opacity: 0.7
        }
    }
}
