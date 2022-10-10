import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import WPMI

Object {
    Component.onCompleted: {
        children.push(WindowMain)
        children.push(WindowPlayer)

        HttpManager.timeout = 5000;
    }

    Window {
        id: windowWebView
        //visible: true
        width: 600; height: 480
        Component.onCompleted: SingletonWebView.parent = contentItem
    }
    Window {
        //visible: true
        width: 600; height: 480
        Component.onCompleted: LeanCloud.parent = contentItem
    }

    Window {
        //visible: true
        width: 600; height: 480

        DialogRoom {
            anchors.fill: parent
        }
    }

    HttpRequest {
        id: updateChecker
        url: "http://127.0.0.1:8080/update_macos.json"
        Component.onCompleted: {
            const NewFeaturesFileName = "newfeatures.txt"

            // remove old exe file
            Backend.removeFile("old")

            // show new feature
            const versionChangeLog = Backend.readFile(NewFeaturesFileName)
            if (versionChangeLog) {
                Backend.removeFile(NewFeaturesFileName)
                const o = JSON.parse(versionChangeLog)
                let content = ""
                o.features.map(feature => content += `- ${feature}\n`)
                WindowMain.showDialog(content, qsTr("Updated to Version %1").arg(o.version))
            }

            // check update
            get().then(response => {
                           for (let info of response.versions) {
                               const currentVersion = Qt.application.version
                               if (currentVersion >= info.after && currentVersion < info.version) {
                                   const targetVersion = info.version
                                   get(info.url).then(newFile => {
                                                          // change permission
                                                          if (!Backend.setFilePermissions(newFile, 0x7555)) {
                                                              Backend.removeFile(newFile)
                                                              console.error("Update: Failed to change download file permission.")
                                                              return
                                                          }

                                                          // replace file
                                                          const exeName = Qt.application.arguments[0]
                                                          if (!Backend.removeFile(exeName)) {
                                                              if (!Backend.moveFile(exeName, "old")) {
                                                                  Backend.removeFile(newFile)
                                                                  console.error("Update: Failed to remove old exe.")
                                                                  return
                                                              }
                                                          }

                                                          Backend.moveFile(newFile, exeName)

                                                          // create new feature file
                                                          let newFeatures = []
                                                          for (let change of response.changelog) {
                                                              if (targetVersion < change.version) continue
                                                              if (currentVersion >= change.version) break
                                                              newFeatures.unshift(...change.new_features)
                                                          }

                                                          const content = {
                                                              version: targetVersion,
                                                              features: newFeatures,
                                                          }
                                                          Backend.writeFile(NewFeaturesFileName, JSON.stringify(content))
                                                      })
                                   break
                               }
                           }
                       })
        }
    }
}
