import QtQuick
import QtQuick.Templates as T
import QtQuick.Controls.impl
import MaterialYou
import MaterialYou.impl

T.Button {
    id: control

    enum ButtonType {
        Elevated,
        Filled,
        Tonal,
        Outlined,
        Text
    }

    property int type: Button.Filled
    property int tonedRole: MaterialYou.SecondaryContainer

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             implicitContentHeight + topPadding + bottomPadding)

    spacing: 8

    icon.width: 18
    icon.height: 18

    leftPadding: type===Button.ButtonType.Text || flat? 12 : icon.name!="" || icon.source!=""? 16 : 24
    rightPadding: type===Button.ButtonType.Text || flat? 12 : 24

    MaterialYou.fontRole: MaterialYou.LabelLarge
    font: MaterialYou.font(MaterialYou.fontRole)

    MaterialYou.elevation: [
        control.hovered && !control.down? 2 : 1,  // Elevated
        control.hovered && !control.down? 1 : 0,  // Filled
        control.hovered && !control.down? 1 : 0,  // Tonal
        0,  // Outlined
        0  // Text
    ][flat? 4 : control.type]

    MaterialYou.foregroundColor: [
        MaterialYou.Primary,  // Elevated
        MaterialYou.OnPrimary,  // Filled
        MaterialYou.OnSurface,  // Tonal
        MaterialYou.Primary,  // Outlined
        MaterialYou.Primary  // Text
    ][flat? 4 : control.type]
    MaterialYou.backgroundColor: [
        MaterialYou.Surface,  // Elevated
        MaterialYou.Primary,  // Filled
        control.tonedRole,  // Tonal
        "transparent",  // Outlined
        "transparent"  // Text
    ][flat? 4 : control.type]

    contentItem: IconLabel {
        spacing: control.spacing
        mirrored: control.mirrored
        display: IconLabel.TextBesideIcon

        readonly property color _foregroundColor: MaterialYou.color(!control.enabled? MaterialYou.OnSurface : control.MaterialYou.foregroundColor)

        icon { width: control.icon.width; height: control.icon.height; color: _foregroundColor; source: control.icon.source; name: control.icon.name }
        text: control.text
        font: control.font
        color: _foregroundColor
    }

    background: Rectangle {
        implicitWidth: 64
        implicitHeight: 40
        radius: height
        color: MaterialYou.color([
                                     control.enabled? control.MaterialYou.backgroundColor : MaterialYou.OnSurface,  // Elevated
                                     control.enabled? control.MaterialYou.backgroundColor : MaterialYou.OnSurface,  // Filled
                                     control.enabled? control.MaterialYou.backgroundColor : MaterialYou.OnSurface,  // Tonal
                                     control.MaterialYou.backgroundColor,  // Outlined
                                     control.MaterialYou.backgroundColor  // Text
                                 ][flat? 4 : control.type])
        opacity: enabled? 1 : 0.12
        border { width: control.type==Button.Outlined? 1 : 0; color: MaterialYou.color(MaterialYou.Outline) }

        layer.enabled: control.enabled && control.MaterialYou.elevation>0
        layer.effect: ElevationEffect { elevation: control.MaterialYou.elevation }

        StatusLayer {
            anchors.fill: parent
            radius: parent.radius
            status: control.down? MaterialYou.Press : control.hovered? MaterialYou.Hover : control.visualFocus? MaterialYou.Focus : MaterialYou.Normal
            MaterialYou.foregroundColor: control.type===Button.Tonal && !flat ? MaterialYou.onFromBackground(control.tunedRole) : control.MaterialYou.foregroundColor
        }
    }

    focusPolicy: Qt.StrongFocus
}
