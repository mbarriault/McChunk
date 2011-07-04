//
//  RegionView.m
//  McChunk
//
//  Created by Michael Barriault on 11-07-04.
//  Copyright 2011 MikBarr Studios. All rights reserved.
//

#import "RegionView.h"


MCPixel MCPoint(CGFloat x, CGFloat y, NSColor* color) {
    MCPixel aPoint = NSMakeRect(x, y, 2, 2);
    [color set];
    NSRectFill(aPoint);
    return aPoint;
}

@implementation RegionView

- (id)initWithOrigin:(NSPoint)origin
{
    NSRect frame = NSMakeRect(origin.x, origin.y, 512, 512);
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (void)drawRect:(NSRect)dirtyRect
{
    // Drawing code here.
    MCPoint(50,25,[NSColor redColor]);
}

@end
