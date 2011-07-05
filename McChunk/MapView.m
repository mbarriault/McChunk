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
    [regions release];
    [super dealloc];
}

- (IBAction)openRegion:(id)sender {
    NSOpenPanel* open = [NSOpenPanel openPanel];
    [open setCanChooseDirectories:YES];
    [open setCanChooseFiles:NO];
//    [open setDirectoryURL:[NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/Library/Application Support/minecraft/saves", NSHomeDirectory()] isDirectory:YES]];
    if ( [open runModalForDirectory:nil file:nil] == NSOKButton ) {
        NSArray* files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[NSString stringWithFormat:@"%@/region", [open filename]] error:NULL];
        NSLog(@"%@", files);
        [regions release];
        regions = [[NSMutableArray alloc] initWithCapacity:[files count]];
        for ( NSString *regionFile in files )
            [regions addObject:[[RegionView alloc] initWithMap:[open filename] andFile:regionFile]];
    }
    [self setNeedsDisplay:YES];
}

- (void)drawRect:(NSRect)dirtyRect
{
    // Drawing code here.
    NSLog(@"%f %f, %f %f", dirtyRect.origin.x, dirtyRect.origin.y, dirtyRect.size.width, dirtyRect.size.height);
    for ( RegionView* region in regions )
        [self addSubview:region];
}

@end
