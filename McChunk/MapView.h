//
//  MapView.h
//  McChunk
//
//  Created by Michael Barriault on 11-07-04.
//  Copyright 2011 MikBarr Studios. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "RegionView.h"


@interface MapView : NSView {
@private
    IBOutlet id window;
    NSMutableArray* regions;
}
- (IBAction)openRegion:(id)sender;

@end
