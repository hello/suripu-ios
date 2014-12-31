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
#import <SenseKit/SENServiceDevice.h>

#import "UIFont+HEMStyle.h"

#import "HEMPillPairViewController.h"
#import "HEMBaseController+Protected.h"
#import "HEMActionButton.h"
#import "HEMOnboardingStoryboard.h"
#import "HEMOnboardingCache.h"
#import "HEMSettingsTableViewController.h"
#import "HEMOnboardingUtils.h"
#import "HEMActivityCoverView.h"
#import "HEMSupportUtil.h"
#import "HEMScrollableView.h"
#import "HelloStyleKit.h"

static CGFloat const kHEMPillPairStartDelay = 2.0f;

@interface HEMPillPairViewController()

@property (weak, nonatomic)   IBOutlet HEMScrollableView *contentView;
@property (weak, nonatomic)   IBOutlet HEMActionButton *retryButton;
@property (weak, nonatomic)   IBOutlet UIButton *helpButton;
@property (weak, nonatomic)   IBOutlet NSLayoutConstraint *retryButtonWidthConstraint;
@property (weak, nonatomic)   IBOutlet UIView *buttonContainer;

@property (strong, nonatomic) HEMActivityCoverView* activityView;
@property (weak,   nonatomic) UIBarButtonItem* cancelItem;
@property (assign, nonatomic) BOOL pairTimedOut;
@property (assign, nonatomic, getter=isLoaded) BOOL loaded;

@property (strong, nonatomic) id disconnectObserverId;

@end

@implementation HEMPillPairViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[self navigationItem] setHidesBackButton:YES];
    
    [self setupContent];
    [self setupCancelButton];
    
    [self updateActivityText:NSLocalizedString(@"pairing.activity.connecting-sense", nil)];
    [self showActivity];
    
    [HEMOnboardingUtils applyShadowToButtonContainer:[self buttonContainer]];
    
    [SENAnalytics track:kHEMAnalyticsEventOnBPairPill];
}

