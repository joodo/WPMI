import QtQuick
import QtQuick.Templates as T
import MaterialYou

T.ToolBar {
    id: control
    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             implicitContentHeight + topPadding + bottomPadding)

    MaterialYou.backgroundColor: MaterialYou.Surface
    background: Rectangle {
        color: control.MaterialYou.backgroundColor
    }
}
