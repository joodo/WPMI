import QtQuick
import QtQuick.Templates as T
import MaterialYou

T.ToolBar {
    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             implicitContentHeight + topPadding + bottomPadding)

    background: Rectangle {
        color: MaterialYou.color(MaterialYou.Surface)
    }
}
