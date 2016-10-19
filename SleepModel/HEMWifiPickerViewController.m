//
//  HEMWifiPickerViewController.m
//  Sense
//
//  Created by Jimmy Lu on 10/27/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//
#import <SenseKit/SENSenseManager.h>
#import <SenseKit/SENSenseMessage.pb.h>
#import <SenseKit/SENSense.h>
#import <SenseKit/SENSenseMetadata.h>
#import <SenseKit/SENServiceDevice.h>
#import <SenseKit/SENPairedDevices.h>

#import "UIFont+HEMStyle.h"
#import "UIColor+HEMStyle.h"
#import "HEMWifiPickerViewController.h"
#import "HEMWiFiDataSource.h"
#import "HEMOnboardingStoryboard.h"
#import "HEMWifiPasswordViewController.h"
#import "HEMActionButton.h"
#import "HEMActivityCoverView.h"
#import "HEMSupportUtil.h"
#import "HEMWifiUtils.h"
#import "HEMMacAddressHeaderView.h"
#import "HEMConfirmationView.h"

static CGFloat const HEMWiFiPickerLockLeftPadding = 24.0f;
static CGFloat const HEMWifiPickerLockRightPadding = 16.0f;
static CGFloat const kHEMWifiCellHeight = 44.0f;
static NSUInteger const kHEMWifiPickerTagLock = 1;
static NSUInteger const kHEMWifiPickerTagWifi = 2;
// 10/29/2014 jimmy:
// even though we really want to scan more than once to get a full list of
// networks nearby, we have decided that we should scan once and make user
// re-scan until they see their own network and analyze the result through
// analytics.  The reason is because top board firmware for Sense cannot handle
// multiple commands at once and if we scan once, user goes
static NSUInteger const kHEMWifiPickerScansRequired = 1;

@interface HEMWifiPickerViewController() <UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *wifiPickerTableView;
@property (weak, nonatomic) IBOutlet HEMActionButton *scanButton;
@property (weak, nonatomic) IBOutlet HEMActivityCoverView *activityView;
@property (weak, nonatomic) IBOutlet UIImageView *topPickerShadow;
@property (weak, nonatomic) IBOutlet UIImageView *botPickerShadow;

@property (strong, nonatomic) SENWifiEndpoint* selectedWifiEndpont;
@property (strong, nonatomic) HEMWiFiDataSource* wifiDataSource;
@property (copy,   nonatomic) NSString* disconnectObserverId;
@property (assign, nonatomic, getter=hasScanned) BOOL scanned;
@property (strong, nonatomic) HEMMacAddressHeaderView* macAddressHeaderView;

@end

@implementation HEMWifiPickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configurePicker];
    [self configureButtons];
    [self trackAnalyticsEvent:HEMAnalyticsEventWiFi];
}

- (BOOL)haveDelegates {
    return [self delegate] != nil || [self sensePairDelegate] != nil;
}

- (void)configureButtons {
    [self showHelpButtonForPage:NSLocalizedString(@"help.url.slug.wifi-scan", nil)
           andTrackWithStepName:kHEMAnalyticsEventPropWiFiScan];
    [[[self scanButton] layer] setBorderWidth:0.0f];
    
    if ([self haveDelegates]) {
        [self showCancelButtonWithSelector:@selector(cancel:)];
    } else {
        [self enableBackButton:NO];
    }
}

- (BOOL)showMacAddress {
    return YES;
    // TODO: figure out manufacturer data
//    SENSense* currentSense = [[self manager] sense];
//    BOOL hide = [currentSense version] == SENSenseAdvertisedVersionUnknown;
//    if (hide) { // check metadata if available
//        SENSenseMetadata* senseMetadata = [[[SENServiceDevice sharedService] devices] senseMetadata];
//        hide = [senseMetadata hardwareVersion] == SENSenseHardwareOne
//            || [senseMetadata hardwareVersion] == SENSenseHardwareUnknown;
//    }
//    return !hide;
}

