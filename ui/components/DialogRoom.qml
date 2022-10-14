import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Qt.labs.settings as Labs
import MaterialYou

Item {
    id: root

    function create(roomName, urlPromise) {
        loader.sourceComponent = null
        loader.sourceComponent = componentCreate
        loader.item.roomName = roomName
        urlPromise.then(url => loader.item.videoUrl = url)
        loader.item.open()
    }

    function detail(roomName, roomUrl) {
        loader.sourceComponent = null
        loader.sourceComponent = componentDetail
        loader.item.title = roomName
        loader.item.roomUrl = roomUrl
        loader.item.open()
    }

    Loader {
        id: loader
        anchors.fill: parent
    }

    Component {
        id: componentCreate
        Dialog {
            id: dialogCreate

            property string videoUrl
            onVideoUrlChanged: if (videoUrl && busyCreating.visible) buttonCreate.clicked()
            property alias roomName: fieldRoomName.text

            anchors.centerIn: parent
            title: qsTr("Create Room")
            width: 350

            ColumnLayout {
                spacing: 16
                anchors.fill: parent

                TextField {
                    id: fieldRoomName
                    Layout.fillWidth: true
                    placeholderText: qsTr("Room Name")
                }

                TextField {
                    id: fieldUserName
                    Layout.fillWidth: true
                    placeholderText: qsTr("Your Nickname")

                    Labs.Settings { property alias userName: fieldUserName.text }
                }

                BusyIndicator {
                    id: busyCreating
                    visible: !buttonCreate
                    Layout.alignment: Qt.AlignHCenter
                    running: true
                }
            }

            footer: DialogButtonBox {
                Button {
                    id: buttonCreate
                    text: qsTr("Create")
                    onClicked: {
                        visible = false
                        destroy()

                        if (!dialogCreate.videoUrl) return

                        LeanCloud.createRoom(fieldUserName.text,
                                             fieldRoomName.text,
                                             dialogCreate.videoUrl)
                        .then(roomUrl => {
                                  if (!dialogCreate.visible) return

                                  Qt.openUrlExternally(roomUrl + `&user=${fieldUserName.text}`)

                                  dialogCreate.accept()

                                  root.detail(fieldRoomName.text,
                                              roomUrl)
                              }).catch(console.error);
                    }
                }
            }
        }
    }

    Component {
        id: componentDetail
        Dialog {
            id: dialogDetail
            anchors.centerIn: parent
            width: 350

            property alias roomUrl: fieldUrl.text

            ColumnLayout {
                anchors.fill: parent

                Label {
                    text: qsTr("Share this link with your friends:")
                }

                TextField {
                    id: fieldUrl
                    Layout.fillWidth: true
                    Layout.rightMargin: buttonCopy.width + buttonCopy.anchors.leftMargin
                    readOnly: true
                    onTextChanged: cursorPosition = 0
                    onActiveFocusChanged: {
                        if (activeFocus) {
                            selectAll()
                        } else {
                            cursorPosition = 0
                        }
                    }
                    ToolButton {
                        id: buttonCopy
                        anchors {
                            left: parent.right
                            leftMargin: 8
                            verticalCenter: parent.verticalCenter
                        }
                        icon.source: "qrc:/copy.svg"
                        onClicked: {
                            timer.start()
                            Backend.copyStringToClipboard(fieldUrl.text)
                        }
                    }
                }

                Item {
                    height: 12
                    Label {
                        text: qsTr("Copied")
                        MaterialYou.foregroundColor: MaterialYou.OnSurfaceVariant
                        MaterialYou.fontRole: MaterialYou.LabelSmall
                        visible: timer.running
                    }
                    Timer {
                        id: timer
                        interval: 1000
                    }
                }
            }
        }
    }
}



