import QtQuick
import QtQuick.Templates as T
import QtQuick.Controls
import QtQuick.Controls.impl
import QtQuick.Controls.Material
import QtQuick.Controls.Material.impl
import MaterialYou 1.0

T.TabButton {
    id: control

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            implicitContentWidth + leftPadding + rightPadding, 96)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             implicitContentHeight + topPadding + bottomPadding)

    topPadding: 16; bottomPadding: 16
    spacing: 8
    display: AbstractButton.TextUnderIcon
    hoverEnabled: true

    icon.width: 24
    icon.height: 24
    icon.color: control.checked? MaterialYou.color["on-secondary-container"] : MaterialYou.color["on-surface-variant"]

    contentItem: IconLabel {
        spacing: control.spacing
        mirrored: control.mirrored
        display: control.display

        Rectangle {
            z: -1
            width: 64; height: 32
            radius: height
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.children[1].verticalCenter
            color: control.checked? MaterialYou.color["secondary-container"] : "transparent"

            Rectangle {
                anchors.fill: parent
                radius: parent.radius
                color: control.checked? MaterialYou.color["on-surface"] : MaterialYou.color["on-surface-variant"]
                opacity: control.pressed? MaterialYou.opacity["pressed"] : control.hovered? MaterialYou.opacity["hovered"] : 0
            }
        }

        icon: control.icon
        text: control.text
        font: control.font
        color: control.checked? MaterialYou.color["on-surface"] : MaterialYou.color["on-surface-variant"]
    }
}
