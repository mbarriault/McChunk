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
    NSString* mapFolder;
    NSString* regionFile;
    NSMutableArray* chunks;
    NSPoint offset;
}
- (id)initWithMap:(NSString*)map andFile:(NSString*)file andOffset:(NSPoint)offset;
- (void)decompress:(NSData*)data;

@property (nonatomic, retain) NSString* mapFolder;
@property (nonatomic, retain) NSString* regionFile;

@end
