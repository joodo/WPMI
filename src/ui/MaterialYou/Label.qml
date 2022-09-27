import QtQuick
import QtQuick.Templates as T
import MaterialYou

T.Label {
    id: control

    MaterialYou.foregroundColor: MaterialYou.OnSurface
    MaterialYou.fontRole: MaterialYou.BodyMedium

    color: MaterialYou.foregroundColor
    linkColor: MaterialYou.color(MaterialYou.primary)
    font: MaterialYou.font(MaterialYou.fontRole)
    lineHeight: MaterialYou.lineHeight(MaterialYou.fontRole)
}
