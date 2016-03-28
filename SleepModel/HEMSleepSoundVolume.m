//
//  HEMSleepSoundVolume.m
//  Sense
//
//  Created by Jimmy Lu on 3/28/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "HEMSleepSoundVolume.h"

@implementation HEMSleepSoundVolume

- (instancetype)initWithName:(NSString*)name volume:(CGFloat)volume {
    self = [super init];
    if (self) {
        _localizedName = [name copy];
        _volume = volume;
    }
    return self;
}

@end
