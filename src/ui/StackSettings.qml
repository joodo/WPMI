import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import MaterialYou
import Qt.labs.settings

ScrollView {
    ColumnLayout {
        spacing: 8
        Label {
            text: qsTr("Settings")
            MaterialYou.fontRole: MaterialYou.DisplaySmall
        }

        Label {
            text: qsTr("Interface")
            MaterialYou.fontRole: MaterialYou.HeadlineSmall
            MaterialYou.foregroundColor: MaterialYou.Secondary
        }

        RowLayout {
            spacing: 8
            Label {
                Layout.alignment: Qt.AlignBaseline
                text: qsTr("Language")
                MaterialYou.fontRole: MaterialYou.TitleSmall
            }
            Label {
                property string _initValue
                Component.onCompleted: _initValue = settings.language
                visible: _initValue !== comboBoxLanguage.currentValue
                text: qsTr("Restart WPMI to apply this change.")
                MaterialYou.foregroundColor: MaterialYou.Primary
                MaterialYou.fontRole: MaterialYou.LabelSmall
            }
        }
        ComboBox {
            id: comboBoxLanguage
            textRole: "text"
            valueRole: "value"
            implicitWidth: 250
            model: Backend.supportedLanguages()
        }
        Item { Layout.preferredHeight: 16; Layout.preferredWidth: 1 }

        RowLayout {
            spacing: 8
            Label {
                Layout.alignment: Qt.AlignBaseline
                text: qsTr("Theme")
                MaterialYou.fontRole: MaterialYou.TitleSmall
            }
            Label {
                visible: settingsMY.theme !== comboBoxTheme.currentValue
                text: qsTr("Restart WPMI to apply this change.")
                MaterialYou.foregroundColor: MaterialYou.Primary
                MaterialYou.fontRole: MaterialYou.LabelSmall
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
        }
        Item { Layout.preferredHeight: 16; Layout.preferredWidth: 1 }

        Label {
            text: qsTr("Network")
            MaterialYou.fontRole: MaterialYou.HeadlineSmall
            MaterialYou.foregroundColor: MaterialYou.Secondary
        }

        Label {
            text: qsTr("Proxy")
            MaterialYou.fontRole: MaterialYou.TitleSmall
        }
        ComboBox {
            id: comboBoxProxy
            textRole: "key"
            valueRole: "value"
            model: ListModel {
                ListElement { key: qsTr("No Proxy"); value: 0 }
                ListElement { key: qsTr("System"); value: 1 }
                ListElement { key: qsTr("HTTP"); value: 2 }
            }
            onActivated: {
                switch (currentValue) {
                case 0: Backend.setProxy("[None]"); break;
                case 1: Backend.setProxy("[System]"); break;
                case 2: Backend.setProxy(fieldProxy.text); break;
                default: ;
                }
            }
        }
        TextField {
            id: fieldProxy
            visible: comboBoxProxy.currentValue === 2
            Layout.preferredWidth: 300
            text: ""
            onEditingFinished: comboBoxProxy.activated(comboBoxProxy.currentIndex)
        }
        Item { Layout.preferredHeight: 16; Layout.preferredWidth: 1 }

        Label {
            text: qsTr("Resource Server")
            MaterialYou.fontRole: MaterialYou.TitleSmall
        }
        Label {
            text: qsTr("Server to search videos.")
        }
        TextField {
            id: fieldResourceServer
            Layout.preferredWidth: 300
            text: "www.dandanzan10.top"
        }
        Item { Layout.preferredHeight: 16; Layout.preferredWidth: 1 }

        Label {
            text: qsTr("About")
            MaterialYou.fontRole: MaterialYou.HeadlineSmall
            MaterialYou.foregroundColor: MaterialYou.Secondary
        }
        Label {
            text: `WPMI - Watch Pirated Movies Illegally  ${APP_VERSION}\nBy Joodo`
        }
        Label {
            text: `<a href='https://github.com/joodo/WPMI'>GitHub</a>`
            onLinkActivated: Qt.openUrlExternally(link)
            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.NoButton
                cursorShape: Qt.PointingHandCursor
            }
        }
        Item { Layout.preferredHeight: 16; Layout.preferredWidth: 1 }
    }

    Settings {
        id: settingsMY
        category: "MaterialYou"
        property int theme: MaterialYou.System
    }
    Settings {
        id: settings
        property alias resourceServer: fieldResourceServer.text
        property alias proxyType: comboBoxProxy.currentIndex
        property alias language: comboBoxLanguage.currentValue
    }

    Component.onDestruction: {
        settingsMY.theme = comboBoxTheme.currentIndex
    }
}
