//
//  HEMEmbeddedVideoView.m
//  Sense
//
//  Created by Jimmy Lu on 8/28/15.
//  Copyright (c) 2015 Hello. All rights reserved.
//

#import <AVFoundation/AVPlayer.h>
#import <AVFoundation/AVPlayerItem.h>
#import <AVFoundation/AVPlayerLayer.h>
#import <AVFoundation/AVAsset.h>

#import "HEMEmbeddedVideoView.h"

static NSString* const HEMEmbeddedVideoPlayerStatusKeyPath = @"status";
static NSString* const HEMEmbeddedVideoPlayerPlaybackKeepUpKeyPath = @"playbackLikelyToKeepUp";
static NSString* const HEMEmbeddedVideoPlayerBufferFullKeyPath = @"playbackBufferFull";

@interface HEMEmbeddedVideoView()

@property (nonatomic, weak) IBOutlet UIImageView* firstFrameView;

@property (nonatomic, copy) NSString* videoPath;
@property (nonatomic, weak) AVPlayer* videoPlayer;
@property (nonatomic, strong) AVPlayerItem* videoPlayerItem;
@property (nonatomic, weak) AVPlayerLayer* videoPlayerLayer;
@property (nonatomic, assign, getter=isStoppedByCaller) BOOL stoppedByCaller;
@property (nonatomic, assign, getter=isSubscribedToPlaybackEvents) BOOL subscribedToPlaybackEvents;

@end

@implementation HEMEmbeddedVideoView

- (id)init {
    self = [super init];
    if (self) {
        [self setLoop:YES];
        [self setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setLoop:YES];
        [self setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setLoop:YES];
    }
    return self;
}

- (void)setFirstFrame:(UIImage*)image videoPath:(NSString*)videoPath {
    if (![self firstFrameView]) {
        UIImageView* imageView = [[UIImageView alloc] initWithFrame:[self bounds]];
        [imageView setContentMode:UIViewContentModeCenter];
        [imageView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
        [self addSubview:imageView];
        [self setFirstFrameView:imageView];
    }
    
    [[self firstFrameView] setImage:image];
    [[self firstFrameView] setContentMode:UIViewContentModeScaleAspectFit];
    
    [self setVideoPath:videoPath];
}

- (void)setVideoPath:(NSString*)videoPath {
    if ([_videoPath isEqualToString:videoPath]) {
        return;
    }
    DDLogVerbose(@"setting video path to %@", videoPath);
    [self setReady:NO];
    
    if ([self videoPlayer]) {
        [self unsubscribeToNotificationFor:[self videoPlayer]];
        [self removeKVOObservers];
    }
    
    if ([self videoPlayerLayer]) {
        [[self videoPlayerLayer] removeFromSuperlayer];
    }
    
    NSURL* url = [NSURL URLWithString:videoPath];
    AVPlayer* player = [AVPlayer playerWithURL:url];
    AVPlayerItem* item = [player currentItem];
    [player setActionAtItemEnd:AVPlayerActionAtItemEndNone];
    [player addObserver:self forKeyPath:HEMEmbeddedVideoPlayerStatusKeyPath options:0 context:nil];
    [item addObserver:self forKeyPath:HEMEmbeddedVideoPlayerPlaybackKeepUpKeyPath options:0 context:nil];
    [item addObserver:self forKeyPath:HEMEmbeddedVideoPlayerBufferFullKeyPath options:0 context:nil];
    
    AVPlayerLayer* layer = [AVPlayerLayer playerLayerWithPlayer:player];
    [layer setBackgroundColor:[[UIColor clearColor] CGColor]];
    [layer setFrame:[self bounds]];

    [[self layer] addSublayer:layer];
    
    if ([self loop]) {
        [self subcribeToNotificationsFor:player];
    }
    
    _videoPath = [videoPath copy];
    [self setVideoPlayer:player];
    [self setVideoPlayerItem:item];
    [self setVideoPlayerLayer:layer];
}

- (void)playVideoWhenReady {
    if ([self isReady]
        && [[self videoPlayer] rate] == 0
        && [[self videoPlayer] status] == AVPlayerStatusReadyToPlay
        && ([[self videoPlayerItem] isPlaybackBufferFull]
            || [[self videoPlayerItem] isPlaybackLikelyToKeepUp])) {
        DDLogVerbose(@"playing video");
        [[self videoPlayer] play];
        [self setStoppedByCaller:NO];
    }
}

- (void)pause {
    if ([[self videoPlayer] rate] > 0 && ![[self videoPlayer] error]) {
        DDLogVerbose(@"pausing video");
        [[self videoPlayer] pause];
        [self setStoppedByCaller:YES];
    }
}

- (void)stop {
    [self pause];
    [[self videoPlayerItem] seekToTime:kCMTimeZero];
}

- (void)setReady:(BOOL)ready {
    _ready = ready;
    [self playVideoWhenReady];
}

- (void)setLoop:(BOOL)loop {
    _loop = loop;
    
    if (loop) {
        [self subcribeToNotificationsFor:[self videoPlayer]];
    } else {
        [self unsubscribeToNotificationFor:[self videoPlayer]];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [[self videoPlayerLayer] setFrame:[self bounds]];
}

#pragma mark - Video Player Notifications

- (void)unsubscribeToNotificationFor:(AVPlayer*)player {
    if (!player || ![self isSubscribedToPlaybackEvents]) {
        return;
    }
    
    NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self
                      name:AVPlayerItemDidPlayToEndTimeNotification
                    object:[player currentItem]];
    
    [self setSubscribedToPlaybackEvents:NO];
}

- (void)subcribeToNotificationsFor:(AVPlayer*)player {
    if (!player) {
        return;
    }
    
    [self setSubscribedToPlaybackEvents:YES];
    NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(videoDidEnd:)
                        name:AVPlayerItemDidPlayToEndTimeNotification
                        object:[player currentItem]];
}

