//
//  MapViewController.m
//  McChunk
//
//  Created by Michael Barriault on 11-07-05.
//  Copyright 2011 MikBarr Studios. All rights reserved.
//

#import "MapViewController.h"


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
    NSScrollView* mapScroller = [[NSScrollView alloc] initWithFrame:[[window contentView] frame]];
    [mapScroller setHasHorizontalScroller:YES];
    [mapScroller setHasVerticalScroller:YES];
    [mapScroller setBorderType:NSNoBorder];
    [mapScroller setAutoresizingMask:NSViewWidthSizable|NSViewHeightSizable];
    NSLog(@"Scrollview frame %f %f, %f %f", [mapScroller frame].origin.x, [mapScroller frame].origin.y, [mapScroller frame].size.width, [mapScroller frame].size.height);
    NSOpenPanel* open = [NSOpenPanel openPanel];
    [open setCanChooseDirectories:YES];
    [open setCanChooseFiles:NO];
    //    [open setDirectoryURL:[NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/Library/Application Support/minecraft/saves", NSHomeDirectory()] isDirectory:YES]];
    if ( [open runModalForDirectory:nil file:nil] == NSOKButton ) {
        MapView* map = [[MapView alloc] initWithMap:[open filename]];
        [mapScroller setDocumentView:map];
        [map release];
    }
    [window setContentView:mapScroller];
    [mapScroller release];
}

- (void)dealloc
{
    [super dealloc];
}

@end
