//
//  HEMRoomConditionsExtViewController.m
//  SenseWidget
//
//  Created by Jimmy Lu on 10/6/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//
#import <SenseKit/SENSensor.h>
#import <SenseKit/SENAuthorizationService.h>
#import <SenseKit/SENAPIClient.h>
#import <SenseKit/SENSensorStatus.h>
#import <SenseKit/SENAPISensor.h>

#import <NotificationCenter/NotificationCenter.h>

#import "UIFont+HEMStyle.h"
#import "UIColor+HEMStyle.h"

#import "HEMRoomConditionsExtViewController.h"
#import "HEMSensorExtTableViewCell.h"
#import "HEMSensorValueFormatter.h"
#import "HEMSensorService.h"
#import "HEMConfig.h"

static NSString* const HEMApiUserAgentFormat = @"%@/%@ Platform/iOS OS/%@";
static NSString* const kHEMRoomConditionsExtErrorDomain = @"is.hello.sense.today";
static NSString* const kHEMRoomConditionsExtConditionsCellId = @"info";
static NSString* const kHEMRoomConditionsExtSenseScheme = @"sense://ext/room";
static NSString* const HEMRoomConditionsExtSensorQueryItem = @"sensor";

static CGFloat const kHEMTodayLeftInset = 15.0f;
static CGFloat const kHEMTodayRightInset = 15.0f;
static CGFloat const kHEMTodayBottomInset = 15.0f;
static CGFloat const kHEMTodayRowHeight = 44.0f;

typedef void(^HEMWidgeUpdateBlock)(NCUpdateResult result);

@interface HEMRoomConditionsExtViewController () <
    NCWidgetProviding,
    UITableViewDataSource,
    UITableViewDelegate
>

@property (nonatomic, weak)   IBOutlet UITableView* tableView;
@property (nonatomic, weak)   IBOutlet UILabel *noDataLabel;
@property (nonatomic, copy)   HEMWidgeUpdateBlock updateBlock;
@property (nonatomic, assign, getter=isLoading) BOOL loading;
@property (nonatomic, strong) NSError* sensorsError;
@property (nonatomic, strong) HEMSensorValueFormatter* sensorFormatter;
@property (nonatomic, strong) SENSensorStatus* status;

@end

@implementation HEMRoomConditionsExtViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureApi];
    [self configureContent];
}

- (void)configureApi {
    UIDevice* device = [UIDevice currentDevice];
    NSBundle* bundle = [NSBundle mainBundle];
    NSString* path = [HEMConfig stringForConfig:HEMConfAPIURL];
    NSString* clientID = [HEMConfig stringForConfig:HEMConfClientId];
    NSString* appName = [bundle objectForInfoDictionaryKey:@"CFBundleDisplayName"];
    NSString* version = [bundle objectForInfoDictionaryKey:@"CFBundleVersion"];
    NSString* osVersion = [device systemVersion];
    NSString* userAgent = [NSString stringWithFormat:HEMApiUserAgentFormat, appName, version, osVersion];
    
    [SENAPIClient setBaseURLFromPath:path];
    [SENAuthorizationService setClientAppID:clientID];
    [SENAPIClient setValue:userAgent forHTTPHeaderField:@"User-Agent"];
    [SENAuthorizationService authorizeRequestsFromKeychain];
}

- (void)configureContent {
    [[self noDataLabel] setText:nil];
    [self setSensorFormatter:[HEMSensorValueFormatter new]];
    [[self sensorFormatter] setIncludeUnitSymbol:YES];
    [[self tableView] setRowHeight:kHEMTodayRowHeight];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self refreshData:nil];
}

- (void)refreshData:(void (^)(NCUpdateResult))completionHandler {
    [self setSensorsError:nil];
    [self setLoading:YES];
    
    __weak typeof(self) weakSelf = self;
    // we can't use the service as it will track errors, which our analytics
    // provider doesn't current support in extensions
    [SENAPISensor getSensorStatus:^(SENSensorStatus* status, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf setStatus:status];
        [strongSelf setSensorsError:error];
        [strongSelf setLoading:NO];
        
        if (completionHandler) {
            NCUpdateResult result = NCUpdateResultNewData;
            if ([strongSelf sensorsError]) {
                result = NCUpdateResultFailed;
            }
            completionHandler(result);
        }
        
        [strongSelf reloadUI];
    }];
}

- (void)showNoDataLabel:(BOOL)show {
    if (show) {
        NSString* message = nil;
        if ([self sensorsError]) {
            message = NSLocalizedString(@"ext.room-conditions.error", nil);
        } else if (![SENAuthorizationService isAuthorized]) {
            message = NSLocalizedString(@"ext.room-conditions.not-signed-in", nil);
        } else if ([self isLoading]) {
            message = NSLocalizedString(@"", nil);
        } else {
            message = NSLocalizedString(@"ext.room-conditions.loading", nil);
        }
        [[self noDataLabel] setText:message];
    }
    [[self tableView] setHidden:show];
    [[self noDataLabel] setHidden:!show];
}

