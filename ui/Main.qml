import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import MaterialYou
import WPMI

Object {
    Component.onCompleted: {
        children.push(WindowMain)
        children.push(WindowPlayer)

        HttpManager.timeout = 5000;

        Backend.setProxy(Settings.proxy)
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

    ApplicationWindow {
        //visible: true
        width: 600; height: 480

        Snackbar {
            id: snack
            text: "Ha hais besal ldlakjtheg."
            actionText: "Undo"
            anchors.centerIn: parent
        }

        Button {
            text: "show"
            onClicked: snack.show()
        }
    }

    UpdateChecker {}
}
