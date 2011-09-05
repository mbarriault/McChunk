//
//  MapView.h
//  McChunk
//
//  Created by Michael Barriault on 11-07-04.
//  Copyright 2011 Michael Barriault. All rights reserved.
//  See LICENSE for copyright information
//

#import <Cocoa/Cocoa.h>
#import "RegionView.h"


@interface MapView : NSView {
@private
    NSMutableArray* regions;
    NSPoint startClick;
}
- (id)initWithURL:(NSURL*)mapURL;
@property (nonatomic, retain) NSMutableArray* regions;

@end
