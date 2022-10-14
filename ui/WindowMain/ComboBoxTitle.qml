import QtQuick
import QtQuick.Controls
import MaterialYou
import MaterialYou.impl

ComboBox {
    id: comboBoxTitle

    textRole: "key"; valueRole: "value"
    model: [
        { key: "DanDanZan", value: "qrc:/SiteDandanzan.qml" },
        { key: "Jable", value: "qrc:/SiteJable.qml" },
    ]

    indicator: null

    contentItem: IconLabel {
        text: comboBoxTitle.displayText
        MaterialYou.fontRole: MaterialYou.LabelSmall
        spacing: 4
        icon {
            source: Settings.proxy !== "[none]"? "qrc:/global.svg" : ""
            width: 12; height: 12
            color: MaterialYou.color(MaterialYou.Tertiary)
        }
    }

    background: StatusLayer {
        visible: comboBoxTitle.enabled
        implicitWidth: 120
        implicitHeight: 20
        radius: height
        status: comboBoxTitle.down? MaterialYou.Press : comboBoxTitle.hovered? MaterialYou.Hover : comboBoxTitle.visualFocus? MaterialYou.Focus : MaterialYou.Normal
        MaterialYou.foregroundColor: MaterialYou.OnSurface
    }
}
