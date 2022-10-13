/****************************************************************************
**
** Copyright (C) 2017 The Qt Company Ltd.
** Contact: https://www.qt.io/licensing/
**
** This file is part of the Qt Quick Controls 2 module of the Qt Toolkit.
**
** $QT_BEGIN_LICENSE:LGPL$
** Commercial License Usage
** Licensees holding valid commercial Qt licenses may use this file in
** accordance with the commercial license agreement provided with the
** Software or, alternatively, in accordance with the terms contained in
** a written agreement between you and The Qt Company. For licensing terms
** and conditions see https://www.qt.io/terms-conditions. For further
** information use the contact form at https://www.qt.io/contact-us.
**
** GNU Lesser General Public License Usage
** Alternatively, this file may be used under the terms of the GNU Lesser
** General Public License version 3 as published by the Free Software
** Foundation and appearing in the file LICENSE.LGPL3 included in the
** packaging of this file. Please review the following information to
** ensure the GNU Lesser General Public License version 3 requirements
** will be met: https://www.gnu.org/licenses/lgpl-3.0.html.
**
** GNU General Public License Usage
** Alternatively, this file may be used under the terms of the GNU
** General Public License version 2.0 or (at your option) the GNU General
** Public license version 3 or any later version approved by the KDE Free
** Qt Foundation. The licenses are as published by the Free Software
** Foundation and appearing in the file LICENSE.GPL2 and LICENSE.GPL3
** included in the packaging of this file. Please review the following
** information to ensure the GNU General Public License requirements will
** be met: https://www.gnu.org/licenses/gpl-2.0.html and
** https://www.gnu.org/licenses/gpl-3.0.html.
**
** $QT_END_LICENSE$
**
****************************************************************************/

import QtQuick
import QtQuick.Templates as T
import QtQuick.Controls.impl
// TODO: clean ElevationEffect
import QtQuick.Controls.Material.impl
import QtQuick.Layouts
import MaterialYou

T.Dialog {
    id: control

    enum DialogAlignment {
        AlignLeft,
        AlignCenter
    }
    property int alignment: Dialog.AlignLeft

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            contentWidth + leftPadding + rightPadding,
                            implicitHeaderWidth,
                            implicitFooterWidth)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             contentHeight + topPadding + bottomPadding
                             + (implicitHeaderHeight > 0 ? implicitHeaderHeight + spacing : 0)
                             + (implicitFooterHeight > 0 ? implicitFooterHeight + spacing : 0))

    horizontalPadding: 24
    bottomPadding: 24

    MaterialYou.elevation: 3
    MaterialYou.backgroundColor: MaterialYou.tintSurfaceColor(3)

    enter: Transition {
        // grow_fade_in
        NumberAnimation { property: "scale"; from: 0.9; to: 1.0; easing.type: Easing.OutQuint; duration: 220 }
        NumberAnimation { property: "opacity"; from: 0.0; to: 1.0; easing.type: Easing.OutCubic; duration: 150 }
    }

    exit: Transition {
        // shrink_fade_out
        NumberAnimation { property: "scale"; from: 1.0; to: 0.9; easing.type: Easing.OutQuint; duration: 220 }
        NumberAnimation { property: "opacity"; from: 1.0; to: 0.0; easing.type: Easing.OutCubic; duration: 150 }
    }

    background: Pane {
        MaterialYou.radius: 20
        MaterialYou.backgroundColor: control.MaterialYou.backgroundColor
        MaterialYou.elevation: control.MaterialYou.elevation
    }

    header: Label {
        text: control.title
        visible: control.title
        elide: Label.ElideRight
        horizontalAlignment: control.alignment === Dialog.AlignLeft? Text.AlignLeft : Text.AlignHCenter
        padding: 24
        bottomPadding: 16
        MaterialYou.fontRole: MaterialYou.HeadlineSmall
    }

    footer: DialogButtonBox {
    }

    dim: true
    // be careful to set modal: true
    // they have save apparence, but modal dialog will cause background Pane unclickable
    // that will cause focus problem
    modal: false

    T.Overlay.modal: Rectangle {
        color: "#30000000"
        Behavior on opacity { NumberAnimation { duration: 150 } }
    }

    T.Overlay.modeless: Rectangle {
        // simulate modal dialog
        MouseArea { anchors.fill: parent }

        color: "#30000000"
        Behavior on opacity { NumberAnimation { duration: 150 } }
    }
}
