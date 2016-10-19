//
//  HEMVoiceSettingsViewController.m
//  Sense
//
//  Created by Jimmy Lu on 10/17/16.
//  Copyright © 2016 Hello. All rights reserved.
//
#import <SenseKit/SENPairedDevices.h>
#import <SenseKit/SENSenseMetadata.h>

#import "HEMVoiceSettingsViewController.h"
#import "HEMVoiceService.h"
#import "HEMDeviceService.h"
#import "HEMVoiceSettingsPresenter.h"
#import "HEMActivityIndicatorView.h"
#import "HEMAlertViewController.h"
#import "HEMVolumeControlViewController.h"
#import "HEMMainStoryboard.h"
#import "HEMSimpleModalTransitionDelegate.h"

@interface HEMVoiceSettingsViewController () <HEMPresenterErrorDelegate, HEMVoiceSettingsDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet HEMActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) id transitionDelegate;

@end

@implementation HEMVoiceSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configurePresenter];
}

- (void)configurePresenter {
    if (![self deviceService]) {
        [self setDeviceService:[HEMDeviceService new]];
    }
    
    if (![self voiceService]) {
        [self setVoiceService:[HEMVoiceService new]];
    }
    
    HEMVoiceSettingsPresenter* settingsPresenter
        = [[HEMVoiceSettingsPresenter alloc] initWithVoiceService:[self voiceService]
                                                    deviceService:[self deviceService]];
    
    [settingsPresenter bindWithTableView:[self tableView]];
    [settingsPresenter bindWithShadowView:[self shadowView]];
    [settingsPresenter bindWithNavigationItem:[self navigationItem]];
    [settingsPresenter bindWithActivityContainer:[[self rootViewController] view]];
    [settingsPresenter bindWithActivityIndicator:[self activityIndicator]];
    [settingsPresenter setErrorDelegate:self];
    [settingsPresenter setDelegate:self];
    
    [self addPresenter:settingsPresenter];
}

#pragma mark - HEMPresenterErrorDelegate

- (void)showErrorWithTitle:(NSString *)title
                andMessage:(NSString *)message
              withHelpPage:(NSString *)helpPage
             fromPresenter:(HEMPresenter *)presenter {
    [self showMessageDialog:message title:title];
}

- (void)showCustomerAlert:(HEMAlertViewController*)alertVC
            fromPresenter:(HEMPresenter *)presenter {
    [alertVC setViewToShowThrough:[self backgroundViewForAlerts]];
    [alertVC showFrom:self];
}

#pragma mark - HEMVoiceSettingsDelegate

- (void)showVolumeControlFromPresenter:(HEMVoiceSettingsPresenter *)presenter {
    [self performSegueWithIdentifier:[HEMMainStoryboard volumeSegueIdentifier] sender:self];
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    id destVC = [segue destinationViewController];
    if ([destVC isKindOfClass:[UINavigationController class]]) {
        UINavigationController* nav = destVC;
        destVC = [nav topViewController];
    }
    
    if ([destVC isKindOfClass:[HEMVolumeControlViewController class]]) {
        if (![self transitionDelegate]) {
            HEMSimpleModalTransitionDelegate* delegate = [HEMSimpleModalTransitionDelegate new];
            [delegate setWantsStatusBar:YES];
            [self setTransitionDelegate:delegate];
        }
        SENSenseMetadata* sense = [[[self deviceService] devices] senseMetadata];
        SENSenseVoiceInfo* voiceInfo = [sense voiceInfo];
        HEMVolumeControlViewController* volumeVC = destVC;
        [volumeVC setVoiceService:[self voiceService]];
        [volumeVC setVoiceInfo:voiceInfo];
        [volumeVC setSenseId:[sense uniqueId]];
        [volumeVC setTransitioningDelegate:[self transitionDelegate]];
        [volumeVC setModalPresentationStyle:UIModalPresentationCustom];
    }
}

@end
