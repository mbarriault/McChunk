//
//  NSData+CocoaDevUsersAdditions.h
//  McChunk
//
//  Created by Michael Barriault on 11-09-04.
//  Copyright 2011 MikBarr Studios. All rights reserved.
//

#import <Foundation/Foundation.h>

// Zlib modified from 
// http://www.cocoadev.com/index.pl?NSDataCategory
@interface NSData (NSData_CocoaDevUsersAdditions)
// Returns range [start, null byte), or (NSNotFound, 0).
- (NSRange) rangeOfNullTerminatedBytesFrom:(int)start;

// ZLIB
- (NSData *) zlibInflate;
- (NSData *) zlibDeflate;

@end
