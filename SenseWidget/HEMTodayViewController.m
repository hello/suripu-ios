//
//  TodayViewController.m
//  SenseWidget
//
//  Created by Jimmy Lu on 10/6/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//
#import <SenseKit/SENSensor.h>
#import <SenseKit/SENAPIRoom.h>
#import <SenseKit/SENAuthorizationService.h>
#import <SenseKit/SENTimeline.h>
#import <SenseKit/SENAPITimeline.h>

#import <NotificationCenter/NotificationCenter.h>

#import "UIColor+HEMStyle.h"
#import "UIFont+HEMStyle.h"

#import "HEMTodayViewController.h"
#import "HEMTodayTableViewCell.h"
#import "HEMSensorValueFormatter.h"

static NSString* const HEMAPIPlistKey = @"SenseApiUrl";
static NSString* const HEMClientIdPlistKey = @"SenseClientId";
static NSString* const kHEMTodayErrorDomain = @"is.hello.sense.today";
static NSString* const kHEMTodaySleepScoreCellId = @"sleepScore";
static NSString* const kHEMTodayConditionsCellId = @"info";
static NSString* const kHEMTodaySenseScheme = @"sense://";
static NSString* const HEMTodaySensorQueryItem = @"sensor";
static CGFloat const kHEMTodayLeftInset = 15.0f;
static CGFloat const kHEMTodayRightInset = 15.0f;
static CGFloat const kHEMTodayBottomInset = 15.0f;
static CGFloat const kHEMTodayRowHeight = 44.0f;

typedef void(^HEMWidgeUpdateBlock)(NCUpdateResult result);

@interface HEMTodayViewController () <
    NCWidgetProviding,
    UITableViewDataSource,
    UITableViewDelegate
>

@property (nonatomic, weak)   IBOutlet UITableView* tableView;
@property (nonatomic, weak)   IBOutlet UILabel *noDataLabel;
@property (nonatomic, strong) NSArray* sensors;
@property (nonatomic, strong) NSDate* lastNight;
@property (nonatomic, strong) SENTimeline* sleepResult;
@property (nonatomic, copy)   HEMWidgeUpdateBlock updateBlock;
@property (nonatomic, assign) BOOL sensorsChecked;
@property (nonatomic, strong) NSError* sensorsError;
@property (nonatomic, strong) HEMSensorValueFormatter* sensorFormatter;

@end

@implementation HEMTodayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configureApi];
    [self listenForSensorUpdates];
    [self configureContent];
}

- (void)configureApi {
    NSBundle* bundle = [NSBundle mainBundle];
    NSString* path = [bundle objectForInfoDictionaryKey:HEMAPIPlistKey];
    NSString* clientId = [bundle objectForInfoDictionaryKey:HEMClientIdPlistKey];
    
    [SENAPIClient setBaseURLFromPath:path];
    [SENAuthorizationService setClientAppID:clientId];
    [SENAuthorizationService authorizeRequestsFromKeychain];
}

- (void)configureContent {
    [self setSensorFormatter:[HEMSensorValueFormatter new]];
    
    self.tableView.rowHeight = kHEMTodayRowHeight;
    
    if ([SENAuthorizationService accessToken] != nil) {
        [self loadCachedSensors];
        [SENSensor refreshCachedSensors];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self reloadUI];
}

- (void)showNoDataLabel:(BOOL)show {
    [[self tableView] setHidden:show];
    [[self noDataLabel] setHidden:!show];
}

- (void)updateHeight {
    CGFloat height = 0.0f;
    if ([SENAuthorizationService accessToken] != nil) {
        NSInteger sensorCount = [[self sensors] count];
        height = (sensorCount * kHEMTodayRowHeight);
    } else {
        CGRect buttonFrame = [[self noDataLabel] frame];
        height = CGRectGetMaxY(buttonFrame) + CGRectGetMinY(buttonFrame);
    }
    [self setPreferredContentSize:CGSizeMake(CGRectGetWidth(self.view.bounds), height)];
}

- (void)reloadUI {
    [self updateHeight];
    [self showNoDataLabel:[SENAuthorizationService accessToken] == nil];
    [[self tableView] reloadData];
}

- (void)completeWhenDone {
    if (![self sensorsChecked]) return;

    if ([NSThread isMainThread]) {
        [self reloadUI];
    }
    
    if ([self updateBlock] != nil) {
        NCUpdateResult result = NCUpdateResultNewData;
        if ([self sensorsError] != nil) {
            result = NCUpdateResultFailed;
        }
        [self updateBlock](result);
        [self setUpdateBlock:nil];
    }
}

