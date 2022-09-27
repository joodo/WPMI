import Qt5Compat.GraphicalEffects
import MaterialYou

Glow {
    property int elevation: 0

    radius: elevation * 2
    spread: 0.05
    //color: MaterialYou.color(MaterialYou.Shadow)
    color: "#60000000"
    transparentBorder: true
}
