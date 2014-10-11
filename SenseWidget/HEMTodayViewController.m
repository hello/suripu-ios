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
#import <SenseKit/SENSleepResult.h>
#import <SenseKit/SENAPITimeline.h>

#import <NotificationCenter/NotificationCenter.h>

#import "HEMTodayViewController.h"

static NSString* const kHEMTodayErrorDomain = @"is.hello.sense.today";
static NSString* const kHEMTodayEmptyData = @"--";
static NSString* const kHEMTodaySleepScoreCellId = @"sleepScore";
static NSString* const kHEMTodayConditionsCellId = @"info";
static NSString* const kHEMTodaySenseScheme = @"sense://";
static CGFloat const kHEMTodayLeftInset = 15.0f;
static CGFloat const kHEMTodayImageSize = 15.0f;
static CGFloat const kHEMTodayRightInset = 15.0f;
static CGFloat const kHEMTodayBottomInset = 15.0f;
static CGFloat const kHEMTodayRowHeight = 44.0f;
static CGFloat const kHEMTodayHeaderInset = 15.0f;
static CGFloat const kHEMTodayHeaderHeight = 40.0f;
static CGFloat const kHEMTodayButtonCornerRadius = 5.0f;

typedef void(^HEMWidgeUpdateBlock)(NCUpdateResult result);

@interface HEMTodayViewController () <
    NCWidgetProviding,
    UITableViewDataSource,
    UITableViewDelegate
>

@property (nonatomic, weak)   IBOutlet UIButton *signInButton;
@property (nonatomic, weak)   IBOutlet UITableView* tableView;
@property (nonatomic, strong) NSArray* sensors;
@property (nonatomic, strong) NSDate* lastNight;
@property (nonatomic, strong) SENSleepResult* sleepResult;
@property (nonatomic, copy)   HEMWidgeUpdateBlock updateBlock;
@property (nonatomic, assign) BOOL scoreChecked;
@property (nonatomic, assign) BOOL sensorsChecked;
@property (nonatomic, strong) NSError* scoreError;
@property (nonatomic, strong) NSError* sensorsError;

@end

@implementation HEMTodayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [SENAuthorizationService authorizeRequestsFromKeychain];
    [[[self signInButton] layer] setCornerRadius:kHEMTodayButtonCornerRadius];
    [self listenForSensorUpdates];
    
    if ([SENAuthorizationService accessToken] != nil) {
        [self loadCachedSleepScore];
        [self loadCachedSensors];
        [self updateScore];
        [SENSensor refreshCachedSensors];
    }

    [self reloadUI];
    
}

- (void)showSignIn:(BOOL)show {
    [[self tableView] setHidden:show];
    [[self signInButton] setHidden:!show];
}

- (void)updateHeight {
    CGFloat height = 0.0f;
    if ([SENAuthorizationService accessToken] != nil) {
        NSInteger sensorCount = [[self sensors] count];
        height = kHEMTodayRowHeight + (2 * kHEMTodayHeaderHeight); // sleep score + conditions header
        if (sensorCount > 0) {
            height += (sensorCount * kHEMTodayRowHeight);
        }
    } else {
        CGRect buttonFrame = [[self signInButton] frame];
        height = CGRectGetMaxY(buttonFrame) + CGRectGetMinY(buttonFrame);
    }
    [self setPreferredContentSize:CGSizeMake(0, height)];
}

- (void)reloadUI {
    [self updateHeight];
    
    if ([SENAuthorizationService accessToken] != nil) {
        [[self tableView] reloadData];
        [self showSignIn:NO];
    } else {
        [self showSignIn:YES];
    }
    
}

