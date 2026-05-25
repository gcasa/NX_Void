#import <AppKit/AppKit.h>
#import "NXVGameView.h"

@interface NXVAppDelegate : NSObject <NSApplicationDelegate>
{
    NSWindow *window;
    NXVGameView *gameView;
}
- (void)applicationDidFinishLaunching:(NSNotification *)notification;
- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender;
@end

@implementation NXVAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
    NSRect frame;
    NSUInteger style;

    frame = NSMakeRect(100.0f, 100.0f, 960.0f, 640.0f);
#if defined(__APPLE__)
    style = NSWindowStyleMaskTitled | NSWindowStyleMaskClosable |
            NSWindowStyleMaskMiniaturizable | NSWindowStyleMaskResizable;
#else
    style = NSTitledWindowMask | NSClosableWindowMask | NSMiniaturizableWindowMask | NSResizableWindowMask;
#endif
    window = [[NSWindow alloc] initWithContentRect:frame
                                         styleMask:style
                                           backing:NSBackingStoreBuffered
                                             defer:NO];
    [window setTitle:@"NX_Void"];
    [window setMinSize:NSMakeSize(640.0f, 420.0f)];

    gameView = [[NXVGameView alloc] initWithFrame:[[window contentView] bounds]];
    [gameView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    [window setContentView:gameView];
    [window makeKeyAndOrderFront:nil];
    [gameView startGame];

#if defined(__APPLE__)
    [NSApp activateIgnoringOtherApps:YES];
#endif
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
    return YES;
}

- (void)dealloc
{
    [gameView release];
    [window release];
    [super dealloc];
}

@end

int main(int argc, const char *argv[])
{
    NSAutoreleasePool *pool;
    NXVAppDelegate *delegate;

    pool = [[NSAutoreleasePool alloc] init];
    [NSApplication sharedApplication];
    delegate = [[NXVAppDelegate alloc] init];
    [NSApp setDelegate:delegate];
    [NSApp run];
    [delegate release];
    [pool release];
    return 0;
}
