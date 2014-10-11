//
//  HEMAlarmCache.h
//  Sense
//
//  Created by Delisa Mason on 10/7/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HEMAlarmCache : NSObject

@property (nonatomic) NSUInteger hour;
@property (nonatomic) NSUInteger minute;
@property (nonatomic, strong) NSString* soundName;
@property (nonatomic) NSUInteger repeatFlags;
@property (nonatomic, getter=isSmart) BOOL smart;

- (void)cacheValuesFromAlarm:(SENAlarm*)alarm;
@end