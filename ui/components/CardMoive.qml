import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Qt5Compat.GraphicalEffects

import MaterialYou
import MaterialYou.impl

Pane {
    id: root
    implicitHeight: paneContentItem.implicitHeight

    signal leftClicked()
    signal rightClicked()
    property alias thumbSource: image.source
    property alias title: labelTitle.text
    property alias brief: labelBrief.text

    padding: 0
    MaterialYou.elevation: mouseArea.containsMouse && !mouseArea.pressed? 2 : 1

    Item {
        id: paneContentItem
        width: parent.width
        implicitHeight: layout.height

        ColumnLayout {
            id: layout
            width: parent.width
            spacing: 0
            Image {
                id: image
                Layout.fillWidth: true
                Layout.preferredHeight: width / sourceSize.width * sourceSize.height
                fillMode: Image.PreserveAspectFit
            }

            Label {
                id: labelTitle
                Layout.fillWidth: true
                Layout.leftMargin: 16; Layout.rightMargin: 16; Layout.topMargin: 12
                elide: Text.ElideRight
                wrapMode: Text.Wrap
                //maximumLineCount: 2
                MaterialYou.fontRole: MaterialYou.TitleSmall
            }
            Label {
                id: labelBrief
                Layout.fillWidth: true
                Layout.margins: 16; Layout.topMargin: 0
                elide: Text.ElideRight
                MaterialYou.fontRole: MaterialYou.LabelSmall
                color: MaterialYou.color(MaterialYou.OnSurfaceVariant)
            }
        }

        layer.enabled: true
        layer.effect: OpacityMask {
            maskSource: Rectangle {
                x: root.x; y:root.y
                width: root.width; height: root.height
                radius: root.MaterialYou.radius
            }
        }
    }

    StatusLayer {
        anchors.fill: parent
        radius: root.MaterialYou.radius
        status: mouseArea.pressed? MaterialYou.Press : mouseArea.containsMouse? MaterialYou.Hover : MaterialYou.Normal
    }

    MouseArea {
        id: mouseArea
        hoverEnabled: true
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: mouse => {
                       switch (mouse.button) {
                       case Qt.LeftButton:
                           root.leftClicked()
                           break
                       case Qt.RightButton:
                           root.rightClicked()
                           break
                       }
                   }
    }
}
