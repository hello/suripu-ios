//
//  HEMAppUsage.h
//  Sense
//
//  Created by Jimmy Lu on 7/27/15.
//  Copyright (c) 2015 Hello. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, HEMAppUsageInterval) {
    HEMAppUsageIntervalLast7Days,
    HEMAppUsageIntervalLast31Days
};

@interface HEMAppUsage : NSObject <NSCoding>

@property (nonatomic, copy,   readonly) NSString* identifier;
@property (nonatomic, strong, readonly) NSDate* created;
@property (nonatomic, strong, readonly) NSDate* updated;

+ (HEMAppUsage*)appUsageForIdentifier:(NSString *)identifier;

- (void)increment:(BOOL)autosave;
- (void)save;
- (NSUInteger)usageWithin:(HEMAppUsageInterval)interval;

@end
