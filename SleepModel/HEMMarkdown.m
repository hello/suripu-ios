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
            NSFontAttributeName : [UIFont backViewBoldFont],
            NSParagraphStyleAttributeName : style,
            NSForegroundColorAttributeName : [UIColor blackColor]
        },
        @(STRONG) : @{
            NSFontAttributeName : [UIFont backViewBoldFont],
            NSParagraphStyleAttributeName : style,
            NSForegroundColorAttributeName : [UIColor blackColor]
        },
        @(BULLETLIST) : @{
            NSFontAttributeName : [UIFont backViewTextFont],
            NSParagraphStyleAttributeName : style,
            NSForegroundColorAttributeName : [UIColor textColor]
        },
        @(PARA) : @{
            NSFontAttributeName : [UIFont backViewTextFont],
            NSParagraphStyleAttributeName : style,
            NSForegroundColorAttributeName : [UIColor textColor]
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
                     NSFontAttributeName : [UIFont insightSummaryBoldFont],
                     NSParagraphStyleAttributeName : style,
                     NSForegroundColorAttributeName : [UIColor blackColor]
                     },
             @(STRONG) : @{
                     NSFontAttributeName : [UIFont insightSummaryBoldFont],
                     NSParagraphStyleAttributeName : style,
                     NSForegroundColorAttributeName : [UIColor blackColor]
                     },
             @(PARA) : @{
                     NSFontAttributeName : [UIFont insightSummaryFont],
                     NSParagraphStyleAttributeName : style,
                     NSForegroundColorAttributeName : [UIColor detailTextColor]
                     },
             @(BULLETLIST) : @{
                     NSFontAttributeName : [UIFont insightSummaryFont],
                     NSParagraphStyleAttributeName : style,
                     NSForegroundColorAttributeName : [UIColor detailTextColor]
                     }
             };
}

+ (NSDictionary *)attributesForAlertMessageText {
    return @{ @(PARA) : @{NSFontAttributeName : [UIFont dialogMessageFont],
                          NSForegroundColorAttributeName : [UIColor blackColor]}};
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
            @{ NSFontAttributeName : [UIFont timelineBreakdownValueFont], NSForegroundColorAttributeName : color }
    };
}

+ (NSDictionary *)attributesForTimelineTimeLabelsText {
    NSMutableParagraphStyle *style = [NSMutableParagraphStyle new];
    style.alignment = NSTextAlignmentCenter;
    return @{
        @(PARA) : @{ NSFontAttributeName : [UIFont timelineTimeLabelFont], NSParagraphStyleAttributeName : style }
    };
}

+ (NSDictionary *)attributesForBackViewTitle {
    return @{ @(PARA) : @{ NSKernAttributeName : @(0.6), NSFontAttributeName : [UIFont backViewTitleFont] } };
}

+ (NSDictionary *)attributesForInsightViewText {
    NSMutableParagraphStyle *style = [NSMutableParagraphStyle new];
    style.lineSpacing = 4.f;
    return @{
        @(EMPH) : @{ NSFontAttributeName : [UIFont insightFullMessageBoldFont] },
        @(STRONG) : @{ NSFontAttributeName : [UIFont insightFullMessageBoldFont] },
        @(BULLETLIST) : @{
            NSFontAttributeName : [UIFont insightFullMessageFont],
            NSForegroundColorAttributeName : [UIColor colorWithWhite:0.0f alpha:0.5f],
            NSParagraphStyleAttributeName : style
        },
        @(PARA) : @{
            NSForegroundColorAttributeName : [UIColor colorWithWhite:0.0f alpha:0.5f],
            NSFontAttributeName : [UIFont insightFullMessageFont],
            NSParagraphStyleAttributeName : style
        }
    };
}

+ (NSDictionary *)attributesForInsightTitleViewText {
    return @{@(PARA) : @{ NSForegroundColorAttributeName : [UIColor colorWithWhite:0.0f alpha:0.7f],
                          NSFontAttributeName : [UIFont insightTitleFont] }};
}

+ (NSDictionary *)attributesForEventMessageText {
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    style.alignment = NSTextAlignmentLeft;
    style.lineSpacing = 2.f;
    style.maximumLineHeight = 18.f;
    style.minimumLineHeight = 18.f;
    return @{
        @(STRONG) : @{
            NSFontAttributeName : [UIFont timelineEventMessageBoldFont],
            NSParagraphStyleAttributeName : style,
            NSForegroundColorAttributeName : [UIColor blackColor]
        },
        @(PARA) : @{
            NSFontAttributeName : [UIFont timelineEventMessageFont],
            NSParagraphStyleAttributeName : style,
            NSForegroundColorAttributeName : [UIColor blackColor]
        },
        @(EMPH) : @{
            NSFontAttributeName : [UIFont timelineEventMessageItalicFont],
            NSParagraphStyleAttributeName : style,
            NSForegroundColorAttributeName : [UIColor lightGrayColor]
        },
    };
}

+ (NSDictionary *)attributesForTimelineMessageText {
    return @{
        @(STRONG) : @{ NSFontAttributeName : [UIFont timelineMessageBoldFont] },
        @(PLAIN) : @{ NSFontAttributeName : [UIFont timelineMessageFont] }
    };
}

+ (NSDictionary *)attributesForTimelineSegmentPopup {
    NSMutableParagraphStyle *style = [NSMutableParagraphStyle new];
    style.alignment = NSTextAlignmentLeft;
    return @{
        @(STRONG) : @{ NSFontAttributeName : [UIFont timelinePopupBoldFont],
                       NSParagraphStyleAttributeName : style,
                       NSForegroundColorAttributeName: [UIColor whiteColor]},
        @(PARA) : @{ NSFontAttributeName : [UIFont timelinePopupFont], NSParagraphStyleAttributeName : style,
                     NSForegroundColorAttributeName: [UIColor whiteColor]}
    };
}

+ (NSDictionary *)attributesForRoomCheckSensorMessage {
    NSMutableParagraphStyle *style = [NSMutableParagraphStyle new];
    style.alignment = NSTextAlignmentCenter;

    return @{
        @(EMPH) : @{
            NSFontAttributeName : [UIFont onboardingRoomCheckSensorBoldFont],
            NSParagraphStyleAttributeName : style
        },
        @(STRONG) : @{
            NSFontAttributeName : [UIFont onboardingRoomCheckSensorBoldFont],
            NSParagraphStyleAttributeName : style
        },
        @(PLAIN) :
            @{ NSFontAttributeName : [UIFont onboardingRoomCheckSensorFont], NSParagraphStyleAttributeName : style },
        @(PARA) :
            @{ NSFontAttributeName : [UIFont onboardingRoomCheckSensorFont], NSParagraphStyleAttributeName : style }
    };
}

+ (NSDictionary *)attributesForSensorMessage {
    return @{
        @(STRONG) : @{ NSFontAttributeName : [UIFont sensorMessageBoldFont] },
        @(EMPH) : @{ NSFontAttributeName : [UIFont sensorMessageBoldFont] },
        @(PARA) : @{ NSFontAttributeName : [UIFont sensorMessageFont] }
    };
}

+ (NSDictionary *)attributesForSensorGraphButtonWithSelectedState:(BOOL)isOn {
    UIColor *color = isOn ? [UIColor tintColor] : [UIColor colorWithWhite:0.6 alpha:1.f];
    return @{
        @(PARA) : @{
            NSFontAttributeName : [UIFont sensorRangeSelectionFont],
            NSKernAttributeName : @(1.2),
            NSForegroundColorAttributeName : color
        }
    };
}

@end
