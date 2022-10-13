import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Window
import QtMultimedia
import MaterialYou

PaneBlur {
    id: root

    property MediaPlayer mediaPlayer


    hoverEnabled: true
    property bool requestAlwaysShow: hovered || menu.visible
    signal showRequested()

    MaterialYou.backgroundColor: MaterialYou.tintSurfaceColor(2)

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        Item {
            Layout.preferredHeight: 48; Layout.fillWidth: true
            IconLabel {
                display: IconLabel.IconOnly
                icon.source: "qrc:/volume.svg"
                anchors.verticalCenter: parent.verticalCenter
                MaterialYou.foregroundColor: MaterialYou.OnSurfaceVariant
                icon.height: 16; icon.width: 16

                Slider {
                    anchors.verticalCenter: parent.verticalCenter
                    x: 18
                    width: 100
                    value: mediaPlayer.audioOutput.volume
                    onMoved: mediaPlayer.audioOutput.volume = value
                }
            }

            RowLayout {
                anchors.centerIn: parent
                ToolButton {
                    id: buttonReplay5
                    icon.height: 20; icon.width: 20
                    icon.source: "qrc:/replay_5.svg"
                    onClicked: mediaPlayer.position -= 5000
                }
                ToolButton {
                    visible: false
                    icon.source: "qrc:/fast_rewind.svg"
                    onPressed: mediaPlayer.playbackRate = -4
                    onReleased: mediaPlayer.playbackRate = 1
                }

                ToolButton {
                    id: buttonPlay
                    icon.width: 40; icon.height: 40
                    states: [
                        State {
                            when: mediaPlayer.playbackState === MediaPlayer.PlayingState
                            name: "pause"
                            PropertyChanges {
                                buttonPlay.icon.source: "qrc:/pause.svg"
                                buttonPlay.onClicked: mediaPlayer.pause()
                            }
                        },
                        State {
                            when: mediaPlayer.playbackState !== MediaPlayer.PlayingState
                            name: "play"
                            PropertyChanges {
                                buttonPlay.icon.source: "qrc:/play.svg"
                                buttonPlay.onClicked: mediaPlayer.play()
                            }
                        }
                    ]
                }
                ToolButton {
                    visible: false
                    icon.source: "qrc:/fast_forward.svg"
                    onPressed: mediaPlayer.playbackRate = 4
                    onReleased: mediaPlayer.playbackRate = 1
                }
                ToolButton {
                    id: buttonForward5
                    icon.height: 20; icon.width: 20
                    icon.source: "qrc:/forward_5.svg"
                    onClicked: mediaPlayer.position += 5000
                }
            }

            RowLayout {
                anchors { right: parent.right; top: parent.top; bottom: parent.bottom; rightMargin: -16 }
                spacing: 0
                ToolButton {
                    icon.source: "qrc:/list.svg"
                    icon.height: 20; icon.width: 20
                    onClicked: {
                        WindowMain.show()
                        WindowMain.raise()
                    }
                }
                ToolButton {
                    icon.source: "qrc:/more.svg"
                    icon.height: 20; icon.width: 20
                    Menu {
                        id: menu

                        MenuItem {
                            text: qsTr("Help")
                            icon.source: "qrc:/question_mark.svg"
                            onTriggered: dialogHelp.open()
                            Dialog {
                                id: dialogHelp
                                parent: root.Window.contentItem
                                title: qsTr("Usage")
                                anchors.centerIn: parent
                                Label {
                                    textFormat: Text.MarkdownText
                                    text: qsTr("**Double Click**: Fullscreen\n\n**Space, Click**: Play / Pause\n\n**Left / Right Arrow**: Replay / Forward 10 seconds\n\n**Up / Down Arrow, Mousewheel Scroll**: Volume Up / Down\n\n**Esc**: Quit Fullscreen")
                                }
                            }
                        }

                        MenuItem {
                            text: qsTr("Copy m3u8")
                            onTriggered: Backend.copyStringToClipboard(mediaPlayer.source)
                            enabled: mediaPlayer.source.toString()
                            leftPadding: 56
                        }


                        MenuItem {
                            text: qsTr("Other devices")
                            enabled: mediaPlayer.source
                            icon.source: "qrc:/smartphone.svg"
                            onTriggered: dialogQRCode.open()
                            Dialog {
                                id: dialogQRCode
                                parent: root.Window.contentItem
                                anchors.centerIn: parent
                                alignment: Dialog.AlignCenter
                                title: qsTr("Watch on Web")
                                ColumnLayout {
                                    spacing: 8
                                    Label {
                                        Layout.preferredWidth: 250
                                        text: qsTr("Visit link below to watch this video on any device's browser:")
                                        wrapMode: Text.Wrap
                                    }
                                    Frame {
                                        Layout.alignment: Qt.AlignHCenter
                                        MaterialYou.backgroundColor: "transparent"
                                        QRCode {
                                            id: qrCode
                                            width: 200; height: 200
                                            background: "transparent"
                                            foreground: MaterialYou.color(MaterialYou.OnSurface)
                                            onVisibleChanged: {
                                                if (!visible) return;
                                                // Avoid property binding, cus mediaPlayer.position change all the time
                                                text = `https://joodo.github.io/WPMI/player.html?title=${encodeURIComponent(Window.window.title)}&url=${encodeURIComponent(mediaPlayer.source)}&position=${parseInt(mediaPlayer.position/1000)}`
                                            }
                                        }
                                    }
                                    Button {
                                        Layout.alignment: Qt.AlignHCenter
                                        text: timerButtonText.running? qsTr("Copied!") : qsTr("Copy to Clipboard")
                                        Timer {
                                            id: timerButtonText
                                            interval: 1000
                                        }
                                        onClicked: {
                                            Backend.copyStringToClipboard(qrCode.text)
                                            timerButtonText.restart()
                                        }
                                    }
                                }
                            }
                        }

                        MenuItem {
                            background: Item { implicitWidth: 200; implicitHeight: 48 }
                            icon.source: "qrc:/brightness.svg"
                            Slider {
                                id: sliderGamma
                                anchors.verticalCenter: parent.verticalCenter
                                x: 48; width: 110
                                from: 0.8; to: 1.2; value: 1
                                onValueChanged: mediaPlayer.gamma = value * value
                                Connections {
                                    target: mediaPlayer
                                    function onGammaChanged() {
                                        if (mediaPlayer.gamma === 1) sliderGamma.value = 1
                                    }
                                }
                            }
                            ToolButton {
                                anchors {
                                    left: sliderGamma.right
                                    verticalCenter: parent.verticalCenter
                                }
                                implicitWidth: 36; implicitHeight: 36
                                visible: sliderGamma.value !== 1
                                icon.source: "qrc:/undo.svg"
                                onClicked: sliderGamma.value = 1
                            }
                        }
                    }

                    onClicked: {
                        if (menu.visible) {
                            menu.close()
                        } else {
                            menu.x = pressX - menu.width; menu.y = pressY - menu.height
                            menu.open()
                        }
                    }
                }
            }
        }

        VideoProgressBar {
            Layout.fillWidth: true; Layout.fillHeight: true
            mediaPlayer: root.mediaPlayer
        }
    }


    Shortcut {
        sequence: "space"
        onActivated: { buttonPlay.clicked(); showRequested() }
    }
    Shortcut {
        sequence: "left"
        onActivated: { buttonReplay5.clicked(); showRequested() }
    }
    Shortcut {
        sequence: "right"
        onActivated: { buttonForward5.clicked(); showRequested() }
    }
    Shortcut {
        sequence: "up"
        onActivated: { mediaPlayer.audioOutput.volume += 0.1; showRequested() }
    }
    Shortcut {
        sequence: "down"
        onActivated: { mediaPlayer.audioOutput.volume -= 0.1; showRequested() }
    }
    Shortcut {
        sequence: "escape"
        onActivated: root.Window.window.showNormal()
    }
}
