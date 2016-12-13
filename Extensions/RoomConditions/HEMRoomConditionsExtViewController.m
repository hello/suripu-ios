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
#import "NSString+HEMUtils.h"

#import "HEMRoomConditionsExtViewController.h"
#import "HEMSensorExtTableViewCell.h"
#import "HEMSensorValueFormatter.h"
#import "HEMSensorService.h"
#import "HEMConfig.h"
#import "HEMTappableView.h"

static NSString* const HEMApiUserAgentFormat = @"%@/%@ Platform/iOS OS/%@";
static NSString* const kHEMRoomConditionsExtErrorDomain = @"is.hello.sense.RoomConditions";
static NSString* const kHEMRoomConditionsExtConditionsCellId = @"info";
static NSString* const kHEMRoomConditionsExtSenseScheme = @"sense://ext/room";
static NSString* const HEMRoomConditionsExtSensorQueryItem = @"sensor";

static CGFloat const kHEMRoomConditionsLeftInset = 15.0f;
static CGFloat const kHEMRoomConditionsRightInset = 15.0f;
static CGFloat const kHEMRoomConditionsBottomInset = 15.0f;
static CGFloat const kHEMRoomConditionsRowHeight = 44.0f;
static NSInteger const kHEMRoomConditionsCollapsedSensors = 4;

typedef void(^HEMWidgeUpdateBlock)(NCUpdateResult result);

@interface HEMRoomConditionsExtViewController () <
    NCWidgetProviding,
    UITableViewDataSource,
    UITableViewDelegate,
    HEMTapDelegate
>

@property (weak, nonatomic) IBOutlet UITableView* tableView;
@property (weak, nonatomic) IBOutlet UILabel *noDataLabel;
@property (weak, nonatomic) IBOutlet UIImageView *headerSensorIcon1;
@property (weak, nonatomic) IBOutlet UILabel *headerSensorLabel1;
@property (weak, nonatomic) IBOutlet UIImageView *headerSensorIcon2;
@property (weak, nonatomic) IBOutlet UILabel *headerSensorLabel2;
@property (weak, nonatomic) IBOutlet UIImageView *headerSensorIcon3;
@property (weak, nonatomic) IBOutlet UILabel *headerSensorLabel3;
@property (weak, nonatomic) IBOutlet UIImageView *headerSensorIcon4;
@property (weak, nonatomic) IBOutlet UILabel *headerSensorLabel4;

@property (copy, nonatomic)   HEMWidgeUpdateBlock updateBlock;
@property (assign, nonatomic, getter=isLoading) BOOL loading;
@property (strong, nonatomic) NSError* sensorsError;
@property (strong, nonatomic) HEMSensorValueFormatter* sensorFormatter;
@property (strong, nonatomic) SENSensorStatus* status;
@property (strong, nonatomic) UIColor* defaultTextColor;

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
    UIImage* senseImage = [UIImage imageNamed:@"extensionSenseIcon"];
    senseImage = [senseImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    
    if ([[self extensionContext] respondsToSelector:@selector(setWidgetLargestAvailableDisplayMode:)]) {
        // iOS 10
        [self setDefaultTextColor:[UIColor grey5]];
        [[self tableView] setSeparatorColor:[UIColor grey5]];
        
        [[self headerSensorIcon1] setTintColor:[UIColor whiteColor]];
        [[self headerSensorIcon2] setTintColor:[UIColor whiteColor]];
        [[self headerSensorIcon3] setTintColor:[UIColor whiteColor]];
        [[self headerSensorIcon4] setTintColor:[UIColor whiteColor]];
        
        CGFloat radius = CGRectGetWidth([[self headerSensorIcon1] bounds]) / 2;
        [[[self headerSensorIcon1] layer] setCornerRadius:radius];
        [[[self headerSensorIcon2] layer] setCornerRadius:radius];
        [[[self headerSensorIcon3] layer] setCornerRadius:radius];
        [[[self headerSensorIcon4] layer] setCornerRadius:radius];
        
        [[self headerSensorLabel1] setTextColor:[self defaultTextColor]];
        [[self headerSensorLabel2] setTextColor:[self defaultTextColor]];
        [[self headerSensorLabel3] setTextColor:[self defaultTextColor]];
        [[self headerSensorLabel4] setTextColor:[self defaultTextColor]];
        
        [[self headerSensorLabel1] setFont:[UIFont h8]];
        [[self headerSensorLabel2] setFont:[UIFont h8]];
        [[self headerSensorLabel3] setFont:[UIFont h8]];
        [[self headerSensorLabel4] setFont:[UIFont h8]];
        
        [[self extensionContext] setWidgetLargestAvailableDisplayMode:NCWidgetDisplayModeExpanded];
        
        if ([[[self tableView] tableHeaderView] isKindOfClass:[HEMTappableView class]]) {
            HEMTappableView* headerView = (id) [[self tableView] tableHeaderView];
            [headerView setTapDelegate:self];
        }
    } else {
        [[self tableView] setTableHeaderView:nil];
        [self setDefaultTextColor:[UIColor whiteColor]];
    }
    
    [[self noDataLabel] setTextColor:[self defaultTextColor]];
    [[self noDataLabel] setText:nil];
    [self setSensorFormatter:[HEMSensorValueFormatter new]];
    [[self sensorFormatter] setIncludeUnitSymbol:YES];
    [[self tableView] setRowHeight:kHEMRoomConditionsRowHeight];
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
        height = (sensorCount * kHEMRoomConditionsRowHeight);
    } else {
        CGRect buttonFrame = [[self noDataLabel] frame];
        height = CGRectGetMaxY(buttonFrame) + CGRectGetMinY(buttonFrame);
    }
    
    if ([[self extensionContext] respondsToSelector:@selector(widgetActiveDisplayMode)]) {
        if ([[self extensionContext] widgetActiveDisplayMode] == NCWidgetDisplayModeExpanded) {
            height += CGRectGetHeight([[[self tableView] tableHeaderView] bounds]);
            [self setPreferredContentSize:CGSizeMake(CGRectGetWidth(self.view.bounds), height)];
        }
    } else {
        [self setPreferredContentSize:CGSizeMake(CGRectGetWidth(self.view.bounds), height)];
    }
}
         
