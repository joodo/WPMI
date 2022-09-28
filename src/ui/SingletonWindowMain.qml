pragma Singleton

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Window
import MaterialYou

ApplicationWindow {
    id: window

    width: 800; height: 600
    minimumWidth: 600; minimumHeight: 480
    visible: true
    title: qsTr("Watch Pirated Movies Illegally!") + " :D"
    MaterialYou.backgroundColor: MaterialYou.tintSurfaceColor(2)

    onVisibleChanged: if (visible) Backend.hideWindowTitleBar(this)

    header: Item {
        height: 30
        HandlerWindowDrag { anchors.fill: parent }
        HandleWindows {
            visible: Qt.platform.os === "windows"
            anchors.right: parent.right
        }
    }

    RowLayout {
        anchors.fill: parent
        spacing: 0

        ToolBar {
            rightPadding: 0
            Layout.fillHeight: true; Layout.preferredWidth: tabBar.implicitWidth
            MaterialYou.backgroundColor: "transparent"

            HandlerWindowDrag { anchors.fill: parent }

            ColumnLayout {
                id: tabBar
                anchors.bottom: parent.bottom
                implicitWidth: childrenRect.width
                //ButtonGroup { buttons: tabBar.children }
                ToolButton {
                    visible: false
                    checkable: true
                    icon.source: checked? "qrc:/download_for_offline_fill.svg" : "qrc:/download_for_offline.svg"
                }
                ToolButton {
                    id: buttonSettings
                    checkable: true
                    icon.source: checked? "qrc:/settings_fill.svg" : "qrc:/settings.svg"
                    onClicked: {
                        if (checked) {
                            stackLayout.push(stackSettings)
                        } else {
                            stackLayout.pop()
                        }
                    }
                }
            }

            ToolButton {
                id: buttonBack
                anchors.horizontalCenter: parent.horizontalCenter
                icon.source: "qrc:/arrow_back.svg"
                visible: stackLayout.currentItem.backable
                onClicked: stackLayout.currentItem.back()
            }
        }

        StackView {
            id: stackLayout
            Layout.fillHeight: true; Layout.fillWidth: true

            initialItem: StackMovies { id: stackMovies }

            StackSettings {
                id: stackSettings
                visible: false
                readonly property bool backable: true
                signal back
                onBack: { stackLayout.pop(); buttonSettings.checked = false }
            }
        }
    }
}
