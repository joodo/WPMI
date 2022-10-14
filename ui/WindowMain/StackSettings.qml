import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import MaterialYou
import Qt.labs.settings as Labs

Page {
    id: root

    background: null

    header: Label {
        height: 40
        MaterialYou.fontRole: MaterialYou.HeadlineMedium
        text: qsTr("Settings")
        verticalAlignment: Text.AlignVCenter
    }

    HeaderShadow {
        z: 10
        x: -56
        anchors.top: scrollView.top
        opacity: scrollView.contentItem.contentY / 56
    }

    ScrollView {
        id: scrollView
        anchors.fill: parent
        anchors.topMargin: 8
        contentWidth: availableWidth

        ColumnLayout {
            anchors.fill: parent
            anchors.leftMargin: 16
            spacing: 8

            Item {
                Layout.preferredHeight: 1
                Layout.preferredWidth: 1
            }
            LabelH1 { text: qsTr("Interface") }

            RowLayout {
                spacing: 8
                Label {
                    Layout.alignment: Qt.AlignBaseline
                    text: qsTr("Language")
                    MaterialYou.fontRole: MaterialYou.TitleSmall
                }
                LabelRequireRestart {
                    property string _initValue
                    visible: comboBoxLanguage.currentIndex !== 0
                }
            }
            ComboBox {
                id: comboBoxLanguage
                textRole: "text"
                valueRole: "value"
                implicitWidth: 250
                model: Backend.supportedLanguages()
                onActivated: Settings.language = currentValue
            }
            SeparatorH2 {}

            RowLayout {
                spacing: 8
                LabelH2 {
                    Layout.alignment: Qt.AlignBaseline
                    text: qsTr("Theme")
                }
                LabelRequireRestart {
                    property int _initValue
                    Component.onCompleted: _initValue = settingsMY.theme
                    visible: _initValue !== comboBoxTheme.currentValue
                }
            }
            ComboBox {
                id: comboBoxTheme
                textRole: "key"
                valueRole: "value"
                model: ListModel {
                    ListElement { key: qsTr("System"); value: MaterialYou.System }
                    ListElement { key: qsTr("Light"); value: MaterialYou.Light }
                    ListElement { key: qsTr("Dark"); value: MaterialYou.Dark }
                }
                Component.onCompleted: comboBoxTheme.currentIndex = settingsMY.theme
                onActivated: settingsMY.theme = currentIndex
            }
            SeparatorH2 {}


            SeparatorH1 {}
            LabelH1 { text: qsTr("Network") }

            LabelH2 { text: qsTr("Proxy") }
            RowLayout {
                spacing: 8
                ComboBox {
                    id: comboBoxProxy
                    textRole: "key"; valueRole: "value"
                    model: ListModel {
                        ListElement { key: qsTr("No Proxy"); value: "[none]" }
                        ListElement { key: qsTr("System"); value: "[system]" }
                        ListElement { key: qsTr("HTTP"); value: "" }
                    }
                    Component.onCompleted: {
                        switch(Settings.proxy) {
                        case "[none]": currentIndex = 0; break
                        case "[system]": currentIndex = 1; break
                        default: currentIndex = 2
                        }
                    }
                    onActivated: Settings.proxy = currentIndex === 2? fieldProxy.text : currentValue
                }
                TextField {
                    id: fieldProxy
                    visible: comboBoxProxy.currentIndex === 2
                    Layout.preferredWidth: 300
                    prefix: "http://"
                    TrivialSettings { property alias proxyAddress: fieldProxy.text }
                    onEditingFinished: if (comboBoxProxy.currentIndex === 2) Settings.proxy = text
                }
            }
            SeparatorH2 {}

            LabelH2 { text: qsTr("Resource Server") }
            Label { text: qsTr("Server to search videos.") }
            TextField {
                id: fieldResourceServer
                Layout.preferredWidth: 300
                prefix: "http://"
                text: Settings.resourceServer
                onEditingFinished: Settings.resourceServer = text
            }
            SeparatorH2 {}


            SeparatorH1 {}
            LabelH1 { text: qsTr("About") }
            Label { text: `WPMI - Watch Pirated Movies Illegally  ${Qt.application.version}\nBy Joodo` }
            Label {
                text: `<a href='https://github.com/joodo/WPMI'>GitHub</a>`
                onLinkActivated: Qt.openUrlExternally(link)
                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.NoButton
                    cursorShape: Qt.PointingHandCursor
                }
            }
            SeparatorH2 {}
        }


        Labs.Settings {
            id: settingsMY
            category: "MaterialYou"
            property int theme: MaterialYou.System
        }

        component LabelH1: Label {
            MaterialYou.fontRole: MaterialYou.TitleLarge
            MaterialYou.foregroundColor: MaterialYou.Secondary
            Layout.leftMargin: -12
        }
        component SeparatorH1: ToolSeparator {
            orientation: Qt.Horizontal
            Layout.fillWidth: true
            Layout.rightMargin: 32
            Layout.topMargin: 16
            Layout.bottomMargin: 8
            Layout.leftMargin: -24
        }
        component LabelH2: Label {
            MaterialYou.fontRole: MaterialYou.TitleSmall
        }
        component SeparatorH2: Item {
            Layout.preferredHeight: 16
            Layout.preferredWidth: 1
        }
        component LabelRequireRestart: RowLayout {
            Label {
                text: qsTr("Restart WPMI to apply this change.")
                MaterialYou.foregroundColor: MaterialYou.OnSurfaceVariant
                MaterialYou.fontRole: MaterialYou.LabelSmall
            }
            Label {
                text: qsTr("<a href='restart'>Restart Now</a>")
                onLinkActivated: Backend.restartApplication()
                MaterialYou.fontRole: MaterialYou.LabelSmall
                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.NoButton
                    cursorShape: Qt.PointingHandCursor
                }
            }
        }
    }
}
