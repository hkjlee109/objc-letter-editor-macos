#import "AppDelegate.h"
#import "WindowController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate {
    WindowController* windowController;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    if(windowController == nil) {
        windowController = [WindowController new];
    }
    
    [windowController.window orderFront:self];
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}


- (BOOL)applicationSupportsSecureRestorableState:(NSApplication *)app {
    return YES;
}


@end
