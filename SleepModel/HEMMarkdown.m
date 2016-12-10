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
    NSMutableParagraphStyle *style = DefaultBodyParagraphStyle();
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
    return @{ @(PARA) : @{ NSFontAttributeName : [UIFont h7],
                           NSKernAttributeName : @1 } };
}

+ (NSDictionary *)attributesForTimelineBreakdownMessage {
    NSMutableParagraphStyle *style = DefaultBodyParagraphStyle();
    style.alignment = NSTextAlignmentLeft;
    return @{
        @(PLAIN) : @{ NSFontAttributeName : [UIFont body],
                      NSForegroundColorAttributeName : [UIColor grey5],
                      NSParagraphStyleAttributeName : style
        },
        @(PARA) : @{ NSFontAttributeName : [UIFont body],
                     NSForegroundColorAttributeName : [UIColor grey5],
                     NSParagraphStyleAttributeName : style
        },
        @(EMPH) : @{
            NSFontAttributeName : [UIFont bodyBold],
            NSForegroundColorAttributeName : [UIColor grey5],
            NSParagraphStyleAttributeName : style
        },
        @(STRONG) : @{
            NSFontAttributeName : [UIFont bodyBold],
            NSForegroundColorAttributeName : [UIColor grey6],
            NSParagraphStyleAttributeName : style
        },
    };
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