- (void)videoDidEnd:(NSNotification*)note {
    AVPlayerItem *playerItem = [note object];
    [playerItem seekToTime:kCMTimeZero];
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (object == [self videoPlayer]) {
        if ([keyPath isEqualToString:HEMEmbeddedVideoPlayerStatusKeyPath]) {
            switch ([[self videoPlayer] status]) {
                case AVPlayerStatusReadyToPlay:
                    DDLogVerbose(@"ready to play");
                    [self playVideoWhenReady];
                    break;
                case AVPlayerStatusFailed:
                    DDLogVerbose(@"avplayer failed");
                    break;
                case AVPlayerStatusUnknown:
                default:
                    break;
            }
        }
    } else if (object == [self videoPlayerItem]) {
        if ([keyPath isEqualToString:HEMEmbeddedVideoPlayerBufferFullKeyPath]) {
            if (![self isStoppedByCaller] && [[self videoPlayerItem] isPlaybackBufferFull]) {
                [self playVideoWhenReady];
            }
        } else if ([keyPath isEqualToString:HEMEmbeddedVideoPlayerPlaybackKeepUpKeyPath]) {
            if (![self isStoppedByCaller] && [[self videoPlayerItem] isPlaybackLikelyToKeepUp]) {
                [self playVideoWhenReady];
            }
        }
    }
}

#pragma mark - Clean UP

- (void)removeKVOObservers {
    if ([self videoPlayer]) {
        [[self videoPlayerItem] removeObserver:self
                                    forKeyPath:HEMEmbeddedVideoPlayerPlaybackKeepUpKeyPath];
        [[self videoPlayerItem] removeObserver:self
                                    forKeyPath:HEMEmbeddedVideoPlayerBufferFullKeyPath];
        [[self videoPlayer] removeObserver:self
                                forKeyPath:HEMEmbeddedVideoPlayerStatusKeyPath];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    if (_videoPlayer) {
        [self removeKVOObservers];
    }
}

@end
