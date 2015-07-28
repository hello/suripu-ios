//
//  HEMAppUsage.h
//  Sense
//
//  Created by Jimmy Lu on 7/27/15.
//  Copyright (c) 2015 Hello. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HEMAppUsage : NSObject <NSCoding>

@property (nonatomic, copy,   readonly) NSString* identifier;
@property (nonatomic, strong, readonly) NSDate* created;
@property (nonatomic, strong, readonly) NSDate* updated;
@property (nonatomic, assign, readonly) long count;

- (instancetype)initWithIdentifier:(NSString*)identifier;
+ (void)appUsageForIdentifier:(NSString *)identifier
                   completion:(void(^)(HEMAppUsage* usage))completion;
- (void)increment;
- (void)resetCount;

@end
