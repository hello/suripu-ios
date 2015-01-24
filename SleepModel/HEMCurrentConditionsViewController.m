
#import <SenseKit/SENAuthorizationService.h>
#import <SenseKit/Model.h>
#import <SenseKit/SENAPIRoom.h>
#import <BEMSimpleLineGraph/BEMSimpleLineGraphView.h>

#import "HEMCurrentConditionsViewController.h"
#import "HEMSensorViewController.h"
#import "HEMMainStoryboard.h"
#import "HelloStyleKit.h"
#import "HEMSensorGraphCollectionViewCell.h"
#import "HEMCardFlowLayout.h"
#import "UIColor+HEMStyle.h"
#import "UIFont+HEMStyle.h"

@interface HEMCurrentConditionsViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>
@property (nonatomic, strong) NSArray* sensors;
@property (nonatomic, assign, getter=isLoading) BOOL loading;
@property (nonatomic, strong) NSTimer* refreshTimer;
@property (nonatomic, strong) NSMutableDictionary* sensorGraphData;
@property (nonatomic) CGFloat refreshRate;
@property (nonatomic, weak) IBOutlet UICollectionView* collectionView;
@property (nonatomic) BOOL shouldReload;
@end

@implementation HEMCurrentConditionsViewController

static CGFloat const HEMCurrentConditionsRefreshIntervalInSeconds = 30.f;
static CGFloat const HEMCurrentConditionsFailureIntervalInSeconds = 1.f;
static CGFloat const HEMCurrentConditionsSensorViewHeight = 104.0f;

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        self.tabBarItem.title = NSLocalizedString(@"current-conditions.title", nil);
        self.tabBarItem.image = [HelloStyleKit sensorsBarIcon];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self configureCollectionView];
    self.loading = YES;
    self.refreshRate = HEMCurrentConditionsFailureIntervalInSeconds;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self registerForNotifications];
    [self configureRefreshTimer];
    if ([self shouldReload]) {
        [self reloadData];
        self.shouldReload = NO;
    } else if (self.sensors.count == 0) {
        [self refreshCachedSensors];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [self invalidateTimers];
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SENSensorsUpdatedNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SENSensorUpdateFailedNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SENAuthorizationServiceDidAuthorizeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SENAuthorizationServiceDidDeauthorizeNotification object:nil];
}

- (void)registerForNotifications
{
    NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
    [center addObserver:self
               selector:@selector(refreshSensors)
                   name:SENSensorsUpdatedNotification object:nil];
    [center addObserver:self
               selector:@selector(failedToRefreshSensors)
                   name:SENSensorUpdateFailedNotification
                 object:nil];
    [center addObserver:self
               selector:@selector(restartRefreshTimers)
                   name:SENAuthorizationServiceDidAuthorizeNotification
                 object:nil];
    [center addObserver:self
               selector:@selector(invalidateTimers)
                   name:SENAuthorizationServiceDidDeauthorizeNotification
                 object:nil];
    [center addObserver:self
               selector:@selector(tempFormatDidChange)
                   name:SENSettingsDidUpdateNotification
                 object:SENSettingsUpdateTypeTemp];
}

