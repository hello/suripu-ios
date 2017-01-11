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
#import "HEMStyle.h"

static NSString* const HEMEmbeddedVideoPlayerStatusKeyPath = @"status";
static NSString* const HEMEmbeddedVideoPlayerPlaybackKeepUpKeyPath = @"playbackLikelyToKeepUp";
static NSString* const HEMEmbeddedVideoPlayerBufferFullKeyPath = @"playbackBufferFull";
static CGFloat const HEMEmbeddedVideoGradientPercentage = 10.0f;

@interface HEMEmbeddedVideoView()

@property (nonatomic, weak) IBOutlet UIImageView* firstFrameView;

@property (nonatomic, copy) NSString* videoPath;
@property (nonatomic, strong) AVPlayer* player;
@property (nonatomic, strong) AVPlayerLayer* playerLayer;
@property (nonatomic, strong) AVPlayerItem* videoPlayerItem;
@property (nonatomic, weak) CAGradientLayer* topGradient;
@property (nonatomic, weak) CAGradientLayer* botGradient;
@property (nonatomic, assign, getter=isStoppedByCaller) BOOL stoppedByCaller;
@property (nonatomic, assign, getter=isSubscribedToPlaybackEvents) BOOL subscribedToPlaybackEvents;

@end

@implementation HEMEmbeddedVideoView

#pragma mark -

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
        [imageView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
        [self addSubview:imageView];
        [self setFirstFrameView:imageView];
    }
    
    [[self firstFrameView] setContentMode:UIViewContentModeScaleAspectFit];
    [[self firstFrameView] setImage:image];
    
    [self setVideoPath:videoPath];
}

- (void)setVideoPath:(NSString*)videoPath {
    if ([_videoPath isEqualToString:videoPath]) {
        return;
    }
    
    _videoPath = [videoPath copy];
    
    DDLogVerbose(@"setting video path to %@", videoPath);
    [self setReady:NO];
    
    if ([self player]) {
        [self unsubscribeToNotificationFor:[self player]];
        [self removeKVOObservers];
    }
    
    [self loadVideo:videoPath];
}

- (void)loadVideo:(NSString*)videoPath {
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURL* url = [NSURL URLWithString:videoPath];
        AVPlayer* player = [AVPlayer playerWithURL:url];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            AVPlayerItem* item = [player currentItem];
            [player setActionAtItemEnd:AVPlayerActionAtItemEndNone];
            [player addObserver:strongSelf forKeyPath:HEMEmbeddedVideoPlayerStatusKeyPath options:0 context:nil];
            [item addObserver:strongSelf forKeyPath:HEMEmbeddedVideoPlayerPlaybackKeepUpKeyPath options:0 context:nil];
            [item addObserver:strongSelf forKeyPath:HEMEmbeddedVideoPlayerBufferFullKeyPath options:0 context:nil];
            
            AVPlayerLayer* layer = [AVPlayerLayer playerLayerWithPlayer:player];
            [layer setBackgroundColor:[[UIColor clearColor] CGColor]];
            [layer setFrame:[self bounds]]; // required to have videoRect be properly defined after video is ready
            
            if ([strongSelf loop]) {
                [strongSelf subcribeToNotificationsFor:player];
            }

            [strongSelf setPlayer:player];
            [strongSelf setPlayerLayer:layer];
            [strongSelf setVideoPlayerItem:item];
        });
    });
}

- (void)playVideoWhenReady {
    BOOL videoBuffered = [[self videoPlayerItem] isPlaybackBufferFull] || [[self videoPlayerItem] isPlaybackLikelyToKeepUp];
    if ([self isReady]
        && [[self player] rate] == 0
        && [[self player] status] == AVPlayerStatusReadyToPlay
        && videoBuffered) {
        DDLogVerbose(@"playing video");
        if (![[self playerLayer] superlayer]) {
            [[self playerLayer] setFrame:[[self playerLayer] videoRect]];
            [[self layer] addSublayer:[self playerLayer]];
            [self addGradientsWhenReady];
        }
        [[self firstFrameView] removeFromSuperview];
        [[self player] play];
        [self setStoppedByCaller:NO];
    }
}

- (void)pause {
    if ([[self player] rate] > 0 && ![[self player] error]) {
        DDLogVerbose(@"pausing video");
        [[self player] pause];
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
        [self subcribeToNotificationsFor:[self player]];
    } else {
        [self unsubscribeToNotificationFor:[self player]];
    }
}

#pragma mark - Add Gradients

- (void)addGradientsWhenReady {
    // This is a workaround to issues encountered on plus devices, where videos
    // are displaying with black lines above and below the video.  It looks like
    // the videos created are not of the correct resolution in H.264 format
    // (height + width should be divisible by 16) and although changing the
    // AVPlayerLayer's frame can sometimes work, it does not work for all videos.
    CGFloat videoHeight = CGRectGetHeight([[self playerLayer] videoRect]);
    DDLogVerbose(@"video height is %f", videoHeight);
    if (videoHeight > 0.0f) {
        [[self topGradient] removeFromSuperlayer];
        [[self botGradient] removeFromSuperlayer];
        
        CGFloat gradientHeight = ceilCGFloat(videoHeight) / HEMEmbeddedVideoGradientPercentage;
        CGFloat fullWidth = CGRectGetWidth([self bounds]);
        CGFloat videoTopY = (CGRectGetHeight([self bounds]) - videoHeight) / 2.0f;
        CGRect gradientFrame = CGRectZero;
        gradientFrame.size.height = gradientHeight;
        gradientFrame.size.width = fullWidth;
        gradientFrame.origin.y = videoTopY;
        
        CAGradientLayer* layer = [CAGradientLayer layer];
        [layer setFrame:gradientFrame];
        [layer setColors:[[HEMGradient topVideoGradient] colorRefs]];
        [[self layer] addSublayer:layer];
        [self setTopGradient:layer];
        
        gradientFrame.origin.y = videoTopY + videoHeight - gradientHeight;
        layer = [CAGradientLayer layer];
        [layer setFrame:gradientFrame]; 
        [layer setColors:[[HEMGradient bottomVideoGradient] colorRefs]];
        [[self layer] addSublayer:layer];
        [self setBotGradient:layer];
    }
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
    if (object == [self player]) {
        if ([keyPath isEqualToString:HEMEmbeddedVideoPlayerStatusKeyPath]) {
            switch ([[self player] status]) {
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
    if ([self videoPlayerItem]) {
        [[self videoPlayerItem] removeObserver:self
                                    forKeyPath:HEMEmbeddedVideoPlayerPlaybackKeepUpKeyPath];
        [[self videoPlayerItem] removeObserver:self
                                    forKeyPath:HEMEmbeddedVideoPlayerBufferFullKeyPath];
    }
    
    if ([self player]) {
        [[self player] removeObserver:self
                           forKeyPath:HEMEmbeddedVideoPlayerStatusKeyPath];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self removeKVOObservers];
}

@end
