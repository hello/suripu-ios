//
//  HEMSettingsUtil.h
//  Sense
//
//  Created by Jimmy Lu on 1/26/15.
//  Copyright (c) 2015 Hello, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HEMSettingsUtil : NSObject

+ (void)enableHealthKit:(BOOL)enable;
+ (BOOL)isHealthKitEnabled;

@end
