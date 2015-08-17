//
//  HEMAudioSession.m
//  Sense
//
//  Created by Delisa Mason on 8/7/15.
//  Copyright (c) 2015 Hello. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "HEMAudioSession.h"

void HEMInitializeAudioSession() {
    NSError *audioSessionError = nil;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&audioSessionError];
    if (audioSessionError)
        [SENAnalytics trackError:audioSessionError];
}

/**
 * https://developer.apple.com/library/ios/documentation/Audio/Conceptual/AudioSessionProgrammingGuide/ConfiguringanAudioSession/ConfiguringanAudioSession.html
 *
 * "Most apps never need to deactivate their audio session explicitly. Important
 * exceptions include VoIP (Voice over Internet Protocol) apps, turn-by-turn 
 * navigation apps, and, in some cases, recording apps."
 *
 * If deactivating the session, be sure to make sure audio is stopped and not
 * paused before doing so.  If not verified before deactivating, an error will
 * occur and a hiccup in the main thread will occur.
 */
void HEMActivateAudioSession(BOOL activate, void (^completion)(NSError *error)) {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSError *error = nil;
        AVAudioSessionSetActiveOptions options = activate ? 0 : AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation;

        [[AVAudioSession sharedInstance] setActive:activate withOptions:options error:&error];
        if (error)
            [SENAnalytics trackError:error];

        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(error);
            });
        }
    });
}