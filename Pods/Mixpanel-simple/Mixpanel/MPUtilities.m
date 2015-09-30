//
//  MixpanelUtilities.m
//  mixpanel-simple
//
//  Created by Conrad Kramer on 10/2/14.
//  Copyright (c) 2014 DeskConnect. All rights reserved.
//

#import <Foundation/Foundation.h>

#if defined(__IPHONE_OS_VERSION_MIN_REQUIRED)
#ifndef __WATCH_OS_VERSION_MIN_REQUIRED
#import <UIKit/UIKit.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>
#endif
#elif defined(__MAC_OS_X_VERSION_MIN_REQUIRED)
#import <AppKit/AppKit.h>
#endif

#include <sys/sysctl.h>
#include <resolv.h>

#import "MPUtilities.h"

static NSString * const MPBaseURLString = @"https://api.mixpanel.com";

id MPJSONSerializableObject(id object) {
    static NSDateFormatter *dateFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
        [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
        [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
    });
    
    NSArray *types = [NSArray arrayWithObjects:[NSString class], [NSNumber class], [NSNull class], nil];
    for (Class typeClass in types)
        if ([object isKindOfClass:typeClass])
            return object;

    if ([object isKindOfClass:[NSArray class]] || [object isKindOfClass:[NSSet class]]) {
        NSMutableArray *array = [NSMutableArray new];
        for (id member in object)
            [array addObject:MPJSONSerializableObject(member)];
        return [array copy];
    }

    if ([object isKindOfClass:[NSDictionary class]]) {
        NSMutableDictionary *dictionary = [NSMutableDictionary new];
        for (__strong id key in object) {
            key = ([key isKindOfClass:[NSString class]] ? key : [key description]);
            id value = MPJSONSerializableObject([object valueForKey:key]);
            [dictionary setObject:value forKey:key];
        }
        return [dictionary copy];;
    }

    if ([object isKindOfClass:[NSDate class]]) {
        return [dateFormatter stringFromDate:object];
    } else if ([object isKindOfClass:[NSURL class]]) {
        return [object absoluteString];
    }

    return [object description];
}

NSMutableURLRequest* MPDataURLRequest(NSData *data, NSString *endpoint) {
    NSString *encodedData = nil;
    
    if ([data respondsToSelector:@selector(base64EncodedStringWithOptions:)]) {
        encodedData = [data base64EncodedStringWithOptions:0];
    } else {
        NSUInteger encodedLength = ((data.length + 2) / 3) * 4 + 1;
        char *buffer = malloc(encodedLength);
        int actual = b64_ntop(data.bytes, data.length, buffer, encodedLength);
        if (!actual) {
            free(buffer);
            return nil;
        }
        
        encodedData = [[NSString alloc] initWithBytesNoCopy:buffer length:(actual + 1) encoding:NSUTF8StringEncoding freeWhenDone:YES];
    }
    
    NSString *escapedData = nil;
    NSString *charactersToEscape = @"!*'();:@&=+$,/?%#[]";
    if ([encodedData respondsToSelector:@selector(stringByAddingPercentEncodingWithAllowedCharacters:)]) {
        NSMutableCharacterSet *characterSet = [[NSCharacterSet URLQueryAllowedCharacterSet] mutableCopy];
        [characterSet removeCharactersInString:charactersToEscape];
        escapedData = [encodedData stringByAddingPercentEncodingWithAllowedCharacters:characterSet];
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        escapedData = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)encodedData, NULL, (__bridge CFStringRef)charactersToEscape, kCFStringEncodingUTF8));
#pragma clang diagnostic pop
    }

    NSData *body = [[NSString stringWithFormat:@"ip=0&data=%@", escapedData] dataUsingEncoding:NSUTF8StringEncoding];
    NSURL *baseURL = [NSURL URLWithString:MPBaseURLString];
    NSURL *url = [NSURL URLWithString:endpoint relativeToURL:baseURL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:body];
    
    return request;
}

extern NSURLRequest *MPURLRequestForEventData(NSData *data) {
    return MPDataURLRequest(data, @"track/");
}

extern NSURLRequest *MPURLRequestForPeopleData(NSData *data) {
    return MPDataURLRequest(data, @"engage/");
}

#if defined(__IPHONE_OS_VERSION_MIN_REQUIRED)

