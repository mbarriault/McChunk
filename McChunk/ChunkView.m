//
//  ChunkView.m
//  McChunk
//
//  Created by Michael Barriault on 11-07-17.
//  Copyright 2011 Michael Barriault. All rights reserved.
//  See LICENSE for copyright information
//

#import "ChunkView.h"
#import "NSData+CocoaDevUsersAdditions.h"
#import "NSColor+MoreColors.h"

MCPixel MCPoint(CGFloat x, CGFloat y, NSColor* color) {
    MCPixel aPoint = NSMakeRect(x, y, 1, 1);
    [color set];
    NSRectFill(aPoint);
    return aPoint;
}

@implementation ChunkView

@synthesize active, index;

-(char) blockAtX:(int)i AtZ:(int)k {
    return blocks[i+16*k];
}

-(void) setBlock:(int)val AtX:(int)i AtZ:(int)k {
    blocks[i+16*k] = val;
}

-(id)initWithIndex:(int)i andData:(NSData*)compressedData andOffset:(NSPoint)offset {
    BOOL debug = NO;
    int x = i % 32;
    int z = (i-x)/32;
    NSRect frame = NSMakeRect(x*16, z*16, 16, 16);
    self = [super initWithFrame:frame];
    if ( self ) {
        active = NO;
        data = [[compressedData zlibInflate] retain];
        index = i;
        pos = NSMakePoint(x - offset.x, z - offset.y);
        void* ptr = (void*)[data bytes];
        void* ptr_end = ptr + [data length];
        NSData* blockData = nil;
        NSMutableArray* TagsFound = [[NSMutableArray alloc] initWithCapacity:10];
        while ( ptr < ptr_end ) {
            NSString* theString;
            char tag_id = *(char*)ptr;
            ptr++; // Pass tag ID
            if ( tag_id > 0 ) {
                int l = Endian16_Swap(*(short*)ptr); // Length of string
                ptr += 2; // Go to string
                theString = [[NSString alloc] initWithData:[NSData dataWithBytes:ptr length:l] encoding:NSUTF8StringEncoding];
                if ( theString && ![theString isEqualToString:@""] ) [TagsFound addObject:[NSString stringWithFormat:@"%@ %d", theString, tag_id]];
                ptr += l; // Pass string ID
                if ( debug ) NSLog(@"TAG %@ of type %d", theString, tag_id);
            }
            else if ( tag_id == 0 ) {
                if ( debug ) NSLog(@"TAG_End");
            }
            else {
                if ( debug ) NSLog(@"This shouldn't run...");
            }
            char list_id;
            int l;
            switch (tag_id) {
                case 10: // TAG_Compound
                    break;
                    
                case 9: // TAG_List
                    list_id = *(char*)ptr;
                    ptr++;
                    l = Endian32_Swap(*(int*)ptr);
                    ptr += 4;  // Length of list as integer
                    if ( debug ) NSLog(@"%@ Found a TAG_List of length %d and type %d", theString, l, list_id);
                    if ( list_id < 10 ) {
                        int f=0;
                        if ( list_id == 1 ) f = 1;
                        else if ( list_id == 2 ) f = 2;
                        else if ( list_id == 3 || list_id == 5 ) f = 4;
                        else if ( list_id == 4 || list_id == 6 ) f = 8;
                        else NSLog(@"Unknown type!!!! %d of type %u", l, list_id);
                        ptr += l*f;
                    }
                    break;
                    
                case 8: // TAG_String
                    l = Endian16_Swap(*(short*)ptr);
                    ptr += 2;
                    NSString* theStringValue = [[NSString alloc] initWithData:[NSData dataWithBytes:ptr length:l] encoding:NSUTF8StringEncoding];
                    ptr += l; // Length of string
                    if ( debug ) NSLog(@"%@ Found a TAG_String of length %d and data %@", theString, l, theStringValue);
                    [theStringValue release];
                    break;
                    
                case 7: // TAG_ByteArray
                    l = Endian32_Swap(*(int*)ptr); // Length of data
                    ptr += 4;
                    if ( debug ) NSLog(@"%@ Found a TAG_ByteArray of length %d", theString, l);
                    if ( [theString isEqualToString:@"Blocks"] )
                        blockData = [[NSData alloc] initWithBytes:ptr length:l];
                    ptr += l;
                    break;
                    
                case 6: // TAG_Double
                    if ( debug ) NSLog(@"%@ Found a TAG_Double with value %f", theString, (double)Endian64_Swap(*(double*)ptr));
                    ptr += 8;
                    break;
                    
                case 5: // TAG_Float
                    if ( debug ) NSLog(@"%@ Found a TAG_Float with value %f", theString, (float)Endian32_Swap(*(float*)ptr));
                    ptr += 4;
                    break;
                    
                case 4: // TAG_Long
                    if ( debug ) NSLog(@"%@ Found a TAG_Long with value %ld", theString, (long)Endian64_Swap(*(long*)ptr));
                    ptr += 8;
                    break;
                    
                case 3: // TAG_Int
                    if ( debug ) NSLog(@"%@ Found a TAG_Int with value %d", theString, (int)Endian32_Swap(*(int*)ptr));
                    ptr += 4;
                    break;
                    
                case 2: // TAG_Short
                    if ( debug ) NSLog(@"%@ Found a TAG_Short with value %d", theString, (short)Endian16_Swap(*(short*)ptr));
                    ptr += 2;
                    break;
                    
                case 1: // TAG_Byte
                    if ( debug ) NSLog(@"%@ Found a TAG_Byte", theString);
                    ptr += 1;
                    break;
                    
                case 0: // TAG_End
                    break;
                    
                default:
                    break;
            }
            if ( tag_id > 0 ) [theString release];
        }
        [TagsFound release];
        if ( blockData ) {
            [self constructFromBlockData:blockData];
            [blockData release];
        }
        else {
            if ( debug ) NSLog(@"Block data not found! Defaulting to air.");
        }
        blockColors = [[NSArray alloc] initWithObjects:
                       [NSColor blackColor], // Air
                       [NSColor darkGrayColor], // Stone
                       [NSColor greenColor], // Grass
                       [NSColor brownColor], // Dirt
                       [NSColor darkGrayColor], // Cobblestone
                       [NSColor brownColor], // Plank
                       [NSColor greenColor], // Sapling
                       [NSColor blackColor], // Bedrock
                       [NSColor blueColor], // Water
                       [NSColor blueColor], // Still water
                       [NSColor redColor], // Lava
                       [NSColor redColor], // Still lava
                       [NSColor yellowColor], // Sand
                       [NSColor yellowColor], // Gravel
                       [NSColor goldColor], // Gold ore
                       [NSColor orangeColor], // Iron ore
                       [NSColor darkGrayColor], // Coal ore
                       [NSColor woodColor], // Wood
                       [NSColor greenColor], // Leaves
                       [NSColor yellowColor], // Sponge
                       [NSColor yellowColor], // Glass
                       [NSColor blueColor], // Lapis Lazuli ore
                       [NSColor blueColor], // Lapis Lazuli block
                       [NSColor grayColor], // Dispenser
                       [NSColor yellowColor], // Sandstone
                       [NSColor brownColor], // Note
                       [NSColor redColor], // Bed
                       [NSColor grayColor], // Powered rail
                       [NSColor grayColor], // Detector rail
                       [NSColor grayColor], // Sticky piston
                       [NSColor yellowColor], // Cobweb
                       [NSColor greenColor], // Tall grass
                       [NSColor greenColor], // Dead shrubs
                       [NSColor brownColor], // Piston
                       [NSColor brownColor], // Piston extension
                       [NSColor whiteColor], // Wool
                       [NSColor brownColor], // Piston moved
                       [NSColor yellowColor], // Dandelion
                       [NSColor redColor], // Rose
                       [NSColor brownColor], // Brown mushroom
                       [NSColor redColor], // Red mushroom
                       [NSColor colorWithDeviceRed:1. green:0.84 blue:0. alpha:1.], // Gold block
                       [NSColor orangeColor], // Iron block
                       [NSColor darkGrayColor], // Double slabs
                       [NSColor darkGrayColor], // Slabs
                       [NSColor yellowColor], // Brick
                       [NSColor magentaColor], // TNT
                       [NSColor greenColor], // Bookshelf
                       [NSColor darkGrayColor], // Moss stone
                       [NSColor darkGrayColor], // Obsidian
                       [NSColor greenColor], // Torch
                       [NSColor redColor], // Fire
                       [NSColor magentaColor], // Monster spawner
                       [NSColor greenColor], // Wooden stairs
                       [NSColor greenColor], // Chest
                       [NSColor magentaColor], // Redstone wire
                       [NSColor orangeColor], // Diamond ore
                       [NSColor orangeColor], // Diamond block
                       [NSColor greenColor], // Crafting table
                       [NSColor greenColor], // Seeds
                       [NSColor brownColor], // Farmland
                       [NSColor darkGrayColor], // Furnace
                       [NSColor darkGrayColor], // Burning furnace
                       [NSColor greenColor], // Sign
                       [NSColor greenColor], // Door
                       [NSColor greenColor], // Ladder
                       [NSColor greenColor], // Rail
                       [NSColor darkGrayColor], // Cobblestone stairs
                       [NSColor greenColor], // Wall sign
                       [NSColor magentaColor], // Lever
                       [NSColor magentaColor], // Stone pressure plate
                       [NSColor magentaColor], // Iron door
                       [NSColor magentaColor], // Wooden pressure plate
                       [NSColor orangeColor], // Redstone ore
                       [NSColor orangeColor], // Glowing redstone ore
                       [NSColor magentaColor], // Redstone torch
                       [NSColor magentaColor], // Redstone torch on
                       [NSColor magentaColor], // Stone button
                       [NSColor blueColor], // Snow
                       [NSColor blueColor], // Ice
                       [NSColor blueColor], // Snow block
                       [NSColor brownColor], // Cactus
                       [NSColor yellowColor], // Clay block
                       [NSColor brownColor], // Sugar cane
                       [NSColor greenColor], // Jukebox
                       [NSColor greenColor], // Fence
                       [NSColor brownColor], // Pumpkin
                       [NSColor brownColor], // Netherrack
                       [NSColor yellowColor], // Soul sand
                       [NSColor yellowColor], // Glowstone block
                       [NSColor whiteColor], // Portal
                       [NSColor brownColor], // Jack-O-Lantern
                       [NSColor brownColor], // Cake
                       [NSColor magentaColor], // Redstone repeater
                       [NSColor magentaColor], // Redstone repeater on
                       [NSColor greenColor], // Locked chest
                       [NSColor greenColor], // Trapdoor
                       [NSColor darkGrayColor], // Silverfish stone
                       [NSColor darkGrayColor], // Stone brick
                       [NSColor brownColor], // Mushroom
                       [NSColor brownColor], // Mushroom
                       [NSColor grayColor], // Iron Bars
                       [NSColor yellowColor], // Glass pane
                       [NSColor yellowColor], // Melon
                       [NSColor blackColor], // Unknown
                       [NSColor blackColor], // Unknown
                       [NSColor greenColor], // Vines
                       [NSColor brownColor], // Fence gate
                       [NSColor darkGrayColor], // Brick stairs
                       [NSColor darkGrayColor], // Stone brick stairs
                       nil];
    }
    return self;
}

