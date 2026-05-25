#import "NXVGameView.h"
#include <stdlib.h>

static float NXVRandomFloat(float minValue, float maxValue)
{
    float r = (float)rand() / (float)RAND_MAX;
    return minValue + (maxValue - minValue) * r;
}

static NSPoint NXVProject(NXVVec3 p, NSRect bounds)
{
    float camera = 7.0f;
    float scale = bounds.size.height * 0.52f;
    float z = p.z + camera;
    if (z < 0.2f) {
        z = 0.2f;
    }
    return NSMakePoint(NSMidX(bounds) + (p.x / z) * scale,
                       NSMidY(bounds) + (p.y / z) * scale);
}

@implementation NXVGameView

- (id)initWithFrame:(NSRect)frameRect
{
    int i;
    self = [super initWithFrame:frameRect];
    if (self != nil) {
        srand(9);
        keyMask = 0;
        shipYaw = 0.0f;
        shipPitch = 0.0f;
        shipRoll = 0.0f;
        shipPos = NXVVec3Make(0.0f, 0.0f, 0.0f);
        shipVel = NXVVec3Make(0.0f, 0.0f, 0.025f);
        pulse = 0.0f;
        score = 0;
        shields = 100;
        boltCooldown = 0;
        frameCount = 0;
        hudFont = [[NSFont fontWithName:@"Menlo" size:12.0f] retain];
        if (hudFont == nil) {
            hudFont = [[NSFont userFixedPitchFontOfSize:12.0f] retain];
        }

        for (i = 0; i < 96; i++) {
            stars[i][0] = NXVRandomFloat(-16.0f, 16.0f);
            stars[i][1] = NXVRandomFloat(-10.0f, 10.0f);
            stars[i][2] = NXVRandomFloat(1.0f, 36.0f);
        }

        for (i = 0; i < 18; i++) {
            obstacles[i][0] = NXVRandomFloat(-5.0f, 5.0f);
            obstacles[i][1] = NXVRandomFloat(-3.6f, 3.6f);
            obstacles[i][2] = NXVRandomFloat(10.0f, 58.0f);
            obstacles[i][3] = NXVRandomFloat(0.22f, 0.72f);
        }

        for (i = 0; i < 12; i++) {
            bolts[i][3] = 0.0f;
        }
    }
    return self;
}

- (void)dealloc
{
    [timer invalidate];
    [timer release];
    [hudFont release];
    [super dealloc];
}

- (BOOL)acceptsFirstResponder
{
    return YES;
}

- (void)viewDidMoveToWindow
{
    [[self window] makeFirstResponder:self];
}

- (void)startGame
{
    if (timer == nil) {
        timer = [[NSTimer scheduledTimerWithTimeInterval:0.033
                                                  target:self
                                                selector:@selector(tick:)
                                                userInfo:nil
                                                 repeats:YES] retain];
    }
}

- (void)setMaskForEvent:(NSEvent *)event enabled:(BOOL)enabled
{
    NSString *chars;
    unichar c;
    unsigned int bit;

    bit = 0;
    chars = [event charactersIgnoringModifiers];
    if ([chars length] == 0) {
        return;
    }

    c = [chars characterAtIndex:0];
    if (c == NSLeftArrowFunctionKey || c == 'a' || c == 'A') {
        bit = NXVKeyLeft;
    } else if (c == NSRightArrowFunctionKey || c == 'd' || c == 'D') {
        bit = NXVKeyRight;
    } else if (c == NSUpArrowFunctionKey || c == 'w' || c == 'W') {
        bit = NXVKeyUp;
    } else if (c == NSDownArrowFunctionKey || c == 's' || c == 'S') {
        bit = NXVKeyDown;
    } else if (c == ' ') {
        bit = NXVKeyThrust;
    } else if (c == 'x' || c == 'X') {
        bit = NXVKeyBrake;
    } else if (c == 'f' || c == 'F') {
        bit = NXVKeyFire;
    }

    if (bit != 0) {
        if (enabled) {
            keyMask |= bit;
        } else {
            keyMask &= ~bit;
        }
    }
}

- (void)keyDown:(NSEvent *)event
{
    [self setMaskForEvent:event enabled:YES];
}

- (void)keyUp:(NSEvent *)event
{
    [self setMaskForEvent:event enabled:NO];
}

- (BOOL)isFlipped
{
    return NO;
}

