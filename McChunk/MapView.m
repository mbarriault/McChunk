//
//  MapView.m
//  McChunk
//
//  Created by Michael Barriault on 11-07-04.
//  Copyright 2011 Michael Barriault. All rights reserved.
//  See LICENSE for copyright information
//

#import "MapView.h"
#import "ChunkView.h"

@implementation MapView

@synthesize regions;

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
    NSRect frame = NSMakeRect(wspan[0]*512, hspan[0]*512, (wspan[1]+1)*512, (hspan[1]+1)*512);
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
        [regions release];
        regions = [[NSMutableArray alloc] initWithCapacity:[files count]];
        for ( NSString *regionFile in files ) {
            [regions addObject:[[[RegionView alloc] initWithMap:mapDir andFile:regionFile andOffset:offset] autorelease]];
        }
    }
    for ( RegionView* region in regions )
        [self addSubview:region];
    
    return self;
}

- (void)dealloc
{
    [regions release];
    [super dealloc];
}

-(void)mouseDown:(NSEvent *)theEvent {
    startClick = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    NSLog(@"Got a down click! %f %f", startClick.x, startClick.y);
}

-(void)keyDown:(NSEvent *)theEvent {
    NSLog(@"Key pressed %d", [theEvent keyCode]);
}

-(void)mouseUp:(NSEvent *)theEvent {
    NSPoint stopClick = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    NSLog(@"Got an up click! %f %f", stopClick.x, stopClick.y);
    float xmin = startClick.x < stopClick.x ? startClick.x : stopClick.x;
    float ymin = startClick.y < stopClick.y ? startClick.y : stopClick.y;
    float xmax = startClick.x > stopClick.x ? startClick.x : stopClick.x;
    float ymax = startClick.y > stopClick.y ? startClick.y : stopClick.y;
    for ( RegionView* region in regions ) {
        NSRect regionFrame = [region frame];
        for ( ChunkView* chunk in region.chunks ) {
            NSRect chunkFrame = [chunk frame];
            if ( regionFrame.origin.x + chunkFrame.origin.x + chunkFrame.size.width >= xmin && regionFrame.origin.x + chunkFrame.origin.x <= xmax && regionFrame.origin.y + chunkFrame.origin.y + chunkFrame.size.height >= ymin && regionFrame.origin.y + chunkFrame.origin.y <= ymax ) {
                NSLog(@"Setting chunk to be active. %f %f", regionFrame.origin.y + chunkFrame.origin.x, regionFrame.origin.y + chunkFrame.origin.y);
                chunk.active = YES;
            } else {
                chunk.active = NO;
            }
        }
    }
    [self setNeedsDisplay:YES];
}



@end
