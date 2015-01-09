//
//  HEMMarkdown.m
//  Sense
//
//  Created by Delisa Mason on 12/22/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import <AttributedMarkdown/markdown_peg.h>
#import "HEMMarkdown.h"
#import "UIFont+HEMStyle.h"

@implementation HEMMarkdown

+ (NSDictionary*)attributesForBackViewText
{
    return @{
        @(EMPH) : @{ NSFontAttributeName : [UIFont backViewBoldFont] },
        @(STRONG) : @{ NSFontAttributeName : [UIFont backViewBoldFont] },
        @(PLAIN) : @{ NSFontAttributeName : [UIFont backViewTextFont] }
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
             NSForegroundColorAttributeName : [UIColor colorWithWhite:0.0f alpha:0.4f],
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
        @(PLAIN)  : @{ NSFontAttributeName : [UIFont backViewTextFont] }
    };
}

@end