- (void)fireBolt
{
    int i;
    if (boltCooldown > 0) {
        return;
    }

    for (i = 0; i < 12; i++) {
        if (bolts[i][3] <= 0.0f) {
            bolts[i][0] = shipPos.x;
            bolts[i][1] = shipPos.y;
            bolts[i][2] = 1.2f;
            bolts[i][3] = 1.0f;
            boltCooldown = 10;
            NSBeep();
            return;
        }
    }
}

- (void)tick:(NSTimer *)aTimer
{
    int i;
    float speed;
    float yawSin;
    float yawCos;

    frameCount++;
    pulse += 0.06f;
    if (boltCooldown > 0) {
        boltCooldown--;
    }

    if ((keyMask & NXVKeyLeft) != 0) {
        shipYaw -= 0.035f;
        shipRoll = -0.45f;
    } else if ((keyMask & NXVKeyRight) != 0) {
        shipYaw += 0.035f;
        shipRoll = 0.45f;
    } else {
        shipRoll *= 0.86f;
    }

    if ((keyMask & NXVKeyUp) != 0) {
        shipPitch += 0.028f;
    }
    if ((keyMask & NXVKeyDown) != 0) {
        shipPitch -= 0.028f;
    }
    if (shipPitch > 0.75f) {
        shipPitch = 0.75f;
    } else if (shipPitch < -0.75f) {
        shipPitch = -0.75f;
    }

    speed = 0.018f;
    if ((keyMask & NXVKeyThrust) != 0) {
        speed = 0.055f;
    }
    if ((keyMask & NXVKeyBrake) != 0) {
        speed = 0.006f;
    }
    if ((keyMask & NXVKeyFire) != 0) {
        [self fireBolt];
    }

    yawSin = sinf(shipYaw);
    yawCos = cosf(shipYaw);
    shipVel.x = yawSin * speed;
    shipVel.y = sinf(shipPitch) * speed;
    shipVel.z = yawCos * speed;
    shipPos = NXVVec3Add(shipPos, shipVel);

    if (shipPos.x < -5.5f) shipPos.x = -5.5f;
    if (shipPos.x > 5.5f) shipPos.x = 5.5f;
    if (shipPos.y < -3.8f) shipPos.y = -3.8f;
    if (shipPos.y > 3.8f) shipPos.y = 3.8f;

    for (i = 0; i < 96; i++) {
        stars[i][2] -= shipVel.z * 4.0f;
        stars[i][0] -= shipVel.x * 0.8f;
        stars[i][1] -= shipVel.y * 0.8f;
        if (stars[i][2] < 0.4f) {
            stars[i][0] = NXVRandomFloat(-16.0f, 16.0f);
            stars[i][1] = NXVRandomFloat(-10.0f, 10.0f);
            stars[i][2] = NXVRandomFloat(30.0f, 42.0f);
        }
    }

    for (i = 0; i < 18; i++) {
        float dx;
        float dy;
        obstacles[i][2] -= shipVel.z * 8.0f + 0.035f;
        obstacles[i][0] -= shipVel.x * 1.2f;
        obstacles[i][1] -= shipVel.y * 1.2f;

        dx = obstacles[i][0] - shipPos.x;
        dy = obstacles[i][1] - shipPos.y;
        if (obstacles[i][2] < 0.75f && fabsf(dx) < obstacles[i][3] + 0.28f &&
            fabsf(dy) < obstacles[i][3] + 0.22f) {
            shields -= 10;
            NSBeep();
            obstacles[i][2] = 45.0f;
        }

        if (obstacles[i][2] < 0.35f) {
            obstacles[i][0] = NXVRandomFloat(-5.0f, 5.0f);
            obstacles[i][1] = NXVRandomFloat(-3.6f, 3.6f);
            obstacles[i][2] = NXVRandomFloat(38.0f, 62.0f);
            obstacles[i][3] = NXVRandomFloat(0.22f, 0.72f);
            score += 5;
        }
    }

    for (i = 0; i < 12; i++) {
        int j;
        if (bolts[i][3] > 0.0f) {
            bolts[i][2] += 1.2f;
            bolts[i][3] -= 0.026f;
            for (j = 0; j < 18; j++) {
                float dx = bolts[i][0] - obstacles[j][0];
                float dy = bolts[i][1] - obstacles[j][1];
                float dz = bolts[i][2] - obstacles[j][2];
                if (fabsf(dx) < obstacles[j][3] && fabsf(dy) < obstacles[j][3] &&
                    fabsf(dz) < 1.0f) {
                    bolts[i][3] = 0.0f;
                    obstacles[j][0] = NXVRandomFloat(-5.0f, 5.0f);
                    obstacles[j][1] = NXVRandomFloat(-3.6f, 3.6f);
                    obstacles[j][2] = NXVRandomFloat(40.0f, 64.0f);
                    score += 25;
                    NSBeep();
                }
            }
            if (bolts[i][2] > 64.0f) {
                bolts[i][3] = 0.0f;
            }
        }
    }

    if (shields <= 0) {
        shields = 100;
        score = 0;
        shipPos = NXVVec3Make(0.0f, 0.0f, 0.0f);
        NSBeep();
    }

    [self setNeedsDisplay:YES];
}

