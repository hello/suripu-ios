//
//  HEMSenseViewController.m
//  Sense
//
//  Created by Jimmy Lu on 9/24/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//
#import <SORelativeDateTransformer/SORelativeDateTransformer.h>

#import <SenseKit/SENDevice.h>
#import <SenseKit/SENSenseManager.h>

#import "UIFont+HEMStyle.h"

#import "HEMSenseViewController.h"
#import "HEMMainStoryboard.h"
#import "HEMDeviceCenter.h"
#import "HEMBaseController+Protected.h"
#import "HEMAlertController.h"
#import "HelloStyleKit.h"
#import "HEMWiFiConfigurationDelegate.h"
#import "HEMWifiPickerViewController.h"
#import "HEMOnboardingStoryboard.h"

static NSInteger const kHEMSenseRowLastSeen = 0;
static NSInteger const kHEMSenseRowVersion = 1;
static NSInteger const kHEMSenseRowSignal = 2;
static NSInteger const kHEMSenseRowWiFi = 3;

@interface HEMSenseViewController() <UITableViewDataSource, UITableViewDelegate, HEMWiFiConfigurationDelegate>

@property (weak, nonatomic) IBOutlet UITableView *senseInfoTableView;
@property (weak, nonatomic) IBOutlet UIView *manageSenseView;
@property (weak, nonatomic) IBOutlet UIView *actionStatusView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *actionStatusActivity;
@property (weak, nonatomic) IBOutlet UILabel *actionStatusLabel;

@property (assign, nonatomic, getter=isLoaded) BOOL loaded;
@property (copy, nonatomic)   NSString* senseSignalStrength;
@property (copy, nonatomic)   NSString* wifiSSID;
@property (strong, nonatomic) HEMAlertController* alertController;

@end

@implementation HEMSenseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[self senseInfoTableView] setTableFooterView:[[UIView alloc] init]];
    
    [[self actionStatusLabel] setText:NSLocalizedString(@"settings.sense.scanning-message", nil)];
    [[self actionStatusLabel] setTintColor:[HelloStyleKit backViewTextColor]];
    [self showActivity];

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self loadSense];
}

- (void)loadSense {
    if ([self isLoaded]) return;
    
    __weak typeof(self) weakSelf = self;
    DDLogVerbose(@"scanning for sense");
    [[HEMDeviceCenter sharedCenter] scanForPairedSense:^(NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        DDLogVerbose(@"finished scanning, error ? %@", error);
        if (strongSelf) {
            if (error != nil) {
                [strongSelf setSenseSignalStrength:NSLocalizedString(@"empty.data", nil)];
                [SENAnalytics trackError:error withEventName:kHEMAnalyticsEventError];
                [strongSelf hideActivity];
            } else {
                // MUST do 1 BLE operation at a time or else top board will crash, or
                // do unexpected things
                [strongSelf loadRSSIThen:^{
                    [[strongSelf actionStatusLabel] setText:NSLocalizedString(@"settings.sense.getting-wifi-configured", nil)];
                    [strongSelf loadWifiThen:^{
                        [strongSelf hideActivity];
                    }];
                }];
            }
            
            [strongSelf setLoaded:YES];
        }
    }];
}

- (void)loadRSSIThen:(void(^)(void))completion {
    __weak typeof(self) weakSelf = self;
    DDLogVerbose(@"reading rssi value");
    [[HEMDeviceCenter sharedCenter] currentSenseRSSI:^(NSNumber *rssi, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) return;
        
        NSInteger value = [rssi integerValue];
        DDLogVerbose(@"rssi value %ld", (long)value);
        NSString* strength = nil;
        if (value <= -30) {
            strength = NSLocalizedString(@"settings.sense.signal.strong", nil);
        } else if (value <= -50) {
            strength = NSLocalizedString(@"settings.sense.signal.good", nil);
        } else {
            strength = NSLocalizedString(@"settings.sense.signal.weak", nil);
        }
        [strongSelf setSenseSignalStrength:strength];
        [strongSelf reloadRow:kHEMSenseRowSignal];
        
        if (completion) completion();
    }];
}

- (void)loadWifiThen:(void(^)(void))completion {
    __weak typeof(self) weakSelf = self;
    DDLogVerbose(@"getting Sense wifi ssid");
    [[HEMDeviceCenter sharedCenter] getConfiguredWiFi:^(NSString *ssid,
                                                        SENWiFiConnectionState state,
                                                        NSError *error) {
        
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) return;
        
        if (error == nil) {
            [strongSelf setWifiSSID:ssid];
            [strongSelf reloadRow:kHEMSenseRowWiFi];
        } else {
            DDLogVerbose(@"failed to retrieve ssid configured with Sense");
            [SENAnalytics trackError:error withEventName:kHEMAnalyticsEventError];
        }
        
        if (completion) completion ();
    }];
}

