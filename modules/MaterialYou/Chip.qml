import QtQuick
import QtQuick.Templates as T
import QtQuick.Controls.impl
import MaterialYou
import MaterialYou.impl

T.Button {
    id: control

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: 32

    icon.width: 18
    icon.height: 18

    rightPadding: 16; leftPadding: icon.name!=="" || icon.source!=""? 8 : 16
    spacing: 8

    MaterialYou.fontRole: MaterialYou.LabelLarge
    font: MaterialYou.font(MaterialYou.fontRole)

    contentItem: IconLabel {
        spacing: control.spacing
        mirrored: control.mirrored
        display: IconLabel.TextBesideIcon

        icon {
            width: control.icon.width; height: control.icon.height
            color: MaterialYou.color(enabled? MaterialYou.Primary : MaterialYou.OnSurface)
            source: control.icon.source
            name: control.icon.name
        }
        text: control.text
        font: control.font
        color: MaterialYou.color(MaterialYou.OnSurface)
        opacity: control.enabled? 1 : 0.38
    }

    background: Rectangle {
        implicitWidth: 64
        implicitHeight: control.implicitHeight
        radius: 4
        color: control.checked? MaterialYou.color(MaterialYou.SecondaryContainer) : "transparent"
        opacity: enabled? 1 : 0.12
        border { width: control.checked? 0 : 1; color: MaterialYou.color(MaterialYou.Outline) }

        layer.enabled: control.enabled && control.MaterialYou.elevation>0
        layer.effect: ElevationEffect { elevation: control.MaterialYou.elevation }

        StatusLayer {
            anchors.fill: parent
            radius: parent.radius
            status: control.down? MaterialYou.Press : control.hovered? MaterialYou.Hover : control.visualFocus? MaterialYou.Focus : MaterialYou.Normal
            MaterialYou.foregroundColor: MaterialYou.OnSurface
        }
    }
}
