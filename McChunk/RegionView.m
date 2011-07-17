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

// Zlib decompress from and modified into functional form from 
// http://www.cocoadev.com/index.pl?NSDataCategory
NSData * zlibInflate(NSData* self) {
	if ([self length] == 0) return self;
    
	unsigned full_length = (unsigned)[self length];
	unsigned half_length = (unsigned)[self length] / 2;
    
	NSMutableData *decompressed = [NSMutableData dataWithLength: full_length + half_length];
	BOOL done = NO;
	int status;
    
	z_stream strm;
	strm.next_in = (Bytef *)[self bytes];
	strm.avail_in = (int)[self length];
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
		strm.avail_out = (unsigned)[decompressed length] - (unsigned)strm.total_out;
        
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

@implementation RegionView

@synthesize mapFolder, regionFile;

- (id)initWithMap:(NSString *)map andFile:(NSString*)file andOffset:(NSPoint)ioffset {
    offset = ioffset;
    NSArray* comps = [file componentsSeparatedByString:@"."];
    NSRect frame = NSMakeRect(([[comps objectAtIndex:1] intValue]-offset.x)*512, ([[comps objectAtIndex:2] intValue]-offset.y)*512, 512, 512);
    if ( (self = [super initWithFrame:frame]) ) {
        if ( [map length] > 0 && [file length] > 0 ) {
            self.mapFolder = map;
            self.regionFile = file;
            NSData* data = [NSData dataWithContentsOfFile:[NSString stringWithFormat:@"%@/%@", mapFolder, regionFile]];
            //NSLog(@"Data length %u", (unsigned)[data length]);
            [self decompress:data];
        }
        for ( ChunkView* chunk in chunks )
            [self addSubview:chunk];
    }
    return self;
}

- (void)dealloc {
    [mapFolder release];
    [chunks release];
    [super dealloc];
}

- (void)decompress:(NSData*)data {
    bool debug = false;
    void* ptr = (void*)[data bytes];
    int chunks_offset[1024];
    char chunks_sectors[1024];
    char* sec;
    
    void* ptr0 = ptr;
    int num_chunks = 0;
    //NSLog(@"Initial pointer %u", (unsigned)ptr0);
    while ( ptr < ptr0+4096 ) {
        int i = (int)((ptr-ptr0)/4);
        chunks_offset[i] = Endian32_Swap(*(int*)ptr);
        sec = (char*)&chunks_offset[i];
        chunks_sectors[i] = *sec;
        chunks_offset[i] >>= 8;
        if ( chunks_offset[i] != 0 )
            num_chunks++;
            //NSLog(@"%u %u", chunks_offset[i], chunks_sectors[i]);
        ptr += 4;
    }
    NSLog(@"Number of generated chunks in region: %d", num_chunks);
    chunks = [[NSMutableArray alloc] initWithCapacity:num_chunks];
    ptr += 4096; // Skip timestamps!
    for ( int i=0; i<1024; i++ ) {
        if ( chunks_offset[i] > 0 ) {
            ptr = ptr0 + 4096*chunks_offset[i];
            int len = Endian32_Swap(*(int*)ptr);
            ptr += 4;
            char type = *(char*)ptr;
            ptr += 1;
            //NSLog(@"Length of chunk %d and compression type %d", len, type);
            NSData* compressedData = [NSData dataWithBytes:ptr length:len-1];
            NSData* decompressedData = [NSData dataWithData:zlibInflate(compressedData)];
            //NSLog(@"Compressed %u decompressed %u", (unsigned)[compressedData length], (unsigned)[decompressedData length]);

            void* tag_ptr = (void*)[decompressedData bytes];
            void* tag_ptr0 = tag_ptr;
            int l;
            NSString* theString;
            int tag_id;
            NSData* blocks;
            int xpos;
            int zpos;
            bool got[3];
            for ( int i=0; i<3; i++ ) got[i] = false;
            while ( tag_ptr < tag_ptr0 + [decompressedData length] ) {
                tag_id = *(char*)tag_ptr;
                tag_ptr++; // Pass tag ID
                l = Endian16_Swap(*(short*)tag_ptr); // Length of string
                tag_ptr += 2; // Go to string
                theString = [[NSString alloc] initWithData:[NSData dataWithBytes:tag_ptr length:l] encoding:NSUTF8StringEncoding];
                tag_ptr += l; // Pass string ID
                switch (tag_id) {
                    case 10: // TAG_Compound
                        break;
                        
                    case 9: // TAG_List
                        tag_ptr++;
                        l = Endian32_Swap(*(int*)tag_ptr);
                        tag_ptr += 4+l;  // Length of list as integer
                        if ( debug ) NSLog(@"%@ Found a TAG_List of length %d and type %d", theString, l, *(char*)(tag_ptr-l-4-1));
                        break;
                        
                    case 8: // TAG_String
                        l = Endian16_Swap(*(short*)tag_ptr);
                        tag_ptr += 2;
                        NSString* theStringValue = [[NSString alloc] initWithData:[NSData dataWithBytes:tag_ptr length:l] encoding:NSUTF8StringEncoding];
                        tag_ptr += l; // Length of string
                        if ( debug ) NSLog(@"%@ Found a TAG_String of length %d and data %@", theString, l, theStringValue);
                        [theStringValue release];
                        break;
                        
                    case 7: // TAG_ByteArray
                        l = Endian32_Swap(*(int*)tag_ptr); // Length of data
                        tag_ptr += 4;
                        if ( debug ) NSLog(@"%@ Found a TAG_ByteArray of length %d", theString, l);
                        if ( [theString isEqualToString:@"Blocks"] ) {
                            blocks = [[NSData alloc] initWithBytes:tag_ptr length:l];
                            got[0] = true;
                        }
                        tag_ptr += l;
                        break;
                        
                    case 6: // TAG_Double
                        if ( debug ) NSLog(@"%@ Found a TAG_Double with value %f", theString, (double)Endian64_Swap(*(double*)tag_ptr));
                        tag_ptr += 8;
                        break;
                        
                    case 5: // TAG_Float
                        if ( debug ) NSLog(@"%@ Found a TAG_Float with value %f", theString, (float)Endian32_Swap(*(float*)tag_ptr));
                        tag_ptr += 4;
                        break;
                        
                    case 4: // TAG_Long
                        if ( debug ) NSLog(@"%@ Found a TAG_Long with value %ld", theString, (long)Endian64_Swap(*(long*)tag_ptr));
                        tag_ptr += 8;
                        break;
                        
                    case 3: // TAG_Int
                        if ( debug ) NSLog(@"%@ Found a TAG_Int with value %d", theString, (int)Endian32_Swap(*(int*)tag_ptr));
                        if ( [theString isEqualToString:@"xPos"] ) {
                            xpos = (int)Endian32_Swap(*(int*)tag_ptr);
                            got[1] = true;
                        }
                        else if ( [theString isEqualToString:@"zPos"] ) {
                            zpos = (int)Endian32_Swap(*(int*)tag_ptr);
                            got[2] = true;
                        }
                        tag_ptr += 4;
                        break;
                        
                    case 2: // TAG_Short
                        if ( debug ) NSLog(@"%@ Found a TAG_Short with value %d", theString, (short)Endian16_Swap(*(short*)tag_ptr));
                        tag_ptr += 2;
                        break;
                        
                    case 1: // TAG_Byte
                        if ( debug ) NSLog(@"%@ Found a TAG_Byte", theString);
                        tag_ptr += 1;
                        break;
                        
                    case 0: // TAG_End
                        tag_ptr -= 2; // TAG_End has no string (thus no string length) so move back
                        break;
                        
                    default:
                        break;
                }
                [theString release];
            }
            if ( got[0] && got[1] && got[2] ) {
                NSLog(@"Blocks of length %u at (%f,%f)", (unsigned)[blocks length], xpos-offset.x*32-[self frame].origin.x/16, zpos-offset.y*32-[self frame].origin.y/16);
//                NSLog(@"%f %f", [self frame].origin.x, [self frame].origin.y);
                [chunks addObject:[[[ChunkView alloc] initWithCoordsX:xpos-offset.x*32-[self frame].origin.x/16 Z:zpos-offset.y*32-[self frame].origin.y/16 data:blocks] autorelease]];
                [blocks release];
            }
        }
    }
    
}

- (void)drawRect:(NSRect)dirtyRect {
    // Drawing code here.
    NSLog(@"RegionView frame %f %f, %f %f", [self frame].origin.x, [self frame].origin.y, [self frame].size.width, [self frame].size.height);
}

@end
