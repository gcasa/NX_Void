#import <AppKit/AppKit.h>
#import "NXVMath.h"

enum {
    NXVKeyLeft = 1 << 0,
    NXVKeyRight = 1 << 1,
    NXVKeyUp = 1 << 2,
    NXVKeyDown = 1 << 3,
    NXVKeyThrust = 1 << 4,
    NXVKeyBrake = 1 << 5,
    NXVKeyFire = 1 << 6
};

@interface NXVGameView : NSView
{
    NSTimer *timer;
    unsigned int keyMask;
    float shipYaw;
    float shipPitch;
    float shipRoll;
    NXVVec3 shipPos;
    NXVVec3 shipVel;
    float stars[96][3];
    float obstacles[18][4];
    float bolts[12][4];
    float pulse;
    int score;
    int shields;
    int boltCooldown;
    int frameCount;
    NSFont *hudFont;
}

- (void)startGame;
- (void)tick:(NSTimer *)aTimer;

@end
