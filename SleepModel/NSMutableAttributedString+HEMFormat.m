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

- (id)initWithFormat:(NSString*)format args:(NSArray*)args {
    self = [self init];
    if (self) {
        [self process:format args:args];
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
                                   


@end
