//
//  MapViewController.h
//  McChunk
//
//  Created by Michael Barriault on 11-07-05.
//  Copyright 2011 Michael Barriault. All rights reserved.
//  See LICENSE for copyright information
//

#import <Foundation/Foundation.h>
#import "MapView.h"


@interface MapViewController : NSObject {
@private
    NSURL* mapURL;
    IBOutlet id window;
}
- (IBAction)deleteSelected:(id)sender;
- (IBAction)openRegion:(id)sender;
-(void)openMap:(NSURL*)path;
@end
