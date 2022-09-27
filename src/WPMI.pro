QT += quick webenginequick network svg xml

SOURCES += \
    backend.cpp \
    main.cpp \
    platform.mm \
    ui/MaterialYou/materialyou.cpp

RESOURCES += \
    assets/assets.qrc \
    qtquickcontrols2.conf \
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
    ui/HandlerWindowDrag.qml \
    ui/ProgressNetwork.qml \
    ui/PaneBlur.qml \
    ui/QRCode/QRCode.qml \
    ui/QRCode/qrcode.js \
    ui/MaterialYou/resources.qrc

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH = $${PWD}/ui

# Additional import path used to resolve QML modules just for Qt Quick Designer
QML_DESIGNER_IMPORT_PATH =

# Default rules for deployment.
qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target

HEADERS += \
    backend.h \
    platform.h \
    ui/MaterialYou/materialyou.h

ICON = WPMI.icns

# i18n
QM_FILES_RESOURCE_PREFIX = "i18n"
DEFINES += QM_FILES_RESOURCE_PREFIX=\\\":/$$QM_FILES_RESOURCE_PREFIX\\\"
TRANSLATIONS = \
    translations/en_US.ts \
    translations/zh_CN.ts

# Version
system("git describe") {
    DEFINES += APP_VERSION=\"\\\"$${system(git describe)}\\\"\"
} else {
    DEFINES += APP_VERSION=\\\"1.0\\\"
}
