import QtQuick 2.0
import "qrcode.js" as QRCodeBackend

Canvas {
    id: canvas

    enum CorrectLevel {
        L = 1,
        M = 0,
        Q = 3,
        H = 2
    }

    // background colour to be used
    property color background : "white"
    // foreground colour to be used
    property color foreground : "black"
    // ECC level to be applied (e.g. L, M, Q, H)
    property int correctLevel : QRCode.M
    // value to be encoded in the generated QR code
    property string text : ""

    implicitHeight: height; implicitWidth: width

    onPaint : {
        QRCodeBackend.drawQRCode({
                                     canvas,
                                     width: Math.min(canvas.width, canvas.height),
                                     background,
                                     foreground,
                                     text,
                                     correctLevel,
                                 })
    }

    onHeightChanged : requestPaint()
    onWidthChanged : requestPaint()
    onBackgroundChanged : requestPaint()
    onForegroundChanged : requestPaint()
    onCorrectLevelChanged : requestPaint()
    onTextChanged : requestPaint()
}
