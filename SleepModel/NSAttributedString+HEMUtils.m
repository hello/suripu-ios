//
//  NSAttributedString+HEMUtils.m
//  Sense
//
//  Created by Delisa Mason on 12/16/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import "NSAttributedString+HEMUtils.h"
#import "NSString+HEMUtils.h"
#import "UIFont+HEMStyle.h"
#import "UIColor+HEMStyle.h"

@implementation NSAttributedString (HEMUtils)

- (NSAttributedString *)trim {
    NSAttributedString *text = [self copy];
    NSCharacterSet *whitespaceSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    while (text.length > 0 && [whitespaceSet characterIsMember:[[text string] characterAtIndex:text.length - 1]])
        text = [text attributedSubstringFromRange:NSMakeRange(0, text.length - 1)];
    return text;
}

- (NSAttributedString *)hyperlink:(NSString *)url {
    NSMutableAttributedString *hyperlink = [self mutableCopy];

    [hyperlink addAttributes:@{
        NSLinkAttributeName : url,
        NSFontAttributeName : [UIFont settingsHelpFont],
        NSForegroundColorAttributeName : [UIColor tintColor]
    } range:NSMakeRange(0, [hyperlink length])];

    return hyperlink;
}

- (CGSize)sizeWithWidth:(CGFloat)width {
    // note that attributed string's boundingRect... method is inaccurate!
    NSString* plainText = [self string];
    NSRange range = NSMakeRange(0, [self length]);
    NSDictionary* attributes = [self attributesAtIndex:0 effectiveRange:&range];
    CGFloat height = [plainText heightBoundedByWidth:width attributes:attributes];
    return CGSizeMake(ceilCGFloat(width), ceilCGFloat(height));
}

@end
