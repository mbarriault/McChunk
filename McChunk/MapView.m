//
//  MapView.m
//  McChunk
//
//  Created by Michael Barriault on 11-07-04.
//  Copyright 2011 MikBarr Studios. All rights reserved.
//

#import "MapView.h"

@implementation MapView

- (void)awakeFromNib {
    [window setDelegate:self];
    regionView = [[RegionView alloc] initWithOrigin:NSMakePoint(0, 0)];
    [self addSubview:regionView];
}

- (void)windowWillClose:(NSNotification*)aNotification {
    [NSApp terminate:self];
}

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)dealloc
{
    [regionView release];
    [super dealloc];
}

- (IBAction)openRegion:(id)sender {
    NSOpenPanel* open = [NSOpenPanel openPanel];
    [open setCanChooseDirectories:YES];
    [open setCanChooseFiles:NO];
//    [open setDirectoryURL:[NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/Library/Application Support/minecraft/saves", NSHomeDirectory()] isDirectory:YES]];
    if ( [open runModalForDirectory:nil file:nil] == NSOKButton ) {
        NSString* world = [open filename];
        NSLog(@"%@", world);
    }
}

- (void)drawRect:(NSRect)dirtyRect
{
    // Drawing code here.
    NSLog(@"%f %f, %f %f", dirtyRect.origin.x, dirtyRect.origin.y, dirtyRect.size.width, dirtyRect.size.height);
    NSBezierPath *path = [NSBezierPath bezierPath];
    [path setLineWidth: 4];
    
    NSPoint startPoint = {  21, 21 };
    NSPoint endPoint   = { 128,128 };
    
    [path moveToPoint: startPoint];	
    
    [path curveToPoint: endPoint
         controlPoint1: NSMakePoint ( 128, 21 )
         controlPoint2: NSMakePoint (  21,128 )];
    
    [[NSColor whiteColor] set];
    [path fill];
    
    [[NSColor grayColor] set]; 
    [path stroke];
}

@end
