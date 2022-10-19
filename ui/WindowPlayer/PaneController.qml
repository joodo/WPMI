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

            RowLayout {
                anchors.verticalCenter: parent.verticalCenter

                IconLabel {
                    Layout.alignment: Qt.AlignVCenter
                    display: IconLabel.IconOnly
                    icon.source: "qrc:/volume.svg"
                    MaterialYou.foregroundColor: MaterialYou.OnSurfaceVariant
                    icon.height: 16; icon.width: 16
                }

                Slider {
                    Layout.alignment: Qt.AlignVCenter
                    Layout.preferredWidth: 100
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
                    id: buttonForward5
                    icon.height: 20; icon.width: 20
                    icon.source: "qrc:/forward_5.svg"
                    onClicked: mediaPlayer.position += 5000
                }
            }

            RowLayout {
                anchors {
                    verticalCenter: parent.verticalCenter
                    right: parent.right
                }
                spacing: 0

                ToolButton {
                    Layout.alignment: Qt.AlignVCenter
                    Layout.preferredWidth: 32
                    Layout.preferredHeight: 32
                    icon.height: 16; icon.width: 16
                    enabled: sliderGamma.value !== 1
                    icon.source: enabled? "qrc:/brightness_fill.svg" : "qrc:/brightness.svg"
                    onClicked: sliderGamma.value = 1
                    ToolTip.text: qsTr("Reset")
                    ToolTip.visible: hovered && enabled
                }

                Slider {
                    id: sliderGamma
                    Layout.alignment: Qt.AlignVCenter
                    Layout.preferredWidth: 100
                    from: 0.8; to: 1.2; value: 1
                    onValueChanged: mediaPlayer.gamma = value * value
                    Connections {
                        target: mediaPlayer
                        function onGammaChanged() {
                            if (mediaPlayer.gamma === 1) sliderGamma.value = 1
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


    onVisualFocusChanged: if (!visualFocus) forceActiveFocus()
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
