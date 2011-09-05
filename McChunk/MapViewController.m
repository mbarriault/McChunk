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
    //    [open setDirectoryURL:[NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/Library/Application Support/minecraft/saves", NSHomeDirectory()] isDirectory:YES]];
    if ( [open runModal] == NSOKButton ) {
        mapPath = [[open URL] relativePath];
        [self openMap:mapPath];
    }
}

-(void)openMap:(NSString*)path {
    NSScrollView* mapScroller = [[NSScrollView alloc] initWithFrame:[[window contentView] frame]];
    [mapScroller setHasHorizontalScroller:YES];
    [mapScroller setHasVerticalScroller:YES];
    [mapScroller setBorderType:NSNoBorder];
    [mapScroller setAutoresizingMask:NSViewWidthSizable|NSViewHeightSizable];
    NSLog(@"Scrollview frame %f %f, %f %f", [mapScroller frame].origin.x, [mapScroller frame].origin.y, [mapScroller frame].size.width, [mapScroller frame].size.height);
    MapView* map = [[MapView alloc] initWithMap:path];
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
    [self openMap:mapPath];
}

- (void)dealloc {
    [mapPath release];
    [super dealloc];
}

@end
