QT += quick webenginequick network svg xml

SOURCES += \
    backend.cpp \
    main.cpp \
    ui/MaterialYou/materialyou.cpp

RESOURCES += \
    assets/assets.qrc \
    qtquickcontrols2.conf \
    translations/translations.qrc \
    ui/OrderedMapModel.qml \
    ui/ListModelWrapper.qml \
    ui/SingletonWindowMain.qml \
    ui/SingletonWindowPlayer.qml \
    ui/SingletonState.qml \
    ui/qmldir \
    ui/Main.qml \
    ui/SingletonWebView.qml \
    ui/StackMovies.qml \
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
    ui/LabelRequireRestart.qml \
    ui/QRCode/QRCode.qml \
    ui/QRCode/qrcode.js \
    ui/MaterialYou/resources.qrc

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH = $${PWD}/ui

# Default rules for deployment.
qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target

HEADERS += \
    backend.h \
    platform.h \
    ui/MaterialYou/materialyou.h

# Translation
TRANSLATIONS = \
    translations/en_US.ts \
    translations/zh_CN.ts
CONFIG += lrelease embed_translations

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
