
#import <SenseKit/SenseKit.h>
#import <BEMSimpleLineGraph/BEMSimpleLineGraphView.h>

#import "NSString+HEMUtils.h"

#import "HEMCurrentConditionsViewController.h"
#import "HEMSensorViewController.h"
#import "HEMMainStoryboard.h"
#import "HEMSensorGraphCollectionViewCell.h"
#import "HEMStyle.h"
#import "HEMTutorial.h"
#import "HEMSenseRequiredCollectionViewCell.h"
#import "HEMSensePairViewController.h"
#import "HEMOnboardingStoryboard.h"
#import "HEMStyledNavigationViewController.h"
#import "HEMActionButton.h"
#import "HEMSensorValueFormatter.h"
#import "HEMSnazzBarController.h"
#import "HEMRootViewController.h"
#import "HEMTextCollectionViewCell.h"

@interface HEMCurrentConditionsViewController () <UICollectionViewDataSource, UICollectionViewDelegate,
                                                  UICollectionViewDelegateFlowLayout, HEMSensePairingDelegate, HEMSnazzBarControllerChild>
@property (nonatomic, strong) NSArray *sensors;
@property (nonatomic, assign, getter=isLoading) BOOL loading;
@property (nonatomic, strong) NSTimer *refreshTimer;
@property (nonatomic, strong) NSMutableDictionary *sensorGraphData;
@property (nonatomic) CGFloat refreshRate;
@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;
@property (nonatomic) BOOL shouldReload;
@property (nonatomic, getter=hasNoSense) BOOL noSense;
@property (nonatomic, strong) NSDate *lastRefreshDate;
@property (nonatomic, strong) HEMSensorValueFormatter* sensorValueFormatter;
@end

@implementation HEMCurrentConditionsViewController

static CGFloat const HEMCurrentConditionsRefreshIntervalInSeconds = 10.f;
static CGFloat const HEMCurrentConditionsFailureIntervalInSeconds = 1.f;
static CGFloat const HEMCurrentConditionsSensorViewHeight = 104.0f;
static CGFloat const HEMCurrentConditionsPairViewHeight = 352.0f;
static CGFloat const HEMCurrentConditionsItemSpacing = 8.f;
static NSUInteger const HEMConditionGraphPointLimit = 130;
static CGFloat const HEMCurrentConditionsErrorTextHorzPadding = 16.0f;
static CGFloat const HEMCurrentConditionsErrorTextVertPadding = 26.0f;

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        self.tabBarItem.title = NSLocalizedString(@"current-conditions.title", nil);
        self.tabBarItem.image = [UIImage imageNamed:@"sensorsBarIcon"];
        self.tabBarItem.selectedImage = [UIImage imageNamed:@"sensorsBarIconActive"];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureCollectionView];
    [self setDefaultProperties];
}

- (void)setDefaultProperties {
    self.loading = YES;
    self.refreshRate = HEMCurrentConditionsFailureIntervalInSeconds;
    self.sensorValueFormatter = [[HEMSensorValueFormatter alloc] init];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self registerForNotifications];
    [self configureRefreshTimer];
    if ([self shouldReload]) {
        [self reloadData];
        self.shouldReload = NO;
    }

    if (self.sensors.count == 0 || [[NSDate date] timeIntervalSinceDate:self.lastRefreshDate] >= self.refreshRate)
        [self refreshCachedSensors];

    [SENAnalytics track:kHEMAnalyticsEventCurrentConditions];
}

- (void)viewDidDisappear:(BOOL)animated {
    [self invalidateTimers];
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SENAPIReachableNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SENSensorsUpdatedNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SENSensorUpdateFailedNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:SENAuthorizationServiceDidAuthorizeNotification
                                                  object:nil];
}

- (void)didReceiveMemoryWarning {
    if (![self isViewLoaded] || !self.view.window) {
        self.shouldReload = YES;
        self.sensors = nil;
    }
    [super didReceiveMemoryWarning];
}

- (void)registerForNotifications {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(refreshSensors) name:SENSensorsUpdatedNotification object:nil];
    [center addObserver:self selector:@selector(refreshSensors) name:SENAPIReachableNotification object:nil];
    [center addObserver:self
               selector:@selector(failedToRefreshSensors)
                   name:SENSensorUpdateFailedNotification
                 object:nil];
    [center addObserver:self
               selector:@selector(restartRefreshTimers)
                   name:SENAuthorizationServiceDidAuthorizeNotification
                 object:nil];
    [center addObserver:self
               selector:@selector(handleSignOut)
                   name:SENAuthorizationServiceDidDeauthorizeNotification
                 object:nil];
    [center addObserver:self
               selector:@selector(tempFormatDidChange)
                   name:SENLocalPrefDidChangeNotification
                 object:[SENPreference nameFromType:SENPreferenceTypeTempCelcius]];
}

