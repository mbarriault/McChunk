//
//  RegionView.h
//  McChunk
//
//  Created by Michael Barriault on 11-07-04.
//  Copyright 2011 MikBarr Studios. All rights reserved.
//

#import <Cocoa/Cocoa.h>


typedef NSRect MCPixel;
MCPixel MCPoint(CGFloat, CGFloat, NSColor*);

@interface RegionView : NSView {
@private
    
}
- (id)initWithOrigin:(NSPoint)origin;

@end
