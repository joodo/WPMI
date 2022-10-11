#include <QQuickWindow>
#include <windows.h>

#include "platform.h"

using namespace Platform;

void Platform::hideTitleBar(QQuickWindow *w)
{
    w->setFlag(Qt::CustomizeWindowHint, true);
}

int Platform::setScreensaverEnabled(bool enable)
{
    return SetThreadExecutionState(enable? ES_CONTINUOUS : ES_DISPLAY_REQUIRED);
}
