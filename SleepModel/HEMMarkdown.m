//
//  HEMMarkdown.m
//  Sense
//
//  Created by Delisa Mason on 12/22/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import <AttributedMarkdown/markdown_peg.h>
#import "HEMMarkdown.h"
#import "UIColor+HEMStyle.h"
#import "UIFont+HEMStyle.h"

@implementation HEMMarkdown

+ (NSDictionary *)attributesForBackViewText {
    NSMutableParagraphStyle *style = [NSMutableParagraphStyle new];
    style.lineSpacing = 2.f;
    style.lineBreakMode = NSLineBreakByWordWrapping;
    style.alignment = NSTextAlignmentLeft;

    return @{
        @(EMPH) : @{
            NSFontAttributeName : [UIFont bodyBold],
            NSParagraphStyleAttributeName : style,
            NSForegroundColorAttributeName : [UIColor boldTextColor]
        },
        @(STRONG) : @{
            NSFontAttributeName : [UIFont bodyBold],
            NSParagraphStyleAttributeName : style,
            NSForegroundColorAttributeName : [UIColor boldTextColor]
        },
        @(BULLETLIST) : @{
            NSFontAttributeName : [UIFont body],
            NSParagraphStyleAttributeName : style,
            NSForegroundColorAttributeName : [UIColor detailTextColor]
        },
        @(PARA) : @{
            NSFontAttributeName : [UIFont body],
            NSParagraphStyleAttributeName : style,
            NSForegroundColorAttributeName : [UIColor detailTextColor]
        }
    };
}

+ (NSDictionary *)attributesForInsightSummaryText {
    NSMutableParagraphStyle *style = [NSMutableParagraphStyle new];
    style.lineSpacing = 2.f;
    style.lineBreakMode = NSLineBreakByWordWrapping;
    style.alignment = NSTextAlignmentLeft;
    return @{
             @(EMPH) : @{
                     NSFontAttributeName : [UIFont bodySmallBold],
                     NSParagraphStyleAttributeName : style,
                     NSForegroundColorAttributeName : [UIColor grey6]
                     },
             @(STRONG) : @{
                     NSFontAttributeName : [UIFont bodySmallBold],
                     NSParagraphStyleAttributeName : style,
                     NSForegroundColorAttributeName : [UIColor grey6]
                     },
             @(PARA) : @{
                     NSFontAttributeName : [UIFont bodySmall],
                     NSParagraphStyleAttributeName : style,
                     NSForegroundColorAttributeName : [UIColor grey5]
                     },
             @(BULLETLIST) : @{
                     NSFontAttributeName : [UIFont bodySmall],
                     NSParagraphStyleAttributeName : style,
                     NSForegroundColorAttributeName : [UIColor grey5]
                     }
             };
}

+ (NSDictionary *)attributesForAlertMessageText {
    return @{ @(PARA) : @{NSFontAttributeName : [UIFont body],
                          NSForegroundColorAttributeName : [UIColor grey5]}};
}

+ (NSDictionary *)attributesForTimelineBreakdownTitle {
    return @{ @(PARA) : @{ NSFontAttributeName : [UIFont timelineBreakdownTitleFont], NSKernAttributeName : @1 } };
}

+ (NSDictionary *)attributesForTimelineBreakdownMessage {
    NSMutableParagraphStyle *style = [NSMutableParagraphStyle new];
    style.lineSpacing = 2.f;
    style.alignment = NSTextAlignmentLeft;
    return @{
        @(PARA) :
            @{ NSFontAttributeName : [UIFont timelineBreakdownMessageFont], NSParagraphStyleAttributeName : style },
        @(EMPH) : @{
            NSFontAttributeName : [UIFont timelineBreakdownMessageBoldFont],
            NSParagraphStyleAttributeName : style
        },
        @(STRONG) : @{
            NSFontAttributeName : [UIFont timelineBreakdownMessageBoldFont],
            NSParagraphStyleAttributeName : style
        },
    };
}

+ (NSDictionary *)attributesForTimelineBreakdownValueWithColor:(UIColor *)color {
    return @{
        @(PARA) :
            @{ NSFontAttributeName : [UIFont h7], NSForegroundColorAttributeName : color }
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
    NSMutableParagraphStyle *style = [NSMutableParagraphStyle new];
    style.lineSpacing = 4.f;
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

+ (NSDictionary *)attributesForEventMessageText {
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    style.alignment = NSTextAlignmentLeft;
    style.lineSpacing = 2.f;
    style.maximumLineHeight = 18.f;
    style.minimumLineHeight = 18.f;
    return @{
        @(STRONG) : @{
            NSFontAttributeName : [UIFont bodyBold],
            NSParagraphStyleAttributeName : style,
            NSForegroundColorAttributeName : [UIColor blackColor]
        },
        @(PARA) : @{
            NSFontAttributeName : [UIFont timelineEventMessageFont],
            NSParagraphStyleAttributeName : style,
            NSForegroundColorAttributeName : [UIColor blackColor]
        },
        @(EMPH) : @{
            NSFontAttributeName : [UIFont body],
            NSParagraphStyleAttributeName : style,
            NSForegroundColorAttributeName : [UIColor lightGrayColor]
        },
    };
}

+ (NSDictionary *)attributesForTimelineMessageText {
    return @{
        @(STRONG) : @{ NSFontAttributeName : [UIFont bodyBold] },
        @(PLAIN) : @{ NSFontAttributeName : [UIFont body] }
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
