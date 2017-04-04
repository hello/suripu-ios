//
//  HEMMarkdown.m
//  Sense
//
//  Created by Delisa Mason on 12/22/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import <AttributedMarkdown/markdown_peg.h>
#import "HEMMarkdown.h"
#import "HEMStyle.h"

@implementation HEMMarkdown

+ (NSDictionary *)attributesForAlertMessageText {
    NSMutableParagraphStyle* style = DefaultBodyParagraphStyle();
    return @{ @(PARA) : @{NSFontAttributeName : [UIFont body],
                          NSForegroundColorAttributeName : [UIColor grey5],
                          NSParagraphStyleAttributeName : style}};
}

+ (NSDictionary *)attributesForTimelineBreakdownTitle {
    return @{ @(PARA) : @{ NSFontAttributeName : [UIFont h7],
                           NSKernAttributeName : @1 } };
}

+ (NSDictionary *)attributesForTimelineBreakdownValueWithColor:(UIColor *)color {
    return @{
        @(PARA) :
            @{ NSFontAttributeName : [UIFont h4],
               NSForegroundColorAttributeName : color }
    };
}

+ (NSDictionary *)attributesForTimelineTimeLabelsText {
    NSMutableParagraphStyle *style = [NSMutableParagraphStyle new];
    style.alignment = NSTextAlignmentCenter;
    return @{
        @(PARA) : @{ NSFontAttributeName : [UIFont h8],
                     NSParagraphStyleAttributeName : style }
    };
}

+ (NSDictionary *)attributesForBackViewTitle {
    return @{ @(PARA) : @{ NSKernAttributeName : @(0.6),
                           NSFontAttributeName : [UIFont h7Bold] } };
}

+ (NSDictionary *)attributesForInsightViewText {
    NSMutableParagraphStyle *style = DefaultBodyParagraphStyle();
    return @{
        @(EMPH) : @{ NSFontAttributeName : [UIFont bodyBold] },
        @(STRONG) : @{ NSFontAttributeName : [UIFont bodyBold] },
        @(BULLETLIST) : @{
            NSFontAttributeName : [UIFont body],
            NSForegroundColorAttributeName : [UIColor colorWithWhite:0.0f alpha:0.5f],
            NSParagraphStyleAttributeName : style
        },
        @(PARA) : @{
            NSForegroundColorAttributeName : [UIColor colorWithWhite:0.0f alpha:0.5f],
            NSFontAttributeName : [UIFont body],
            NSParagraphStyleAttributeName : style
        }
    };
}

+ (NSDictionary *)attributesForInsightTitleViewText {
    return @{@(PARA) : @{ NSForegroundColorAttributeName : [UIColor colorWithWhite:0.0f alpha:0.7f],
                          NSFontAttributeName : [UIFont h4] }};
}

+ (NSDictionary *)attributesForTimelineMessageText {
    NSMutableParagraphStyle *style = DefaultBodyParagraphStyle();
    style.alignment = NSTextAlignmentCenter;
    return @{
        @(STRONG) : @{ NSFontAttributeName : [UIFont bodyBold],
                       NSForegroundColorAttributeName : [UIColor grey6],
                       NSParagraphStyleAttributeName : style},
        @(PLAIN) : @{ NSFontAttributeName : [UIFont body],
                      NSForegroundColorAttributeName : [UIColor grey5],
                      NSParagraphStyleAttributeName : style},
        @(PARA) : @{ NSFontAttributeName : [UIFont body],
                     NSForegroundColorAttributeName : [UIColor grey5],
                     NSParagraphStyleAttributeName : style}
    };
}

+ (NSDictionary *)attributesForTimelineSegmentPopup {
    NSMutableParagraphStyle *style = [NSMutableParagraphStyle new];
    style.alignment = NSTextAlignmentLeft;
    return @{
        @(STRONG) : @{ NSFontAttributeName : [UIFont bodyBold],
                       NSParagraphStyleAttributeName : style,
                       NSForegroundColorAttributeName: [UIColor whiteColor]},
        @(PARA) : @{ NSFontAttributeName : [UIFont body], NSParagraphStyleAttributeName : style,
                     NSForegroundColorAttributeName: [UIColor whiteColor]}
    };
}
@end
