//
//  HEMMarkdown.h
//  Sense
//
//  Created by Delisa Mason on 12/22/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HEMMarkdown : NSObject

+ (NSDictionary*)attributesForAlertMessageText;
+ (NSDictionary*)attributesForBackViewTitle;
+ (NSDictionary*)attributesForInsightViewText;
+ (NSDictionary*)attributesForInsightTitleViewText;
+ (NSDictionary*)attributesForTimelineTimeLabelsText;
+ (NSDictionary*)attributesForTimelineMessageText;
+ (NSDictionary*)attributesForTimelineBreakdownTitle;
+ (NSDictionary*)attributesForTimelineBreakdownValueWithColor:(UIColor*)color;
+ (NSDictionary*)attributesForTimelineSegmentPopup;

@end