- (void)updateHeight {
    CGFloat height = 0.0f;
    if ([SENAuthorizationService isAuthorized]) {
        NSInteger sensorCount = [[[self status] sensors] count];
        height = (sensorCount * kHEMTodayRowHeight);
    } else {
        CGRect buttonFrame = [[self noDataLabel] frame];
        height = CGRectGetMaxY(buttonFrame) + CGRectGetMinY(buttonFrame);
    }
    [self setPreferredContentSize:CGSizeMake(CGRectGetWidth(self.view.bounds), height)];
}
         
- (UIImage *)imageForSensor:(SENSensor *)sensor {
    NSString* typeLowerCase = [[sensor typeStringValue] lowercaseString];
    NSString* imageName = [NSString stringWithFormat:@"%@IconWhite", typeLowerCase];
    UIImage* image = [UIImage imageNamed:imageName];
    return image;
}

- (UIColor*)colorForSensor:(SENSensor*)sensor {
    switch ([sensor condition]) {
        case SENConditionAlert:
        case SENConditionWarning:
            return [UIColor colorForCondition:[sensor condition]];
        default:
            return [UIColor whiteColor];
    }
}

- (NSString*)valueForSensor:(SENSensor*)sensor {
    NSString* value = [[self sensorFormatter] stringFromSensor:sensor];
    return  [value length] > 0 ? value : NSLocalizedString(@"empty-data", nil);
}

- (void)reloadUI {
    __weak typeof(self) weakSelf = self;
    void(^reload)(void) = ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        BOOL noData = [[[strongSelf status] sensors] count] == 0;
        [strongSelf updateHeight];
        [strongSelf showNoDataLabel:noData];
        [[strongSelf tableView] reloadData];
    };

    if ([NSThread isMainThread]) {
        reload();
    } else {
        dispatch_async(dispatch_get_main_queue(), reload);
    }
}

#pragma mark - NCWidgetProviding

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
    if ([SENAuthorizationService isAuthorized]) {
        [self setUpdateBlock:completionHandler];
        [self refreshData:completionHandler];
    } else {
        [self showNoDataLabel:YES];
        completionHandler (NCUpdateResultNoData);
    }
}

- (UIEdgeInsets)widgetMarginInsetsForProposedMarginInsets:(UIEdgeInsets)defaultMarginInsets {
    return UIEdgeInsetsMake(0.0f, kHEMTodayLeftInset, kHEMTodayBottomInset, kHEMTodayRightInset);
}

#pragma mark - UITableViewDataSource / Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    return [[[self status] sensors] count];
}

- (UITableViewCell*)tableView:(UITableView *)tableView
        cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString* cellID = kHEMRoomConditionsExtConditionsCellId;
    return [tableView dequeueReusableCellWithIdentifier:cellID];
}

- (void)tableView:(UITableView *)tableView
  willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath {
    [self configureConditionsCell:(id)cell atIndexPath:indexPath];
}

- (SENSensor*)sensorAtIndexPath:(NSIndexPath *)indexPath {
    if ([indexPath row] < [[[self status] sensors] count]) {
        return [[self status] sensors][[indexPath row]];
    } else {
        return nil;
    }
}

- (void)configureConditionsCell:(HEMSensorExtTableViewCell*)cell
                    atIndexPath:(NSIndexPath*)indexPath {
    SENSensor* sensor = [self sensorAtIndexPath:indexPath];
    [[cell sensorIconView] setImage:[self imageForSensor:sensor]];
    [[cell sensorNameLabel] setText:[sensor localizedName]];
    [[cell sensorValueLabel] setText:[self valueForSensor:sensor]];
    [[cell sensorValueLabel] setTextColor:[self colorForSensor:sensor]];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self openApp:indexPath];
}

#pragma mark - Actions

- (IBAction)openApp:(id)sender {
    NSURLComponents* components = [NSURLComponents componentsWithString:kHEMRoomConditionsExtSenseScheme];
    if ([sender isKindOfClass:[NSIndexPath class]]) {
        SENSensor* sensor = [self sensorAtIndexPath:sender];
        NSString* type = [[sensor typeStringValue] lowercaseString];
        if ([type length] > 0) {
            components.queryItems = @[[NSURLQueryItem queryItemWithName:HEMRoomConditionsExtSensorQueryItem
                                                                  value:type]];
        }
    }
    [[self extensionContext] openURL:[components URL] completionHandler:nil];
}

#pragma mark - Cleanup

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if (_updateBlock) {
        _updateBlock = nil;
    }
}

@end
