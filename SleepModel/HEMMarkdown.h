//
//  HEMMarkdown.h
//  Sense
//
//  Created by Delisa Mason on 12/22/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HEMMarkdown : NSObject

+ (NSDictionary*)attributesForBackViewText;
+ (NSDictionary*)attributesForBackViewTitle;
+ (NSDictionary*)attributesForInsightViewText;
+ (NSDictionary*)attributesForInsightTitleViewText;
+ (NSDictionary*)attributesForEventMessageText;
+ (NSDictionary*)attributesForTimelineMessageText;
+ (NSDictionary*)attributesForTimelineBreakdownTitle;
+ (NSDictionary*)attributesForTimelineBreakdownValueWithColor:(UIColor*)color;
+ (NSDictionary*)attributesForTimelineSegmentPopup;
+ (NSDictionary*)attributesForRoomCheckWithConditionColor:(UIColor*)color;
+ (NSDictionary*)attributesForSensorMessage;
+ (NSDictionary*)attributesForSensorGraphButtonWithSelectedState:(BOOL)isOn;
@end
