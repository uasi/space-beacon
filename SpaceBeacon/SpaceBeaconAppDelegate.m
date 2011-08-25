#import "SpaceBeaconAppDelegate.h"

#define kSpecialFinderWindowLevel (-2147483603)

@interface SpaceBeaconAppDelegate ()

- (void)setupWindow;
- (void)switchSpacesToSpace1;
- (void)activeSpaceDidChange:(NSNotification *)notification;
- (NSInteger)currentSpace;

@end

@implementation SpaceBeaconAppDelegate

@synthesize window;
@synthesize currentSpaceNumber;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [self setupWindow];
    
    NSNotificationCenter *center = [[NSWorkspace sharedWorkspace] notificationCenter];
    [center addObserver:self
               selector:@selector(activeSpaceDidChange:)
                   name:NSWorkspaceActiveSpaceDidChangeNotification
                 object:nil];
    
    // We need to switch to Space #1 for getting a special Window ID;
    // see - (NSInteger)currentSpace for the detail.
    [self switchSpacesToSpace1];
}

- (void)setupWindow {
    [window setStyleMask:NSBorderlessWindowMask];
    
    // Set window level lower than the level of a Finder's special window
    // so this window lays under the desktop icons and doesn't fade-out on Exposé'ing.
    [window setLevel:kSpecialFinderWindowLevel - 1];

    [window setOpaque:NO];
    [window setBackgroundColor:[NSColor clearColor]];
    
    [window setCollectionBehavior:NSWindowCollectionBehaviorCanJoinAllSpaces];
    
    NSRect frame = [[NSScreen mainScreen] frame];
    [window setFrame:frame display:YES];
}

- (void)switchSpacesToSpace1
{
    NSDistributedNotificationCenter *center = [NSDistributedNotificationCenter defaultCenter];
    [center postNotificationName:@"com.apple.switchSpaces"
                          object:@"0"];
}

- (void)activeSpaceDidChange:(NSNotification *)notification
{
    NSInteger currentSpace = [self currentSpace];
    [self setCurrentSpaceNumber:(currentSpace ? [NSNumber numberWithInteger:currentSpace] : nil)];
    DebugLog(@"Current space = %ld", currentSpace);
}

- (NSInteger)currentSpace
{
    static NSInteger firstDockWindowID = 0;
    NSInteger dockWindowID = 0;
    NSInteger workspace = 0;
    
    CFArrayRef windowsInSpace = CGWindowListCopyWindowInfo(kCGWindowListOptionAll | kCGWindowListOptionOnScreenOnly, kCGNullWindowID);   
    
    for (NSMutableDictionary *windowInfo in (NSArray *)windowsInSpace)
    {
        if (   [windowInfo objectForKey:(id)kCGWindowOwnerName]
            && [[windowInfo objectForKey:(id)kCGWindowOwnerName] isEqualToString:@"Dock"]
            && [windowInfo objectForKey:(id)kCGWindowWorkspace]) {
            
            dockWindowID = [[windowInfo objectForKey:(id)kCGWindowNumber] intValue];
            workspace = [[windowInfo objectForKey:(id)kCGWindowWorkspace] intValue];
            DebugLog(@"Dock window info = %@", windowInfo);
            break;
        }
    }
    
    if (firstDockWindowID == 0 && workspace == 1) {
        firstDockWindowID = dockWindowID;
    }
    
    if (firstDockWindowID != 0) {
        return (dockWindowID - firstDockWindowID) + 1;
    }
    else {
        // We don't know...
        return 0;
    }
}

@end
