import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import MaterialYou
import Qt.labs.settings

ScrollView {
    contentWidth: availableWidth
    ColumnLayout {
        anchors.fill: parent
        anchors.leftMargin: 24
        spacing: 8

        LabelH1 { text: qsTr("Settings") }

        LabelH2 { text: qsTr("Interface") }

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
            textRole: "text"
            valueRole: "value"
            implicitWidth: 250
            model: Backend.supportedLanguages()
        }
        SeparatorH3 {}

        RowLayout {
            spacing: 8
            LabelH3 {
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
        SeparatorH3 {}


        SeparatorH2 {}
        LabelH2 { text: qsTr("Network") }

        LabelH3 { text: qsTr("Proxy") }
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
            Component.onCompleted: activated(currentIndex)
        }
        TextField {
            id: fieldProxy
            visible: comboBoxProxy.currentValue === 2
            Layout.preferredWidth: 300
            text: ""
            prefix: "http://"
            onEditingFinished: comboBoxProxy.activated(comboBoxProxy.currentIndex)
        }
        SeparatorH3 {}

        LabelH3 { text: qsTr("Resource Server") }
        Label { text: qsTr("Server to search videos.") }
        TextField {
            id: fieldResourceServer
            Layout.preferredWidth: 300
            prefix: "http://"
            text: "www.dandanzan10.top"
        }
        SeparatorH3 {}


        SeparatorH2 {}
        LabelH2 { text: qsTr("About") }
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
        SeparatorH3 {}
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
        property alias proxyAddress: fieldProxy.text
        property alias language: comboBoxLanguage.currentValue
    }


    component LabelH1: Label {
        MaterialYou.fontRole: MaterialYou.DisplaySmall
        Layout.leftMargin: -24
    }
    component LabelH2: Label {
        MaterialYou.fontRole: MaterialYou.HeadlineSmall
        MaterialYou.foregroundColor: MaterialYou.Secondary
        Layout.leftMargin: -12
    }
    component SeparatorH2: ToolSeparator {
        orientation: Qt.Horizontal
        Layout.fillWidth: true
        Layout.rightMargin: 32
        Layout.topMargin: 16
        Layout.bottomMargin: 8
        Layout.leftMargin: -24
    }
    component LabelH3: Label {
        MaterialYou.fontRole: MaterialYou.TitleSmall
    }
    component SeparatorH3: Item {
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
