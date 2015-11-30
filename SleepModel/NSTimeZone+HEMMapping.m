//
//  NSTimeZone+HEMMapping.m
//  Sense
//
//  Created by Jimmy Lu on 7/10/15.
//  Copyright (c) 2015 Hello. All rights reserved.
//

#import "NSTimeZone+HEMMapping.h"

static NSString* const HEMTimeZoneResourceName = @"TimeZones";
static NSString* const HEMTimeZoneCountryCodeResource = @"TZCountryCodes";

@implementation NSTimeZone (HEMMapping)

+ (NSDictionary*)timeZoneMapping {
    NSString *path = [[NSBundle mainBundle] pathForResource:HEMTimeZoneResourceName ofType:@"plist"];
    return [NSDictionary dictionaryWithContentsOfFile:path];
}

/**
 * Not all country codes are mapped
 */
+ (NSDictionary*)tzCountryCodeMapping {
    NSString *path = [[NSBundle mainBundle] pathForResource:HEMTimeZoneCountryCodeResource
                                                     ofType:@"plist"];
    return [NSDictionary dictionaryWithContentsOfFile:path];
}

+ (NSString*)localTimeZoneMappedName {
    NSTimeZone* local = [NSTimeZone localTimeZone];
    NSDictionary* mapping = [self timeZoneMapping];
    NSString* displayName = [[mapping allKeysForObject:[local name]] firstObject];
    return displayName ?: [local name];
}

+ (NSString*)countryCodeForSense {
    [NSTimeZone resetSystemTimeZone];
    
    NSDictionary* countryCodes = [[self class] tzCountryCodeMapping];
    NSString* tzName = [[NSTimeZone systemTimeZone] name];
    NSString* countryCode = countryCodes[tzName];
    if (![countryCode isEqualToString:@"US"] && ![countryCode isEqualToString:@"JP"]) {
        countryCode = @"EU"; // all else, use EU, per firmware
    }
    return countryCode;
}

@end
