//
//  HEMSleepSoundVolume.h
//  Sense
//
//  Created by Jimmy Lu on 3/28/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HEMSleepSoundVolume : NSObject

@property (nonatomic, copy) NSString* localizedName;
@property (nonatomic, assign) CGFloat volume;

- (instancetype)initWithName:(NSString*)name volume:(CGFloat)volume;

@end

NS_ASSUME_NONNULL_END