- (void)completeWhenDone {
    if (![self scoreChecked] || ![self sensorsChecked]) return;
    
    if ([NSThread isMainThread]) {
        [self reloadUI];
    }
    
    if ([self updateBlock] != nil) {
        NCUpdateResult result = NCUpdateResultNewData;
        if ([self scoreError] != nil || [self sensorsError] != nil) {
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
        
        [self updateScore];
    } else {
        [self showSignIn:YES];
    }

}

- (UIEdgeInsets)widgetMarginInsetsForProposedMarginInsets:(UIEdgeInsets)defaultMarginInsets {
    return UIEdgeInsetsMake(0.0f, kHEMTodayLeftInset, kHEMTodayBottomInset, kHEMTodayRightInset);
}

#pragma mark - Sleep Score

- (void)loadCachedSleepScore {
    [self setLastNight:[NSDate dateWithTimeInterval:-86400 sinceDate:[NSDate date]]];
    [self setSleepResult:[SENSleepResult sleepResultForDate:[self lastNight]]];
}

- (void)updateScore {
    [self setScoreError:nil];
    [self setScoreChecked:NO];
    __weak typeof(self) weakSelf = self;
    [SENAPITimeline timelineForDate:[self lastNight] completion:^(NSArray* timelines, NSError* error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            if (error == nil) {
                [[strongSelf sleepResult] updateWithDictionary:[timelines firstObject]];
                [[strongSelf sleepResult] save];
            }
            [strongSelf setScoreError:error];
            [strongSelf setScoreChecked:YES];
            [strongSelf completeWhenDone];
        }
    }];
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

#pragma mark - UITableViewDataSource / Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    return section == 0 ? 1 : [[self sensors] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return kHEMTodayHeaderHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kHEMTodayRowHeight;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    CGFloat tableWidth = CGRectGetWidth([tableView bounds]);
    CGRect headerFrame = {0.0f, 0.0f, tableWidth, kHEMTodayHeaderHeight};
    UIView* containerView = [[UIView alloc] initWithFrame:headerFrame];
    [containerView setBackgroundColor:[UIColor colorWithWhite:1.0f alpha:0.1f]];
    
    NSString* title = section == 0
        ? NSLocalizedString(@"today.section.title.last-night", nil)
        : NSLocalizedString(@"today.section.title.current-conditions", nil);
    
    CGRect labelFrame = {kHEMTodayHeaderInset, 0.0f, tableWidth-(2*kHEMTodayHeaderInset), kHEMTodayHeaderHeight};
    UILabel* headerLabel = [[UILabel alloc] initWithFrame:labelFrame];
    [headerLabel setBackgroundColor:[UIColor clearColor]];
    [headerLabel setFont:[UIFont fontWithName:@"Agile-Light" size:18.0f]];
    [headerLabel setTextColor:[UIColor whiteColor]];
    [headerLabel setText:title];
    
    [containerView addSubview:headerLabel];
    
    return containerView;
}

- (UITableViewCell*)tableView:(UITableView *)tableView
        cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [tableView dequeueReusableCellWithIdentifier:kHEMTodayConditionsCellId];
}

- (void)displaySleepScoreCell:(UITableViewCell*)cell {
    NSNumber* score = [[self sleepResult] score];
    NSInteger scoreValue = [score integerValue];
    NSString* scoreText
        = scoreValue > 0
        ? [NSString stringWithFormat:@"%ld", (long)scoreValue]
        : kHEMTodayEmptyData;
    [[cell detailTextLabel] setText:scoreText];
    [[cell textLabel] setText:NSLocalizedString(@"today.cell.title.sleep-score", nil)];
    [[cell imageView] setImage:[UIImage imageNamed:@"sleepScoreIcon"]];
}

- (void)displayConditionsCell:(UITableViewCell*)cell atIndexPath:(NSIndexPath*)indexPath {
    SENSensor* sensor = [self sensors][[indexPath row]];
    
    UIImage* icon = nil;
    NSString* title = [sensor localizedName];
    NSString* detail = [sensor localizedValue]?[sensor localizedValue]:kHEMTodayEmptyData;
    
    switch ([sensor unit]) {
        case SENSensorUnitDegreeCentigrade: {
            icon = [UIImage imageNamed:@"temperatureIcon"];
            break;
        }
        case SENSensorUnitPartsPerMillion: {
            icon = [UIImage imageNamed:@"particleIcon"];
            break;
        }
        case SENSensorUnitPercent: {
            icon = [UIImage imageNamed:@"humidityIcon"];
            break;
        }
        default:
            break;
    }
    
    [[cell imageView] setImage:icon];
    [[cell textLabel] setText:title];
    [[cell detailTextLabel] setText:detail];
    [[cell detailTextLabel] setTextAlignment:NSTextAlignmentRight];

}

- (void)tableView:(UITableView *)tableView
  willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([indexPath section] == 0) {
        [self displaySleepScoreCell:cell];
    } else {
        [self displayConditionsCell:cell atIndexPath:indexPath];
    }
    
    CGRect bounds = [[cell imageView] bounds];
    bounds.size.width = kHEMTodayImageSize;
    bounds.size.height = kHEMTodayImageSize;
    [[cell imageView] setBounds:bounds];
    
    [[cell detailTextLabel] sizeToFit];
    
    CGFloat contentWidth = CGRectGetWidth([[cell contentView] bounds]);
    CGFloat contentHeight = CGRectGetHeight([[cell contentView] bounds]);
    CGRect frame = [[cell detailTextLabel] frame];
    frame.origin.x = contentWidth-CGRectGetWidth([[cell detailTextLabel] bounds]);
    frame.origin.y = (contentHeight-CGRectGetHeight([[cell detailTextLabel] bounds]))/2;
    [[cell detailTextLabel] setFrame:frame];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self openApp:self];
}

#pragma mark - Actions

- (IBAction)openApp:(id)sender {
    NSURL* url = [NSURL URLWithString:kHEMTodaySenseScheme];
    [[self extensionContext] openURL:url completionHandler:nil];
}

#pragma mark - Cleanup

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self setUpdateBlock:nil];
}

@end
