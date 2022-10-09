/*
 * https://m3.material.io/components/text-fields/overview
 * TODO: Filled type, Leading icon, Supporting text, Trailing icon, error status
 */

import QtQuick
import QtQuick.Templates as T
import QtQuick.Controls.impl
import QtQuick.Shapes
import MaterialYou
import MaterialYou.impl

T.TextField {
    id: control

    implicitWidth: implicitBackgroundWidth + leftInset + rightInset
                   || Math.max(contentWidth, placeholder.implicitWidth) + leftPadding + rightPadding
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             contentHeight + topPadding + bottomPadding,
                             placeholder.implicitHeight + topPadding + bottomPadding)

    topPadding: 8; bottomPadding: 8

    selectByMouse: true

    MaterialYou.foregroundColor: MaterialYou.OnSurface
    color: MaterialYou.foregroundColor
    selectionColor: MaterialYou.color(MaterialYou.Primary)
    selectedTextColor: MaterialYou.color(MaterialYou.OnPrimary)
    placeholderTextColor: MaterialYou.color(MaterialYou.OnSurfaceVariant)
    verticalAlignment: TextInput.AlignVCenter
    opacity: enabled? 1 : 0.38

    MaterialYou.fontRole: MaterialYou.BodyLarge
    font: MaterialYou.font(MaterialYou.fontRole)

    MaterialYou.animDuration: 250

    cursorDelegate: CursorDelegate { }


    property string prefix: ""
    property string sufix: ""
    Text {
        id: textPrefix
        visible: !placeholder.visible || placeholder.state === "positioned"
        rightPadding: 2
        anchors { left: parent.left; leftMargin: 16; verticalCenter: parent.verticalCenter }
        text: control.prefix
        color: control.placeholderTextColor
        font: parent.font
    }
    Text {
        id: textSufix
        visible: !placeholder.visible || placeholder.state === "positioned"
        leftPadding: 2
        anchors { right: parent.right; rightMargin: 16; verticalCenter: parent.verticalCenter }
        text: control.sufix
        color: control.placeholderTextColor
        font: parent.font
    }
    leftPadding: 16 + textPrefix.implicitWidth
    rightPadding: 16 + textSufix.implicitWidth


    property bool placeholderPositionable: true
    Text {
        id: placeholder
        text: control.placeholderText
        verticalAlignment: control.verticalAlignment
        renderType: control.renderType
        // TODO: AlignHCenter case
        // visible: !control.length && !control.preeditText && (!control.activeFocus || control.horizontalAlignment !== Qt.AlignHCenter)
        Behavior on font.pointSize {
            NumberAnimation {
                duration: control.MaterialYou.animDuration
                easing.type: Easing.OutCubic
            }
        }
        states: [
            State {
                name: "positioned"
                when: (control.placeholderPositionable
                       && control.placeholderText
                       && (control.activeFocus || control.length || control.preeditText))
                PropertyChanges {
                    target: placeholder
                    x: textPositioned.x
                    y: textPositioned.y
                    width: textPositioned.width
                    height: textPositioned.height
                    font: textPositioned.font
                    color: shape.borderColor
                    opacity: control.background.opacity
                }
                PropertyChanges {
                    target: shape
                    state: "positioned"
                }
            },
            State {
                name: "hidden"
                extend: "normal"
                when: !control.placeholderText || !control.placeholderPositionable && (control.length
                                                                                       || control.preeditText
                                                                                       || (control.activeFocus && (control.prefix || control.sufix)))
                PropertyChanges {
                    target: placeholder
                    visible: false
                }
            },
            State {
                name: "normal"
                when: true
                PropertyChanges {
                    target: placeholder
                    x: 16
                    y: control.topPadding
                    width: control.width - (control.leftPadding + control.rightPadding)
                    height: control.height - (control.topPadding + control.bottomPadding)
                    font: control.font
                    color: control.placeholderTextColor
                }
                PropertyChanges {
                    target: shape
                    state: "normal"
                }
            }
        ]
        state: "normal"
        transitions: Transition {
            NumberAnimation {
                properties: "x, y, width, height"
                duration: control.MaterialYou.animDuration
                easing.type: Easing.OutCubic
            }
            ColorAnimation {
                property: "color"
                duration: control.MaterialYou.animDuration
            }
        }
    }

    background: Item {
        implicitWidth: 200
        implicitHeight: 56
        opacity: control.enabled? 1 : 0.12/control.opacity

        Text {
            id: textPositioned
            x: 16
            anchors.verticalCenter: parent.top
            font: MaterialYou.font(MaterialYou.BodySmall)
            text: control.placeholderText
            color: "transparent"
        }

        Item {
            anchors { fill: parent; margins: -10 }
            layer { enabled: true; smooth: true; samples: 8 }
            Shape {
                id: shape
                anchors { fill: parent; margins: 10 }
                property color borderColor: control.activeFocus ? MaterialYou.color(MaterialYou.Primary) :
                                                                  !control.enabled || control.hovered? MaterialYou.color(MaterialYou.OnSurface) :
                                                                                                       MaterialYou.color(MaterialYou.Outline)
                readonly property int radius: 4
                property int positionWidth
                Behavior on positionWidth {
                    NumberAnimation {
                        duration: control.MaterialYou.animDuration
                        easing.type: Easing.OutCubic
                    }
                }
                states: [
                    State {
                        name: "normal"
                        PropertyChanges {
                            target: shape
                            positionWidth: 0
                        }
                    },
                    State {
                        name: "positioned"
                        PropertyChanges {
                            target: shape
                            positionWidth: textPositioned.width + 8
                        }
                    }
                ]

                ShapePath {
                    startX: shape.radius; startY: 0
                    strokeColor: shape.borderColor
                    Behavior on strokeColor { ColorAnimation { duration: control.MaterialYou.animDuration } }
                    strokeWidth: control.activeFocus ? 2 : 1
                    Behavior on strokeWidth { NumberAnimation { duration: control.MaterialYou.animDuration } }
                    fillColor: "transparent"
                    capStyle: ShapePath.FlatCap

                    PathLine {
                        x: 16 + (textPositioned.width)/2 - shape.positionWidth/2
                    }
                    PathMove {
                        relativeX: shape.positionWidth
                    }
                    PathLine {
                        x: shape.width - shape.radius
                    }
                    PathArc {
                        relativeX: shape.radius; relativeY: shape.radius
                        radiusX: shape.radius; radiusY: shape.radius
                    }
                    PathLine {
                        relativeX: 0
                        relativeY: shape.height - 2*shape.radius
                    }
                    PathArc {
                        relativeX: -shape.radius; relativeY: shape.radius
                        radiusX: shape.radius; radiusY: shape.radius
                    }
                    PathLine {
                        relativeX: -shape.width + 2*shape.radius
                        relativeY: 0
                    }
                    PathArc {
                        relativeX: -shape.radius; relativeY: -shape.radius
                        radiusX: shape.radius; radiusY: shape.radius
                    }
                    PathLine {
                        relativeX: 0
                        relativeY: -shape.height + 2*shape.radius
                    }
                    PathArc {
                        relativeX: shape.radius; relativeY: -shape.radius
                        radiusX: shape.radius; radiusY: shape.radius
                    }
                }
            }
        }
    }
}
