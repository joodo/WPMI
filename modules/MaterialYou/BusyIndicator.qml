import QtQuick
import QtQuick.Templates as T
import QtQuick.Controls.Material.impl
import MaterialYou

T.BusyIndicator {
    id: control

    enum BusyIndicatorType {
        Linear,
        Circular
    }
    property int type: BusyIndicator.Circular

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             implicitContentHeight + topPadding + bottomPadding)

    padding: type === BusyIndicator.Circular? 6 : 0

    MaterialYou.foregroundColor: MaterialYou.Primary
    MaterialYou.backgroundColor: MaterialYou.SurfaceVariant

    contentItem: type === BusyIndicator.Circular? componentCircular.createObject(this) : componentLinear.createObject(this)
    background: type === BusyIndicator.Circular? null : componentLinearBackground.createObject(this)

    Component {
        id: componentLinear
        ProgressBarImpl {
            implicitWidth: 200
            implicitHeight: 4
            indeterminate: true
            color: control.MaterialYou.foregroundColor
        }
    }

    Component {
        id: componentLinearBackground
        Rectangle {
            implicitWidth: 200
            implicitHeight: 4
            y: (control.height - height) / 2
            height: 4
            color: control.MaterialYou.backgroundColor
        }
    }

    Component {
        id: componentCircular
        BusyIndicatorImpl {
            implicitWidth: 48
            implicitHeight: 48
            color: control.MaterialYou.foregroundColor
            running: control.running
            opacity: control.running ? 1 : 0
            Behavior on opacity { OpacityAnimator { duration: 250 } }
        }
    }
}
