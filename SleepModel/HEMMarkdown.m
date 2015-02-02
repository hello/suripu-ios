//
//  HEMMarkdown.m
//  Sense
//
//  Created by Delisa Mason on 12/22/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import <AttributedMarkdown/markdown_peg.h>
#import "HEMMarkdown.h"
#import "HelloStyleKit.h"
#import "UIFont+HEMStyle.h"

@implementation HEMMarkdown

+ (NSDictionary*)attributesForBackViewText
{
    NSMutableParagraphStyle* style = [NSMutableParagraphStyle new];
    style.lineSpacing = 2.f;
    style.alignment = NSTextAlignmentLeft;
    UIColor* textColor = [UIColor colorWithWhite:0.3f alpha:1.f];
    return @{
        @(EMPH) : @{ NSFontAttributeName : [UIFont backViewBoldFont],
                     NSParagraphStyleAttributeName: style,
                     NSForegroundColorAttributeName: textColor },
        @(STRONG) : @{ NSFontAttributeName : [UIFont backViewBoldFont],
                       NSParagraphStyleAttributeName: style,
                       NSForegroundColorAttributeName: textColor },
        @(PARA) : @{ NSFontAttributeName : [UIFont backViewTextFont],
                     NSParagraphStyleAttributeName: style,
                     NSForegroundColorAttributeName: textColor }
    };
}

+ (NSDictionary*)attributesForBackViewTitle
{
    return @{
        @(PARA) : @{ NSKernAttributeName : @(0.6), NSFontAttributeName : [UIFont backViewTitleFont] }
    };
}

+ (NSDictionary*)attributesForInsightViewText
{
    return @{
        @(EMPH) : @{ NSFontAttributeName : [UIFont insightFullMessageBoldFont] },
        @(STRONG) : @{ NSFontAttributeName : [UIFont insightFullMessageBoldFont] },
        @(PARA) : @{
            NSForegroundColorAttributeName : [UIColor colorWithWhite:0.0f alpha:0.7f],
            NSFontAttributeName : [UIFont insightFullMessageFont]
        }
    };
}

+ (NSDictionary*)attributesForInsightTitleViewText
{
    return @{
        @(PARA) : @{
             NSForegroundColorAttributeName : [UIColor blackColor],
             NSFontAttributeName : [UIFont insightTitleFont]
        }
    };
}

+ (NSDictionary*)attributesForEventMessageText
{
    return @{
        @(STRONG) : @{ NSFontAttributeName : [UIFont timelineEventMessageBoldFont] },
        @(PLAIN) : @{ NSFontAttributeName : [UIFont timelineEventMessageFont] }
    };
}

+ (NSDictionary*)attributesForTimelineMessageText
{
    return @{
        @(STRONG) : @{ NSFontAttributeName : [UIFont timelineMessageBoldFont] },
        @(PLAIN) : @{ NSFontAttributeName : [UIFont timelineMessageFont] }
    };
}

+ (NSDictionary*)attributesForRoomCheckWithConditionColor:(UIColor*)color
{
    return @{
        @(EMPH)   : @{ NSForegroundColorAttributeName : color },
        @(STRONG) : @{ NSForegroundColorAttributeName : color },
        @(PLAIN)  : @{ NSFontAttributeName : [UIFont onboardingRoomCheckSensorFont] }
    };
}

+ (NSDictionary*)attributesForSensorMessageWithConditionColor:(UIColor*)color
{
    return @{
        @(STRONG) : @{ NSForegroundColorAttributeName : color },
        @(EMPH)   : @{ NSForegroundColorAttributeName : color },
        @(PARA)   : @{ NSFontAttributeName : [UIFont sensorMessageFont] }
    };
}

+ (NSDictionary*)attributesForSensorGraphButtonWithSelectedState:(BOOL)isOn
{
    UIColor* color = isOn ? [HelloStyleKit tintColor] : [UIColor colorWithWhite:0.6 alpha:1.f];
    return @{ @(PARA) : @{ NSFontAttributeName : [UIFont sensorRangeSelectionFont],
                           NSKernAttributeName : @(1.2),
                           NSForegroundColorAttributeName : color }
    };
}

@end
