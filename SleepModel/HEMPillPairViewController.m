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
#import "HEMSettingsTableViewController.h"
#import "HEMOnboardingUtils.h"
#import "HelloStyleKit.h"
#import "HEMActivityCoverView.h"

@interface HEMPillPairViewController()

@property (weak, nonatomic)   IBOutlet UILabel *titleLabel;
@property (weak, nonatomic)   IBOutlet UILabel *subtitleLabel;
@property (weak, nonatomic)   IBOutlet UIImageView *pillDiagram;
@property (weak, nonatomic)   IBOutlet HEMActionButton *readyButton;
@property (weak, nonatomic)   IBOutlet UIButton *helpButton;
@property (strong, nonatomic) HEMActivityCoverView* activityView;


@property (strong, nonatomic) id disconnectObserverId;

@end

@implementation HEMPillPairViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupSubtitle];
}

- (void)setupSubtitle {
    NSString* shakeIt = [NSString stringWithFormat:@"%@ ",
                         NSLocalizedString(@"pill-pair.subtitle.shake-pill", nil)];
    NSString* green = NSLocalizedString(@"onboarding.green", nil);
    NSString* thenTap = [NSString stringWithFormat:@", %@",
                         NSLocalizedString(@"pill-pair.subtitle.tap-continue", nil)];
    
    NSMutableAttributedString* attrSubtitle
        = [[NSMutableAttributedString alloc] initWithString:shakeIt];
    [attrSubtitle appendAttributedString:[HEMOnboardingUtils boldAttributedText:green
                                                                  withColor:[HelloStyleKit green]]];
    [attrSubtitle appendAttributedString:[[NSAttributedString alloc] initWithString:thenTap]];
    
    [HEMOnboardingUtils applyCommonDescriptionAttributesTo:attrSubtitle];
    
    [[self subtitleLabel] setAttributedText:attrSubtitle];
}

- (void)listenForDisconnects {
    SENSenseManager* manager = [[HEMUserDataCache sharedUserDataCache] senseManager];
    if ([self disconnectObserverId] == nil) {
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
        [self listenForDisconnects];
        
        SENSenseManager* manager = [[HEMUserDataCache sharedUserDataCache] senseManager];
        NSString* token = [SENAuthorizationService accessToken];
        
        __weak typeof(self) weakSelf = self;
        [manager pairWithPill:token success:^(id response) {
            __block typeof(weakSelf) strongSelf = weakSelf;
            if (strongSelf) {
                NSString* paired = NSLocalizedString(@"pairing.done", nil);
                [[strongSelf activityView] dismissWithResultText:paired completion:^{
                    [strongSelf disconnectSenseAndClearCache];
                    
                    NSString* segueId = [HEMOnboardingStoryboard doneSegueIdentifier];
                    [strongSelf performSegueWithIdentifier:segueId sender:self];
                }];
            }
        } failure:^(NSError *error) {
            __block typeof(weakSelf) strongSelf = weakSelf;
            if (strongSelf) {
                [[strongSelf activityView] dismissWithResultText:nil completion:^{
                    [strongSelf showMessageDialog:NSLocalizedString(@"pairing.error.pill-pair-failed", nil)
                                            title:NSLocalizedString(@"pairing.failed.title", nil)];
                }];
            }
        }];
    }];
}

- (IBAction)help:(id)sender {
    DLog(@"WARNING: this has not been implemented yet!")
    // TODO (jimmy): the help website is still being discussed / worked on.  When
    // we know what to actually point to, we likely will open up a browser to
    // show the help
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
}

@end
