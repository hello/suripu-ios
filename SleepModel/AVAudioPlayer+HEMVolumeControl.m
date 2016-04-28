//
//  AVAudioPlayer+HEMVolumeControl.m
//  Sense
//
//  Created by Jimmy Lu on 4/27/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "AVAudioPlayer+HEMVolumeControl.h"

static CGFloat const HEMVolumeControlFadeSteps = 20;

@implementation AVAudioPlayer (HEMVolumeControl)

- (BOOL)playWithVolumeFadeOver:(NSTimeInterval)seconds {
    if ([self isPlaying]) {
        return NO; // do nothing if it's already playing
    }
    
    CGFloat startVolume = 0.0f;
    
    [self setVolume:startVolume];
    
    BOOL playing = [self play];
    
    if (playing) {
        DDLogVerbose(@"start fade at %@", [NSDate date]);
        NSTimeInterval timeInterval = seconds / HEMVolumeControlFadeSteps;
        CGFloat volumeDelta = 1.0f / HEMVolumeControlFadeSteps;
        [self fadeVolumeFrom:startVolume
                 volumeDelta:volumeDelta
                    increase:YES
                    interval:timeInterval];
    }
    
    return playing;
}

- (void)fadeVolumeFrom:(CGFloat)volume
           volumeDelta:(CGFloat)volumeDelta
              increase:(BOOL)increase
              interval:(NSTimeInterval)interval {
    
    if (![self isPlaying]
        || (increase && volume > 1.001f)
        || (!increase && volume < 0.001f)) {
        DDLogVerbose(@"end fade at %@", [NSDate date]);
        // we're done here
        return;
    }
    
    DDLogVerbose(@"setting volume to %f", volume);
    [self setVolume:volume];
    
    __weak typeof(self) weakSelf = self;
    int64_t delaySecs = (int64_t)(interval * NSEC_PER_SEC);
    dispatch_time_t dispatchTime = dispatch_time(DISPATCH_TIME_NOW, delaySecs);
    dispatch_after(dispatchTime, dispatch_get_main_queue(), ^(void) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        CGFloat multiplier = increase ? 1.0f : -1.0f;
        CGFloat nextVolume = volume + (multiplier * volumeDelta);
        [strongSelf fadeVolumeFrom:nextVolume
                       volumeDelta:volumeDelta
                          increase:increase
                          interval:interval];
    });
}

@end
