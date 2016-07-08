//
//  HEMPillFinderPresenter.m
//  Sense
//
//  Created by Jimmy Lu on 7/5/16.
//  Copyright © 2016 Hello. All rights reserved.
//
#import <SenseKit/SENSleepPill.h>

#import "HEMPillFinderPresenter.h"
#import "HEMDeviceService.h"
#import "HEMActivityIndicatorView.h"
#import "HEMEmbeddedVideoView.h"
#import "HEMAnimationUtils.h"

static CGFloat const HEMPillFinderAnimeDuration = 0.5f;
static CGFloat const HEMPillFinderSuccessDuration = 1.0f;

@interface HEMPillFinderPresenter()

@property (nonatomic, weak) HEMDeviceService* deviceService;
@property (nonatomic, weak) UILabel* titleLabel;
@property (nonatomic, weak) UILabel* descriptionLabel;
@property (nonatomic, weak) UILabel* statusLabel;
@property (nonatomic, weak) HEMActivityIndicatorView* indicatorView;
@property (nonatomic, weak) HEMEmbeddedVideoView* videoView;
@property (nonatomic, weak) SENSleepPill* sleepPill;

@end

@implementation HEMPillFinderPresenter

- (instancetype)initWithDeviceService:(HEMDeviceService*)deviceService {
    self = [super init];
    if (self) {
        _deviceService = deviceService;
    }
    return self;
}

- (void)bindWithTitleLabel:(UILabel*)titleLabel descriptionLabel:(UILabel*)descriptionLabel {
    [self setTitleLabel:titleLabel];
    [self setDescriptionLabel:descriptionLabel];
}

- (void)bindWithStatusLabel:(UILabel*)statusLabel andIndicator:(HEMActivityIndicatorView*)indicatorView {
    [indicatorView start];
    [self setStatusLabel:statusLabel];
    [self setIndicatorView:indicatorView];
}

- (void)bindWithVideoView:(HEMEmbeddedVideoView*)videoView {
    UIImage* image = [UIImage imageNamed:@"pairing_your_sleep_pill"];
    NSString* videoPath = NSLocalizedString(@"video.url.onboarding.pill-pair", nil);
    [videoView setFirstFrame:image videoPath:videoPath];
    [self setVideoView:videoView];
}

- (void)findNearestPillIfNotFound {
    if (![[self deviceService] isScanningPill] && ![self sleepPill]) {
        __weak typeof(self) weakSelf = self;
        [[self deviceService] findNearestPill:^(SENSleepPill * _Nullable sleepPill, NSError * _Nullable error) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (sleepPill) {
                [strongSelf finishWithSleepPill:sleepPill];
            } else {
                NSString* errorTitle = NSLocalizedString(@"dfu.pill.error.title.pill-not-found", nil);
                NSString* errorMessage = NSLocalizedString(@"dfu.pill.error.pill-not-found", nil);
                NSString* helpSlug = NSLocalizedString(@"help.url.slug.pill-dfu-not-found", nil);
                [[strongSelf errorDelegate] showErrorWithTitle:errorTitle
                                                    andMessage:errorMessage
                                                  withHelpPage:helpSlug
                                                 fromPresenter:strongSelf];
            }
        }];
    }
}

- (void)finishWithSleepPill:(SENSleepPill*)sleepPill {
    [[self videoView] stop];
    [self setSleepPill:sleepPill];
    
    UIImageView* successView = [[UIImageView alloc] initWithFrame:[[self indicatorView] frame]];
    [successView setImage:[UIImage imageNamed:@"check"]];
    [successView setContentMode:UIViewContentModeScaleAspectFit];
    [successView setTransform:CGAffineTransformMakeScale(0.0f, 0.0f)];
    [[[self indicatorView] superview] addSubview:successView];
    
    NSString* foundText = NSLocalizedString(@"dfu.pill.connected", nil);
    
    [UIView animateWithDuration:HEMPillFinderAnimeDuration animations:^{
        [[self indicatorView] setAlpha:0.0f];
        [[self statusLabel] setText:foundText];
    } completion:^(BOOL finished) {
        [HEMAnimationUtils grow:successView completion:^(BOOL finished) {
            __weak typeof(self) weakSelf = self;
            int64_t delay = (int64_t) (HEMPillFinderSuccessDuration * NSEC_PER_SEC);
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delay), dispatch_get_main_queue(), ^{
                __strong typeof(weakSelf) strongSelf = weakSelf;
                [[strongSelf finderDelegate] didFindSleepPill:sleepPill from:strongSelf];
            });
        }];
    }];
    
}

#pragma mark - Presenter Events

- (void)didAppear {
    [super didAppear];
    [[self videoView] setReady:YES];
    [[self videoView] playVideoWhenReady];
    [self findNearestPillIfNotFound];
}

@end
