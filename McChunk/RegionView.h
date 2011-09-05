//
//  RegionView.h
//  McChunk
//
//  Created by Michael Barriault on 11-07-04.
//  Copyright 2011 Michael Barriault. All rights reserved.
//  See LICENSE for copyright information
//

#import <Cocoa/Cocoa.h>


@interface RegionView : NSView {
@private
@public
    int x,z;
    NSURL* mapURL;
    NSMutableArray* chunks;
    NSPoint offset;
    NSMutableData* data;
}
- (id)initWithMap:(NSURL*)url andOffset:(NSPoint)ioffset;
- (void)deleteActive;

@property (nonatomic, retain) NSURL* mapURL;
@property (nonatomic, retain) NSMutableArray* chunks;

@end
