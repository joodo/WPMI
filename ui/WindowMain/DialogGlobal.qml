import QtQuick
import QtQuick.Controls
import MaterialYou

Dialog {
    id: dialog

    property var content

    onAboutToHide: content = null

    function exec(content, title, standardButtons) {
        dialog.content = content
        dialog.title = title || ""
        dialog.standardButtons = standardButtons || Dialog.NoButton
        dialog.open()
        return new Promise((resolve, reject) => {
                               dialog.accepted.connect(() => resolve())
                               dialog.rejected.connect(() => reject())
                           })
    }

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
