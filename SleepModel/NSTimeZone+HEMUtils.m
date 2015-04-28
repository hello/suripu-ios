//
//  NSTimeZone+HEMUtils.m
//  Sense
//
//  Created by Jimmy Lu on 3/17/15.
//  Copyright (c) 2015 Hello. All rights reserved.
//

#import "NSTimeZone+HEMUtils.h"

@implementation NSTimeZone (HEMUtils)

+ (NSSet*)senseUnsupportedTimeZoneIds {
    static NSSet* unsupportedIds = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        unsupportedIds = [NSSet setWithArray:@[@"Antarctica/Troll",
                                               @"Asia/Chita",
                                               @"Asia/Khandyga",
                                               @"Asia/Srednekolymsk",
                                               @"Asia/Ust-Nera",
                                               @"Europe/Busingen"]];
    });
    return unsupportedIds;
}

+ (NSDictionary*)supportedTimeZoneByDisplayNames {
    NSMutableDictionary* names = [[NSMutableDictionary alloc] init];
    NSTimeZone* timeZone = nil;
    NSString* timeZoneName = nil;
    NSLocale* locale = [NSLocale currentLocale];
    
    for (NSString* tzId in [NSTimeZone knownTimeZoneNames]) {
        if (![[self senseUnsupportedTimeZoneIds] containsObject:tzId]) {
            timeZone = [NSTimeZone timeZoneWithName:tzId];
            timeZoneName = [timeZone localizedName:NSTimeZoneNameStyleGeneric locale:locale];
            names[timeZoneName] = timeZone;
        }
    }
    
    return names;
}

- (NSString*)displayNameForCurrentLocale {
    NSLocale* locale = [NSLocale currentLocale];
    return [self localizedName:NSTimeZoneNameStyleGeneric locale:locale];
}

@end
