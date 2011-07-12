//
//  MapView.m
//  McChunk
//
//  Created by Michael Barriault on 11-07-04.
//  Copyright 2011 MikBarr Studios. All rights reserved.
//

#import "MapView.h"

@implementation MapView

- (id)initWithMap:(NSString*)mapDir {
    NSArray* files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[NSString stringWithFormat:@"%@", mapDir] error:NULL];
    NSLog(@"%@", files);
    int wspan[2], hspan[2];
    for ( int i=0; i<2; i++ )
        wspan[i] = hspan[i] = 0;
    for ( NSString* file in files ) {
        NSArray* comps = [file componentsSeparatedByString:@"."];
        if ( [[comps objectAtIndex:1] intValue] < wspan[0] )
            wspan[0] = [[comps objectAtIndex:1] intValue];
        if ( [[comps objectAtIndex:1] intValue] > wspan[1] )
            wspan[1] = [[comps objectAtIndex:1] intValue];
        if ( [[comps objectAtIndex:2] intValue] < hspan[0] )
            hspan[0] = [[comps objectAtIndex:2] intValue];
        if ( [[comps objectAtIndex:2] intValue] > hspan[1] )
            hspan[1] = [[comps objectAtIndex:2] intValue];
    }
    NSPoint offset = NSMakePoint(wspan[0], hspan[0]);
    for ( int i=1; i>=0; i-- ) {
        wspan[i] = wspan[i]-wspan[0];
        hspan[i] = hspan[i]-hspan[0];
    }
    NSRect frame = NSMakeRect(wspan[0]*512, hspan[0]*512, (wspan[1]-wspan[0]+1)*512, (hspan[1]-hspan[0]+1)*512);
    NSLog(@"!MapView frame %f %f, %f %f", frame.origin.x, frame.origin.y, frame.size.width, frame.size.height);
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
        [regions release];
        regions = [[NSMutableArray alloc] initWithCapacity:[files count]];
        for ( NSString *regionFile in files )
            [regions addObject:[[[RegionView alloc] initWithMap:mapDir andFile:regionFile andOffset:offset] autorelease]];
    }
    
    return self;
}

- (void)awakeFromNib {
    NSLog(@"MapView frame %f %f, %f %f", [self frame].origin.x, [self frame].origin.y, [self frame].size.width, [self frame].size.height);
    for ( RegionView* region in regions )
        [self addSubview:region];
}

- (void)dealloc
{
    [regions release];
    [super dealloc];
}

- (void)drawRect:(NSRect)dirtyRect
{
    // Drawing code here.
    NSLog(@"Redrawn map!");
    for ( RegionView* region in regions )
        [self addSubview:region];
}

@end
