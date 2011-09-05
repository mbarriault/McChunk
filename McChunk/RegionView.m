//
//  RegionView.m
//  McChunk
//
//  Created by Michael Barriault on 11-07-04.
//  Copyright 2011 Michael Barriault. All rights reserved.
//  See LICENSE for copyright information
//

#import "RegionView.h"
#import "ChunkView.h"
#import <zlib.h>
#import "NSData+CocoaDevUsersAdditions.h"

@implementation RegionView

@synthesize chunks, mapURL;

- (id)initWithMap:(NSURL*)url andOffset:(NSPoint)ioffset {
    offset = ioffset;
    NSArray* comps = [[url lastPathComponent] componentsSeparatedByString:@"."];
    x = [[comps objectAtIndex:1] intValue];
    z = [[comps objectAtIndex:2] intValue];
    NSRect frame = NSMakeRect((x-offset.x)*512, (z-offset.y)*512, 512, 512);
    if ( (self = [super initWithFrame:frame]) ) {
        self.mapURL = url;
        data = [[NSMutableData alloc] initWithContentsOfURL:mapURL];
        
        void* ptr = (void*)[data bytes];
        int chunks_offset[1024];
        char chunks_sectors[1024];
        char* sec;
        
        void* ptr0 = ptr;
        int num_chunks = 0;
        while ( ptr < ptr0 + 4096 ) {
            int i = (int)((ptr-ptr0)/4);
            chunks_offset[i] = Endian32_Swap(*(int*)ptr);
            sec = (char*)&chunks_offset[i];
            chunks_sectors[i] = *sec;
            chunks_offset[i] >>= 8;
            if ( chunks_offset[i] != 0 )
                num_chunks++;
            ptr += 4;
        }
        
        NSPoint chunkOffset = NSMakePoint(offset.x*32+[self frame].origin.x/16, offset.y*32+[self frame].origin.y/16);
        chunks = [[NSMutableArray alloc] initWithCapacity:num_chunks];
        for ( int i=0; i<1024; i++ ) {
            if ( chunks_offset[i] > 0 ) {
                ptr = ptr0 + 4096*chunks_offset[i];
                int len = Endian32_Swap(*(int*)ptr);
                ptr += 4;
                ptr += 1;
                NSData* compressedData = [NSData dataWithBytes:ptr length:len-1];
                ChunkView* chunk = [[ChunkView alloc] initWithIndex:i andData:compressedData andOffset:chunkOffset];
                [chunks addObject:chunk];
                [chunk release];
            }
        }
        
        for ( ChunkView* chunk in chunks)
            [self addSubview:chunk];
    }
    return self;
}

-(void)awakeFromNib {
    [self setToolTip:[NSString stringWithFormat:@"(%d, %d)", x, z]];
}

- (void)dealloc {
    [mapURL release];
    [chunks release];
    [data release];
    [super dealloc];
}

-(void)deleteActive {
    while ( YES ) {
        BOOL con = NO;
        for ( ChunkView* chunk in chunks ) {
            if ( chunk.active ) {
                int* chunkPos = (int*)([data bytes]+4*chunk.index);
                *chunkPos = 0;
                [chunk removeFromSuperview];
                [chunks removeObject:chunk];
                con = YES;
                break;
            }
        }
        if ( con ) continue;
        break;
    }
    [self setNeedsDisplay:YES];
    if ( ![data writeToURL:mapURL atomically:YES] ) {
        NSLog(@"Something went wrong.");
    }
}

- (void)drawRect:(NSRect)dirtyRect {
    // Drawing code here.
    for ( int i=0; i<512; i++ )
        MCPoint(i, 0, [NSColor blackColor]);
    for ( int i=0; i<512; i++ )
        MCPoint(i, 511, [NSColor blackColor]);
    for ( int j=0; j<512; j++ )
        MCPoint(0, j, [NSColor blackColor]);
    for ( int j=0; j<512; j++ )
        MCPoint(511, j, [NSColor blackColor]);
}

@end
