//
//  HEMSegmentProvider.h
//  Sense
//
//  Created by Jimmy Lu on 11/10/15.
//  Copyright © 2015 Hello. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HEMSegmentProvider : NSObject <SENAnalyticsProvider>

- (nonnull instancetype)initWithWriteKey:(nonnull NSString*)writeKey NS_DESIGNATED_INITIALIZER;
- (nonnull instancetype)init NS_UNAVAILABLE;

@end
