#import <SenseKit/SENAlarm.h>
#import <SenseKit/SENBackgroundNoise.h>
#import <SenseKit/SENAuthorizationService.h>
#import <SenseKit/SENSensor.h>
#import <SenseKit/SENAPIRoom.h>
#import <SenseKit/SENInsight.h>

#import <markdown_peg.h>

#import "HEMCurrentConditionsTableViewController.h"
#import "HEMSensorViewController.h"
#import "HEMMainStoryboard.h"
#import "HelloStyleKit.h"
#import "HEMPagingFlowLayout.h"
#import "HEMInsightCollectionViewCell.h"
#import "HEMOnboardingStoryboard.h"
#import "UIColor+HEMStyle.h"
#import "UIFont+HEMStyle.h"

NSString* const HEMCurrentConditionsCellIdentifier = @"currentConditionsCell";

@interface HEMCurrentConditionsTableViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>
@property (nonatomic, strong) NSArray* sensors;
@property (nonatomic, assign, getter=isLoading) BOOL loading;
@property (nonatomic, strong) NSTimer* refreshTimer;
@property (nonatomic) CGFloat refreshRate;
@property (nonatomic, weak) IBOutlet UICollectionView* collectionView;
@end

@implementation HEMCurrentConditionsTableViewController

static CGFloat const HEMCurrentConditionsRefreshIntervalInSeconds = 30.f;
static CGFloat const HEMCurrentConditionsFailureIntervalInSeconds = 1.f;
static CGFloat const HEMCurrentConditionsSensorViewHeight = 112.0f;
static CGFloat const HEMCurrentConditionsSensorViewMargin = 16.0f;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tabBarItem.title = NSLocalizedString(@"current-conditions.title", nil);
    self.refreshRate = HEMCurrentConditionsFailureIntervalInSeconds;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self registerForNotifications];
    [self refreshCachedSensors];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [self.refreshTimer invalidate];
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)dealloc
{
    [_refreshTimer invalidate];
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
}

#pragma mark - Data Loading

- (void)refreshCachedSensors {
    [self setLoading:YES];
    [SENSensor refreshCachedSensors];
}

- (void)refreshSensors {
    if (![SENAuthorizationService isAuthorized])
        return;
    DDLogVerbose(@"Refreshing sensor data (rate: %f)", self.refreshRate);
    self.sensors = [[SENSensor sensors] sortedArrayUsingComparator:^NSComparisonResult(SENSensor* obj1, SENSensor* obj2) {
        return [obj2.localizedName compare:obj1.localizedName];
    }];
    NSMutableArray* values = [[self.sensors valueForKey:NSStringFromSelector(@selector(value))] mutableCopy];
    [values removeObject:[NSNull null]];
    if (values.count == 0)
        [self configureFailureRefreshTimer];
    else
        [self configureRefreshTimer];

    [self setLoading:NO];
    [self.collectionView reloadData];
}

- (void)failedToRefreshSensors {
    [self setLoading:NO];
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
    [self.refreshTimer invalidate];
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

#pragma mark - UICollectionViewDatasource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 5;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString* identifier = [HEMMainStoryboard sensorGraphCellReuseIdentifier];
    UICollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier
                                                                           forIndexPath:indexPath];

    return cell;
}

#pragma mark - UICollectionViewDelegate

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat itemWidth = CGRectGetWidth([collectionView bounds]) - (2*HEMCurrentConditionsSensorViewMargin);
    return CGSizeMake(itemWidth, HEMCurrentConditionsSensorViewHeight);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.sensors.count > indexPath.row)
        [self openDetailViewForSensor:self.sensors[indexPath.item]];
}

- (void)openDetailViewForSensor:(SENSensor*)sensor {
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    HEMSensorViewController* controller = (HEMSensorViewController*)[storyboard instantiateViewControllerWithIdentifier:@"sensorViewController"];
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

@end
