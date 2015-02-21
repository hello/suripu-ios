//
//  NSAttributedString+HEMUtils.m
//  Sense
//
//  Created by Delisa Mason on 12/16/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import "NSAttributedString+HEMUtils.h"
#import "UIFont+HEMStyle.h"
#import "HelloStyleKit.h"

@implementation NSAttributedString (HEMUtils)

- (NSAttributedString *)trim
{
    NSAttributedString* text = [self copy];
    NSCharacterSet* whitespaceSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    while (text.length > 0 && [whitespaceSet characterIsMember:[[text string] characterAtIndex:text.length - 1]])
        text = [text attributedSubstringFromRange:NSMakeRange(0, text.length - 1)];
    return text;
}

- (NSAttributedString *)hyperlink:(NSString*)url {
    NSMutableAttributedString* hyperlink = [self mutableCopy];
    
    [hyperlink addAttributes:@{NSLinkAttributeName : url,
                               NSFontAttributeName : [UIFont settingsHelpFont],
                               NSForegroundColorAttributeName : [HelloStyleKit senseBlueColor]}
                       range:NSMakeRange(0, [hyperlink length])];
    
    return hyperlink;
}

@end
