//
//  HEMVoiceSettingsViewController.m
//  Sense
//
//  Created by Jimmy Lu on 10/17/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "HEMVoiceSettingsViewController.h"
#import "HEMVoiceService.h"
#import "HEMDeviceService.h"
#import "HEMVoiceSettingsPresenter.h"

@interface HEMVoiceSettingsViewController () <HEMPresenterErrorDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

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
    [settingsPresenter setErrorDelegate:self];
    
    [self addPresenter:settingsPresenter];
}

#pragma mark - HEMPresenterErrorDelegate

- (void)showErrorWithTitle:(NSString *)title
                andMessage:(NSString *)message
              withHelpPage:(NSString *)helpPage
             fromPresenter:(HEMPresenter *)presenter {
    [self showMessageDialog:message title:title];
}

@end
