//
//  NSMutableAttributedString+HEMFormat.m
//  Sense
//
//  Created by Jimmy Lu on 10/15/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import "NSMutableAttributedString+HEMFormat.h"

static NSString* const kHEMStringFormatSymbol = @"%@";

@implementation NSMutableAttributedString (HEMFormat)

- (instancetype)initWithFormat:(NSString*)format args:(NSArray*)args {
    self = [self init];
    if (self) {
        [self process:format args:args];
    }
    return self;
}

- (instancetype)initWithFormat:(NSString *)format
                          args:(NSArray *)args
                     baseColor:(UIColor*)color
                      baseFont:(UIFont*)font {
    self = [self initWithFormat:format args:args];
    if (self) {
        [self applyColor:color andFont:font];
    }
    return self;
}

- (void)process:(NSString*)format args:(NSArray*)args {
    NSScanner* scanner = [NSScanner scannerWithString:format];
    [scanner setCharactersToBeSkipped:nil]; // otherwise, whitespace will be skipped
    
    NSString* scanned = nil;
    NSUInteger argIndex = 0;
    NSMutableAttributedString* attrArg = nil;
    NSInteger argCount = [args count];
    
    while (![scanner isAtEnd]) {
        [scanner scanUpToString:kHEMStringFormatSymbol intoString:&scanned];
        
        if (scanned) {
            [self appendAttributedString:[[NSAttributedString alloc] initWithString:scanned]];
        }
        
        if ([scanner scanString:kHEMStringFormatSymbol intoString:NULL]) {
            if (argIndex < argCount) {
                attrArg = args[argIndex];
                if ([attrArg isKindOfClass:[NSAttributedString class]]) {
                    [self appendAttributedString:attrArg];
                }
            }
            argIndex++;
        }
    }
    
}

- (void)applyColor:(UIColor*)color andFont:(UIFont*)font {
    [self enumerateAttributesInRange:NSMakeRange(0, [self length])
                             options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired
                          usingBlock:^(NSDictionary *attrs, NSRange range, BOOL *stop) {
                              if ([attrs valueForKey:NSFontAttributeName] == nil) {
                                  [self addAttribute:NSFontAttributeName
                                               value:font
                                               range:range];
                              }
                                  
                              if ([attrs valueForKey:NSForegroundColorAttributeName] == nil) {
                                  [self addAttribute:NSForegroundColorAttributeName
                                               value:color
                                               range:range];
                              }
                                  
                          }];
}

@end
