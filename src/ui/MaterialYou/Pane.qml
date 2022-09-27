import QtQuick
import QtQuick.Templates as T
import Qt5Compat.GraphicalEffects
import MaterialYou
import MaterialYou.impl

T.Pane {
    id: control

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             implicitContentHeight + topPadding + bottomPadding)
    MaterialYou.radius: 12
    MaterialYou.backgroundColor: MaterialYou.Surface
    padding: 16

    background: Rectangle {
        color: control.MaterialYou.backgroundColor
        radius: control.MaterialYou.radius

        layer.enabled: control.enabled && control.MaterialYou.elevation > 0
        layer.effect: ElevationEffect {
            elevation: control.MaterialYou.elevation
        }
    }
}