-(void)constructFromBlockData:(NSData*)blockData {
    char bid;
    int o;
    for ( int i=0; i<16; i++ ) for ( int k=0; k<16; k++ ) {
        BOOL gotair = NO;
        for ( int j=127; j>=0; j-- ) {
            o = j+k*128+i*2048;
            bid = ((char*)[blockData bytes])[o];
            if ( bid == 0 ) gotair = YES;
            if ( gotair && bid != 0 ) {
                [self setBlock:bid AtX:i AtZ:k];
                break;
            }
        }
    }
}

- (void)dealloc {
    [blockColors release];
    [data release];
    [super dealloc];
}

- (void)drawRect:(NSRect)dirtyRect {
    // Drawing code here.
    for ( int i=0; i<16; i++ ) for ( int k=0; k<16; k++ ) {
        int c = [self blockAtX:i AtZ:k];
        if ( c > [blockColors count] )
            MCPoint(i, k, [NSColor blackColor]);
        else
            MCPoint(i, k, [blockColors objectAtIndex:c]);
    }
    if ( active ) {
        for ( int i=0; i<16; i++ )
            MCPoint(i, 0, [NSColor whiteColor]);
        for ( int i=0; i<16; i++ )
            MCPoint(i, 15, [NSColor whiteColor]);
        for ( int j=0; j<16; j++ )
            MCPoint(0, j, [NSColor whiteColor]);
        for ( int j=0; j<16; j++ )
            MCPoint(15, j, [NSColor whiteColor]);
    }
}

@end
