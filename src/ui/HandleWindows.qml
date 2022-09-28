import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Window
import MaterialYou

RowLayout {
    spacing: 0
    ToolButton {
        icon.source:"qrc:/minimize.svg"
        icon.width: 16; icon.height: 16
        MaterialYou.radius: 0
        implicitHeight: 24
        bottomInset: 0; topInset: 0; leftInset: 0; rightInset: 0
        onClicked: Window.window.showMinimized()
    }
    ToolSeparator { Layout.preferredHeight: 24; opacity: 0.2 }
    ToolButton {
        id: buttonMaximize
        icon.width: 16; icon.height: 16
        MaterialYou.radius: 0
        implicitHeight: 24
        bottomInset: 0; topInset: 0; leftInset: 0; rightInset: 0
        states: [
            State {
                name: "maximize"
                when: buttonMaximize.Window.window.visibility !== Window.Maximized
                PropertyChanges {
                    target: buttonMaximize
                    icon.source:"qrc:/maximize.svg"
                    onClicked: buttonMaximize.Window.window.showMaximized()
                }
            },
            State {
                name: "normalize"
                when: buttonMaximize.Window.window.visibility === Window.Maximized
                PropertyChanges {
                    target: buttonMaximize
                    icon.source:"qrc:/normalize.svg"
                    onClicked: buttonMaximize.Window.window.showNormal()
                }
            }
        ]
    }
    ToolSeparator { Layout.preferredHeight: 24; opacity: 0.2 }
    ToolButton {
        icon.source:"qrc:/close.svg"
        icon.width: 16; icon.height: 20
        MaterialYou.radius: 0
        implicitHeight: 24
        bottomInset: 0; topInset: 0; leftInset: 0; rightInset: 0
        MaterialYou.backgroundColor: MaterialYou.Error
        checked: hovered
        onClicked: Window.window.close()
    }
}
