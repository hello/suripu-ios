//
//  NSTimeZone+HEMMapping.m
//  Sense
//
//  Created by Jimmy Lu on 7/10/15.
//  Copyright (c) 2015 Hello. All rights reserved.
//

#import "NSTimeZone+HEMMapping.h"

static NSString* const HEMTimeZoneResourceName = @"TimeZones";

@implementation NSTimeZone (HEMMapping)

+ (NSDictionary*)timeZoneMapping {
    NSString *path = [[NSBundle mainBundle] pathForResource:HEMTimeZoneResourceName ofType:@"plist"];
    return [NSDictionary dictionaryWithContentsOfFile:path];
}

+ (NSString*)localTimeZoneMappedName {
    NSTimeZone* local = [NSTimeZone localTimeZone];
    NSDictionary* mapping = [self timeZoneMapping];
    NSString* displayName = [[mapping allKeysForObject:[local name]] firstObject];
    return displayName ?: [local name];
}

@end
