import QtQuick
import QtQuick.Layouts
import MaterialYou

Pane {
    id: control

    signal actionTriggered()
    onActionTriggered: hide()

    signal hidden()

    property alias text: label.text
    property alias actionText: button.text

    function show() {
        timerHide.start()
        opacity = 1
    }

    function hide() {
        timerHide.stop()
        opacity = 0
    }

    visible: opacity !== 0
    opacity: 0
    onOpacityChanged: if (opacity === 0) hidden()
    Behavior on opacity {
        NumberAnimation {
            duration: 200
            easing.type: Easing.OutCubic
        }
    }

    MaterialYou.radius: 4
    MaterialYou.elevation: 4
    MaterialYou.backgroundColor: MaterialYou.SecondaryContainer
    verticalPadding: 8
    leftPadding: 16
    rightPadding: actionText? 8 : 16

    RowLayout {
        anchors.fill: parent
        spacing: 4
        Label {
            id: label
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            verticalAlignment: Text.AlignVCenter
            wrapMode: Text.Wrap
            //MaterialYou.fontRole: MaterialYou.LabelMedium
        }
        Button {
            id: button
            flat: true
            visible: text
            onClicked: control.actionTriggered()
        }
    }

    hoverEnabled: true
    onHoveredChanged: hovered? timerHide.stop() : timerHide.start()

    Timer {
        id: timerHide
        interval: 4000
        onTriggered: control.hide()
    }
}
