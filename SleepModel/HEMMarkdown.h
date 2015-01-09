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
+ (NSDictionary*)attributesForInsightViewText;
+ (NSDictionary*)attributesForInsightTitleViewText;
+ (NSDictionary*)attributesForEventMessageText;
+ (NSDictionary*)attributesForTimelineMessageText;
+ (NSDictionary*)attributesForRoomCheckWithConditionColor:(UIColor*)color;
+ (NSDictionary*)attributesForSensorMessageWithConditionColor:(UIColor*)color;
@end
