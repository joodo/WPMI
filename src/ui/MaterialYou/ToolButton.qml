// https://m3.material.io/components/icon-buttons/overview

import QtQuick
import QtQuick.Templates as T
import QtQuick.Controls.impl
import MaterialYou
import MaterialYou.impl

T.ToolButton {
    id: control

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             implicitContentHeight + topPadding + bottomPadding)

    bottomInset: 8; topInset: 8; leftInset: 8; rightInset: 8

    MaterialYou.radius: 40
    MaterialYou.foregroundColor: MaterialYou.OnSurfaceVariant
    MaterialYou.backgroundColor: MaterialYou.Primary

    icon.width: 24
    icon.height: 24
    icon.color: !control.enabled ? MaterialYou.color(MaterialYou.OnSurface) :
                                   control.checked || control.highlighted ? control.MaterialYou.backgroundColor : control.MaterialYou.foregroundColor

    contentItem: IconLabel {
        spacing: control.spacing
        mirrored: control.mirrored
        display: control.display

        icon: control.icon
        text: control.text
        font: control.font
        color: !control.enabled ? MaterialYou.color(MaterialYou.OnSurface) :
                                  control.checked || control.highlighted ? control.MaterialYou.backgroundColor : control.MaterialYou.foregroundColor
    }

    background: StatusLayer {
        implicitWidth: 40; implicitHeight: 40
        radius: control.MaterialYou.radius

        MaterialYou.foregroundColor: control.checked? control.MaterialYou.backgroundColor : control.MaterialYou.foregroundColor
        status: control.down? MaterialYou.Press : control.hovered? MaterialYou.Hover : control.visualFocus? MaterialYou.Focus : MaterialYou.Normal
    }
}
