import QtQuick
import QtQuick.Controls
import MaterialYou
import MaterialYou.impl

ComboBox {
    id: comboBoxTitle

    model: [
        { key: "DanDanZan", value: "qrc:/SiteDandanzan.qml" },
        { key: "Jable", value: "qrc:/SiteJable.qml" },
    ]

    indicator: null

    textRole: "key"; valueRole: "value"

    contentItem: Label {
        text: comboBoxTitle.displayText
        MaterialYou.fontRole: MaterialYou.LabelSmall
        horizontalAlignment: Qt.AlignHCenter
        verticalAlignment: Qt.AlignVCenter
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