- (void)drawLineFrom:(NXVVec3)a to:(NXVVec3)b color:(NSColor *)color width:(float)width
{
    NSBezierPath *path;
    NSRect bounds;
    bounds = [self bounds];
    path = [NSBezierPath bezierPath];
    [path setLineWidth:width];
    [path moveToPoint:NXVProject(a, bounds)];
    [path lineToPoint:NXVProject(b, bounds)];
    [color set];
    [path stroke];
}

- (void)drawReticleInRect:(NSRect)bounds
{
    NSPoint c;
    float r;
    [[NSColor colorWithCalibratedRed:0.24f green:0.86f blue:0.76f alpha:0.8f] set];
    c = NSMakePoint(NSMidX(bounds), NSMidY(bounds));
    r = 22.0f + sinf(pulse) * 2.0f;
    [NSBezierPath strokeLineFromPoint:NSMakePoint(c.x - r, c.y)
                              toPoint:NSMakePoint(c.x - 7.0f, c.y)];
    [NSBezierPath strokeLineFromPoint:NSMakePoint(c.x + 7.0f, c.y)
                              toPoint:NSMakePoint(c.x + r, c.y)];
    [NSBezierPath strokeLineFromPoint:NSMakePoint(c.x, c.y - r)
                              toPoint:NSMakePoint(c.x, c.y - 7.0f)];
    [NSBezierPath strokeLineFromPoint:NSMakePoint(c.x, c.y + 7.0f)
                              toPoint:NSMakePoint(c.x, c.y + r)];
}

- (void)drawObstacleAtIndex:(int)i
{
    NXVVec3 p[8];
    NXVVec3 center;
    float s;
    float r;
    int edges[12][2] = {
        {0, 1}, {1, 2}, {2, 3}, {3, 0},
        {4, 5}, {5, 6}, {6, 7}, {7, 4},
        {0, 4}, {1, 5}, {2, 6}, {3, 7}
    };
    int e;
    NSColor *color;

    s = obstacles[i][3];
    r = pulse * 0.7f + (float)i;
    center = NXVVec3Make(obstacles[i][0], obstacles[i][1], obstacles[i][2]);
    p[0] = NXVVec3Make(-s, -s, -s);
    p[1] = NXVVec3Make(s, -s, -s);
    p[2] = NXVVec3Make(s, s, -s);
    p[3] = NXVVec3Make(-s, s, -s);
    p[4] = NXVVec3Make(-s, -s, s);
    p[5] = NXVVec3Make(s, -s, s);
    p[6] = NXVVec3Make(s, s, s);
    p[7] = NXVVec3Make(-s, s, s);

    for (e = 0; e < 8; e++) {
        p[e] = NXVRotateX(NXVRotateY(p[e], r), r * 0.43f);
        p[e] = NXVVec3Add(p[e], center);
    }

    color = [NSColor colorWithCalibratedRed:0.95f green:0.38f blue:0.24f alpha:0.9f];
    for (e = 0; e < 12; e++) {
        [self drawLineFrom:p[edges[e][0]] to:p[edges[e][1]] color:color width:1.0f];
    }
}

- (void)drawStarsInRect:(NSRect)bounds
{
    int i;
    [[NSColor colorWithCalibratedWhite:0.72f alpha:0.85f] set];
    for (i = 0; i < 96; i++) {
        NSPoint p = NXVProject(NXVVec3Make(stars[i][0], stars[i][1], stars[i][2]), bounds);
        float size = 1.0f;
        if (stars[i][2] < 8.0f) {
            size = 2.0f;
        }
        NSRectFill(NSMakeRect(p.x, p.y, size, size));
    }
}

