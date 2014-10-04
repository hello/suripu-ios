//
//  HEMSenseViewController.m
//  Sense
//
//  Created by Jimmy Lu on 9/24/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import <SenseKit/SENDevice.h>
#import <SenseKit/SENSenseManager.h>

#import "HEMSenseViewController.h"
#import "HEMMainStoryboard.h"
#import "HEMDeviceCenter.h"

static NSInteger kHEMSenseAlertTagPairModeConfirmation = 1;

@interface HEMSenseViewController() <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *senseInfoTableView;
@property (weak, nonatomic) IBOutlet UIView *manageSenseView;
@property (weak, nonatomic) IBOutlet UIView *actionStatusView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *actionStatusActivity;
@property (weak, nonatomic) IBOutlet UILabel *actionStatusLabel;

@property (copy, nonatomic) NSString* senseSignalStrength;

@end

@implementation HEMSenseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[self senseInfoTableView] setTableFooterView:[[UIView alloc] init]];
    
    [[self actionStatusLabel] setText:NSLocalizedString(@"settings.sense.scanning-message", nil)];
    [self showActivity];

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self loadSense];
}

- (void)loadSense {
    __weak typeof(self) weakSelf = self;
    DLog(@"scanning for sense");
    [[HEMDeviceCenter sharedCenter] scanForPairedSense:^(NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        DLog(@"finished scanning, error ? %@", error);
        if (strongSelf) {
            if (error != nil) {
                [strongSelf setSenseSignalStrength:NSLocalizedString(@"empty.data", nil)];
            } else {
                [strongSelf loadRSSI];
            }
            [strongSelf hideActivity];
        }
    }];
}

- (void)loadRSSI {
    __weak typeof(self) weakSelf = self;
    DLog(@"reading rssi value");
    [[HEMDeviceCenter sharedCenter] currentSenseRSSI:^(NSNumber *rssi, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) return;
        
        NSInteger value = [rssi integerValue];
        DLog(@"rssi value %ld", (long)value);
        NSString* strength = nil;
        if (value <= -30) {
            strength = NSLocalizedString(@"settings.sense.signal.strong", nil);
        } else if (value <= -50) {
            strength = NSLocalizedString(@"settings.sense.signal.good", nil);
        } else {
            strength = NSLocalizedString(@"settings.sense.signal.weak", nil);
        }
        [strongSelf setSenseSignalStrength:strength];
        [[strongSelf senseInfoTableView] reloadSections:[NSIndexSet indexSetWithIndex:0]
                                       withRowAnimation:UITableViewRowAnimationAutomatic];
    }];
}

#pragma mark - UITableViewDelegate / DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSInteger sections = 1; // the info
    if ([[[HEMDeviceCenter sharedCenter] senseInfo] state] == SENDeviceStateFirmwareUpdate) {
        sections++; // need to show firmware update cell / section
    }
    return sections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return section == 0 ? 3 : 1;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString* cellId
        = [indexPath section] == 0
        ? [HEMMainStoryboard senseInfoCellReuseIdentifier]
        : [HEMMainStoryboard firmwareUpdateCellReuseIdentifier];
    return [tableView dequeueReusableCellWithIdentifier:cellId];
}

- (void)tableView:(UITableView *)tableView
  willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([indexPath section] == 0) {
        NSString* title = nil;
        NSString* detail = NSLocalizedString(@"empty-data", nil); // TODO (jimmy): data not supported yet;
        
        switch ([indexPath row]) {
            case 0: {
                title = NSLocalizedString(@"settings.device.last-seen", nil);
                break;
            }
            case 1: {
                title = NSLocalizedString(@"settings.sense.signal", nil);
                if ([self senseSignalStrength] != nil) {
                    detail = [self senseSignalStrength];
                }
                break;
            }
            case 2: {
                title = NSLocalizedString(@"settings.device.firmware-version", nil);
                break;
            }
            default:
                break;
        }
        
        [[cell textLabel] setText:title];
        [[cell detailTextLabel] setText:detail];
        
    } // else, look at the storyboard
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Alerts

