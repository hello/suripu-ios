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
        dispatch_async(dispatch_get_main_queue(), ^{
            completion (timeZoneCodeMapping);
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

- (nonnull NSArray<NSString*>*)sortedCityNamesFrom:(nonnull NSDictionary<NSString*, NSString*>*)timeZoneMapping {
    NSArray* timeZoneCities = [timeZoneMapping allKeys];
    return [timeZoneCities sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 compare:obj2];
    }];
}

- (nonnull NSString*)cityForTimeZone:(nonnull NSTimeZone*)timeZone
                         fromMapping:(nonnull NSDictionary<NSString*, NSString*>*)timeZoneMapping {
    NSArray<NSString*>* cityNames = [timeZoneMapping allKeys];
    NSString* currentTimeZoneName = [timeZone name];
    NSString* matchingCityName = nil;
    for (NSString* city in cityNames) {
        NSString* timeZoneName = timeZoneMapping[city];
        if ([timeZoneName isEqualToString:currentTimeZoneName]) {
            matchingCityName = city;
            break;
        }
    }
    return matchingCityName;
}

- (nonnull NSArray<NSString*>*)sortedCityNamesWithout:(nonnull NSTimeZone*)timeZone
                                                 from:(nonnull NSDictionary<NSString*, NSString*>*)timeZoneMapping
                                     matchingCityName:(NSString *_Nonnull *_Nonnull)matchingCityName {
    
    NSArray* sortedCities = [self sortedCityNamesFrom:timeZoneMapping];
    NSString* cityNameToFilter = [self cityForTimeZone:timeZone fromMapping:timeZoneMapping];
    
    if (cityNameToFilter) {
        NSRange fullRange = NSMakeRange(0, [sortedCities count]);
        NSMutableArray* mutableNames = [sortedCities mutableCopy];
        NSInteger foundIndex = [mutableNames indexOfObject:cityNameToFilter
                                             inSortedRange:fullRange
                                                   options:NSBinarySearchingFirstEqual
                                           usingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
                                               return [obj1 compare:obj2];
                                           }];
        if (foundIndex != NSNotFound) {
            [mutableNames removeObjectAtIndex:foundIndex];
        }
        
        if (matchingCityName != NULL) {
            *matchingCityName = cityNameToFilter;
        }
        
        return mutableNames;
    } else {
        return sortedCities;
    }
}

@end
