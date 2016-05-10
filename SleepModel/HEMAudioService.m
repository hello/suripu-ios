//
//  HEMAudioService.m
//  Sense
//
//  Created by Jimmy Lu on 4/5/16.
//  Copyright © 2016 Hello. All rights reserved.
//
#import <AVFoundation/AVFoundation.h>
#import <AFNetworking/AFNetworking.h>

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
    // downloads, we can modify this.  This will also prevent the wrong file from
    // being played, which is important
    [[self soundFileDownloadQueue] cancelAllOperations];
    
    if ([urlString length] == 0) {
        NSDictionary* info = @{NSLocalizedDescriptionKey : urlString ? : @"url is undefined"};
        NSError* error = [NSError errorWithDomain:HEMAudioServiceErrorDomain
                                             code:HEMAudioServiceErrorInvalidURL
                                         userInfo:info];
        [SENAnalytics trackError:error];
        completion (nil, error);
        return;
    }
    
    [[self soundFileDownloadQueue] addOperationWithBlock:^{
        AFHTTPSessionManager* downloader = [AFHTTPSessionManager manager];
        [downloader setResponseSerializer:[AFHTTPResponseSerializer serializer]];
        [downloader GET:urlString parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            completion (responseObject, nil);
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            [SENAnalytics trackError:error];
            completion (nil, error);
        }];
    }];
}

#pragma mark - Clean up

- (void)dealloc {
    if (_soundFileDownloadQueue) {
        [_soundFileDownloadQueue cancelAllOperations];
    }
}

@end
