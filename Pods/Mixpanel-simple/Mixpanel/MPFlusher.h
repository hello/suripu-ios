//
//  MPFlusher.h
//  mixpanel-simple
//
//  Created by Conrad Kramer on 11/19/14.
//  Copyright (c) 2014 DeskConnect. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MPFlusher : NSObject

@property (nonatomic) NSTimeInterval flushInterval;
@property (nonatomic, readonly, retain) NSURL *cacheDirectory;

- (instancetype)initWithCacheDirectory:(NSURL *)cacheDirectory NS_DESIGNATED_INITIALIZER;

- (void)flush;

@end