- (void)drawShipInRect:(NSRect)bounds
{
    NXVVec3 a;
    NXVVec3 b;
    NXVVec3 c;
    NXVVec3 d;
    NXVVec3 origin;
    NSColor *color;

    origin = NXVVec3Make(0.0f, -2.2f, 3.0f);
    a = NXVVec3Make(0.0f, 0.36f, 1.0f);
    b = NXVVec3Make(-0.62f, -0.26f, -0.25f);
    c = NXVVec3Make(0.62f, -0.26f, -0.25f);
    d = NXVVec3Make(0.0f, -0.1f, -0.72f);

    a = NXVVec3Add(NXVRotateZ(a, shipRoll), origin);
    b = NXVVec3Add(NXVRotateZ(b, shipRoll), origin);
    c = NXVVec3Add(NXVRotateZ(c, shipRoll), origin);
    d = NXVVec3Add(NXVRotateZ(d, shipRoll), origin);

    color = [NSColor colorWithCalibratedRed:0.45f green:0.92f blue:1.0f alpha:0.9f];
    [self drawLineFrom:a to:b color:color width:1.4f];
    [self drawLineFrom:a to:c color:color width:1.4f];
    [self drawLineFrom:b to:d color:color width:1.1f];
    [self drawLineFrom:c to:d color:color width:1.1f];
    [self drawLineFrom:d to:a color:color width:1.0f];
}

- (void)drawBolts
{
    int i;
    NSColor *color;
    color = [NSColor colorWithCalibratedRed:0.95f green:0.94f blue:0.42f alpha:0.9f];
    for (i = 0; i < 12; i++) {
        if (bolts[i][3] > 0.0f) {
            NXVVec3 a = NXVVec3Make(bolts[i][0], bolts[i][1], bolts[i][2]);
            NXVVec3 b = NXVVec3Make(bolts[i][0], bolts[i][1], bolts[i][2] + 1.4f);
            [self drawLineFrom:a to:b color:color width:2.0f];
        }
    }
}

- (void)drawHudInRect:(NSRect)bounds
{
    NSString *hud;
    NSDictionary *attrs;
    NSColor *hudColor;
    float velocity;

    velocity = NXVVec3Length(shipVel) * 1000.0f;
    hud = [NSString stringWithFormat:@"NX_VOID  SCORE %05d  SHIELD %03d  VEL %03d",
                                     score, shields, (int)velocity];
    hudColor = [NSColor colorWithCalibratedRed:0.48f green:0.96f blue:0.78f alpha:0.95f];
    attrs = [NSDictionary dictionaryWithObjectsAndKeys:hudFont, NSFontAttributeName,
                                                       hudColor, NSForegroundColorAttributeName,
                                                       nil];
    [hud drawAtPoint:NSMakePoint(14.0f, bounds.size.height - 24.0f) withAttributes:attrs];

    hud = @"A/D or arrows turn  W/S pitch  Space thrust  X brake  F fire";
    [hud drawAtPoint:NSMakePoint(14.0f, 12.0f) withAttributes:attrs];
}

- (void)drawRect:(NSRect)dirtyRect
{
    int i;
    NSRect bounds;
    bounds = [self bounds];

    [[NSColor colorWithCalibratedRed:0.015f green:0.018f blue:0.024f alpha:1.0f] set];
    NSRectFill(bounds);

    [self drawStarsInRect:bounds];

    [[NSColor colorWithCalibratedRed:0.08f green:0.16f blue:0.20f alpha:0.45f] set];
    for (i = 0; i < 8; i++) {
        float z = 4.0f + (float)i * 4.0f - fmodf(pulse * 3.0f, 4.0f);
        [self drawLineFrom:NXVVec3Make(-6.0f, -3.4f, z)
                        to:NXVVec3Make(6.0f, -3.4f, z)
                     color:[NSColor colorWithCalibratedRed:0.08f green:0.18f blue:0.22f alpha:0.55f]
                     width:0.7f];
    }

    for (i = 0; i < 18; i++) {
        [self drawObstacleAtIndex:i];
    }

    [self drawBolts];
    [self drawShipInRect:bounds];
    [self drawReticleInRect:bounds];
    [self drawHudInRect:bounds];
}

@end
