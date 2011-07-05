//
//  RegionView.m
//  McChunk
//
//  Created by Michael Barriault on 11-07-04.
//  Copyright 2011 MikBarr Studios. All rights reserved.
//

#import "RegionView.h"
#import <zlib.h>

// Zlib decompress from and modified into functional form from 
// http://www.cocoadev.com/index.pl?NSDataCategory
NSData * zlibInflate(NSData* self) {
	if ([self length] == 0) return self;
    
	unsigned full_length = [self length];
	unsigned half_length = [self length] / 2;
    
	NSMutableData *decompressed = [NSMutableData dataWithLength: full_length + half_length];
	BOOL done = NO;
	int status;
    
	z_stream strm;
	strm.next_in = (Bytef *)[self bytes];
	strm.avail_in = [self length];
	strm.total_out = 0;
	strm.zalloc = Z_NULL;
	strm.zfree = Z_NULL;
    
	if (inflateInit (&strm) != Z_OK) return nil;
    
	while (!done)
	{
		// Make sure we have enough room and reset the lengths.
		if (strm.total_out >= [decompressed length])
			[decompressed increaseLengthBy: half_length];
		strm.next_out = [decompressed mutableBytes] + strm.total_out;
		strm.avail_out = [decompressed length] - strm.total_out;
        
		// Inflate another chunk.
		status = inflate (&strm, Z_SYNC_FLUSH);
		if (status == Z_STREAM_END) done = YES;
		else if (status != Z_OK) break;
	}
	if (inflateEnd (&strm) != Z_OK ) return nil;
    
	// Set real length.
	if (done)
	{
		[decompressed setLength: strm.total_out];
		return [NSData dataWithData: decompressed];
	}
	else return nil;
}

MCPixel MCPoint(CGFloat x, CGFloat y, NSColor* color) {
    MCPixel aPoint = NSMakeRect(x, y, 2, 2);
    [color set];
    NSRectFill(aPoint);
    return aPoint;
}

@implementation RegionView

@synthesize mapFolder, regionFile, data;

- (id)initWithMap:(NSString *)map andFile:(NSString*)file {
    NSRect frame = NSMakeRect(0, 0, 512, 512);
    if ( (self = [super initWithFrame:frame]) ) {
        if ( [map length] > 0 && [file length] > 0 ) {
            self.mapFolder = map;
            self.regionFile = file;
            self.data = [NSData dataWithContentsOfFile:[NSString stringWithFormat:@"%@/region/%@", mapFolder, regionFile]];
            NSLog(@"Data length %u", [data length]);
        }
    }
    return self;
}

- (void)dealloc {
    [mapFolder release];
    [data release];
    [super dealloc];
}

- (void)drawRect:(NSRect)dirtyRect {
    // Drawing code here.
    
    void* ptr = [data bytes];
    int chunks_offset[1024];
    char chunks_sectors[1024];
    char* sec;

    void* ptr0 = ptr;
    int num_chunks = 0;
    NSLog(@"Initial pointer %d", ptr0);
    while ( ptr < ptr0+4096 ) {
        int i = (int)((ptr-ptr0)/4);
        chunks_offset[i] = Endian32_Swap(*(int*)ptr);
        sec = (char*)&chunks_offset[i];
        chunks_sectors[i] = *sec;
        chunks_offset[i] >>= 8;
        if ( chunks_offset[i] != 0 )
            //num_chunks++;
            NSLog(@"%u %u", chunks_offset[i], chunks_sectors[i]);
        ptr += 4;
    }
    NSLog(@"Number of generated chunks in region: %d", num_chunks);
    ptr += 4096; // Skip timestamps!
    for ( int i=0; i<1024; i++ ) {
        if ( chunks_offset[i] > 0 ) {
            ptr = ptr0 + 4096*chunks_offset[i];
            int len = Endian32_Swap(*(int*)ptr);
            ptr += 4;
            char type = *(char*)ptr;
            ptr += 1;
            NSLog(@"Length of chunk %d and compression type %d", len, type);
            NSMutableData* compressedData = [NSMutableData dataWithLength:len-1];
            [data getBytes:[compressedData mutableBytes] range:NSMakeRange(ptr-ptr0, len-1)];
            NSData* decompressedData = [NSData dataWithData:zlibInflate(compressedData)];
            NSLog(@"Compressed %d decompressed %d", [compressedData length], [decompressedData length]);
            NSMutableData* blocksData = [NSMutableData dataWithLength:32768];
            [decompressedData getBytes:[blocksData mutableBytes] length:32768];
        }
    }
    
    MCPoint(50,25,[NSColor redColor]);
}

@end