- (void)reloadRow:(NSInteger)row {
    NSIndexPath* path = [NSIndexPath indexPathForItem:row inSection:0];
    [[self senseInfoTableView] reloadRowsAtIndexPaths:@[path]
                                     withRowAnimation:UITableViewRowAnimationAutomatic];
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
    return section == 0 ? 4 : 1;
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
        SENDevice* info = [[HEMDeviceCenter sharedCenter] senseInfo];
        NSString* title = nil;
        NSMutableAttributedString* detail = nil;
        UITableViewCellSelectionStyle selection = UITableViewCellSelectionStyleNone;
        
        switch ([indexPath row]) {
            case kHEMSenseRowLastSeen: {
                title = NSLocalizedString(@"settings.device.last-seen", nil);
                if ([info lastSeen] != nil) {
                    NSValueTransformer* transformer = [SORelativeDateTransformer registeredTransformer];
                    detail = [[NSMutableAttributedString alloc] initWithString:[transformer transformedValue:[info lastSeen]]];
                }
                break;
            }
            case kHEMSenseRowVersion: {
                title = NSLocalizedString(@"settings.device.firmware-version", nil);
                if ([[info firmwareVersion] length] > 0) {
                    detail = [[NSMutableAttributedString alloc] initWithString:[info firmwareVersion]];
                }
                break;
            }
            case kHEMSenseRowSignal: {
                title = NSLocalizedString(@"settings.sense.signal", nil);
                if ([self senseSignalStrength] != nil) {
                    detail = [[NSMutableAttributedString alloc] initWithString:[self senseSignalStrength]];
                }
                break;
            }
            case kHEMSenseRowWiFi: {
                title = NSLocalizedString(@"settings.sense.wifi", nil);
                if ([[self wifiSSID] length] > 0) {
                    detail = [[NSMutableAttributedString alloc] initWithString:[self wifiSSID]
                                                                    attributes:@{NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle)}];
                    selection = UITableViewCellSelectionStyleDefault;
                }
                break;
            }
            default:
                break;
        }
        
        [[cell textLabel] setText:title];
        [[cell textLabel] setTextColor:[HelloStyleKit backViewTextColor]];
        [[cell textLabel] setFont:[UIFont settingsTitleFont]];
        
        if (detail == nil) {
            detail = [[NSMutableAttributedString alloc] initWithString:NSLocalizedString(@"empty-data", nil)];
        }
        [detail addAttributes:@{NSFontAttributeName : [UIFont settingsTableCellDetailFont],
                                NSForegroundColorAttributeName : [HelloStyleKit backViewDetailTextColor]}
                        range:NSMakeRange(0, [detail length])];
        [[cell detailTextLabel] setAttributedText:detail];
        
        [cell setSelectionStyle:selection];
        
    } // else, look at the storyboard
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch ([indexPath row]) {
        case kHEMSenseRowWiFi:
            if ([[HEMDeviceCenter sharedCenter] pairedSenseAvailable]) {
                [self configureWiFi];
            }
            break;
        default:
            break;
    }
}

#pragma mark - Alerts

- (void)showFailureToEnablePairingModeAlert {
    NSString* title = NSLocalizedString(@"settings.sense.dialog.pair-failed-title", nil);
    NSString* message = NSLocalizedString(@"settings.sense.dialog.pair-failed-message", nil);
    [self showMessageDialog:message title:title];
}

- (void)showConfirmation:(NSString*)title message:(NSString*)message action:(void(^)(void))action {
    HEMAlertController* alert = [[HEMAlertController alloc] initWithTitle:title
                                                                  message:message
                                                                    style:HEMAlertControllerStyleAlert
                                                     presentingController:self];
    
    [alert addActionWithText:NSLocalizedString(@"actions.no", nil) block:nil];
    [alert addActionWithText:NSLocalizedString(@"actions.yes", nil) block:action];
    
    [self setAlertController:alert];
    [[self alertController] show];
}

- (void)showPairingModeConfirmation {
    NSString* title = NSLocalizedString(@"settings.sense.dialog.enable-pair-mode-title", nil);
    NSString* message = NSLocalizedString(@"settings.sense.dialog.enable-pair-mode-message", nil);
    
    __weak typeof(self) weakSelf = self;
    [self showConfirmation:title message:message action:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            [strongSelf enablePairingMode];
        }
    }];
}

- (void)showFactoryRestoreConfirmation {
    NSString* title = NSLocalizedString(@"settings.device.dialog.factory-restore-title", nil);
    NSString* message = NSLocalizedString(@"settings.device.dialog.factory-restore-message", nil);

    __weak typeof(self) weakSelf = self;
    [self showConfirmation:title message:message action:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            [strongSelf restore];
        }
    }];
}

