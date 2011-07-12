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

MCPixel MCPoint(CGFloat x, CGFloat y, NSColor* color) {
    MCPixel aPoint = NSMakeRect(x, y, 2, 2);
    [color set];
    NSRectFill(aPoint);
    return aPoint;
}

@implementation RegionView

@synthesize mapFolder, regionFile, data;

- (id)initWithMap:(NSString *)map andFile:(NSString*)file andOffset:(NSPoint)offset {
    NSArray* comps = [file componentsSeparatedByString:@"."];
    NSRect frame = NSMakeRect(([[comps objectAtIndex:1] intValue]-offset.x)*512, ([[comps objectAtIndex:2] intValue]-offset.y)*512, 512, 512);
    NSLog(@"RegionView frame %f %f, %f %f", frame.origin.x, frame.origin.y, frame.size.width, frame.size.height);
    if ( (self = [super initWithFrame:frame]) ) {
        if ( [map length] > 0 && [file length] > 0 ) {
            self.mapFolder = map;
            self.regionFile = file;
            self.data = [NSData dataWithContentsOfFile:[NSString stringWithFormat:@"%@/%@", mapFolder, regionFile]];
            NSLog(@"Data length %u", (unsigned)[data length]);
            [self decompress];
        }
    }
    return self;
}

- (void)dealloc {
    [mapFolder release];
    [data release];
    [super dealloc];
}

- (void)decompress {
    void* ptr = (void*)[data bytes];
    int chunks_offset[1024];
    char chunks_sectors[1024];
    char* sec;
    
    void* ptr0 = ptr;
    int num_chunks = 0;
    NSLog(@"Initial pointer %u", (unsigned)ptr0);
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
            NSLog(@"Length of chunk %d and compression type %d", len, type);
            NSData* compressedData = [NSData dataWithBytes:ptr length:len-1];
            NSData* decompressedData = [NSData dataWithData:zlibInflate(compressedData)];
            NSLog(@"Compressed %u decompressed %u", (unsigned)[compressedData length], (unsigned)[decompressedData length]);

            void* tag_ptr = (void*)[decompressedData bytes];
            void* tag_ptr0 = tag_ptr;
            int l;
            NSString* theString;
            while ( tag_ptr < tag_ptr0 + [decompressedData length] ) {
                switch (*(char*)tag_ptr) {
                    case 10: // TAG_Compound
                        tag_ptr++;
                        tag_ptr += Endian16_Swap(*(short*)tag_ptr)+2; // Skip string ID
                        break;
                        
                    case 9: // TAG_List
                        tag_ptr++;
                        tag_ptr += Endian16_Swap(*(short*)tag_ptr)+2; // Skip string ID
                        tag_ptr += Endian32_Swap(*(int*)tag_ptr)+4;  // Length of list as integer
                        break;
                        
                    case 8: // TAG_String
                        tag_ptr++;
                        tag_ptr += Endian16_Swap(*(short*)tag_ptr)+2; // Skip string ID
                        tag_ptr += Endian16_Swap(*(short*)tag_ptr)+2; // Length of string
                        break;
                        
                    case 7: // TAG_ByteArray
                        tag_ptr++;
                        l = Endian16_Swap(*(short*)tag_ptr); // Length of string
                        tag_ptr += 2;
                        theString = [[NSString alloc] initWithData:[NSData dataWithBytes:tag_ptr length:l] encoding:NSUTF8StringEncoding];
                        tag_ptr += l;
                        l = Endian32_Swap(*(int*)tag_ptr); // Length of data
                        tag_ptr += 4;
                        if ( [theString isEqualToString:@"Blocks"] ) {
                            NSData *blocks = [NSData dataWithBytes:tag_ptr length:l];
                            int o;
                            char id;
                            for ( int z=127; z>=0; z-- ) for ( int x=0; x<16; x++ ) for ( int y=0; y<16; y++ ) {
                                o = y+z*128+x*2048;
                                id = ((char*)[blocks data])[o];
                                NSLog(@"Block id %d", (int)id);
                            }
                        }
                        [theString release];
                        tag_ptr += l;
                        break;
                        
                    case 6: // TAG_Double
                        tag_ptr++;
                        tag_ptr += Endian16_Swap(*(short*)tag_ptr)+sizeof(short); // Skip string ID
                        tag_ptr += 8;
                        break;
                        
                    case 5: // TAG_Float
                        tag_ptr++;
                        tag_ptr += Endian16_Swap(*(short*)tag_ptr)+sizeof(short); // Skip string ID
                        tag_ptr += 4;
                        break;
                        
                    case 4: // TAG_Long
                        tag_ptr++;
                        tag_ptr += Endian16_Swap(*(short*)tag_ptr)+sizeof(short); // Skip string ID
                        tag_ptr += 8;
                        break;
                        
                    case 3: // TAG_Int
                        tag_ptr++;
/*                        tag_ptr += Endian16_Swap(*(short*)tag_ptr)+sizeof(short); // Skip string ID
                        tag_ptr += 4;*/
                        l = Endian16_Swap(*(short*)tag_ptr); // Length of string
                        tag_ptr += 2;
                        theString = [[NSString alloc] initWithData:[NSData dataWithBytes:tag_ptr length:l] encoding:NSUTF8StringEncoding];
                        tag_ptr += l;
                        if ( [theString isEqualToString:@"xPos"] ) {
                            
                        }
                        [theString release];
                        break;
                        
                    case 2: // TAG_Short
                        tag_ptr++;
                        tag_ptr += Endian16_Swap(*(short*)tag_ptr)+sizeof(short); // Skip string ID
                        tag_ptr += 2;
                        break;
                        
                    case 1: // TAG_Byte
                        tag_ptr++;
                        tag_ptr += Endian16_Swap(*(short*)tag_ptr)+sizeof(short); // Skip string ID
                        tag_ptr += 1;
                        break;
                        
                    case 0: // TAG_End
                        tag_ptr++;
                        
                    default:
                        break;
                }
            }
        }
    }
    
}

- (void)drawRect:(NSRect)dirtyRect {
    // Drawing code here.
    NSLog(@"%f %f, %f %f", dirtyRect.origin.x, dirtyRect.origin.y, dirtyRect.size.width, dirtyRect.size.height);
    MCPoint(0,0,[NSColor redColor]);
    NSRect r;
    NSBezierPath *bp;
    
    [[NSColor blackColor] set];
    NSRectFill(dirtyRect);
    
    r = NSMakeRect(10, 10, 50, 60);
    bp = [NSBezierPath bezierPathWithRect:r];
    [[NSColor blueColor] set];
    [bp fill];
    NSLog(@"Redrawn!");
}

@end
