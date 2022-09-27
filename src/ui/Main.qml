import QtQuick
import QtQuick.Controls

QtObject {
    property var mainWindow
    property var playerWindow
    Component.onCompleted: {
        mainWindow = SingletonWindowMain
        playerWindow = SingletonWindowPlayer
    }

    property var webViewWindow:  Window {
        //visible: true
        width: 600; height: 480
        Component.onCompleted: SingletonWebView.parent = contentItem
    }

    property var testWindow: Window {
        //visible: true


        Button {
            anchors.centerIn: parent
            onClicked: text = text === "aaaaaaaaaaaaaaaaaaaaaa" ? "a" : "aaaaaaaaaaaaaaaaaaaaaa"
        }
    }
}
