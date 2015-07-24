//
//  HEMWifiPickerViewController.m
//  Sense
//
//  Created by Jimmy Lu on 10/27/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//
#import <SenseKit/SENSenseManager.h>
#import <SenseKit/SENSenseMessage.pb.h>

#import "UIFont+HEMStyle.h"
#import "UIColor+HEMStyle.h"
#import "HEMWifiPickerViewController.h"
#import "HEMBaseController+Protected.h"
#import "HEMWiFiDataSource.h"
#import "HelloStyleKit.h"
#import "HEMOnboardingStoryboard.h"
#import "HEMWifiPasswordViewController.h"
#import "HEMActionButton.h"
#import "HEMActivityCoverView.h"
#import "HEMSupportUtil.h"
#import "HEMWifiUtils.h"

static CGFloat const kHEMWifiCellHeight = 44.0f;
static CGFloat const kHEMWifiPickerIconPadding = 5.0f;
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

@property (strong, nonatomic) SENWifiEndpoint* selectedWifiEndpont;
@property (strong, nonatomic) HEMWiFiDataSource* wifiDataSource;
@property (weak,   nonatomic) UIBarButtonItem* cancelItem;
@property (copy,   nonatomic) NSString* disconnectObserverId;
@property (assign, nonatomic, getter=hasScanned) BOOL scanned;

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

- (void)configurePicker {
    [[[self activityView] activityLabel] setFont:[UIFont onboardingActivityFontMedium]];
    
    [self setWifiDataSource:[[HEMWiFiDataSource alloc] init]];
    [[self wifiDataSource] setKeepSenseLEDOn:![self haveDelegates]];
    [[self wifiPickerTableView] setDataSource:[self wifiDataSource]];
    [[self wifiPickerTableView] setDelegate:self];
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
    UIImage* lockIcon = [HelloStyleKit lockIcon];
    UIImage* wifiIcon = [HEMWifiUtils wifiIconForRssi:-1]; // make sure to use a strong signal icon to start
    
    CGRect lockFrame = CGRectZero;
    lockFrame.size = lockIcon.size;
    UIImageView* lockView = [[UIImageView alloc] initWithImage:lockIcon];
    [lockView setFrame:lockFrame];
    [lockView setBackgroundColor:[UIColor clearColor]];
    [lockView setTag:kHEMWifiPickerTagLock];
    
    CGRect wifiFrame = CGRectZero;
    wifiFrame.size = wifiIcon.size;
    wifiFrame.origin.x = kHEMWifiPickerIconPadding + CGRectGetMaxX(lockFrame);
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
        
        [[strongSelf wifiPickerTableView] reloadData];
        [[strongSelf activityView] dismissWithResultText:nil showSuccessMark:NO remove:NO completion:^{
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
