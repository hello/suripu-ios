//
//  HEMPillPairViewController.m
//  Sense
//
//  Created by Jimmy Lu on 9/2/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//
#import <SenseKit/SENSenseManager.h>
#import <SenseKit/SENSense.h>
#import <SenseKit/SENAuthorizationService.h>

#import "NSMutableAttributedString+HEMFormat.h"

#import "HEMPillPairViewController.h"
#import "HEMBaseController+Protected.h"
#import "HEMActionButton.h"
#import "HEMOnboardingStoryboard.h"
#import "HEMUserDataCache.h"
#import "HEMSettingsTableViewController.h"
#import "HEMOnboardingUtils.h"
#import "HelloStyleKit.h"
#import "HEMActivityCoverView.h"
#import "HEMDeviceCenter.h"

static CGFloat const kHEMPillPairTimeout = 60.0f; // accommodate case when scanning is needed

@interface HEMPillPairViewController()

@property (weak, nonatomic)   IBOutlet UILabel *titleLabel;
@property (weak, nonatomic)   IBOutlet UILabel *subtitleLabel;
@property (weak, nonatomic)   IBOutlet UIImageView *pillDiagram;
@property (weak, nonatomic)   IBOutlet HEMActionButton *readyButton;
@property (weak, nonatomic)   IBOutlet UIButton *helpButton;
@property (strong, nonatomic) HEMActivityCoverView* activityView;

@property (assign, nonatomic) BOOL pairTimedOut;


@property (strong, nonatomic) id disconnectObserverId;

@end

@implementation HEMPillPairViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupSubtitle];
    [self setupCancelButton];
    [SENAnalytics track:kHEMAnalyticsEventOnBPairPill];
}

- (void)setupSubtitle {
    NSString* subtitleFormat = NSLocalizedString(@"pill-pair.subtitle.format", nil);
    NSString* green = NSLocalizedString(@"onboarding.green", nil);
    
    NSArray* args = @[
        [HEMOnboardingUtils boldAttributedText:green withColor:[HelloStyleKit green]]
    ];
    
    NSMutableAttributedString* attrSubtitle
        = [[NSMutableAttributedString alloc] initWithFormat:subtitleFormat args:args];

    [HEMOnboardingUtils applyCommonDescriptionAttributesTo:attrSubtitle];
    
    [[self subtitleLabel] setAttributedText:attrSubtitle];
}

- (void)setupCancelButton {
    if ([self delegate] != nil) {
        NSString* title = NSLocalizedString(@"actions.cancel", nil);
        UIBarButtonItem* cancelItem = [[UIBarButtonItem alloc] initWithTitle:title
                                                                       style:UIBarButtonItemStyleBordered
                                                                      target:self
                                                                      action:@selector(cancel:)];
        [[self navigationItem] setLeftBarButtonItem:cancelItem];
    }
}

- (void)listenForDisconnects {
    SENSenseManager* manager = [[HEMUserDataCache sharedUserDataCache] senseManager];
    if ([self disconnectObserverId] == nil && manager != nil) {
        __weak typeof(self) weakSelf = self;
        self.disconnectObserverId =
            [manager observeUnexpectedDisconnect:^(NSError *error) {
                __block typeof(weakSelf) strongSelf = weakSelf;
                if (strongSelf) {
                    [[strongSelf activityView] dismissWithResultText:nil completion:^{
                        [strongSelf showMessageDialog:NSLocalizedString(@"pairing.error.unexpected-disconnect", nil)
                                                title:NSLocalizedString(@"pairing.failed.title", nil)];
                    }];
                }
                
                [SENAnalytics trackError:error withEventName:kHEMAnalyticsEventError];
            }];
    }
}

- (void)pairingTimedOut {
    [self setPairTimedOut:YES];
    [[self activityView] dismissWithResultText:nil completion:^{
        [self showMessageDialog:NSLocalizedString(@"pill-pair.error.timed-out", nil)
                          title:NSLocalizedString(@"pairing.failed.title", nil)];
    }];
    
    [SENAnalytics track:kHEMAnalyticsEventError
             properties:@{kHEMAnalyticsEventPropMessage : @"pairing timed out"}];
}

