import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import MaterialYou

RowLayout {
    id: root

    property var retryWork: null

    property bool idle: !label.visible

    BusyIndicator {
        id: progressBar
        visible: SingletonWebView.loadProgress < 100
        Layout.alignment: Qt.AlignVCenter
        //from: 0; to: 110; value: SingletonWebView.loadProgress + 10
        //type: ProgressBar.Circular
    }

    Label {
        id: label
        visible: progressBar.visible || buttonRetry.visible
        Layout.alignment: Qt.AlignVCenter
        text: SingletonWebView.loading? qsTr("Loading...") : qsTr("Can't seem to load right now.")
        MaterialYou.foregroundColor: SingletonWebView.loading? MaterialYou.OnSurfaceVariant : MaterialYou.Error
        verticalAlignment: Text.AlignVCenter
    }

    Chip {
        id: buttonRetry
        visible: (SingletonWebView.loadStatus === SingletonWebView.LoadFailedStatus
                  || SingletonWebView.loadStatus === SingletonWebView.LoadStoppedStatus)
        Layout.alignment: Qt.AlignVCenter; Layout.leftMargin: 16
        text: qsTr("Retry")
        MaterialYou.foregroundColor: MaterialYou.Error
        onClicked: root.retryWork()
    }
}
