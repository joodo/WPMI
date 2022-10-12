import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import WPMI

Object {
    Component.onCompleted: {
        children.push(WindowMain)
        children.push(WindowPlayer)

        HttpManager.timeout = 5000;
    }

    Window {
        id: windowWebView
        //visible: true
        width: 600; height: 480
        Component.onCompleted: SingletonWebView.parent = contentItem
    }
    Window {
        //visible: true
        width: 600; height: 480
        Component.onCompleted: LeanCloud.parent = contentItem
    }

    Window {
        //visible: true
        width: 600; height: 480

        DialogRoom {
            anchors.fill: parent
        }
    }

    UpdateChecker {}
}
