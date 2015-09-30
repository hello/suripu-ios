//
//  MPFlushOperation.h
//  mixpanel-simple
//
//  Created by Conrad Kramer on 11/19/14.
//  Copyright (c) 2014 DeskConnect. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, MPFlushOperationType) {
    MPFlushOperationTypeEvent,
    MPFlushOperationTypePeople,
    MPFlushOperationTypeNone,
};

@interface MPFlushOperation : NSOperation

@property (nonatomic, readonly, retain) NSURL *cacheURL;

- (instancetype)initWithCacheURL:(NSURL *)cacheURL type:(MPFlushOperationType)type NS_DESIGNATED_INITIALIZER;

@end
