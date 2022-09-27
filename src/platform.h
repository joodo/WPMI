#ifndef PLATFORM_H
#define PLATFORM_H

#include <QQuickWindow>

namespace Platform
{
void hideTitleBar(QQuickWindow* window);
int setScreensaverEnabled(bool enable);
#ifdef Q_OS_MACOS
#endif
}

#endif // PLATFORM_H