- (void)tempFormatDidChange
{
    if ([self isViewLoaded] && self.view.window) {
        [self reloadData];
    } else {
        self.shouldReload = YES;
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Data Loading

- (void)refreshCachedSensors
{
    [self setLoading:YES];
    [SENSensor refreshCachedSensors];
}

- (void)refreshSensors
{
    if (![SENAuthorizationService isAuthorized])
        return;
    DDLogVerbose(@"Refreshing sensor data (rate: %f)", self.refreshRate);
    self.sensorGraphData = [[NSMutableDictionary alloc] init];
    self.sensors = [[SENSensor sensors] sortedArrayUsingComparator:^NSComparisonResult(SENSensor* obj1, SENSensor* obj2) {
        return [@([self indexForSensor:obj1]) compare:@([self indexForSensor:obj2])];
    }];
    NSMutableArray* values = [[self.sensors valueForKey:NSStringFromSelector(@selector(value))] mutableCopy];
    [values removeObject:[NSNull null]];
    if (values.count == 0)
        [self configureFailureRefreshTimer];
    else
        [self configureRefreshTimer];
    [self fetchGraphData];
    [self setLoading:NO];
    [self.collectionView reloadData];
}

- (NSUInteger)indexForSensor:(SENSensor*)sensor
{
    switch (sensor.unit) {
        case SENSensorUnitDegreeCentigrade: return 0;
        case SENSensorUnitPercent: return 1;
        case SENSensorUnitAQI: return 2;
        case SENSensorUnitLux: return 3;
        case SENSensorUnitDecibel: return 4;
        case SENSensorUnitUnknown:
        default:
            return 5;
    }
}

- (void)fetchGraphData
{
    NSArray* sensors = [self.sensors copy];
    __weak typeof(self) weakSelf = self;
    SENAPIDataBlock (^completion)(SENSensor *, int) = ^SENAPIDataBlock(SENSensor *sensor, int index) {
        return ^(id data, NSError *error) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            [[strongSelf sensorGraphData] setValue:error?nil:data forKey:sensor.name];
            [strongSelf updateCellAtIndex:index];
        };
    };
    for (int i = 0; i < sensors.count; i++) {
        SENSensor* sensor = sensors[i];
        [SENAPIRoom hourlyHistoricalDataForSensor:sensor completion:completion(sensor, i)];
    }
}

- (void)failedToRefreshSensors
{
    [self setLoading:NO];
    [self.collectionView reloadData];
}

- (void)reloadData
{
    [self.collectionView reloadData];
}

#pragma mark Refresh Timer

- (void)configureRefreshTimer
{
    self.refreshRate = HEMCurrentConditionsRefreshIntervalInSeconds;
    [self updateTimer];
}

- (void)configureFailureRefreshTimer
{
    self.refreshRate = MIN(HEMCurrentConditionsRefreshIntervalInSeconds, self.refreshRate * 2);
    [self updateTimer];
}

- (void)updateTimer
{
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

- (void)invalidateTimers
{
    [self.refreshTimer invalidate];
}

#pragma mark - UICollectionView


- (void)configureCollectionView
{
    self.collectionView.backgroundColor = [UIColor clearColor];
    HEMCardFlowLayout* layout = (id)self.collectionView.collectionViewLayout;
    [layout setItemHeight:HEMCurrentConditionsSensorViewHeight];
}

- (void)updateCellAtIndex:(NSUInteger)index
{
    NSIndexPath* indexPath = [NSIndexPath indexPathForItem:index inSection:0];
    HEMSensorGraphCollectionViewCell* cell = (id)[self.collectionView cellForItemAtIndexPath:indexPath];
    [self configureSensorCell:cell forItemAtIndexPath:indexPath];
}

- (void)openDetailViewForSensor:(SENSensor*)sensor {
    HEMSensorViewController* controller = [HEMMainStoryboard instantiateSensorViewController];
    controller.sensor = sensor;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)openDetailViewForSensorNamed:(NSString *)name {
    for (SENSensor* sensor in self.sensors) {
        if ([sensor.name isEqualToString:name]) {
            [self openDetailViewForSensor:sensor];
            return;
        }
    }
}

#pragma mark UICollectionViewDatasource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.sensors.count > 0 ? self.sensors.count : 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString* identifier = [HEMMainStoryboard sensorGraphCellReuseIdentifier];
    HEMSensorGraphCollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier
                                                                                       forIndexPath:indexPath];

    if (self.sensors.count > indexPath.row) {
        [self configureSensorCell:cell forItemAtIndexPath:indexPath];
    } else {
        [self configureNoSensorsCell:cell];
    }
    return cell;
}


- (void)configureSensorCell:(HEMSensorGraphCollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    SENSensor* sensor = self.sensors[indexPath.row];
    cell.sensorValueLabel.text = sensor.localizedValue;
    cell.sensorValueLabel.textColor = [UIColor colorForSensorWithCondition:sensor.condition];
    cell.sensorValueLabel.hidden = NO;
    if (sensor.message.length > 0) {
        cell.sensorMessageLabel.hidden = NO;
        cell.separatorView.hidden = NO;
        [cell setMessageText:sensor.message];
    } else {
        cell.sensorMessageLabel.hidden = YES;
        cell.separatorView.hidden = YES;
    }
    [cell setGraphData:self.sensorGraphData[sensor.name] sensor:sensor];
    cell.statusLabel.hidden = YES;
}

- (void)configureNoSensorsCell:(HEMSensorGraphCollectionViewCell *)cell
{
    cell.statusLabel.text = [self isLoading]
        ? NSLocalizedString(@"activity.loading", nil)
        : NSLocalizedString(@"sensor.data-unavailable", nil);
    cell.statusLabel.hidden = NO;
    cell.sensorValueLabel.hidden = YES;
    cell.sensorMessageLabel.hidden = YES;
    cell.separatorView.hidden = YES;
}

#pragma mark UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView
       willDisplayCell:(UICollectionViewCell *)cell
    forItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell isKindOfClass:[HEMSensorGraphCollectionViewCell class]]) {
        HEMSensorGraphCollectionViewCell* graphCell = (id)cell;
        [graphCell.sensorMessageLabel layoutIfNeeded];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.sensors.count > indexPath.row)
        [self openDetailViewForSensor:self.sensors[indexPath.item]];
}

@end