#pragma mark - NCWidgetProviding

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
    if ([SENAuthorizationService accessToken] != nil) {
        [self setUpdateBlock:completionHandler];
        [self setSensorsError:nil];
        [SENSensor refreshCachedSensors];
    } else {
        [self showNoDataLabel:YES];
    }

}

- (UIEdgeInsets)widgetMarginInsetsForProposedMarginInsets:(UIEdgeInsets)defaultMarginInsets {
    return UIEdgeInsetsMake(0.0f, kHEMTodayLeftInset, kHEMTodayBottomInset, kHEMTodayRightInset);
}

#pragma mark - Sensors

- (void)loadCachedSensors {
    self.sensors = [[SENSensor sensors] sortedArrayUsingComparator:^NSComparisonResult(SENSensor* obj1, SENSensor* obj2) {
        return [obj1.name compare:obj2.name];
    }];
}

- (void)listenForSensorUpdates {
    NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
    [center addObserver:self
               selector:@selector(update)
                   name:SENSensorUpdatedNotification object:nil];
    [center addObserver:self
               selector:@selector(failedToUpdate)
                   name:SENSensorUpdateFailedNotification
                 object:nil];
}

- (void)failedToUpdate {
    [self setSensorsError:[NSError errorWithDomain:kHEMTodayErrorDomain
                                              code:-1
                                          userInfo:nil]];
    [self setSensorsChecked:YES];
    [self completeWhenDone];
}

- (void)update {
    [self loadCachedSensors];
    [self setSensorsChecked:YES];
    [self completeWhenDone];
}

- (UIImage *)imageForSensor:(SENSensor *)sensor {
    switch ([sensor unit]) {
        case SENSensorUnitDegreeCentigrade:
            return [UIImage imageNamed:@"temperatureIcon"];
        case SENSensorUnitAQI:
            return [UIImage imageNamed:@"particleIcon"];
        case SENSensorUnitPercent:
            return [UIImage imageNamed:@"humidityIcon"];
        case SENSensorUnitLux:
            return [UIImage imageNamed:@"lightIcon"];
        case SENSensorUnitDecibel:
            return [UIImage imageNamed:@"soundIcon"];
        default:
            return nil;
    }
}

- (UIColor *)colorForSensor:(SENSensor *)sensor {
    switch ([sensor condition]) {
        case SENConditionAlert:
        case SENConditionWarning:
            return [UIColor colorForCondition:[sensor condition]];
        default:
            return [UIColor whiteColor];
    }
}

#pragma mark - UITableViewDataSource / Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    return [[self sensors] count];
}

- (UITableViewCell*)tableView:(UITableView *)tableView
        cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HEMTodayTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:kHEMTodayConditionsCellId];
    [self configureConditionsCell:cell atIndexPath:indexPath];
    return cell;
}

- (SENSensor*)sensorAtIndexPath:(NSIndexPath *)indexPath {
    if (self.sensors.count > indexPath.row)
        return [self sensors][[indexPath row]];
    return nil;
}

- (void)configureConditionsCell:(HEMTodayTableViewCell*)cell atIndexPath:(NSIndexPath*)indexPath {
    SENSensor* sensor = [self sensorAtIndexPath:indexPath];
    NSString* value = [[self sensorFormatter] stringFromSensor:sensor];
    
    if (value) {
        // if AQI, ignore unit, to match room conditions view
        if (sensor.unit != SENSensorUnitAQI) {
            value = [value stringByAppendingString:[sensor localizedUnit]];
        }
    } else {
        value = NSLocalizedString(@"empty-data", nil);
    }
    
    cell.sensorIconView.image = [self imageForSensor:sensor];
    cell.sensorNameLabel.text = [sensor localizedName];
    cell.sensorValueLabel.text = value;
    cell.sensorValueLabel.textColor = [self colorForSensor:sensor];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self openApp:indexPath];
}

#pragma mark - Actions

- (IBAction)openApp:(id)sender {
    NSURLComponents* components = [NSURLComponents componentsWithString:kHEMTodaySenseScheme];
    if ([sender isKindOfClass:[NSIndexPath class]]) {
        SENSensor* sensor = [self sensorAtIndexPath:sender];
        if (sensor.name.length > 0)
            components.queryItems = @[[NSURLQueryItem queryItemWithName:HEMTodaySensorQueryItem value:sensor.name]];
    }
    [[self extensionContext] openURL:[components URL] completionHandler:nil];
}

#pragma mark - Cleanup

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self setUpdateBlock:nil];
}

@end
