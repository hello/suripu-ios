//
//  MPTracker.h
//  mixpanel-simple
//
//  Created by Conrad Kramer on 11/16/14.
//  Copyright (c) 2014 DeskConnect. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MPDataPropagator.h"

@interface MPTracker : MPDataPropagator

@property (copy) NSDictionary *defaultProperties;

- (void)track:(NSString *)event;
- (void)track:(NSString *)event properties:(NSDictionary *)properties;

- (void)createAlias:(NSString *)alias forDistinctID:(NSString *)distinctID;

@end