- (void)setupContent {
    NSString* subtitle = NSLocalizedString(@"pairing.pill.subtitle", nil);
    NSMutableAttributedString* attrSubtitle
        = [[NSMutableAttributedString alloc] initWithString:subtitle];
    [HEMOnboardingUtils applyCommonDescriptionAttributesTo:attrSubtitle];
    
    [[self contentView] addTitle:NSLocalizedString(@"pairing.pill.title", nil)];
    [[self contentView] addDescription:attrSubtitle];
    [[self contentView] addImage:[HelloStyleKit shakePill]];
    
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

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (![self isLoaded]) {
        [self performSelector:@selector(pairPill:)
                   withObject:self
                   afterDelay:kHEMPillPairStartDelay];
        [self setLoaded:YES];
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    CGFloat shadowOpacity = [[self contentView] scrollRequired]?1.0f:0.0f;
    [[[self buttonContainer] layer] setShadowOpacity:shadowOpacity];
}

- (void)updateActivityText:(NSString*)text {
    [[self helpButton] setTitle:text forState:UIControlStateDisabled];
}

- (void)showActivity {
    [[self helpButton] setEnabled:NO];
    
    if ([self cancelItem] == nil) {
        [[self navigationItem] setHidesBackButton:YES animated:YES];
    } else {
        [[self cancelItem] setEnabled:NO];
    }

    [[self retryButton] showActivityWithWidthConstraint:[self retryButtonWidthConstraint]];
}

- (void)hideActivity {
    [[self helpButton] setEnabled:YES];

    if ([self cancelItem] == nil) {
        [[self navigationItem] setHidesBackButton:NO animated:YES];
    } else {
        [[self cancelItem] setEnabled:YES];
    }
    
    [[self retryButton] stopActivity];
}

- (SENSenseManager*)manager {
    SENSenseManager* manager = [[SENServiceDevice sharedService] senseManager];
    return manager ? manager : [[HEMOnboardingCache sharedCache] senseManager];
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
        DDLogVerbose(@"sense not found, loading account info to scan existing paired sense");
        [self updateActivityText:NSLocalizedString(@"pairing.activity.loading-paired-sense", nil)];
        
        [[SENServiceDevice sharedService] loadDeviceInfo:^(NSError *error) {
            __block typeof(weakSelf) strongSelf = weakSelf;
            if (!strongSelf) return;
            
            if (error != nil) {

                NSString* msg = NSLocalizedString(@"pairing.error.fail-to-load-paired-info", nil);
                [strongSelf showError:error customMessage:msg];
                
                completion (nil);
                return;
            }
            
            DDLogVerbose(@"looking for sense to trigger pill pairing");
            [strongSelf updateActivityText:NSLocalizedString(@"pairing.activity.scanning-sense", nil)];
            
            [[SENServiceDevice sharedService] scanForPairedSense:^(NSError *error) {
                if (error != nil) {
                    
                    NSString* msg = NSLocalizedString(@"pairing.error.sense-not-found", nil);
                    [strongSelf showError:error customMessage:msg];
                    
                    completion (nil);
                    return;
                }
                
                completion ([[SENServiceDevice sharedService] senseManager]);
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
    
    [self updateActivityText:NSLocalizedString(@"pairing.activity.looking-for-pill", nil)];
    
    __weak typeof(self) weakSelf = self;
    [manager setLED:SENSenseLEDStateActivity completion:^(id response, NSError *error) {
        __block typeof(weakSelf) strongSelf = weakSelf;
        DDLogVerbose(@"attempting to pair pill through %@", [[[strongSelf manager] sense] name]);
        [[strongSelf manager] pairWithPill:[SENAuthorizationService accessToken] success:^(id response) {
            [strongSelf flashPairedState];
        } failure:^(NSError *error) {
            [[strongSelf manager] setLED:SENSenseLEDStateOff completion:^(id response, NSError *error) {
                [strongSelf showError:error customMessage:nil];
            }];
        }];
    }];
}

- (void)flashPairedState {
    if ([self activityView] == nil) {
        [self setActivityView:[[HEMActivityCoverView alloc] init]];
    }
    
    NSString* paired = NSLocalizedString(@"pairing.done", nil);
    [[self activityView] showInView:[[self navigationController] view] withText:paired activity:NO completion:^{
        [[self cancelItem] setEnabled:YES];
        
        __block BOOL ledSet = NO;
        __block BOOL activityDimissed = NO;
        __weak typeof(self) weakSelf = self;
        
        void(^finish)(void) = ^{
            if (ledSet && activityDimissed) {
                [weakSelf proceed];
            }
        };
        
        [[self activityView] dismissWithResultText:nil showSuccessMark:YES remove:YES completion:^{
            activityDimissed = YES;
            finish();
        }];
        
        [[self manager] setLED:SENSenseLEDStateSuccess completion:^(id response, NSError *error) {
            ledSet = YES;
            finish();
        }];
    }];
}

- (IBAction)help:(id)sender {
    [SENAnalytics track:kHEMAnalyticsEventHelp];
    [HEMSupportUtil openHelpFrom:self];
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

#pragma mark - Errors

- (void)showError:(NSError*)error customMessage:(NSString*)customMessage {
    [self hideActivity];
    
    NSString* message = customMessage;
    
    if (message == nil) {
        
        switch ([error code]) {
            case SENSenseManagerErrorCodeSenseAlreadyPaired:
                message = NSLocalizedString(@"pairing.error.pill-already-paired", nil);
                break;
            case SENSenseManagerErrorCodeTimeout:
            default:
                message = NSLocalizedString(@"pairing.error.pill-pairing-failed", nil);
                break;
        }
    }
    
    [self showMessageDialog:message
                      title:NSLocalizedString(@"pairing.pill.error.title", nil)
                      image:nil
                   withHelp:YES];
    
    if (error) {
        [SENAnalytics trackError:error withEventName:kHEMAnalyticsEventError];
    }
}

#pragma mark - Clean Up

- (void)dealloc {
    if (_disconnectObserverId != nil) {
        SENSenseManager* manager = [self manager];
        [manager removeUnexpectedDisconnectObserver:_disconnectObserverId];
        [self setDisconnectObserverId:nil];
    }
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

@end
