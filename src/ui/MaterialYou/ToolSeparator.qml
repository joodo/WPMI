import QtQuick
import QtQuick.Templates as T
import MaterialYou

T.ToolSeparator {
    id: control

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             implicitContentHeight + topPadding + bottomPadding)


    MaterialYou.foregroundColor: MaterialYou.OnSurfaceVariant

    contentItem: Rectangle {
        implicitWidth: control.vertical ? 1 : 38
        implicitHeight: control.vertical ? 38 : 1
        color: control.MaterialYou.foregroundColor
    }
}
