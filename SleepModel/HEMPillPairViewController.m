//
//  HEMPillPairViewController.m
//  Sense
//
//  Created by Jimmy Lu on 9/2/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//
#import <SenseKit/SENSenseManager.h>
#import <SenseKit/SENAuthorizationService.h>

#import "HEMPillPairViewController.h"
#import "HEMBaseController+Protected.h"
#import "HEMActionButton.h"
#import "HEMOnboardingStoryboard.h"
#import "HEMUserDataCache.h"

@interface HEMPillPairViewController()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subtitleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *pillImageView;
@property (weak, nonatomic) IBOutlet HEMActionButton *readyButton;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *pillImageVSpaceConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *readyButtonVSpaceConstraint;

@property (strong, nonatomic) id disconnectObserverId;

@end

@implementation HEMPillPairViewController

- (void)adjustConstraintsForIPhone4 {
    CGFloat diff = -40.0f;
    [self updateConstraint:[self pillImageVSpaceConstraint] withDiff:diff];
    [self updateConstraint:[self readyButtonVSpaceConstraint] withDiff:diff];
}

- (void)listenForDisconnects {
    SENSenseManager* manager = [[HEMUserDataCache sharedUserDataCache] senseManager];
    if ([self disconnectObserverId] == nil) {
        __weak typeof(self) weakSelf = self;
        self.disconnectObserverId =
            [manager observeUnexpectedDisconnect:^(NSError *error) {
                __block typeof(weakSelf) strongSelf = weakSelf;
                if (strongSelf && [[strongSelf readyButton] isShowingActivity]) {
                    [[strongSelf readyButton] stopActivity];
                    [strongSelf showMessageDialog:NSLocalizedString(@"pairing.error.unexpected-disconnect", nil)
                                            title:NSLocalizedString(@"pairing.failed.title", nil)];
                }
            }];
    }
}

- (IBAction)pairPill:(id)sender {
    SENSenseManager* manager = [[HEMUserDataCache sharedUserDataCache] senseManager];
    NSString* token = [SENAuthorizationService accessToken];
    
    [[self readyButton] showActivity];
    __weak typeof(self) weakSelf = self;
    [manager pairWithPill:token success:^(id response) {
        __block typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            [[strongSelf readyButton] stopActivity];
            [strongSelf disconnectSenseAndClearCache];
            [strongSelf next];
        }
    } failure:^(NSError *error) {
        __block typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf && [[strongSelf readyButton] isShowingActivity]) {
            [[strongSelf readyButton] stopActivity];
            [strongSelf showMessageDialog:NSLocalizedString(@"pairing.error.pill-pair-failed", nil)
                                    title:NSLocalizedString(@"pairing.failed.title", nil)];
        }
    }];
}

- (void)next {
    // prevent user from going back to this screen
    UIViewController* dataIntroVC = [HEMOnboardingStoryboard instantiateDataIntroViewController];
    [[self navigationController] setViewControllers:@[dataIntroVC] animated:YES];
}

- (void)disconnectSenseAndClearCache {
    SENSenseManager* manager = [[HEMUserDataCache sharedUserDataCache] senseManager];
    [manager disconnectFromSense];
    if ([self disconnectObserverId] != nil) {
        [manager removeUnexpectedDisconnectObserver:[self disconnectObserverId]];
        [self setDisconnectObserverId:nil];
    }
    [[HEMUserDataCache sharedUserDataCache] setSenseManager:nil];
}

#pragma mark - Clean Up

- (void)dealloc {
    [self disconnectSenseAndClearCache];
}

@end
