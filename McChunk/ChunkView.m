//
//  ChunkView.m
//  McChunk
//
//  Created by Michael Barriault on 11-07-17.
//  Copyright 2011 Michael Barriault. All rights reserved.
//  See LICENSE for copyright information
//

#import "ChunkView.h"

MCPixel MCPoint(CGFloat x, CGFloat y, NSColor* color) {
    MCPixel aPoint = NSMakeRect(x, y, 1, 1);
    [color set];
    NSRectFill(aPoint);
    return aPoint;
}

@implementation ChunkView

@synthesize active, posInRegionData;

-(char) blockAtX:(int)i AtZ:(int)k {
    return blocks[i+16*k];
}

-(void) setBlock:(int)val AtX:(int)i AtZ:(int)k {
    blocks[i+16*k] = val;
}

- (id)initWithCoordsX:(int)ix Z:(int)iz data:(NSData*)data posInRegionData:(int)pos {
    posInRegionData = pos;
    NSRect frame = NSMakeRect(ix*16, iz*16, 16, 16);
    self = [super initWithFrame:frame];
    if (self) {
        active = NO;
        x = ix;
        z = iz;
        int o;
        char id;
        for ( int i=0; i<16; i++ ) for ( int k=0; k<16; k++ ) {
            // This algorithm I believe is less efficient
/*            for ( int j=0; j<128; j++ ) {
                o = j+k*128+i*2048;
                id = ((char*)[data bytes])[o];
                if ( id > 0 ) [self setBlock:id AtX:i AtZ:k];
            }*/
            // This algorithm I believe is more efficient and works in the Nether
            bool gotair = false;
            for ( int j=127; j>=0; j-- ) {
                o = j+k*128+i*2048;
                id = ((char*)[data bytes])[o];
                if ( id == 0 ) gotair = true;
                if ( gotair && id != 0 ) {
                    [self setBlock:id AtX:i AtZ:k];
                    break;
                }
            }
        }
        blockColors = [[NSArray alloc] initWithObjects:
                       [NSColor blackColor], // Air
                       [NSColor darkGrayColor], // Stone
                       [NSColor brownColor], // Grass
                       [NSColor brownColor], // Dirt
                       [NSColor darkGrayColor], // Cobblestone
                       [NSColor magentaColor], // Plank
                       [NSColor greenColor], // Sapling
                       [NSColor darkGrayColor], // Bedrock
                       [NSColor blueColor], // Water
                       [NSColor blueColor], // Still water
                       [NSColor redColor], // Lava
                       [NSColor redColor], // Still lava
                       [NSColor yellowColor], // Sand
                       [NSColor yellowColor], // Gravel
                       [NSColor orangeColor], // Gold ore
                       [NSColor orangeColor], // Iron ore
                       [NSColor orangeColor], // Coal ore
                       [NSColor greenColor], // Wood
                       [NSColor greenColor], // Leaves
                       [NSColor yellowColor], // Sponge
                       [NSColor yellowColor], // Glass
                       [NSColor orangeColor], // Lapis Lazuli ore
                       [NSColor orangeColor], // Lapis Lazuli block
                       [NSColor magentaColor], // Dispenser
                       [NSColor magentaColor], // Sandstone
                       [NSColor greenColor], // Note
                       [NSColor greenColor], // Bed
                       [NSColor magentaColor], // Powered rail
                       [NSColor magentaColor], // Detector rail
                       [NSColor magentaColor], // Sticky piston
                       [NSColor yellowColor], // Cobweb
                       [NSColor brownColor], // Tall grass
                       [NSColor brownColor], // Dead shrubs
                       [NSColor magentaColor], // Piston
                       [NSColor magentaColor], // Piston extension
                       [NSColor whiteColor], // Wool
                       [NSColor magentaColor], // Piston moved
                       [NSColor brownColor], // Dandelion
                       [NSColor brownColor], // Rose
                       [NSColor brownColor], // Brown mushroom
                       [NSColor brownColor], // Red mushroom
                       [NSColor orangeColor], // Gold block
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
                       nil];
    }
    
    return self;
}

- (void)dealloc {
    [blockColors release];
    [super dealloc];
}

- (void)drawRect:(NSRect)dirtyRect {
    // Drawing code here.
    for ( int i=0; i<16; i++ ) for ( int k=0; k<16; k++ ) {
        MCPoint(i, k, [blockColors objectAtIndex:[self blockAtX:i AtZ:k]]);
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
