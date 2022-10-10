pragma Singleton

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Window
import Qt.labs.settings
import QtMultimedia as Multimedia
import MaterialYou
import MaterialYou.impl

ApplicationWindow {
    id: window

    signal siteChanged(string site)

    width: 800; height: 600
    minimumWidth: 600; minimumHeight: 480
    visible: true
    title: qsTr("Watch Pirated Movies Illegally!") + " :D"

    onVisibleChanged: if (visible) Backend.hideWindowTitleBar(this)
    MaterialYou.backgroundColor: MaterialYou.tintSurfaceColor(1)

    ColumnLayout {
        anchors.fill: parent
        Item {
            Layout.preferredHeight: 30; Layout.fillWidth: true
            HandlerWindowDrag { anchors.fill: parent }
            HandleWindows {
                visible: Qt.platform.os === "windows"
                anchors.right: parent.right
            }
            ComboBox {
                id: comboBoxTitle
                enabled: false
                anchors { horizontalCenter: parent.horizontalCenter; top: parent.top }
                indicator: null
                model: [
                    { key: "DanDanZan", value: "qrc:/SiteDandanzan.qml" },
                    { key: "Jable", value: "qrc:/SiteJable.qml" },
                ]
                textRole: "key"; valueRole: "value"
                contentItem: Label {
                    text: comboBoxTitle.displayText
                    MaterialYou.fontRole: MaterialYou.LabelSmall
                    horizontalAlignment: Qt.AlignHCenter
                    verticalAlignment: Qt.AlignVCenter
                }
                background: StatusLayer {
                    implicitWidth: 120
                    implicitHeight: 20
                    radius: height
                    status: comboBoxTitle.down? MaterialYou.Press : comboBoxTitle.hovered? MaterialYou.Hover : comboBoxTitle.visualFocus? MaterialYou.Focus : MaterialYou.Normal
                    MaterialYou.foregroundColor: MaterialYou.OnSurface
                }
                onCurrentValueChanged: window.siteChanged(currentValue)
            }
        }

        RowLayout {
            Layout.fillHeight: true; Layout.fillWidth: true
            spacing: 0

            ToolBar {
                Layout.fillHeight: true; Layout.preferredWidth: 56
                MaterialYou.backgroundColor: "transparent"

                HandlerWindowDrag { anchors.fill: parent }

                ToolButton {
                    id: buttonBack
                    anchors.horizontalCenter: parent.horizontalCenter
                    icon.source: "qrc:/arrow_back.svg"
                    visible: Session.backableItemStack.count
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
                    // ButtonGroup { buttons: tabBar.children }
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

                initialItem: Loader {
                    source: comboBoxTitle.currentValue
                }

                StackSettings {
                    id: stackSettings
                    visible: false
                    StackView.onActivated: Session.backableItemStack.append(this)
                    StackView.onDeactivated: Session.backableItemStack.remove(Session.backableItemStack.count - 1)
                    function back() {
                        stackLayout.pop()
                        buttonSettings.checked = false
                    }
                }
            }
        }
    }


    // Dialog
    property Dialog dialog: dialog
    Dialog {
        id: dialog
        property var content
        anchors.centerIn: parent
        modal: true
        onAboutToHide: content = null
        Loader {
            id: loaderDialogContent
            sourceComponent: typeof dialog.content === "string"? componentDialogContent : dialog.content
        }

        Component {
            id: componentDialogContent
            Label {
                MaterialYou.foregroundColor: MaterialYou.OnSurfaceVariant
                textFormat: Text.MarkdownText
                text: dialog.content
            }
        }
    }
    function showDialog(content, title, standardButtons) {
        dialog.content = content
        dialog.title = title || ""
        dialog.standardButtons = standardButtons || Dialog.NoButton
        dialog.open()
        return new Promise((resolve, reject) => {
                               dialog.accepted.connect(() => resolve())
                               dialog.rejected.connect(() => reject())
                           })
    }


    // Drop Items
    DropArea {
        anchors.fill: parent
        keys: ["text/uri-list"]
        onEntered: {
            //
        }
        onDropped: drop => {
            const path = Backend.localFileFromUrl(drop.urls[0].toString())
            if (path.endsWith(".png")) {
                if (Backend.getPngText(path) === "sweetsweetdream") {
                    comboBoxTitle.enabled = true
                    sound.play()
                }
            }
        }

        Multimedia.MediaPlayer {
            id: sound
            source: "qrc:/celebration.wav"
            audioOutput: Multimedia.AudioOutput {}
        }

        Rectangle {
            visible: parent.containsDrag
            anchors.fill: parent
            color: MaterialYou.color(MaterialYou.Primary)
            opacity: 0.2
        }
    }

    Settings {
        property alias mainWindowX: window.x
        property alias mainWindowY: window.y
        property alias mainWindowWidth: window.width
        property alias mainWindowHeight: window.height
    }
}