- (void)tempFormatDidChange {
    if ([self isViewLoaded] && self.view.window) {
        [self reloadData];
    } else { self.shouldReload = YES; }
}

- (void)handleSignOut {
    [self invalidateTimers];
    self.sensors = nil;
    self.shouldReload = YES;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_collectionView setDelegate:nil];
    [_collectionView setDataSource:nil];
}

#pragma mark - Snazz Events

- (void)snazzViewDidAppear {
    [self showTutorialIfSelectedWithData];
}

#pragma mark - Tutorial

- (void)showTutorialIfSelectedWithData {
    HEMRootViewController* rootVC = [HEMRootViewController rootViewControllerForKeyWindow];
    HEMSnazzBarController* snazzVC = [rootVC barController];
    if ([[snazzVC selectedViewController] isEqual:self.parentViewController]
        && self.sensors.count > 0
        && self.isViewLoaded
        && self.view.window) {
            [HEMTutorial showTutorialForSensorsIfNeeded];
    }
}

#pragma mark - Data Loading

- (void)refreshCachedSensors {
    if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive) {
        [self setLoading:YES];
        [SENSensor refreshCachedSensors];
    }
}

- (void)refreshSensors {
    if (![SENAuthorizationService isAuthorized])
        return;
    self.noSense = NO;
    SENServiceDevice *service = [SENServiceDevice sharedService];
    if ([service isInfoLoaded]) {
        [self checkDeviceInfoForSenseAndRefresh];
    } else {
        [service loadDeviceInfo:^(NSError *error) {
          if (error) {
              self.noSense = NO;
              self.loading = NO;
              [self.collectionView reloadData];
          } else { [self checkDeviceInfoForSenseAndRefresh]; }
        }];
    }
}

- (void)checkDeviceInfoForSenseAndRefresh {
    SENServiceDevice *service = [SENServiceDevice sharedService];
    self.noSense = ![[service devices] hasPairedSense];
    if ([self hasNoSense]) {
        self.loading = NO;
        self.sensors = nil;
        [self.collectionView reloadData];
    } else {
        [self updateSensorsFromCache];
    }
}

- (void)updateSensorsFromCache {
    DDLogVerbose(@"Refreshing sensor data (rate: %f)", self.refreshRate);
    NSArray *cachedSensors = [self sortedCachedSensors];
    if (![self.sensors isEqualToArray:cachedSensors]) {
        self.sensors = cachedSensors;
        [self.collectionView reloadData];
        [self showTutorialIfSelectedWithData];
    }
    self.lastRefreshDate = [NSDate date];
    [self updateSensorRefreshInterval];
    [self fetchGraphData];
    [self setLoading:NO];
}

- (void)updateSensorRefreshInterval {
    NSMutableArray *values = [[self.sensors valueForKey:NSStringFromSelector(@selector(value))] mutableCopy];
    [values removeObject:[NSNull null]];
    if (values.count == 0)
        [self configureFailureRefreshTimer];
    else
        [self configureRefreshTimer];
}

- (NSArray *)sortedCachedSensors {
    return [[SENSensor sensors] sortedArrayUsingComparator:^NSComparisonResult(SENSensor *obj1, SENSensor *obj2) {
      return [@([self indexForSensor:obj1]) compare:@([self indexForSensor:obj2])];
    }];
}

- (NSUInteger)indexForSensor:(SENSensor *)sensor {
    switch (sensor.unit) {
        case SENSensorUnitDegreeCentigrade:
            return 0;
        case SENSensorUnitPercent:
            return 1;
        case SENSensorUnitAQI:
            return 2;
        case SENSensorUnitLux:
            return 3;
        case SENSensorUnitDecibel:
            return 4;
        case SENSensorUnitUnknown:
        default:
            return 5;
    }
}

- (void)fetchGraphData {
    __weak typeof(self) weakSelf = self;
    [SENAPIRoom historicalConditionsForLast24HoursWithCompletion:^(NSDictionary *data, NSError *error) {
      __strong typeof(weakSelf) strongSelf = weakSelf;
      if (error) {
          strongSelf.sensorGraphData = [[NSMutableDictionary alloc] init];
          [strongSelf reloadData];
      } else {
          __block NSMutableDictionary *graphData = [[NSMutableDictionary alloc] initWithCapacity:data.count];
          [data enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSArray *points, BOOL *stop) {
            [graphData setValue:[strongSelf filteredPointsFromData:points] forKey:key];
          }];
          if (![graphData isEqual:strongSelf.sensorGraphData]) {
              strongSelf.sensorGraphData = graphData;
              [strongSelf reloadData];
          }
      }
    }];
}