- (void)configurePicker {
    [[[self activityView] activityLabel] setFont:[UIFont onboardingActivityFontMedium]];
    
    [self setWifiDataSource:[[HEMWiFiDataSource alloc] init]];
    [[self wifiDataSource] setKeepSenseLEDOn:![self haveDelegates]];
    [[self wifiPickerTableView] setDataSource:[self wifiDataSource]];
    [[self wifiPickerTableView] setDelegate:self];

    // shares the same shadow image as the topPickerShadow, which requires a flip
    [[self botPickerShadow] setTransform:CGAffineTransformMakeRotation(M_PI)];

    if ([self showMacAddress]) {
        HEMMacAddressHeaderView* headerView = (id)[[self wifiPickerTableView] tableHeaderView];
        SENSense* sense = [[self manager] sense];
        
        [[headerView titleLabel] setFont:[UIFont h6]];
        [[headerView titleLabel] setTextColor:[UIColor grey6]];
        
        [[headerView macAddressLabel] setFont:[UIFont body]];
        [[headerView macAddressLabel] setTextColor:[UIColor grey4]];
        [[headerView macAddressLabel] setText:[sense macAddress]];
        
        [[[headerView actionButton] titleLabel] setFont:[UIFont button]];
        [[headerView actionButton] setTitleColor:[UIColor tintColor] forState:UIControlStateNormal];
        [[headerView actionButton] addTarget:self
                                      action:@selector(copyMacAddress:)
                            forControlEvents:UIControlEventTouchUpInside];
        
        [[headerView separator] setBackgroundColor:[[self wifiPickerTableView] separatorColor]];
        [headerView setHidden:YES];
    } else {
        [[self wifiPickerTableView] setTableHeaderView:nil];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    // only auto start a scan if one has not yet been done before
    if (![self hasScanned]) {
        [self trackAnalyticsEvent:HEMAnalyticsEventWiFiScan];
        [self scanWithActivity];
        [self setScanned:YES];
    }
    
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [[self activityView] setNeedsLayout];
}

- (void)updateContentBottomShadowVisibility {
    CGFloat pickerHeight = CGRectGetHeight([[self wifiPickerTableView] bounds]);
    CGFloat contentHeight = [[self wifiPickerTableView] contentSize].height;
    CGFloat bottomShadowAlpha = contentHeight > pickerHeight ? 1.0f : 0.0f;
    [[self botPickerShadow] setAlpha:bottomShadowAlpha];
}

#pragma mark - Disconnects

- (void)observeUnexpectedDisconnects {
    if ([self disconnectObserverId] == nil) {
        __weak typeof(self) weakSelf = self;
        self.disconnectObserverId =
        [[self manager] observeUnexpectedDisconnect:^(NSError *error) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            [[strongSelf activityView] dismissWithResultText:nil showSuccessMark:NO remove:NO completion:^{
                [[strongSelf cancelItem] setEnabled:YES];
                if ([strongSelf isVisible]) {
                    [strongSelf showError:error];
                }
            }];
        }];
    }
}

#pragma mark - UITableViewDelegate

- (UIView*)wifiAccessoryView {
    UIImage* lockIcon = [UIImage imageNamed:@"lockIcon"];
    UIImage* wifiIcon = [HEMWifiUtils wifiIconForRssi:-1]; // make sure to use a strong signal icon to start
    
    CGRect lockFrame = CGRectZero;
    lockFrame.size = lockIcon.size;
    lockFrame.origin.x = HEMWiFiPickerLockLeftPadding;
    UIImageView* lockView = [[UIImageView alloc] initWithImage:lockIcon];
    [lockView setFrame:lockFrame];
    [lockView setBackgroundColor:[UIColor clearColor]];
    [lockView setTag:kHEMWifiPickerTagLock];
    
    CGRect wifiFrame = CGRectZero;
    wifiFrame.size = wifiIcon.size;
    wifiFrame.origin.x = HEMWifiPickerLockRightPadding + CGRectGetMaxX(lockFrame);
    UIImageView* wifiView = [[UIImageView alloc] initWithImage:wifiIcon];
    [wifiView setFrame:wifiFrame];
    [wifiView setBackgroundColor:[UIColor clearColor]];
    [wifiView setTag:kHEMWifiPickerTagWifi];
    
    CGRect containerFrame = CGRectZero;
    containerFrame.size.width = CGRectGetMaxX(wifiFrame);
    containerFrame.size.height = MAX([lockIcon size].height, [wifiIcon size].height);
    UIView* container = [[UIView alloc] initWithFrame:containerFrame];
    container.backgroundColor = [UIColor clearColor];

    [container addSubview:lockView];
    [container addSubview:wifiView];
    
    return container;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kHEMWifiCellHeight;
}

- (void)tableView:(UITableView *)tableView
  willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath {

    SENWifiEndpoint* endpoint = [[self wifiDataSource] endpointAtIndexPath:indexPath];
    DDLogVerbose(@"endpoint %@, rssi %ld", [endpoint ssid], [endpoint rssi]);
    
    UIView* accessoryView = [cell accessoryView];
    if (accessoryView == nil) {
        accessoryView = [self wifiAccessoryView];
        [cell setAccessoryView:accessoryView];
    }
    
    BOOL showWifiIcon = YES;
    NSString* ssid = [endpoint ssid];
    if (ssid == nil) {
        showWifiIcon = NO;
        ssid = NSLocalizedString(@"settings.wifi.other", nil);
    }
    
    UIImageView* lockView = (UIImageView*)[accessoryView viewWithTag:kHEMWifiPickerTagLock];
    [lockView setHidden:[endpoint security] == SENWifiEndpointSecurityTypeOpen];
    
    UIImageView* wifiView = (UIImageView*)[accessoryView viewWithTag:kHEMWifiPickerTagWifi];
    [wifiView setHidden:!showWifiIcon];
    [wifiView setImage:[HEMWifiUtils wifiIconForRssi:[endpoint rssi]]];
    
    [[cell textLabel] setFont:[UIFont wifiTitleFont]];
    [[cell textLabel] setText:ssid];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self setSelectedWifiEndpont:[[self wifiDataSource] endpointAtIndexPath:indexPath]];
    [self next];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat yOffset = [scrollView contentOffset].y;
    
    CGFloat topShadowAlpha = yOffset > 0.0f ? 1.0f : 0.0f;
    [[self topPickerShadow] setAlpha:topShadowAlpha];
    
    CGFloat contentHeight = [scrollView contentSize].height;
    CGFloat scrollHeight = CGRectGetHeight([scrollView bounds]);
    CGFloat botShadowAlpha = yOffset < (contentHeight - scrollHeight) ? 1.0f : 0.0f;
    [[self botPickerShadow] setAlpha:botShadowAlpha];
}

