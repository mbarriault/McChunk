//
//  MapViewController.m
//  McChunk
//
//  Created by Michael Barriault on 11-07-05.
//  Copyright 2011 Michael Barriault. All rights reserved.
//  See LICENSE for copyright information
//

#import "MapViewController.h"
#import "ChunkView.h"

@implementation MapViewController

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)awakeFromNib {
    [window setDelegate:self];
}

- (void)windowWillClose:(NSNotification*)aNotification {
    [NSApp terminate:self];
}

- (IBAction)openRegion:(id)sender {
    NSOpenPanel* open = [NSOpenPanel openPanel];
    [open setCanChooseDirectories:YES];
    [open setCanChooseFiles:NO];
    if ( [open runModal] == NSOKButton ) {
        mapURL = [open URL];
        [self openMap:mapURL];
    }
}

-(void)openMap:(NSURL*)path {
    NSScrollView* mapScroller = [[NSScrollView alloc] initWithFrame:[[window contentView] frame]];
    [mapScroller setHasHorizontalScroller:YES];
    [mapScroller setHasVerticalScroller:YES];
    [mapScroller setBorderType:NSNoBorder];
    [mapScroller setAutoresizingMask:NSViewWidthSizable|NSViewHeightSizable];
    //NSLog(@"Scrollview frame %f %f, %f %f", [mapScroller frame].origin.x, [mapScroller frame].origin.y, [mapScroller frame].size.width, [mapScroller frame].size.height);
    MapView* map = [[MapView alloc] initWithURL:path];
    [mapScroller setDocumentView:map];
    [map release];
    [window setContentView:mapScroller];
    [mapScroller release];
}

- (IBAction)deleteSelected:(id)sender {
    for ( NSView* clips in [[window contentView] subviews] ) {
        if ( [clips isKindOfClass:[NSClipView class]] ) {
            for ( NSView* views in [clips subviews] ) {
                if ( [views isKindOfClass:[MapView class]] ) {
                    MapView* map = (MapView*)views;
                    for ( RegionView* region in map.regions ) {
                        [region deleteActive];
                    }
                }
            }
        }
    }
}

- (void)dealloc {
    [mapURL release];
    [super dealloc];
}

@end