NSDictionary *MPDeviceProperties() {
    size_t length = 0;
    int mib[2] = {CTL_HW, HW_MACHINE};
    sysctl(mib, 2, NULL, &length, NULL, 0);
    char *buffer = malloc(length);
    sysctl(mib, 2, buffer, &length, NULL, 0);
    NSString *model = [[NSString alloc] initWithBytesNoCopy:buffer length:(length - 1) encoding:NSUTF8StringEncoding freeWhenDone:YES];
    
    NSString *systemName = nil;
    NSString *systemVersion = nil;
    CGSize size = CGSizeZero;
    NSString *carrier = nil;

    UIDevice *device = [UIDevice currentDevice];
    systemName = [device systemName];
    systemVersion = [device systemVersion];
    
    size = [[UIScreen mainScreen] bounds].size;

    CTTelephonyNetworkInfo *networkInfo = [[CTTelephonyNetworkInfo alloc] init];
    carrier = [[networkInfo subscriberCellularProvider] carrierName];

    NSNumber *width = [NSNumber numberWithInteger:(NSInteger)MIN(size.width, size.height)];
    NSNumber *height = [NSNumber numberWithInteger:(NSInteger)MAX(size.width, size.height)];

    NSMutableDictionary *properties = [NSMutableDictionary new];
    [properties setValue:@"Apple" forKey:@"$manufacturer"];
    [properties setValue:carrier forKey:@"$carrier"];
    [properties setValue:model forKey:@"$model"];
    [properties setValue:systemName forKey:@"$os"];
    [properties setValue:systemVersion forKey:@"$os_version"];
    [properties setValue:width forKey:@"$screen_width"];
    [properties setValue:height forKey:@"$screen_height"];

    return [properties copy];
}

#elif defined(__MAC_OS_X_VERSION_MIN_REQUIRED)

NSDictionary *MPDeviceProperties() {
    size_t length = 0;
    int mib[2] = {CTL_HW, HW_MODEL};
    sysctl(mib, 2, NULL, &length, NULL, 0);
    char *buffer = malloc(length);
    sysctl(mib, 2, buffer, &length, NULL, 0);
    NSString *model = [[NSString alloc] initWithBytesNoCopy:buffer length:(length - 1) encoding:NSUTF8StringEncoding freeWhenDone:YES];
    
    SInt32 major, minor, bugfix;
    Gestalt(gestaltSystemVersionMajor, &major);
    Gestalt(gestaltSystemVersionMinor, &minor);
    Gestalt(gestaltSystemVersionBugFix, &bugfix);
    NSString *version = [NSString stringWithFormat:@"%d.%d", (int)major, (int)minor];
    if (bugfix)
        version = [version stringByAppendingString:[NSString stringWithFormat:@".%d", (int)bugfix]];

    NSSize size = [[NSScreen mainScreen] frame].size;
    NSNumber *width = [NSNumber numberWithInteger:(NSInteger)size.width];
    NSNumber *height = [NSNumber numberWithInteger:(NSInteger)size.height];

    NSMutableDictionary *properties = [NSMutableDictionary new];
    [properties setValue:@"Apple" forKey:@"$manufacturer"];
    [properties setValue:model forKey:@"$model"];
    [properties setValue:@"Mac OS" forKey:@"$os"];
    [properties setValue:version forKey:@"$os_version"];
    [properties setValue:width forKey:@"$screen_width"];
    [properties setValue:height forKey:@"$screen_height"];

    return [properties copy];
}

#else

NSDictionary *MPDeviceProperties() {
    return nil;
}

#endif

NSDictionary *MPAutomaticProperties() {
    static NSDictionary *automaticProperties = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSBundle *bundle = [NSBundle mainBundle];
        
        NSMutableDictionary *properties = [NSMutableDictionary dictionaryWithDictionary:MPDeviceProperties()];
        [properties setValue:[bundle.infoDictionary objectForKey:(id)kCFBundleVersionKey] forKey:@"$app_version"];
        [properties setValue:[bundle.infoDictionary objectForKey:@"CFBundleShortVersionString"] forKey:@"$app_release"];
        [properties setValue:@"iphone" forKey:@"mp_lib"];
        [properties setValue:@"1.1" forKey:@"$lib_version"];
        automaticProperties = [properties copy];
    });
    return automaticProperties;
}
