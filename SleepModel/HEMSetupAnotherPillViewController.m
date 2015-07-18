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
#import "UIColor+HEMStyle.h"
#import "HEMSetupAnotherPillViewController.h"
#import "HEMBaseController+Protected.h"
#import "HEMOnboardingService.h"
#import "HEMOnboardingStoryboard.h"

@interface HEMSetupAnotherPillViewController ()

@property (weak, nonatomic) IBOutlet UIButton *setupButton;

@end

@implementation HEMSetupAnotherPillViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureButtons];
    [self enableBackButton:NO];
    [self trackAnalyticsEvent:HEMAnalyticsEventAnotherPill];
}

- (void)configureButtons {
    [self showHelpButtonForPage:NSLocalizedString(@"help.url.slug.pill-setup-another", nil)
           andTrackWithStepName:kHEMAnalyticsEventPropPillAnother];
    [[[self setupButton] titleLabel] setFont:[UIFont secondaryButtonFont]];
    [[self setupButton] setTitleColor:[UIColor tintColor]
                             forState:UIControlStateNormal];
}

- (IBAction)setupAnother:(UIButton *)sender {
    __weak typeof(self) weakSelf = self;
    
    SENSenseManager* manager = [[HEMOnboardingService sharedService] currentSenseManager];
    [manager enablePairingMode:YES success:^(id response) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            [manager disconnectFromSense]; // must disconnect to allow other app to connect
            [strongSelf getApp];
        }
    } failure:^(NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            [strongSelf showError:error];
        }
    }];
}

- (IBAction)skip:(id)sender {
    [[HEMOnboardingService sharedService] disconnectCurrentSense];
    [self completeOnboarding];
}

- (void)getApp {
    [[HEMOnboardingService sharedService] disconnectCurrentSense];
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
