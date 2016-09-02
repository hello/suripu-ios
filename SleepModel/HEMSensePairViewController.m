//
//  HEMBluetoothViewController.m
//  Sense
//
//  Created by Jimmy Lu on 8/19/14.
//  Copyright (c) 2014 Hello Inc. All rights reserved.
//

#import "HEMSensePairViewController.h"
#import "HEMOnboardingStoryboard.h"
#import "HEMActionButton.h"
#import "HEMOnboardingService.h"
#import "HEMSupportUtil.h"
#import "HEMWifiPickerViewController.h"
#import "HEMAlertViewController.h"
#import "HEMDeviceService.h"

#import "HEMOnboardingPairSensePresenter.h"

@interface HEMSensePairViewController() <HEMPairSenseActionDelegate, HEMPresenterErrorDelegate>

@property (weak, nonatomic) IBOutlet HEMActionButton *readyButton;
@property (weak, nonatomic) IBOutlet UIButton *notGlowingButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *senseIconHeightConstraint;
@property (assign, nonatomic, getter=isSenseConnectedToWiFi) BOOL senseConnectedToWiFi;

@end

@implementation HEMSensePairViewController

- (void)viewDidLoad {
    [self configurePresenter];
    [super viewDidLoad];
    [self trackAnalyticsEvent:HEMAnalyticsEventPairSense];
}

- (void)configurePresenter {
    if (![self presenter]) {
        HEMOnboardingService* service = [HEMOnboardingService sharedService];
        HEMDeviceService* deviceService = [HEMDeviceService new];
        
        [self setPresenter:[[HEMOnboardingPairSensePresenter alloc] initWithOnboardingService:service
                                                                                deviceService:deviceService]];
        [self setDeviceService:deviceService];
    }
    
    [[self presenter] bindWithTitleLabel:[self titleLabel]
                        descriptionLabel:[self descriptionLabel]
                descriptionTopConstraint:[self descriptionTopConstraint]];
    [[self presenter] bindWithNavigationItem:[self navigationItem]];
    [[self presenter] bindWithIllustrationView:nil
                           andHeightConstraint:[self senseIconHeightConstraint]];
    [[self presenter] bindWithNextButton:[self readyButton]];
    [[self presenter] bindWithNotGlowingButton:[self notGlowingButton]];
    [[self presenter] bindWithActivityContainerView:[[self navigationController] view]];
    [[self presenter] setActionDelegate:self];
    [[self presenter] setErrorDelegate:self];
    
    [self addPresenter:[self presenter]];
}

#pragma mark - HEMSensePairingDelegate

- (void)didPairWithSenseWithCurrentSSID:(NSString *)ssid fromPresenter:(HEMPairSensePresenter *)presenter {
    [self setSenseConnectedToWiFi:ssid != nil];
    
    HEMOnboardingService* service = [HEMOnboardingService sharedService];
    SENSenseManager* manager = [service currentSenseManager];
    
    if (manager) {
        [service notifyOfSensePairingChange];
    }
    
    if (![self continueWithFlowBySkipping:NO]) {
        if ([self isSenseConnectedToWiFi]) {
            DDLogVerbose(@"sense is already connected to WiFi on %@, skipping WiFi flow", ssid);
            if ([self delegate]) {
                [[HEMOnboardingService sharedService] clearAll];
                [[self delegate] didPairSenseUsing:manager from:self];
            } else {
                NSString* segueId = [HEMOnboardingStoryboard sensePairToPillSegueIdentifier];
                [self performSegueWithIdentifier:segueId sender:self];
            }
        } else {
            NSString* segueId = segueId = [HEMOnboardingStoryboard wifiSegueIdentifier];
            [self performSegueWithIdentifier:segueId sender:self];
            
        }
    }
}

- (void)didCancelPairingFromPresenter:(HEMPairSensePresenter *)presenter {
    if ([self delegate]) {
        [[self delegate] didPairSenseUsing:nil from:self];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)showHelpWithPage:(NSString *)page
           fromPresenter:(HEMPairSensePresenter *)presenter {
    [HEMSupportUtil openHelpToPage:page fromController:self];
}

#pragma mark - HEMPresenterErrorDelegate

- (void)showErrorWithTitle:(NSString *)title
                andMessage:(NSString *)message
              withHelpPage:(NSString *)helpPage
             fromPresenter:(HEMPresenter *)presenter {
    if (helpPage) {
        [self showMessageDialog:message title:title image:nil withHelpPage:helpPage];
    } else {
        [self showMessageDialog:message title:title];
    }
}

- (void)showCustomerAlert:(HEMAlertViewController *)alert
            fromPresenter:(HEMPresenter *)presenter {
    [alert setViewToShowThrough:[self backgroundViewForAlerts]];
    [alert showFrom:self];
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [super prepareForSegue:segue sender:sender];
    
    UIViewController* destVC = segue.destinationViewController;
    if ([destVC isKindOfClass:[HEMWifiPickerViewController class]]) {
        HEMWifiPickerViewController* pickerVC = (HEMWifiPickerViewController*)destVC;
        [pickerVC setSensePairDelegate:[self delegate]]; // if one is set, pass it along
    }
}

@end
