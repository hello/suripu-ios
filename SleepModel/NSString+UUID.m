//
//  NSString+UUID.m
//  Sense
//
//  Created by Jimmy Lu on 8/20/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import "NSString+UUID.h"

@implementation NSString (UUID)

+ (NSString*)uuid {
    CFUUIDRef theUUID = CFUUIDCreate(NULL);
    CFStringRef string = CFUUIDCreateString(NULL, theUUID);
    CFRelease(theUUID);
    return (__bridge NSString *)string;
}

@end
