//
//  ChunkView.h
//  McChunk
//
//  Created by Michael Barriault on 11-07-17.
//  Copyright 2011 Michael Barriault. All rights reserved.
//  See LICENSE for copyright information
//

#import <Cocoa/Cocoa.h>

typedef NSRect MCPixel;
MCPixel MCPoint(CGFloat, CGFloat, NSColor*);

@interface ChunkView : NSView {
@private
    BOOL active;
    int x;
    int z;
    char blocks[256];
    int posInRegionData;
    NSArray* blockColors;
}
-(id)initWithCoordsX:(int)ix Z:(int)iz data:(NSData*)data posInRegionData:(int)pos;
@property (readwrite) BOOL active;
@property (readwrite) int posInRegionData;

@end
