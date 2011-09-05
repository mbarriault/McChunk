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
    NSPoint pos;
    char blocks[256];
    int index;
    NSArray* blockColors;
    NSData* data;
}
-(id)initWithIndex:(int)i andData:(NSData*)compressedData andOffset:(NSPoint)offset;
@property (readwrite) BOOL active;
@property (readwrite) int index;

@end
