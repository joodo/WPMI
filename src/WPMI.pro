QT += quick webenginequick network svg xml

SOURCES += \
    backend.cpp \
    httprequest.cpp \
    main.cpp \
    ui/MaterialYou/materialyou.cpp

RESOURCES += \
    assets/assets.qrc \
    qtquickcontrols2.conf \
    ui/SiteDandanzan.qml \
    ui/WindowMain.qml \
    ui/WindowPlayer.qml \
    ui/qmldir \
    ui/Object.qml \
    ui/Main.qml \
    ui/HttpRequest.qml \
    ui/OrderedMapModel.qml \
    ui/ListModelWrapper.qml \
    ui/SingletonState.qml \
    ui/SingletonWebView.qml \
    ui/StackHistory.qml \
    ui/StackMovieDetail.qml \
    ui/StackSettings.qml \
    ui/CardMoive.qml \
    ui/StackSearch.qml \
    ui/FieldSearch.qml \
    ui/HandleWindows.qml \
    ui/HandlerWindowDrag.qml \
    ui/ProgressNetwork.qml \
    ui/PaneBlur.qml \
    ui/QRCode/QRCode.qml \
    ui/QRCode/qrcode.js \
    ui/SiteJable.qml \
    ui/MaterialYou/resources.qrc

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

DISTFILES += \