- (NSArray *)filteredPointsFromData:(NSArray *)data {
    if (data.count > HEMConditionGraphPointLimit) {
        NSRange range = NSMakeRange(data.count - HEMConditionGraphPointLimit, HEMConditionGraphPointLimit);
        NSArray *filteredData = [data subarrayWithRange:range];
        SENSensorDataPoint *point = [data lastObject];
        if ([point.value floatValue] == 0) {
            range.length -= 1;
            filteredData = [data subarrayWithRange:range];
        }
        return filteredData;
    }
    return data;
}

- (void)failedToRefreshSensors {
    [self setLoading:NO];
    [self.collectionView reloadData];
}

- (void)reloadData {
    [self.collectionView reloadData];
}

#pragma mark Refresh Timer

- (void)configureRefreshTimer {
    self.refreshRate = HEMCurrentConditionsRefreshIntervalInSeconds;
    [self updateTimer];
}

- (void)configureFailureRefreshTimer {
    self.refreshRate = MIN(HEMCurrentConditionsRefreshIntervalInSeconds, self.refreshRate * 2);
    [self updateTimer];
}

- (void)updateTimer {
    [self invalidateTimers];
    self.refreshTimer = [NSTimer scheduledTimerWithTimeInterval:self.refreshRate
                                                         target:self
                                                       selector:@selector(refreshCachedSensors)
                                                       userInfo:nil
                                                        repeats:YES];
}

- (void)restartRefreshTimers {
    self.refreshRate = HEMCurrentConditionsFailureIntervalInSeconds;
    [self refreshCachedSensors];
}

- (void)invalidateTimers {
    [self.refreshTimer invalidate];
}

#pragma mark - Pairing Sense

- (IBAction)pairSense:(id)sender {
    HEMSensePairViewController *pairVC
        = (HEMSensePairViewController *)[HEMOnboardingStoryboard instantiateSensePairViewController];
    [pairVC setDelegate:self];
    UINavigationController *nav = [[HEMStyledNavigationViewController alloc] initWithRootViewController:pairVC];
    [self presentViewController:nav animated:YES completion:nil];
}

#pragma mark HEMSensePairDelegate

- (void)didPairSenseUsing:(SENSenseManager *)senseManager from:(UIViewController *)controller {
    [self refreshSensors];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didSetupWiFiForPairedSense:(SENSenseManager *)senseManager from:(UIViewController *)controller {
    [self refreshSensors];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UICollectionView

- (void)configureCollectionView {
    self.collectionView.backgroundColor = [UIColor clearColor];
    UICollectionViewFlowLayout *layout = (id)self.collectionView.collectionViewLayout;
    layout.minimumInteritemSpacing = HEMCurrentConditionsItemSpacing;
    layout.minimumLineSpacing = HEMCurrentConditionsItemSpacing;
    CGSize size = layout.itemSize;
    size.height = HEMCurrentConditionsSensorViewHeight;
    layout.itemSize = size;
}

- (void)updateCellAtIndex:(NSUInteger)index {
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
    HEMSensorGraphCollectionViewCell *cell = (id)[self.collectionView cellForItemAtIndexPath:indexPath];
    [self configureSensorCell:cell forItemAtIndexPath:indexPath];
}

- (void)openDetailViewForSensor:(SENSensor *)sensor {
    HEMSensorViewController *controller = [HEMMainStoryboard instantiateSensorViewController];
    controller.sensor = sensor;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)openDetailViewForSensorNamed:(NSString *)name {
    for (SENSensor *sensor in self.sensors) {
        if ([sensor.name isEqualToString:name]) {
            [self openDetailViewForSensor:sensor];
            return;
        }
    }
}

#pragma mark UICollectionViewDatasource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.sensors.count > 0 ? self.sensors.count : 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([self hasNoSense]) {
        NSString *identifier = [HEMMainStoryboard pairReuseIdentifier];
        HEMSenseRequiredCollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier
                                                                                             forIndexPath:indexPath];
        [[cell descriptionLabel] setText:NSLocalizedString(@"sensor.no-sense.message", nil)];
        [[cell pairSenseButton] addTarget:self action:@selector(pairSense:) forControlEvents:UIControlEventTouchUpInside];
        [[cell pairSenseButton] setTitle:[NSLocalizedString(@"sensor.no-sense.button.title", nil) uppercaseString]
                                forState:UIControlStateNormal];
        return cell;
    } else if (self.sensors.count <= indexPath.row){
        NSString* identifier = [HEMMainStoryboard errorReuseIdentifier];
        HEMTextCollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
        [self configureNoSensorsCell:cell];
        return cell;
    } else {
        NSString *identifier = [HEMMainStoryboard sensorGraphCellReuseIdentifier];
        HEMSensorGraphCollectionViewCell *cell =
            [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
        [self configureSensorCell:cell forItemAtIndexPath:indexPath];
        return cell;
    }
}

