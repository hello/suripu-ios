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

#import "HEMWifiPickerViewController.h"
#import "HEMBaseController+Protected.h"
#import "HEMWiFiDataSource.h"
#import "HelloStyleKit.h"
#import "HEMOnboardingStoryboard.h"
#import "HEMWifiPasswordViewController.h"
#import "HEMActionButton.h"
#import "HEMActivityCoverView.h"
#import "HEMSupportUtil.h"

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

@property (weak, nonatomic) IBOutlet UILabel *subtitleLabel;
@property (weak, nonatomic) IBOutlet UITableView *wifiPickerTableView;
@property (weak, nonatomic) IBOutlet UIButton *helpButton;
@property (weak, nonatomic) IBOutlet HEMActionButton *scanButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scanButtonWidthConstraint;
@property (weak, nonatomic) IBOutlet HEMActivityCoverView *activityView;

@property (strong, nonatomic) SENWifiEndpoint* selectedWifiEndpont;
@property (strong, nonatomic) HEMWiFiDataSource* wifiDataSource;
@property (assign, nonatomic, getter=isVisible) BOOL visible;
@property (assign, nonatomic, getter=hasScanned) BOOL scanned;

@end

@implementation HEMWifiPickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self showHelpButton];
    [self setWifiDataSource:[[HEMWiFiDataSource alloc] init]];
    [[self wifiPickerTableView] setDataSource:[self wifiDataSource]];
    [[self wifiPickerTableView] setDelegate:self];
    
    [[[self activityView] activityLabel] setFont:[UIFont onboardingActivityFontMedium]];
    
    [[[self scanButton] layer] setBorderWidth:0.0f];
    
    [self setupCancelButton];
    
    if ([self delegate] == nil && [self sensePairDelegate] == nil) {
        [self enableBackButton:NO];
        [SENAnalytics track:kHEMAnalyticsEventOnBWiFi];
    }
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setVisible:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // only auto start a scan if one has not yet been done before
    if (![self hasScanned]) {
        [self scanWithActivity];
        [self setScanned:YES];
    }
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self setVisible:NO];
}

- (void)adjustConstraintsForIphone5 {
    CGFloat diff = -kHEMWifiCellHeight;
    [self updateConstraint:[self tableViewHeightConstraint] withDiff:diff];
}

- (void)adjustConstraintsForIPhone4 {
    CGFloat diff = -(2*kHEMWifiCellHeight);
    [self updateConstraint:[self tableViewHeightConstraint] withDiff:diff];
}

- (void)setupCancelButton {
    if ([self delegate] != nil || [self sensePairDelegate] != nil) {
        NSString* title = NSLocalizedString(@"actions.cancel", nil);
        UIBarButtonItem* cancelItem = [[UIBarButtonItem alloc] initWithTitle:title
                                                                       style:UIBarButtonItemStyleBordered
                                                                      target:self
                                                                      action:@selector(cancel:)];
        [[self navigationItem] setLeftBarButtonItem:cancelItem];
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [[self activityView] setNeedsLayout];
}

#pragma mark - UITableViewDelegate

- (UIView*)wifiAccessoryView {
    UIImage* lockIcon = [HelloStyleKit lockIcon];
    UIImage* wifiIcon = [HelloStyleKit wifiIcon];
    
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

    UIView* accessoryView = [cell accessoryView];
    if (accessoryView == nil) {
        accessoryView = [self wifiAccessoryView];
        [cell setAccessoryView:accessoryView];
    }
    
    SENWifiEndpoint* endpoint = [[self wifiDataSource] endpointAtIndexPath:indexPath];
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
    
    [[cell textLabel] setFont:[UIFont wifiTitleFont]];
    [[cell textLabel] setText:ssid];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self setSelectedWifiEndpont:[[self wifiDataSource] endpointAtIndexPath:indexPath]];
    [self next];
}

- (void)scanWithActivity {
    [SENAnalytics startEvent:kHEMAnalyticsEventOnBWiFiScan];
    DDLogVerbose(@"wifi scan started");
    
    NSString* message = NSLocalizedString(@"wifi.activity.scanning", nil);
    [[self activityView] showWithText:message activity:YES completion:nil];
    
    __weak typeof(self) weakSelf = self;
    [self scanUntilDoneWithCount:0 completion:^(NSError *error) {
        __block typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            DDLogVerbose(@"wifi scan completed");
            [SENAnalytics endEvent:kHEMAnalyticsEventOnBWiFiScan];
            
            [[strongSelf activityView] dismissWithResultText:nil showSuccessMark:NO remove:NO completion:^{
                [[strongSelf wifiPickerTableView] reloadData];
                [[strongSelf wifiPickerTableView] flashScrollIndicators];
            }];
            
            if (error != nil && [strongSelf isVisible]) {
                [strongSelf showError:error];
            }
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
    [self showMessageDialog:message title:title];
    [SENAnalytics trackError:error withEventName:kHEMAnalyticsEventError];
}

#pragma mark - Actions

- (IBAction)scan:(id)sender {
    [SENAnalytics track:kHEMAnalyticsEventOnBWiFiScan];
    
    [[self wifiDataSource] clearDetectedWifis];
    [[self wifiPickerTableView] reloadData];
    [self scanWithActivity];
}

- (IBAction)cancel:(id)sender {
    [[self delegate] didCancelWiFiConfigurationFrom:self];
    [[self sensePairDelegate] didSetupWiFiForPairedSense:NO from:self];
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

@end
