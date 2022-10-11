QT += quick webenginequick network svg xml

SOURCES += \
    backend.cpp \
    httprequest.cpp \
    main.cpp \
    ui/MaterialYou/materialyou.cpp

RESOURCES += \
    assets/assets.qrc \
    qtquickcontrols2.conf \
    ui/DialogRoom.qml \
    ui/Session.qml \
    ui/WindowMain.qml \
    ui/WindowPlayer.qml \
    ui/qmldir \
    ui/Object.qml \
    ui/Main.qml \
    ui/HttpRequest.qml \
    ui/OrderedMapModel.qml \
    ui/ListModelWrapper.qml \
    ui/SingletonWebView.qml \
    ui/StackSettings.qml \
    ui/CardMoive.qml \
    ui/SiteDandanzan/StackSearch.qml \
    ui/FieldSearch.qml \
    ui/HandleWindows.qml \
    ui/HandlerWindowDrag.qml \
    ui/ProgressNetwork.qml \
    ui/MaterialYou/resources.qrc \
    ui/MediaPlayer/MediaPlayer.qml \
    ui/MediaPlayer/PaneBlur.qml \
    ui/QRCode/QRCode.qml \
    ui/QRCode/qrcode.js \
    ui/LeanCloud/av-min.js \
    ui/LeanCloud/im-browser.min.js \
    ui/LeanCloud/LeanCloud.html \
    ui/LeanCloud/LeanCloud.qml \
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

HEADERS += \
    backend.h \
    httprequest.h \
    platform.h \
    ui/MaterialYou/materialyou.h


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
    ICON = WPMI.icns

    OBJECTIVE_SOURCES += platform.macos.mm

    LIBS += -framework Foundation
}

win32 {
    RC_ICONS = WPMI.ico

    SOURCES += platform.windows.cpp
}

DISTFILES +=
