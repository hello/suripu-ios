//
//  HEMAlarmCache.h
//  Sense
//
//  Created by Delisa Mason on 10/7/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SENExpansion;
@class SENAlarmExpansion;

@interface HEMAlarmCache : NSObject

@property (nonatomic) NSUInteger hour;
@property (nonatomic) NSUInteger minute;
@property (nonatomic, strong) NSString* soundName;
@property (nonatomic, strong) NSString* soundID;
@property (nonatomic) NSUInteger repeatFlags;
@property (nonatomic, getter=isSmart) BOOL smart;
@property (nonatomic, getter=isOn) BOOL on;
@property (nonatomic, strong) NSArray<SENAlarmExpansion*>* expansions;

- (void)cacheValuesFromAlarm:(SENAlarm*)alarm;
- (BOOL)isRepeated;
- (void)setAlarmExpansion:(SENAlarmExpansion*)alarmExpansion;

@end
