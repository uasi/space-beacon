#import <Cocoa/Cocoa.h>

@interface SpaceBeaconAppDelegate : NSObject <NSApplicationDelegate> {
@private
    NSWindow *window;
    NSNumber *currentSpaceNumber;
}

@property(assign) IBOutlet NSWindow *window;
@property(retain) IBOutlet NSNumber *currentSpaceNumber;

@end
