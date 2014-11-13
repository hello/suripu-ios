//
//  HEMAudioCache.h
//  Sense
//
//  Created by Delisa Mason on 11/12/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HEMAudioCache : NSObject

+ (void)cacheURLforAssetAtPath:(NSString*)URLPath completion:(void(^)(NSURL* url, NSError* error))completion;
@end
