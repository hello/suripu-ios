//
//  HEMAudioService.m
//  Sense
//
//  Created by Jimmy Lu on 4/5/16.
//  Copyright © 2016 Hello. All rights reserved.
//
#import <AVFoundation/AVFoundation.h>

#import "HEMAudioService.h"

NSString* const HEMAudioServiceErrorDomain = @"is.hello.app.audio";

@interface HEMAudioService()

@property (nonatomic, strong) NSOperationQueue* soundFileDownloadQueue;

@end

@implementation HEMAudioService

- (instancetype)init {
    self = [super init];
    if (self) {
        _soundFileDownloadQueue = [NSOperationQueue new];
        [_soundFileDownloadQueue setMaxConcurrentOperationCount:1];
        
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

- (void)downloadAudioFileWithURL:(NSString*)urlString completion:(HEMAudioDownloadHandler)completion {
    // if there are anything pending, don't let it block new call, so cancel the
    // download.  if we want to, in the future, decide to queue up a bunch of
    // downloads, we can modify this
    [[self soundFileDownloadQueue] cancelAllOperations];
    [[self soundFileDownloadQueue] addOperationWithBlock:^{
        NSURL* url = [NSURL URLWithString:urlString];
        NSError* error = nil;
        NSData* data = nil;
        
        if (!url) {
            NSDictionary* info = @{NSLocalizedDescriptionKey : urlString ? : @"url is undefined"};
            error = [NSError errorWithDomain:HEMAudioServiceErrorDomain
                                        code:HEMAudioServiceErrorInvalidURL
                                    userInfo:info];
            [SENAnalytics trackError:error];
        } else {
            data = [NSData dataWithContentsOfURL:url];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completion (data, error);
        });
        
    }];
}

#pragma mark - Clean up

- (void)dealloc {
    if (_soundFileDownloadQueue) {
        [_soundFileDownloadQueue cancelAllOperations];
    }
}

@end
