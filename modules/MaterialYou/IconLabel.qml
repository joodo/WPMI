import QtQuick
import QtQuick.Controls.impl as Impl
import MaterialYou

Impl.IconLabel {
    MaterialYou.foregroundColor: MaterialYou.OnSurface
    MaterialYou.fontRole: MaterialYou.BodyMedium
    color: MaterialYou.foregroundColor
    icon.color: MaterialYou.foregroundColor
    font: MaterialYou.font(MaterialYou.fontRole)
}
