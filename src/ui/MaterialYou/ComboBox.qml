import QtQuick
import QtQuick.Window
import QtQuick.Controls.impl
import QtQuick.Templates as T
import MaterialYou
import MaterialYou.impl

T.ComboBox {
    id: control

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             implicitContentHeight + topPadding + bottomPadding)

    leftPadding: padding + (!control.mirrored || !indicator || !indicator.visible ? 0 : indicator.width + spacing)
    rightPadding: padding + (control.mirrored || !indicator || !indicator.visible ? 0 : indicator.width + spacing)

    delegate: MenuItem {
        width: ListView.view.width
        text: control.textRole ? (Array.isArray(control.model) ? modelData[control.textRole] : model[control.textRole]) : modelData
        MaterialYou.foregroundColor: control.currentIndex === index ? MaterialYou.Primary : MaterialYou.OnSurfaceVariant
        highlighted: control.highlightedIndex === index
        hoverEnabled: control.hoverEnabled
    }

    indicator: ColorImage {
        x: control.mirrored ? control.padding : control.width - width - control.padding
        y: control.topPadding + (control.availableHeight - height) / 2
        color: contentItem.color
        source: "qrc:/qt-project.org/imports/QtQuick/Controls/Material/images/drop-indicator.png"
    }

    contentItem: T.TextField {
        padding: 6
        leftPadding: control.editable ? 2 : control.mirrored ? 0 : 16
        rightPadding: control.editable ? 2 : control.mirrored ? 16 : 0

        text: control.editable ? control.editText : control.displayText

        enabled: control.editable
        autoScroll: control.editable
        readOnly: control.down
        inputMethodHints: control.inputMethodHints
        validator: control.validator
        selectByMouse: control.selectTextByMouse

        font: control.font
        color: control.enabled ? MaterialYou.color(MaterialYou.OnSurface) : MaterialYou.color(MaterialYou.OnSurfaceVariant)
        selectionColor: MaterialYou.color(MaterialYou.Primary)
        selectedTextColor: MaterialYou.color(MaterialYou.OnPrimary)
        verticalAlignment: Text.AlignVCenter
    }

    background: Rectangle {
        implicitWidth: 120
        implicitHeight: 40

        radius: 4
        color: "transparent"
        border { width: 1; color: MaterialYou.color(MaterialYou.Outline) }

        StatusLayer {
            anchors.fill: parent
            radius: parent.radius
            status: control.down? MaterialYou.Press : control.hovered? MaterialYou.Hover : control.visualFocus? MaterialYou.Focus : MaterialYou.Normal
            MaterialYou.foregroundColor: MaterialYou.OnSurface
        }
    }

    popup: Menu {
        y: control.editable ? control.height - 5 : -12 - 48*control.currentIndex
        width: control.width
        height: Math.min(contentItem.implicitHeight+16, control.Window.height - topMargin - bottomMargin)
        transformOrigin: Item.Top
        topMargin: 12
        bottomMargin: 12

        contentItem: ListView {
            clip: true
            implicitHeight: contentHeight
            model: control.delegateModel
            currentIndex: control.highlightedIndex
            highlightMoveDuration: 0

            ScrollIndicator.vertical: ScrollIndicator { }
        }
    }
}