- (void)ensureSenseIsReady:(void(^)(SENSenseManager* manager))completion {
    if (!completion) return;
    
    SENSenseManager* manager = [[HEMUserDataCache sharedUserDataCache] senseManager];
    if (manager != nil) {
        completion (manager);
    } else {
        __weak typeof(self) weakSelf = self;
        [[HEMDeviceCenter sharedCenter] loadDeviceInfo:^(NSError *error) {
            __block typeof(weakSelf) strongSelf = weakSelf;
            if (!strongSelf) return;
            
            if (error != nil) {
                [[strongSelf activityView] dismissWithResultText:nil completion:^{
                    [strongSelf showMessageDialog:NSLocalizedString(@"pill-pair.error.device-info-unknown", nil)
                                            title:NSLocalizedString(@"pairing.failed.title", nil)];
                }];
                completion (nil);
                return;
            }
            
            DDLogVerbose(@"looking for sense to trigger pill pairing");
            [[HEMDeviceCenter sharedCenter] scanForPairedSense:^(NSError *error) {
                if (error != nil) {
                    [[strongSelf activityView] dismissWithResultText:nil completion:^{
                        [strongSelf showMessageDialog:NSLocalizedString(@"pill-pair.error.sense-not-found", nil)
                                                title:NSLocalizedString(@"pairing.failed.title", nil)];
                    }];
                    [SENAnalytics trackError:error withEventName:kHEMAnalyticsEventError];
                    completion (nil);
                    return;
                }
                
                if (completion) completion ([[HEMDeviceCenter sharedCenter] senseManager]);
            }];
        }];
    }
}

- (IBAction)pairPill:(id)sender {
    if ([self activityView] == nil) {
        [self setActivityView:[[HEMActivityCoverView alloc] init]];
    }
    
    NSString* pairing = NSLocalizedString(@"pill-pair.pairing-message", nil);
    [[[self activityView] activityLabel] setText:pairing];
    
    [[self activityView] showInView:[[self navigationController] view] completion:^{
        [self setPairTimedOut:NO];
        [self performSelector:@selector(pairingTimedOut)
                   withObject:nil
                   afterDelay:kHEMPillPairTimeout];
        
        __weak typeof(self) weakSelf = self;
        
        [self ensureSenseIsReady:^(SENSenseManager *manager) {
            __block typeof(weakSelf) strongSelf = weakSelf;
            if (!strongSelf || manager == nil) return;
            [strongSelf pairNowWith:manager];
        }];
    }];
}

- (void)pairNowWith:(SENSenseManager*)manager {
    [self listenForDisconnects];
    
    NSString* token = [SENAuthorizationService accessToken];
    
    __weak typeof(self) weakSelf = self;
    DDLogVerbose(@"attempting to pair pill through %@", [[manager sense] name]);
    [manager pairWithPill:token success:^(id response) {
        __block typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf && ![strongSelf pairTimedOut]) {
            [NSObject cancelPreviousPerformRequestsWithTarget:strongSelf
                                                     selector:@selector(pairingTimedOut)
                                                       object:nil];
            NSString* paired = NSLocalizedString(@"pairing.done", nil);
            [[strongSelf activityView] dismissWithResultText:paired completion:^{
                [strongSelf disconnectSenseAndClearCache];
                [strongSelf proceed];
            }];
        }
    } failure:^(NSError *error) {
        __block typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf && ![strongSelf pairTimedOut]) {
            [NSObject cancelPreviousPerformRequestsWithTarget:strongSelf
                                                     selector:@selector(pairingTimedOut)
                                                       object:nil];
            [[strongSelf activityView] dismissWithResultText:nil completion:^{
                [strongSelf showMessageDialog:NSLocalizedString(@"pill-pair.error.pill-pair-failed", nil)
                                        title:NSLocalizedString(@"pairing.failed.title", nil)];
            }];
        }
        
        [SENAnalytics trackError:error withEventName:kHEMAnalyticsEventError];
    }];
}

- (IBAction)help:(id)sender {
    DDLogVerbose(@"WARNING: this has not been implemented yet!");
    // TODO (jimmy): the help website is still being discussed / worked on.  When
    // we know what to actually point to, we likely will open up a browser to
    // show the help
    [SENAnalytics track:kHEMAnalyticsEventHelp];
    
#pragma message ("remove when we have devices!")
    
    if ([self delegate] == nil) {
        [self proceed];
    }
    
}

- (IBAction)cancel:(id)sender {
    [[self delegate] didCancelPairing:self];
}

- (void)proceed {
    if ([self delegate] == nil) {
        [HEMOnboardingUtils saveOnboardingCheckpoint:HEMOnboardingCheckpointPillDone];
        
        NSString* segueId = [HEMOnboardingStoryboard doneSegueIdentifier];
        [self performSegueWithIdentifier:segueId sender:self];
    } else {
        [[self delegate] didPairWithPillFrom:self];
    }
}

#pragma mark - Clean Up

- (void)disconnectSenseAndClearCache {
    SENSenseManager* manager = [[HEMUserDataCache sharedUserDataCache] senseManager];
    [manager disconnectFromSense];
    if ([self disconnectObserverId] != nil) {
        [manager removeUnexpectedDisconnectObserver:[self disconnectObserverId]];
        [self setDisconnectObserverId:nil];
    }
    [[HEMUserDataCache sharedUserDataCache] setSenseManager:nil];
}

- (void)dealloc {
    [self disconnectSenseAndClearCache];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

@end
