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
@property (nonatomic, assign, readonly) NSUInteger count;

- (instancetype)initWithIdentifier:(NSString*)identifier;
+ (HEMAppUsage *)appUsageForIdentifier:(NSString *)identifier;
- (void)increment;

@end
