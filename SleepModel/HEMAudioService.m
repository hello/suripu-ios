//
//  HEMAudioService.m
//  Sense
//
//  Created by Jimmy Lu on 4/5/16.
//  Copyright © 2016 Hello. All rights reserved.
//
#import <AVFoundation/AVFoundation.h>

#import "HEMAudioService.h"

@implementation HEMAudioService

- (instancetype)init {
    self = [super init];
    if (self) {
        [self configureSessionCategory];
    }
    return self;
}

- (void)configureSessionCategory {
    NSError* error = nil;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback
                                           error:&error];
    if (error) {
        [SENAnalytics trackError:error];
    }
}

- (void)activateSession:(BOOL)activate completion:(HEMAudioActivationHandler)completion {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        AVAudioSessionSetActiveOptions options = 0;
        if (!activate) {
            options = AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation;
        }
        
        NSError *error = nil;
        [[AVAudioSession sharedInstance] setActive:activate withOptions:options error:&error];
        
        if (error) {
            [SENAnalytics trackError:error];
        }
        
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(error);
            });
        }
    });
}

@end
