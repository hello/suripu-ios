//
//  NSString+HEMUtils.m
//  Sense
//
//  Created by Delisa Mason on 12/16/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import <CGFloatType/CGFloatType.h>
#import "NSString+HEMUtils.h"

@implementation NSString (HEMUtils)

static NSPredicate* emailPredicate;

+ (void)initialize {
    NSString* regex = @"^.+@.+\\..+$";
    emailPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
}

+ (NSString*)camelCaseWord:(NSString*)word {
    if ([word length] == 0) {
        return word;
    }
    if ([word length] == 1) {
        return [word uppercaseString];
    }
    NSString* upper = [word uppercaseString];
    char firstChar = [upper characterAtIndex:0];
    return [NSString stringWithFormat:@"%c%@", firstChar, [[word substringFromIndex:1] lowercaseString]];
}

- (BOOL)isValidEmail {
    if ([self length] == 0) return NO;
    return [emailPredicate evaluateWithObject:self];
}

- (NSString*)trim {
    NSCharacterSet* spaces = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    return [self stringByTrimmingCharactersInSet:spaces];
}

- (CGFloat)heightBoundedByWidth:(CGFloat)width usingFont:(UIFont*)font {
    return [self heightBoundedByWidth:width attributes:@{NSFontAttributeName : font}];
}

- (CGFloat)heightBoundedByWidth:(CGFloat)width attributes:(NSDictionary *)attributes {
    return [self sizeBoundedByWidth:width attriburtes:attributes].height;
}

- (CGFloat)heightBoundedByWidth:(CGFloat)width
                     attributes:(NSDictionary *)attributes
             withDrawingOptions:(NSStringDrawingOptions)options {
    return [self sizeBoundedByWidth:width attriburtes:attributes options:options].height;
}

- (CGSize)sizeBoundedByWidth:(CGFloat)width attriburtes:(NSDictionary *)attributes {
    NSStringDrawingOptions options
        = NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin;
    return [self sizeBoundedByWidth:width attriburtes:attributes options:options];
}

- (CGSize)sizeBoundedByHeight:(CGFloat)height attributes:(NSDictionary *)attributes {
    NSStringDrawingOptions options
        = NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin;
    CGSize textSize = [self boundingRectWithSize:CGSizeMake(MAXFLOAT, height)
                                         options:options
                                      attributes:attributes
                                         context:nil].size;
    return CGSizeMake(ceilCGFloat(textSize.width), ceilCGFloat(textSize.height));
}

- (CGSize)sizeBoundedByWidth:(CGFloat)width
                 attriburtes:(NSDictionary *)attributes
                     options:(NSStringDrawingOptions)options {
    CGSize textSize = [self boundingRectWithSize:CGSizeMake(width, MAXFLOAT)
                                         options:options
                                      attributes:attributes
                                         context:nil].size;
    return CGSizeMake(ceilCGFloat(textSize.width), ceilCGFloat(textSize.height));
}

@end
