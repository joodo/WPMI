import QtQuick
import QtQuick.Templates as T
import QtQuick.Controls.Material.impl
import QtQuick.Shapes
import MaterialYou

T.ProgressBar {
    id: control

    onIndeterminateChanged: if (indeterminate) console.warn("Progress Bar: indeterminate is disabled in MaterialYou. It should be complemented in BusyIndicator")

    enum ProgressBarType {
        Linear,
        Circular
    }
    property int type: ProgressBar.Linear

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset)

    property int barWidth: 4
    Behavior on barWidth { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }

    MaterialYou.foregroundColor: MaterialYou.Primary
    MaterialYou.backgroundColor: MaterialYou.SurfaceVariant

    contentItem: Item {
        implicitWidth: control.type===ProgressBar.Linear? 200 : 48
        implicitHeight: control.type===ProgressBar.Linear? control.barWidth : 48
        Rectangle {
            visible: control.type === ProgressBar.Linear
            anchors.verticalCenter: parent.verticalCenter
            height: control.barWidth
            width: control.width*control.position

            scale: control.mirrored ? -1 : 1
            color: control.MaterialYou.foregroundColor
        }
        Shape {
            id: shape
            visible: control.type === ProgressBar.Circular
            anchors.centerIn: parent
            readonly property int size: 32
            //width: size; height: size
            ShapePath {
                startX: 0; startY: -shape.size/2
                strokeColor: control.MaterialYou.foregroundColor
                strokeWidth: control.barWidth
                fillColor: "transparent"
                capStyle: ShapePath.FlatCap

                PathArc {
                    property real arc: control.position * 2 * Math.PI - 0.0001
                    relativeX: Math.sin(arc)*shape.size/2; relativeY: shape.size/2 - Math.cos(arc)*shape.size/2
                    radiusX: shape.size/2; radiusY: shape.size/2
                    useLargeArc: control.position > 0.5
                }
            }
        }
        layer.enabled: true
        layer.samples: 4
    }

    background: Rectangle {
        implicitWidth: control.type===ProgressBar.Linear? 200 : 48
        implicitHeight: control.type===ProgressBar.Linear? control.barWidth : 48
        y: (control.height - height) / 2

        color: control.type===ProgressBar.Linear? control.MaterialYou.backgroundColor : "transparent"
        radius: control.MaterialYou.radius
    }
}