- (void)showFailureToEnablePairingModeAlert {
    NSString* title = NSLocalizedString(@"settings.sense.dialog.pair-failed-title", nil);
    NSString* message = NSLocalizedString(@"settings.sense.dialog.pair-failed-message", nil);
    UIAlertView* error = [[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:self
                                          cancelButtonTitle:NSLocalizedString(@"actions.ok", nil)
                                          otherButtonTitles:nil];
    [error show];
}

- (void)showPairingModeConfirmation {
    NSString* title = NSLocalizedString(@"settings.sense.dialog.enable-pair-mode-title", nil);
    NSString* message = NSLocalizedString(@"settings.sense.dialog.enable-pair-mode-message", nil);
    UIAlertView* confirmDialog = [[UIAlertView alloc] initWithTitle:title
                                                            message:message
                                                           delegate:self
                                                  cancelButtonTitle:NSLocalizedString(@"actions.no", nil)
                                                  otherButtonTitles:NSLocalizedString(@"actions.yes", nil), nil];
    [confirmDialog setTag:kHEMSenseAlertTagPairModeConfirmation];
    [confirmDialog setDelegate:self];
    [confirmDialog show];
}

- (void)showNoSenseWithMessage:(NSString*)message {
    NSString* title = NSLocalizedString(@"settings.sense.not-found-title", nil);
    UIAlertView* error = [[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:self
                                          cancelButtonTitle:NSLocalizedString(@"actions.ok", nil)
                                          otherButtonTitles:nil];
    [error show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex != [alertView cancelButtonIndex]) {
        if ([alertView tag] == kHEMSenseAlertTagPairModeConfirmation) {
            [self enablePairingMode];
        }
    }
}

#pragma mark - Actions

- (void)showActivity {
    [[self manageSenseView] setHidden:YES];
    [[self manageSenseView] setAlpha:0.0f];
    [[self actionStatusView] setAlpha:0.0f];
    [[self actionStatusView] setHidden:[[HEMDeviceCenter sharedCenter] senseInfo] == nil];
    
    if (![[self actionStatusView] isHidden]) {
        [UIView animateWithDuration:0.25f
                         animations:^{
                             [[self actionStatusView] setAlpha:1.0f];
                         }];
    }

}

- (void)hideActivity {
    [[self manageSenseView] setHidden:![[HEMDeviceCenter sharedCenter] pairedSenseAvailable]];
    
    if (![[self manageSenseView] isHidden]) {
        [UIView animateWithDuration:0.25f
                         animations:^{
                             [[self manageSenseView] setAlpha:1.0f];
                             [[self actionStatusView] setAlpha:0.0f];
                         }
                         completion:^(BOOL finished) {
                             [[self actionStatusView] setHidden:YES];
                         }];
    }
}

- (void)enablePairingMode {
    [[self actionStatusLabel] setText:NSLocalizedString(@"settings.sense.enabling-pairing-mode", nil)];
    [self showActivity];
    
    __weak typeof(self) weakSelf = self;
    HEMDeviceCenter* center = [HEMDeviceCenter sharedCenter];
    [center scanForPairedSense:^(NSError *error) {
        if (error != nil) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (!strongSelf) return;
            if ([error code] == HEMDeviceCenterErrorSenseUnavailable) {
                NSString* message = NSLocalizedString(@"settings.sense.unpair-no-sense-message", nil);
                [strongSelf showNoSenseWithMessage:message];
            } else {
                [strongSelf showFailureToEnablePairingModeAlert];
            }
            [strongSelf hideActivity];
        } else {
            [[HEMDeviceCenter sharedCenter] putSenseIntoPairingMode:^(NSError *error) {
                __strong typeof(weakSelf) strongSelf = weakSelf;
                if (strongSelf) {
                    if (error != nil) {
                        return [strongSelf showFailureToEnablePairingModeAlert];
                    }
                    // TODO (jimmy): what to actually show?
                    [strongSelf hideActivity];
                }
            }];
        }
    }];
}

- (IBAction)putSenseInPairingMode:(id)sender {
    [self showPairingModeConfirmation];
}

- (IBAction)restoreToFactoryDefaults:(id)sender {
    // TODO (jimmy): reset!
}

#pragma mark - Cleanup

- (void)dealloc {
    [[HEMDeviceCenter sharedCenter] stopScanning];
}

@end
