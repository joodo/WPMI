pragma Singleton

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Window
import MaterialYou

ApplicationWindow {
    id: window

    visible: true
    title: qsTr("Watch Pirated Movies Illegally!") + " :D"

    width: 800; height: 600
    minimumWidth: 600; minimumHeight: 480
    TrivialSettings {
        property alias mainWindowX: window.x
        property alias mainWindowY: window.y
        property alias mainWindowWidth: window.width
        property alias mainWindowHeight: window.height
    }

    onVisibleChanged: if (visible) Backend.hideWindowTitleBar(this)

    MaterialYou.backgroundColor: MaterialYou.tintSurfaceColor(1)


    header: Item {
        height: 30
        HandlerWindowDrag { anchors.fill: parent }
        HandleWindows {
            visible: Qt.platform.os === "windows"
            anchors.right: parent.right
        }
        ComboBoxTitle {
            id: comboBoxTitle
            enabled: false
            anchors {
                top: parent.top
                horizontalCenter: parent.horizontalCenter
            }
        }
    }


    RowLayout {
        anchors.fill: parent
        spacing: 0

        Item {
            Layout.fillHeight: true; Layout.preferredWidth: 56

            HandlerWindowDrag { anchors.fill: parent }

            ToolButton {
                id: buttonBack
                visible: opacity !== 0
                opacity: Session.backableItemStack.count
                Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
                anchors.horizontalCenter: parent.horizontalCenter
                icon.source: "qrc:/arrow_back.svg"
                onClicked: Session.backableItemStack.get(Session.backableItemStack.count - 1).back()
            }

            ColumnLayout {
                id: tabBar
                anchors {
                    bottom: parent.bottom
                    bottomMargin: 8
                    horizontalCenter: parent.horizontalCenter
                }
                spacing: 8

                ToolButton {
                    visible: false
                    checkable: true
                    icon.source: checked? "qrc:/download_for_offline_fill.svg" : "qrc:/download_for_offline.svg"
                }
                ToolButton {
                    id: buttonSettings
                    checkable: true
                    icon.source: checked? "qrc:/settings_fill.svg" : "qrc:/settings.svg"
                    onCheckedChanged: {
                        if (checked) {
                            stackLayout.push(stackSettings)
                        } else {
                            stackLayout.pop()
                        }
                    }
                }
            }
        }

        StackView {
            id: stackLayout
            Layout.fillHeight: true; Layout.fillWidth: true

            initialItem: Loader { source: comboBoxTitle.currentValue }

            StackSettings {
                id: stackSettings
                visible: false
                StackView.onViewChanged: if (StackView.view) Session.backableItemStack.append(this)
                StackView.onRemoved: Session.backableItemStack.remove(Session.backableItemStack.count - 1)
                function back() {
                    stackLayout.pop()
                    buttonSettings.checked = false
                }
            }
        }
    }


    property Dialog dialog: DialogGlobal {
        parent: window.contentItem
        anchors.centerIn: parent
    }


    property Item snackbar: SnackbarGlobal {
        parent: window.contentItem
        anchors {
            bottom: parent.bottom
            bottomMargin: 16
            horizontalCenter: parent.horizontalCenter
        }
        width: Math.min(parent.width - 32, 400, implicitWidth)
        z: 10
    }


    DropAreaKeys {
        anchors.fill: parent
        onUnlocked: comboBoxTitle.enabled = true
    }
}
