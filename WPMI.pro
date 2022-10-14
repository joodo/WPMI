QT += quick webenginequick network svg xml

HEADERS += \
    src/backend.h \
    src/httprequest.h \
    src/platform.h \
    modules/MaterialYou/materialyou.h

SOURCES += \
    src/backend.cpp \
    src/httprequest.cpp \
    src/main.cpp \
    modules/MaterialYou/materialyou.cpp

RESOURCES += \
    assets/assets.qrc \
    modules/MaterialYou/materialyou.qrc \
    qtquickcontrols2.conf \
    # "ui" is a magic path name
    ui/qmldir \
    ui/Main.qml \
    ui/business/UpdateChecker.qml \
    ui/business/Session.qml \
    ui/business/Settings.qml \
    ui/business/TrivialSettings.qml \
    ui/business/Object.qml \
    ui/business/HttpRequest.qml \
    ui/business/OrderedMapModel.qml \
    ui/business/ListModelWrapper.qml \
    ui/business/SingletonWebView.qml \
    ui/components/DialogRoom.qml \
    ui/components/CardMoive.qml \
    ui/components/FieldSearch.qml \
    ui/components/HandlerWindowDrag.qml \
    ui/components/ProgressNetwork.qml \
    ui/components/HeaderShadow.qml \
    ui/WindowMain/WindowMain.qml \
    ui/WindowMain/StackSettings.qml \
    ui/WindowMain/HandleWindows.qml \
    ui/WindowMain/DialogGlobal.qml \
    ui/WindowMain/DropAreaKeys.qml \
    ui/WindowMain/ComboBoxTitle.qml \
    ui/WindowPlayer/WindowPlayer.qml \
    ui/WindowPlayer/RectScreen.qml \
    ui/WindowPlayer/PaneController.qml \
    ui/WindowPlayer/VideoProgressBar.qml \
    ui/WindowPlayer/PaneBlur.qml \
    ui/QRCode/QRCode.qml \
    ui/QRCode/qrcode.js \
    ui/LeanCloud/av-min.js \
    ui/LeanCloud/im-browser.min.js \
    ui/LeanCloud/LeanCloud.html \
    ui/LeanCloud/LeanCloud.qml \
    ui/SiteDandanzan/StackSearch.qml \
    ui/SiteDandanzan/SiteDandanzan.qml \
    ui/SiteDandanzan/StackHistory.qml \
    ui/SiteDandanzan/StackMovieDetail.qml \
    ui/SiteJable/SiteJable.qml

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH = $${PWD}/ui

# Default rules for deployment.
qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target


# Translation
CONFIG += lrelease embed_translations

TRANSLATIONS = \
    translations/en_US.ts \
    translations/zh_CN.ts

RESOURCES += \
    translations/qt/qtbase_zh_CN.qm


# Version
system("git describe --tags") {
    DEFINES += APP_VERSION=\"\\\"$${system(git describe --tags)}\\\"\"
} else {
    DEFINES += APP_VERSION=\\\"0.0.0\\\"
}


# LeanCloud
DEFINES += \
    LEANCLOUD_APP=\\\"$$(LEANCLOUD_APP)\\\" \
    LEANCLOUD_KEY=\\\"$$(LEANCLOUD_KEY)\\\" \


# Platform
macx {
    ICON = assets/WPMI.icns

    OBJECTIVE_SOURCES += src/platform.macos.mm

    LIBS += -framework Foundation
}

win32 {
    RC_ICONS = assets/WPMI.ico

    SOURCES += src/platform.windows.cpp
}

DISTFILES +=
