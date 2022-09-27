// https://m3.material.io/components/icon-buttons/overview

import QtQuick
import QtQuick.Templates as T
import QtQuick.Controls
import QtQuick.Controls.impl
import MaterialYou
import MaterialYou.impl

T.ToolButton {
    id: control

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             implicitContentHeight + topPadding + bottomPadding)

    padding: 8
    spacing: 4

    icon.width: 24
    icon.height: 24
    icon.color: !control.enabled ? MaterialYou.color(MaterialYou.OnSurface) :
                                   control.checked || control.highlighted ? MaterialYou.color(MaterialYou.Primary) : MaterialYou.color(MaterialYou.OnSurfaceVariant)

    contentItem: IconLabel {
        spacing: control.spacing
        mirrored: control.mirrored
        display: control.display

        icon: control.icon
        text: control.text
        font: control.font
        color: !control.enabled ? MaterialYou.color(MaterialYou.OnSurface) :
                                  control.checked || control.highlighted ? MaterialYou.color(MaterialYou.Primary) : MaterialYou.color(MaterialYou.OnSurfaceVariant)
    }

    background: Item {
        implicitWidth: 48
        implicitHeight: 48

        StatusLayer {
            anchors.centerIn: parent
            implicitWidth: 40; implicitHeight: 40; radius: 40

            colorRole: control.checked? MaterialYou.Primary : MaterialYou.OnSurfaceVariant
            status: control.down? MaterialYou.Press : control.hovered? MaterialYou.Hover : control.visualFocus? MaterialYou.Focus : MaterialYou.Normal
        }
    }
}