- (void)showFactoryRestoreErrorMessage:(NSError*)error {
    NSString* title = NSLocalizedString(@"settings.factory-restore.error.title", nil);
    NSString* message = nil;
    
    switch ([error code]) {
        case HEMDeviceCenterErrorUnlinkPillFromAccount:
            message = NSLocalizedString(@"settings.factory-restore.error.unlink-pill", nil);
            break;
        case HEMDeviceCenterErrorUnlinkSenseFromAccount:
            message = NSLocalizedString(@"settings.factory-restore.error.unlink-sense", nil);
            break;
        case HEMDeviceCenterErrorInProgress:
        case HEMDeviceCenterErrorSenseUnavailable: {
            title = NSLocalizedString(@"settings.sense.not-found-title", nil);
            message = NSLocalizedString(@"settings.sense.no-sense-message", nil);
            break;
        }
        default:
            break;
    }
    
    [self showMessageDialog:message title:title];
}

- (void)showNoSenseWithMessage:(NSString*)message {
    NSString* title = NSLocalizedString(@"settings.sense.not-found-title", nil);
    [self showMessageDialog:message title:title];
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

    // still need to hide status view regardless of whether manageSenseView is hidden.
    [UIView animateWithDuration:0.25f
                     animations:^{
                         [[self manageSenseView] setAlpha:1.0f];
                         [[self actionStatusView] setAlpha:0.0f];
                     }
                     completion:^(BOOL finished) {
                         [[self actionStatusView] setHidden:YES];
                     }];
}

- (void)enablePairingMode {
    [SENAnalytics track:kHEMAnalyticsEventDeviceAction
             properties:@{kHEMAnalyticsEventPropAction : kHEMAnalyticsEventDevicePairingMode}];
    
    [[self actionStatusLabel] setText:NSLocalizedString(@"settings.sense.enabling-pairing-mode", nil)];
    [self showActivity];
    
    __weak typeof(self) weakSelf = self;
    HEMDeviceCenter* center = [HEMDeviceCenter sharedCenter];
    [center scanForPairedSense:^(NSError *error) {
        if (error != nil) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            
            [SENAnalytics trackError:error withEventName:kHEMAnalyticsEventError];

            if (strongSelf) {
                if ([error code] == HEMDeviceCenterErrorSenseUnavailable) {
                    NSString* message = NSLocalizedString(@"settings.sense.no-sense-message", nil);
                    [strongSelf showNoSenseWithMessage:message];
                } else {
                    [strongSelf showFailureToEnablePairingModeAlert];
                }
                
                [strongSelf hideActivity];
            }
            
        } else {
            [[HEMDeviceCenter sharedCenter] putSenseIntoPairingMode:^(NSError *error) {
                __strong typeof(weakSelf) strongSelf = weakSelf;
                if (strongSelf) {
                    if (error != nil) {
                        [SENAnalytics trackError:error withEventName:kHEMAnalyticsEventError];
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

#pragma mark Factory Reset

- (void)restore {
    [SENAnalytics track:kHEMAnalyticsEventDeviceAction
             properties:@{kHEMAnalyticsEventPropAction : kHEMAnalyticsEventDeviceFactoryRestore}];
    
    [[self actionStatusLabel] setText:NSLocalizedString(@"settings.device.restoring-factory-settings", nil)];
    [self showActivity];
    
    __weak typeof(self) weakSelf = self;
    [[HEMDeviceCenter sharedCenter] restoreFactorySettings:^(NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf && error != nil) {
            [SENAnalytics trackError:error withEventName:kHEMAnalyticsEventError];
            // if there's no error, notification of factory restore will fire,
            // which will trigger app to be put back at checkpoint
            [strongSelf hideActivity];
            [strongSelf showFactoryRestoreErrorMessage:error];
        }
    }];
}

- (IBAction)restoreToFactoryDefaults:(id)sender {
    [self showFactoryRestoreConfirmation];
}

#pragma mark Configure WiFi

- (void)configureWiFi {
    HEMWifiPickerViewController* picker =
        (HEMWifiPickerViewController*) [HEMOnboardingStoryboard instantiateWifiPickerViewController];
    [picker setDelegate:self];
    
    UINavigationController* nav = [[UINavigationController alloc] initWithRootViewController:picker];
    [self presentViewController:nav animated:YES completion:nil];
}

#pragma mark HEMWifiConfigurationDelegate

- (void)didCancelWiFiConfigurationFrom:(id)controller {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didConfigureWiFiTo:(NSString *)ssid from:(id)controller {
    [self setWifiSSID:ssid];
    [self dismissViewControllerAnimated:YES completion:^{
        [self reloadRow:kHEMSenseRowWiFi];
    }];
}

#pragma mark - Cleanup

- (void)dealloc {
    [[HEMDeviceCenter sharedCenter] stopScanning];
}

@end
