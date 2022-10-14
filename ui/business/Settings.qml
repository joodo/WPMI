pragma Singleton

import QtQuick
import Qt.labs.settings as Lab

Lab.Settings {
    property string state: ""

    property string resourceServer: "www.dandanzan10.top"

    property string proxy: ""
    onProxyChanged: Backend.setProxy(proxy)

    property string language: ""
}
