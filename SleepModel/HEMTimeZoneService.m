//
//  HEMTimeZoneService.m
//  Sense
//
//  Created by Jimmy Lu on 11/23/15.
//  Copyright © 2015 Hello. All rights reserved.
//
#import <SenseKit/SENAPITimeZone.h>

#import "NSTimeZone+HEMMapping.h"

#import "HEMTimeZoneService.h"

@implementation HEMTimeZoneService

- (void)getConfiguredTimeZone:(nonnull HEMCurrentTimeZoneHandler)completion {
    [SENAPITimeZone getConfiguredTimeZone:^(NSTimeZone* tz, NSError *error) {
        if (error) {
            [SENAnalytics trackError:error];
        }
        completion (tz);
    }];
}

- (void)getTimeZones:(nonnull HEMAllTimeZoneHandler)completion {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSDictionary* timeZoneCodeMapping = [NSTimeZone timeZoneMapping];
        NSArray* timeZoneCities = [timeZoneCodeMapping allKeys];
        NSArray* sortedCities = [timeZoneCities sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            return [obj1 compare:obj2];
        }];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completion (timeZoneCodeMapping, sortedCities);
        });
        
    });
}

- (void)updateToTimeZone:(nonnull NSTimeZone*)timeZone completion:(nullable HEMUpdateTimeZoneHandler)completion {
    [SENAPITimeZone setTimeZone:timeZone completion:^(id data, NSError *error) {
        if (!error) {
            NSString* tz = [timeZone name] ?: @"unknown";
            [SENAnalytics track:HEMAnalyticsEventTimeZoneChanged
                     properties:@{HEMAnalyticsEventPropTZ : tz}];
        } else {
            [SENAnalytics trackError:error];
        }
        
        if (completion) {
            completion (error);
        }
        
    }];
}

@end
