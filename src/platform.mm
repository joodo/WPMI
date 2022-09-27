#import "platform.h"

#import <Cocoa/Cocoa.h>

#import <IOKit/pwr_mgt/IOPMLib.h>

using namespace Platform;

static IOPMAssertionID assertionID;

void Platform::hideTitleBar(QQuickWindow *w)
{
    NSWindow* window = [(NSView*)w->winId() window];
    window.styleMask = window.styleMask | NSWindowStyleMaskFullSizeContentView;
    window.titlebarAppearsTransparent = YES;
    window.titleVisibility = NSWindowTitleHidden;
}

int Platform::setScreensaverEnabled(bool enable)
{
    if (enable)
    {
        return IOPMAssertionRelease(assertionID);
    }
    else
    {
        CFStringRef reasonForActivity = CFSTR("Maximum Trainer Workout");
        return IOPMAssertionCreateWithName(kIOPMAssertionTypeNoDisplaySleep,
                                           kIOPMAssertionLevelOn, reasonForActivity, &assertionID);
    }
}