- (UIImage *)imageForSensor:(SENSensor *)sensor {
    NSString* camelCase = [NSString camelCaseWord:[sensor typeStringValue]];
    NSString* imageName = [NSString stringWithFormat:@"extension%@Icon", camelCase];
    UIImage* image = [UIImage imageNamed:imageName];
    return [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
}

- (UIColor*)colorForSensor:(SENSensor*)sensor {
    switch ([sensor condition]) {
        case SENConditionAlert:
        case SENConditionWarning:
            return [UIColor colorForCondition:[sensor condition]];
        default:
            return [self defaultTextColor];
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
        [strongSelf updateHeader];
        [strongSelf showNoDataLabel:noData];
        [[strongSelf tableView] reloadData];
    };

    if ([NSThread isMainThread]) {
        reload();
    } else {
        dispatch_async(dispatch_get_main_queue(), reload);
    }
}

- (void)updateHeader {
    NSArray* sensors = [[self status] sensors];
    if ([sensors count] >= kHEMRoomConditionsCollapsedSensors) {
        [self updateHeaderImage:[self headerSensorIcon1]
                          label:[self headerSensorLabel1]
                      forSensor:sensors[0]];
        [self updateHeaderImage:[self headerSensorIcon2]
                          label:[self headerSensorLabel2]
                      forSensor:sensors[1]];
        [self updateHeaderImage:[self headerSensorIcon3]
                          label:[self headerSensorLabel3]
                      forSensor:sensors[2]];
        [self updateHeaderImage:[self headerSensorIcon4]
                          label:[self headerSensorLabel4]
                      forSensor:sensors[3]];
    }
}

- (void)updateHeaderImage:(UIImageView*)imageView
                    label:(UILabel*)label
                forSensor:(SENSensor*)sensor {
    [imageView setImage: [self imageForSensor:sensor]];
    [imageView setBackgroundColor:[UIColor colorForCondition:[sensor condition]]];
    [label setText:[sensor localizedName]];
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

- (void)widgetActiveDisplayModeDidChange:(NCWidgetDisplayMode)activeDisplayMode withMaximumSize:(CGSize)maxSize {
    switch (activeDisplayMode) {
        case NCWidgetDisplayModeCompact:
            [self setPreferredContentSize:maxSize];
            break;
        default: {
            NSInteger sensorCount = [[[self status] sensors] count];
            CGFloat height = sensorCount * kHEMRoomConditionsRowHeight;
            height += CGRectGetHeight([[[self tableView] tableHeaderView] bounds]);
            [self setPreferredContentSize:CGSizeMake(maxSize.width, height)];
            break;
        }
    }
}

- (UIEdgeInsets)widgetMarginInsetsForProposedMarginInsets:(UIEdgeInsets)defaultMarginInsets {
    
    if ([[self extensionContext] respondsToSelector:@selector(widgetActiveDisplayMode)]) {
        // iOS 10
        return defaultMarginInsets;
    } else {
        return UIEdgeInsetsMake(0.0f, kHEMRoomConditionsLeftInset, kHEMRoomConditionsBottomInset, kHEMRoomConditionsRightInset);
    }
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
    BOOL lastRow = [indexPath row] == [[[self status] sensors] count] - 1;
    SENSensor* sensor = [self sensorAtIndexPath:indexPath];
    [[cell sensorIconView] setImage:[self imageForSensor:sensor]];
    [[cell sensorNameLabel] setText:[sensor localizedName]];
    [[cell sensorNameLabel] setTextColor:[self defaultTextColor]];
    [[cell sensorValueLabel] setText:[self valueForSensor:sensor]];
    [[cell sensorValueLabel] setTextColor:[self colorForSensor:sensor]];
    [[cell sensorIconView] setTintColor:[self defaultTextColor]]; // match the text
    [[cell separator] setBackgroundColor:[[self defaultTextColor] colorWithAlphaComponent:0.5f]]; // match the text
    [[cell separator] setHidden:lastRow];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self openApp:indexPath];
}

#pragma mark - Actions

- (void)didTapOnView:(HEMTappableView *)tappableView {
    NSURLComponents* components = [NSURLComponents componentsWithString:kHEMRoomConditionsExtSenseScheme];
    [[self extensionContext] openURL:[components URL] completionHandler:nil];
}

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