- (void)scanWithActivity {
    DDLogVerbose(@"wifi scan started");
    
    [self observeUnexpectedDisconnects];
    [[self cancelItem] setEnabled:NO];
    
    NSString* message = NSLocalizedString(@"wifi.activity.scanning", nil);
    [[self activityView] showWithText:message activity:YES completion:nil];
    
    __weak typeof(self) weakSelf = self;
    [self scanUntilDoneWithCount:0 completion:^(NSError *error) {
        __block typeof(weakSelf) strongSelf = weakSelf;
        DDLogVerbose(@"wifi scan completed");
        
        [[[strongSelf wifiPickerTableView] tableHeaderView] setHidden:NO];
        [[strongSelf wifiPickerTableView] reloadData];
        [[strongSelf activityView] dismissWithResultText:nil showSuccessMark:NO remove:NO completion:^{
            [strongSelf updateContentBottomShadowVisibility];
            [[strongSelf wifiPickerTableView] flashScrollIndicators];
            [[strongSelf cancelItem] setEnabled:YES];
        }];
        
        if (error != nil) {
            [strongSelf showError:error];
        }
    }];
}

- (void)scanUntilDoneWithCount:(NSInteger)scanCount completion:(void(^)(NSError* error))completion {
    __weak typeof(self) weakSelf = self;
    [[self wifiDataSource] scan:^(NSError *error) {
        __block typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            if (error != nil) {
                if (completion) completion (error);
                return;
            }
            NSInteger nextCount = scanCount + 1;
            if (nextCount < kHEMWifiPickerScansRequired && [strongSelf isVisible]) {
                [[strongSelf wifiPickerTableView] reloadData]; // show what we have
                [strongSelf scanUntilDoneWithCount:nextCount completion:completion];
            } else {
                if (completion) completion (nil);
            }
        }
    }];
}

#pragma mark - Errors / Alerts

- (void)showError:(NSError*)error {
    NSString* title = NSLocalizedString(@"wifi.error.scan-title", nil);
    NSString* message = nil;
    switch ([error code]) {
        case SENSenseManagerErrorCodeSenseOutOfMemory:
            message = NSLocalizedString(@"wifi.error.scan-out-of-memory", nil);
            break;
        default:
            message = NSLocalizedString(@"wifi.error.scan-general", nil);
            break;
    }
    
    [self showMessageDialog:message
                      title:title
                      image:nil
               withHelpPage:NSLocalizedString(@"help.url.slug.wifi-scan", nil)];
    [SENAnalytics trackError:error];
}

#pragma mark - Actions

- (void)copyMacAddress:(UIButton*)sender {
    SENSense* sense = [[self manager] sense];
    UIPasteboard* copyBoard = [UIPasteboard generalPasteboard];
    [copyBoard setString:[sense macAddress]];
    
    NSString* copiedText = NSLocalizedString(@"status.copied", nil);
    HEMConfirmationView* copiedView =
        [[HEMConfirmationView alloc] initWithText:copiedText layout:HEMConfirmationLayoutHorizontal];
    [copiedView showInView:[[self navigationController] view]];
}

- (IBAction)scan:(id)sender {
    [self trackAnalyticsEvent:HEMAnalyticsEventWiFiRescan];
    [[self wifiDataSource] clearDetectedWifis];
    [[self wifiPickerTableView] reloadData];
    [self scanWithActivity];
}

- (IBAction)cancel:(id)sender {
    [[self delegate] didCancelWiFiConfigurationFrom:self];
    [[self sensePairDelegate] didSetupWiFiForPairedSense:nil from:self];
}

#pragma mark - Navigation

- (void)next {
    [self performSegueWithIdentifier:[HEMOnboardingStoryboard wifiPasswordSegueIdentifier]
                              sender:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [super prepareForSegue:segue sender:sender];
    
    UIViewController* destVC = [segue destinationViewController];
    if ([destVC isKindOfClass:[HEMWifiPasswordViewController class]]) {
        HEMWifiPasswordViewController* wifiVC = (HEMWifiPasswordViewController*)destVC;
        [wifiVC setEndpoint:[self selectedWifiEndpont]];
        [wifiVC setDelegate:[self delegate]];
        [wifiVC setSensePairDelegate:[self sensePairDelegate]];
    }
}

#pragma mark - Clean Up

- (void)dealloc {
    if (_disconnectObserverId != nil) {
        [[self manager] removeUnexpectedDisconnectObserver:_disconnectObserverId];
    }
}

@end
