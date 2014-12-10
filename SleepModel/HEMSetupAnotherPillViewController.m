//
//  HEMSetupSecondPillViewController.m
//  Sense
//
//  Created by Jimmy Lu on 11/7/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import <SenseKit/SENSenseManager.h>

#import "NSMutableAttributedString+HEMFormat.h"

#import "UIFont+HEMStyle.h"

#import "HEMSetupAnotherPillViewController.h"
#import "HEMBaseController+Protected.h"
#import "HEMOnboardingUtils.h"
#import "HEMActionButton.h"
#import "HEMUserDataCache.h"
#import "HEMOnboardingStoryboard.h"

@interface HEMSetupAnotherPillViewController ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subtitleLabel;
@property (weak, nonatomic) IBOutlet HEMActionButton *setupButton;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *setupButtonWidthConstraint;

@end

@implementation HEMSetupAnotherPillViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[self titleLabel] setFont:[UIFont onboardingTitleFont]];
    [self setupSubtitle];
    [[self navigationItem] setHidesBackButton:YES];
}

- (void)setupSubtitle {
    NSString* format = NSLocalizedString(@"setup.second-pill.subtitle.format", nil);
    NSString* settings = NSLocalizedString(@"setup.second-pill.settings", nil);
    
    NSArray* args = @[
        [HEMOnboardingUtils boldAttributedText:settings withColor:[UIColor blackColor]]
    ];

    NSMutableAttributedString* attrSubtitle
        = [[NSMutableAttributedString alloc] initWithFormat:format args:args];
    
    [HEMOnboardingUtils applyCommonDescriptionAttributesTo:attrSubtitle];
    
    [[self subtitleLabel] setAttributedText:attrSubtitle];
}

- (IBAction)setupAnother:(UIButton *)sender {
    [[self setupButton] showActivityWithWidthConstraint:[self setupButtonWidthConstraint]];
    
    __weak typeof(self) weakSelf = self;
    
    SENSenseManager* manager = [[HEMUserDataCache sharedUserDataCache] senseManager];
    [manager enablePairingMode:YES success:^(id response) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            [manager disconnectFromSense]; // must disconnect to allow other app to connect
            [[strongSelf setupButton] stopActivity];
            [strongSelf getApp];
        }
    } failure:^(NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            [[strongSelf setupButton] stopActivity];
            [strongSelf showError:error];
        }
    }];
}

- (IBAction)skip:(id)sender {
    [[[HEMUserDataCache sharedUserDataCache] senseManager] disconnectFromSense];
    [self performSegueWithIdentifier:[HEMOnboardingStoryboard anotherPillToBeforeSleepSegueIdentifier] sender:self];
}

- (void)getApp {
    [[[HEMUserDataCache sharedUserDataCache] senseManager] disconnectFromSense];
    [self performSegueWithIdentifier:[HEMOnboardingStoryboard getAppSegueIdentifier]
                              sender:self];
}

#pragma mark - Errors

- (void)showError:(NSError*)error {
    NSString* title = NSLocalizedString(@"setup.second-pill.error.title", nil);
    NSString* msg = nil;
    
    switch ([error code]) {
        case SENSenseManagerErrorCodeSenseDbFull:
            msg = NSLocalizedString(@"setup.second-pill.error.sense-full", nil);
            break;
            
        default:
            msg = NSLocalizedString(@"setup.second-pill.error.failed-to-enable-pairing-mode", nil);
            break;
    }
    
    [self showMessageDialog:msg title:title];
}

@end
