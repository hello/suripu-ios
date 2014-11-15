//
//  NSString+Email.m
//  Sense
//
//  Created by Jimmy Lu on 8/20/14.
//  Copyright (c) 2014 Hello Inc. All rights reserved.
//

#import "NSString+Email.h"

static NSPredicate* emailPredicate;

@implementation NSString (Email)

+ (void)initialize {
    NSString* regex = @"^.+@.+\\..+$";
    emailPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
}

- (BOOL)isValidEmail {
    if ([self length] == 0) return NO;
    return [emailPredicate evaluateWithObject:self];
}

@end
