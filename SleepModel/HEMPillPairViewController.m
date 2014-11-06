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
#import "HEMActivityCoverView.h"
#import "HEMDeviceCenter.h"

static CGFloat const kHEMPillPairedStateDuration = 2.0f;
static CGFloat const kHEMPillPairStartDelay = 2.0f;

@interface HEMPillPairViewController()

@property (weak, nonatomic)   IBOutlet UILabel *titleLabel;
@property (weak, nonatomic)   IBOutlet UILabel *subtitleLabel;
@property (weak, nonatomic)   IBOutlet UIImageView *pillDiagram;
@property (weak, nonatomic)   IBOutlet HEMActionButton *retryButton;
@property (weak, nonatomic)   IBOutlet UIButton *helpButton;
@property (weak, nonatomic)   IBOutlet NSLayoutConstraint *retryButtonWidthConstraint;

@property (strong, nonatomic) HEMActivityCoverView* activityView;
@property (weak,   nonatomic) UIBarButtonItem* cancelItem;
@property (assign, nonatomic) BOOL pairTimedOut;


@property (strong, nonatomic) id disconnectObserverId;

@end

@implementation HEMPillPairViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupSubtitle];
    [self setupCancelButton];
    
    [self updateActivityText:NSLocalizedString(@"pill-pair.connecting-sense", nil)];
    [self showActivity];
    
    [SENAnalytics track:kHEMAnalyticsEventOnBPairPill];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self performSelector:@selector(pairPill:)
               withObject:self
               afterDelay:kHEMPillPairStartDelay];
}

- (void)setupSubtitle {
    NSString* subtitleFormat = NSLocalizedString(@"pill-pair.subtitle.format", nil);
    NSString* blue = NSLocalizedString(@"onboarding.blue", nil);
    
    NSArray* args = @[
        [HEMOnboardingUtils boldAttributedText:blue withColor:[UIColor blueColor]]
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
        [self setCancelItem:cancelItem];
    }
}

- (void)updateActivityText:(NSString*)text {
    [[self helpButton] setTitle:text forState:UIControlStateDisabled];
}

- (void)showActivity {
    [[self cancelItem] setEnabled:NO];
    [[self helpButton] setEnabled:NO];
    [[self navigationItem] setHidesBackButton:YES animated:YES];
    [[self retryButton] showActivityWithWidthConstraint:[self retryButtonWidthConstraint]];
}

- (void)hideActivity {
    [[self cancelItem] setEnabled:YES];
    [[self helpButton] setEnabled:YES];
    [[self navigationItem] setHidesBackButton:NO animated:YES];
    [[self retryButton] stopActivity];
}

- (SENSenseManager*)manager {
    SENSenseManager* manager = [[HEMDeviceCenter sharedCenter] senseManager];
    return manager ? manager : [[HEMUserDataCache sharedUserDataCache] senseManager];
}

- (void)listenForDisconnects {
    SENSenseManager* manager = [self manager];
    if ([self disconnectObserverId] == nil && manager != nil) {
        __weak typeof(self) weakSelf = self;
        self.disconnectObserverId =
            [manager observeUnexpectedDisconnect:^(NSError *error) {
                __block typeof(weakSelf) strongSelf = weakSelf;
                if (strongSelf) {
                    NSString* msg = NSLocalizedString(@"pairing.error.unexpected-disconnect", nil);
                    [strongSelf showError:error customMessage:msg];
                }
            }];
    }
}

- (void)ensureSenseIsReady:(void(^)(SENSenseManager* manager))completion {
    if (!completion) return;
    
    SENSenseManager* manager = [self manager];
    if (manager != nil) {
        completion (manager);
    } else {
        __weak typeof(self) weakSelf = self;
        [[HEMDeviceCenter sharedCenter] loadDeviceInfo:^(NSError *error) {
            __block typeof(weakSelf) strongSelf = weakSelf;
            if (!strongSelf) return;
            
            if (error != nil) {

                NSString* msg = NSLocalizedString(@"pill-pair.error.device-info-unknown", nil);
                [strongSelf showError:error customMessage:msg];
                
                completion (nil);
                return;
            }
            
            DDLogVerbose(@"looking for sense to trigger pill pairing");
            [strongSelf updateActivityText:NSLocalizedString(@"pill-pair.connecting-sense", nil)];
            
            [[HEMDeviceCenter sharedCenter] scanForPairedSense:^(NSError *error) {
                if (error != nil) {
                    
                    NSString* msg = NSLocalizedString(@"pill-pair.error.sense-not-found", nil);
                    [strongSelf showError:error customMessage:msg];
                    
                    completion (nil);
                    return;
                }
                
                completion ([[HEMDeviceCenter sharedCenter] senseManager]);
            }];
        }];
    }
}