- (void)configureSensorCell:(HEMSensorGraphCollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    SENSensor *sensor = self.sensors[indexPath.row];
    cell.sensorValueLabel.attributedText = [self valueTextForSensor:sensor];
    cell.sensorValueLabel.textColor = [UIColor colorForCondition:sensor.condition];
    cell.sensorValueLabel.hidden = NO;
    if (sensor.message.length > 0) {
        cell.sensorMessageLabel.hidden = NO;
        cell.separatorView.hidden = NO;
        [cell setMessageText:sensor.message];
    } else {
        cell.sensorMessageLabel.hidden = YES;
        cell.separatorView.hidden = YES;
    }
    cell.graphView.hidden = NO;
    [cell setGraphData:self.sensorGraphData[sensor.name] sensor:sensor];
    cell.statusLabel.hidden = YES;
}

- (NSAttributedString *)valueTextForSensor:(SENSensor *)sensor {
    NSDictionary *baseAttributes = @{ NSFontAttributeName : [UIFont sensorListValueFontForUnit:sensor.unit] };
    NSString *valueText = [self.sensorValueFormatter stringFromSensor:sensor];
    NSMutableAttributedString *composite =
        [[NSMutableAttributedString alloc] initWithString:valueText attributes:baseAttributes];
    
    if (sensor.value) {
        NSAttributedString* unitText = [self unitTextForSensor:sensor];
        if (unitText) {
            [composite appendAttributedString:unitText];
        }
    }

    return composite;
}

- (NSAttributedString*)unitTextForSensor:(SENSensor *)sensor {
    // the particulates unit is too large to fit so it has been decided to not
    // show the unit here.  The solution, for later, is to redesign the view to
    // accommodate for this
    if (sensor.unit == SENSensorUnitAQI) {
        return nil;
    }
    
    NSInteger unitVerticalOffset = 14;
    if (sensor.unit == SENSensorUnitDegreeCentigrade) {
        unitVerticalOffset = 12;
    }
    NSDictionary *unitAttributes = @{NSFontAttributeName : [UIFont sensorListUnitFontForUnit:sensor.unit],
                                     NSBaselineOffsetAttributeName : @(unitVerticalOffset)};
    NSAttributedString *unit = [[NSAttributedString alloc] initWithString:sensor.localizedUnit
                                                               attributes:unitAttributes];
    return unit;
}

- (void)configureNoSensorsCell:(HEMTextCollectionViewCell *)cell {
    cell.textLabel.text = NSLocalizedString(@"sensor.data-unavailable", nil);
    cell.textLabel.font = [UIFont errorStateDescriptionFont];
    [cell displayAsACard:YES];
}

#pragma mark UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView
       willDisplayCell:(UICollectionViewCell *)cell
    forItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell isKindOfClass:[HEMSensorGraphCollectionViewCell class]]) {
        HEMSensorGraphCollectionViewCell *graphCell = (id)cell;
        [graphCell.sensorMessageLabel layoutIfNeeded];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.sensors.count > indexPath.row)
        [self openDetailViewForSensor:self.sensors[indexPath.item]];
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                    layout:(UICollectionViewLayout *)collectionViewLayout
    sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGSize defaultSize = ((UICollectionViewFlowLayout *)collectionViewLayout).itemSize;
    if ([self hasNoSense]) {
        return CGSizeMake(defaultSize.width, HEMCurrentConditionsPairViewHeight);
    } else if ([self.sensors count] == 0) {
        NSString* text = NSLocalizedString(@"sensor.data-unavailable", nil);
        CGFloat maxWidth = defaultSize.width - (HEMCurrentConditionsErrorTextHorzPadding * 2);
        UIFont* font = [UIFont errorStateDescriptionFont];
        CGFloat textHeight = [text heightBoundedByWidth:maxWidth usingFont:font];
        return CGSizeMake(maxWidth, textHeight + (HEMCurrentConditionsErrorTextVertPadding * 2));
    }
    return defaultSize;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [[self shadowView] updateVisibilityWithContentOffset:[scrollView contentOffset].y];
}

@end
