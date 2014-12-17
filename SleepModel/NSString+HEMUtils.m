//
//  NSString+HEMUtils.m
//  Sense
//
//  Created by Delisa Mason on 12/16/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import "NSString+HEMUtils.h"

@implementation NSString (HEMUtils)

static NSPredicate* emailPredicate;

+ (void)initialize
{
    NSString* regex = @"^.+@.+\\..+$";
    emailPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
}

- (BOOL)isValidEmail
{
    if ([self length] == 0) return NO;
    return [emailPredicate evaluateWithObject:self];
}

- (NSString*)trim
{
    NSCharacterSet* spaces = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    return [self stringByTrimmingCharactersInSet:spaces];
}

@end
