//
//  McChunkAppDelegate.h
//  McChunk
//
//  Created by Michael Barriault on 11-07-04.
//  Copyright 2011 Michael Barriault. All rights reserved.
//  See LICENSE for copyright information
//

#import <Cocoa/Cocoa.h>

@interface McChunkAppDelegate : NSObject <NSApplicationDelegate> {
@private
    NSWindow *window;
}

@property (assign) IBOutlet NSWindow *window;

@end