- (IBAction)pairPill:(id)sender {
    [self showActivity];
    
    __weak typeof(self) weakSelf = self;
    [self ensureSenseIsReady:^(SENSenseManager *manager) {
        __block typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf || manager == nil) return;
        [strongSelf pairNowWith:manager];
    }];
}

- (void)pairNowWith:(SENSenseManager*)manager {
    [self listenForDisconnects];
    
    [self updateActivityText:NSLocalizedString(@"pill-pair.pairing-message", nil)];
    
    NSString* token = [SENAuthorizationService accessToken];
    
    __weak typeof(self) weakSelf = self;
    DDLogVerbose(@"attempting to pair pill through %@", [[manager sense] name]);
    [manager pairWithPill:token success:^(id response) {
        __block typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            [strongSelf flashPairedState];
        }
    } failure:^(NSError *error) {
        __block typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            [strongSelf showError:error customMessage:nil];
        }
    }];
}

- (void)flashPairedState {
    if ([self activityView] == nil) {
        [self setActivityView:[[HEMActivityCoverView alloc] init]];
        
        NSString* paired = NSLocalizedString(@"pairing.done", nil);
        [[[self activityView] activityLabel] setText:paired];
    }
    
    [[self activityView] showInView:[[self navigationController] view] activity:NO completion:^{
        [[self cancelItem] setEnabled:YES];
        
        [self performSelector:@selector(dismissPairedState)
                   withObject:nil
                   afterDelay:kHEMPillPairedStateDuration];
    }];
}

- (void)dismissPairedState {
    [[self activityView] dismissWithResultText:nil completion:^{
        [self proceed];
    }];
}

- (IBAction)help:(id)sender {
    DDLogVerbose(@"WARNING: this has not been implemented yet!");
    // TODO (jimmy): the help website is still being discussed / worked on.  When
    // we know what to actually point to, we likely will open up a browser to
    // show the help
    [SENAnalytics track:kHEMAnalyticsEventHelp];
}

- (IBAction)cancel:(id)sender {
    [[self delegate] didCancelPairing:self];
}

- (void)proceed {
    if ([self delegate] == nil) {
        [self disconnectSenseAndClearCache];
        
        [HEMOnboardingUtils saveOnboardingCheckpoint:HEMOnboardingCheckpointPillDone];
        
        NSString* segueId = [HEMOnboardingStoryboard doneSegueIdentifier];
        [self performSegueWithIdentifier:segueId sender:self];
    } else {
        [[self delegate] didPairWithPillFrom:self];
    }
}

#pragma mark - Errors

- (void)showError:(NSError*)error customMessage:(NSString*)customMessage {
    [self hideActivity];
    
    NSString* message = customMessage;
    
    if (message == nil) {
        
        switch ([error code]) {
            case SENSenseManagerErrorCodeSenseAlreadyPaired:
                message = NSLocalizedString(@"pill-pair.error.already-paired", nil);
                break;
            case SENSenseManagerErrorCodeTimeout:
                message = NSLocalizedString(@"pill-pair.error.timed-out", nil);
                break;
            default:
                message = NSLocalizedString(@"pill-pair.error.pill-pair-failed", nil);
                break;
        }
    }
    
    [self showMessageDialog:message title:NSLocalizedString(@"pairing.failed.title", nil)];
    
    if (error) {
        [SENAnalytics trackError:error withEventName:kHEMAnalyticsEventError];
    }
}

#pragma mark - Clean Up

- (void)disconnectSenseAndClearCache {
    SENSenseManager* manager = [self manager];
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
