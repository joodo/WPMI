import Qt5Compat.GraphicalEffects
import MaterialYou
import QtQuick.Controls.Material.impl as Impl
// TODO: implement ElevationEffect
// Glow active strange under Windows Qt 6.4
/*
Glow {
    property int elevation: 0

    radius: elevation * 2
    spread: 0.05
    //color: MaterialYou.color(MaterialYou.Shadow)
    color: "#60000000"
    transparentBorder: true
}
*/
Impl.ElevationEffect {

}
