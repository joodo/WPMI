import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import MaterialYou
import Qt.labs.settings

ScrollView {
    contentWidth: availableWidth
    ColumnLayout {
        anchors.fill: parent
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
            LabelRequireRestart {
                property string _initValue
                Component.onCompleted: _initValue = settings.language
                visible: _initValue !== comboBoxLanguage.currentValue
            }
        }
        ComboBox {
            id: comboBoxLanguage
            Layout.leftMargin: 12
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
            LabelRequireRestart {
                property int _initValue
                Component.onCompleted: _initValue = settingsMY.theme
                visible: _initValue !== comboBoxTheme.currentValue
            }
        }
        ComboBox {
            id: comboBoxTheme
            Layout.leftMargin: 12
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
        Item { Layout.preferredHeight: 16; Layout.preferredWidth: 1 }


        ToolSeparator {
            orientation: Qt.Horizontal
            Layout.fillWidth: true
            Layout.rightMargin: 32
            Layout.topMargin: 16
            Layout.bottomMargin: 8
        }
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
            Layout.leftMargin: 12
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
            Layout.leftMargin: 12
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
            Layout.leftMargin: 12
            text: qsTr("Server to search videos.")
        }
        TextField {
            Layout.leftMargin: 12
            id: fieldResourceServer
            Layout.preferredWidth: 300
            text: "www.dandanzan10.top"
        }
        Item { Layout.preferredHeight: 16; Layout.preferredWidth: 1 }


        ToolSeparator {
            orientation: Qt.Horizontal
            Layout.fillWidth: true
            Layout.rightMargin: 32
            Layout.topMargin: 16
            Layout.bottomMargin: 8
        }
        Label {
            text: qsTr("About")
            MaterialYou.fontRole: MaterialYou.HeadlineSmall
            MaterialYou.foregroundColor: MaterialYou.Secondary
        }
        Label {
            Layout.leftMargin: 12
            text: `WPMI - Watch Pirated Movies Illegally  ${APP_VERSION}\nBy Joodo`
        }
        Label {
            Layout.leftMargin: 12
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
}
