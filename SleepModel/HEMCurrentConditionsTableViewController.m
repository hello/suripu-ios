#import <SenseKit/SENAlarm.h>
#import <SenseKit/SENBackgroundNoise.h>
#import <SenseKit/SENAuthorizationService.h>
#import <SenseKit/SENSensor.h>
#import <SenseKit/SENAPIRoom.h>

#import <markdown_peg.h>

#import "UIFont+HEMStyle.h"

#import "HEMCurrentConditionsTableViewController.h"
#import "HEMAlarmViewController.h"
#import "HEMInsetGlyphTableViewCell.h"
#import "HEMSensorViewController.h"
#import "HEMMainStoryboard.h"
#import "HEMColorUtils.h"
#import "HelloStyleKit.h"
#import "HEMPagingFlowLayout.h"
#import "HEMInsightCollectionViewCell.h"
#import "HEMInsightsSummaryDataSource.h"

NSString* const HEMCurrentConditionsCellIdentifier = @"currentConditionsCell";
static CGFloat const kHEMCurrentConditionsInsightsViewHeight = 112.0f;
static CGFloat const kHEMCurrentConditionsInsightsMargin = 12.0f;
static CGFloat const kHEMCurrentConditionsInsightsSpacing= 5.0f;

@interface HEMCurrentConditionsTableViewController () <UITableViewDataSource, UITableViewDelegate, UICollectionViewDelegateFlowLayout>
@property (nonatomic, strong) IBOutlet UITableView* tableView;
@property (nonatomic, strong) NSArray* sensors;
@property (nonatomic, assign, getter=isLoading) BOOL loading;
@property (nonatomic, strong) NSTimer* refreshTimer;
@property (nonatomic) CGFloat refreshRate;
@property (nonatomic, strong) HEMInsightsSummaryDataSource* insightsDataSource;
@property (nonatomic, strong) UICollectionView* insightsView;
@end

@implementation HEMCurrentConditionsTableViewController

static CGFloat const HEMCurrentConditionsRefreshIntervalInSeconds = 30.f;
static CGFloat const HEMCurrentConditionsFailureIntervalInSeconds = 1.f;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"current-conditions.title", nil);
    
    [[self tableView] setTableFooterView:[[UIView alloc] init]];
    [self configureInsightsView];
    [self refreshCachedSensors];
    self.refreshRate = HEMCurrentConditionsFailureIntervalInSeconds;
}

- (void)configureInsightsView {
    HEMPagingFlowLayout* layout = [[HEMPagingFlowLayout alloc] init];
    [layout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    [layout setSectionInset:UIEdgeInsetsMake(0.0f,
                                             kHEMCurrentConditionsInsightsMargin,
                                             0.0f,
                                             kHEMCurrentConditionsInsightsMargin)];
    [layout setMinimumLineSpacing:kHEMCurrentConditionsInsightsSpacing];
    
    CGRect collectionFrame = CGRectZero;
    collectionFrame.size.width = CGRectGetWidth([[self tableView] bounds]);
    collectionFrame.size.height = kHEMCurrentConditionsInsightsViewHeight;
    
    UICollectionView* collectView = [[UICollectionView alloc] initWithFrame:collectionFrame
                                                       collectionViewLayout:layout];
    [collectView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [collectView setTranslatesAutoresizingMaskIntoConstraints:YES];
    [collectView setBackgroundColor:[[self tableView] backgroundColor]];
    [collectView setDelegate:self];
    [collectView setShowsHorizontalScrollIndicator:NO];
    
    [self setInsightsDataSource:[[HEMInsightsSummaryDataSource alloc] initWithCollectionView:collectView]];
    [collectView setDataSource:[self insightsDataSource]];
    [collectView setDelegate:self];
    
    [self setInsightsView:collectView];
    [[self tableView] setTableHeaderView:collectView];
}

- (IBAction)dismissCurrentConditionsController:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // the below should reside in viewDidAppear rather than willAppear because
    // if you drag the view back will call viewWillAppear, which consequently
    // causes a relatively huge delay before anything actually moves
    [self refreshSensors];
    
    __weak typeof(self) weakSelf = self;
    [[self insightsDataSource] refreshInsights:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            [[strongSelf insightsView] reloadData];
        }
    }];
    [self setLoading:YES];
    
    NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
    [center addObserver:self
               selector:@selector(refreshSensors)
                   name:SENSensorsUpdatedNotification object:nil];
    [center addObserver:self
               selector:@selector(failedToRefreshSensors)
                   name:SENSensorUpdateFailedNotification
                 object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [self.refreshTimer invalidate];
    [super viewDidDisappear:animated];
}

- (void)failedToRefreshSensors {
    [self setLoading:NO];
    [self.tableView reloadData];
}

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

- (void)refreshCachedSensors {
    [SENSensor refreshCachedSensors];
}

- (void)refreshSensors {
    if (![SENAuthorizationService isAuthorized])
        return;
    DDLogVerbose(@"Refreshing sensor data (rate: %f)", self.refreshRate);
    self.sensors = [[SENSensor sensors] sortedArrayUsingComparator:^NSComparisonResult(SENSensor* obj1, SENSensor* obj2) {
        return [obj1.name compare:obj2.name];
    }];
    NSMutableArray* values = [[self.sensors valueForKey:NSStringFromSelector(@selector(value))] mutableCopy];
    [values removeObject:[NSNull null]];
    if (values.count == 0)
        [self configureFailureRefreshTimer];
    else
        [self configureRefreshTimer];
    
    [self setLoading:NO];
    [self.tableView reloadData];
}

- (void)colorizeSensorTextIn:(UILabel*)label forCondition:(SENSensorCondition)condition {
    UIColor* textColor = nil;
    switch (condition) {
        case SENSensorConditionAlert:
            textColor = [HelloStyleKit alertSensorColor];
            break;
        case SENSensorConditionWarning:
            textColor = [HelloStyleKit warningSensorColor];
            break;
        case SENSensorConditionIdeal:
            textColor = [HelloStyleKit idealSensorColor];
            break;
        default:
            textColor = [HelloStyleKit backViewTextColor];
            break;
    }
    [label setTextColor:textColor];
}

- (void)dealloc
{
    [_refreshTimer invalidate];
}

#pragma mark - UICollectionViewDelegate

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat itemWidth
        = CGRectGetWidth([collectionView bounds])
        - (2*kHEMCurrentConditionsInsightsMargin);
    return CGSizeMake(itemWidth, kHEMCurrentConditionsInsightsViewHeight);
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView
{
    return 3; // empty section below
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView* headerView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 20.0f)];
    [headerView setBackgroundColor:[UIColor clearColor]];
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 20.0f;
}

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
    case 0:
        return self.sensors.count == 0 ? 1 : self.sensors.count;

    case 1:
        return 2;

    default:
        return 0;
    }
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    UITableViewCell* cell = nil;

    switch (indexPath.section) {
    case 0:
        cell = [self tableView:tableView sensorCellForRowAtIndexPath:indexPath];
        break;

    case 1:
        cell = [self tableView:tableView menuCellForRowAtIndexPath:indexPath];
        break;
    }

    return cell;
}

- (UITableViewCell*)tableView:(UITableView*)tableView sensorCellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    HEMInsetGlyphTableViewCell* cell = (HEMInsetGlyphTableViewCell*)[tableView dequeueReusableCellWithIdentifier:HEMCurrentConditionsCellIdentifier forIndexPath:indexPath];

    if (self.sensors.count <= indexPath.row) {
        cell.titleLabel.text = [self isLoading] ? NSLocalizedString(@"activity.loading", nil) : NSLocalizedString(@"sensor.data-unavailable", nil);
        cell.detailLabel.text = nil;
        cell.glyphImageView.image = nil;
        [cell showDetailBubble:NO];
        [cell setAccessoryType:UITableViewCellAccessoryNone];
    } else {
        SENSensor* sensor = self.sensors[indexPath.row];
        cell.titleLabel.text = sensor.localizedName;
        cell.detailLabel.text = sensor.localizedValue ?: NSLocalizedString(@"empty-data", nil);

        [cell showDetailBubble:YES];
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        
        [self colorizeSensorTextIn:cell.detailLabel forCondition:sensor.condition];
        
        switch (sensor.unit) {
        case SENSensorUnitDegreeCentigrade:
            cell.glyphImageView.image = [HelloStyleKit temperatureIcon];
            cell.detailLabel.text = sensor.localizedValue ?: NSLocalizedString(@"empty-data", nil);
            break;
        case SENSensorUnitMicrogramPerCubicMeter:
            cell.glyphImageView.image = [HelloStyleKit particleIcon];
            cell.detailLabel.text = sensor.value ? [NSString stringWithFormat:@"%.02f", [sensor.value doubleValue]] : NSLocalizedString(@"empty-data", nil);
            break;
        case SENSensorUnitPercent:
            cell.glyphImageView.image = [HelloStyleKit humidityIcon];
            cell.detailLabel.text = sensor.localizedValue ?: NSLocalizedString(@"empty-data", nil);
            break;
        case SENSensorUnitUnknown:
        default:
            cell.glyphImageView.image = nil;
            break;
        }
    }

    return cell;
}

- (UITableViewCell*)tableView:(UITableView*)tableView menuCellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    HEMInsetGlyphTableViewCell* cell = (HEMInsetGlyphTableViewCell*)[tableView dequeueReusableCellWithIdentifier:HEMCurrentConditionsCellIdentifier forIndexPath:indexPath];
    cell.detailLabel.text = nil;
    cell.detailLabel.textColor = [HelloStyleKit backViewTextColor];
    
    [cell showDetailBubble:NO];
    
    switch (indexPath.row) {
    case 0: {
        cell.titleLabel.text = NSLocalizedString(@"alarms.title", nil);
        cell.detailLabel.text = nil;
        cell.glyphImageView.image = [HelloStyleKit alarmsIcon];
    } break;

    case 1: {
        cell.titleLabel.text = NSLocalizedString(@"sleep.trends.title", nil);
        cell.detailLabel.text = nil;
        cell.glyphImageView.image = [HelloStyleKit sleepInsightsIcon];
    } break;
    }
    return cell;
}

#pragma mark - UITableViewDelegate

- (BOOL)tableView:(UITableView*)tableView shouldHighlightRowAtIndexPath:(NSIndexPath*)indexPath
{
    return !(indexPath.section == 0 && self.sensors.count == 0);
}

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    switch (indexPath.section) {
    case 0: {
        if (self.sensors.count > indexPath.row) {
            HEMSensorViewController* controller = (HEMSensorViewController*)[storyboard instantiateViewControllerWithIdentifier:@"sensorViewController"];
            controller.sensor = self.sensors[indexPath.row];
            [self.navigationController pushViewController:controller animated:YES];
        }
    } break;

    case 1: {
        switch (indexPath.row) {
        case 0: {
            UIViewController* controller = [HEMMainStoryboard instantiateAlarmListViewController];
            [self.navigationController pushViewController:controller animated:YES];
        } break;

        case 1: {
            // TODO (jimmy): sleep insights not yet implemented, I think!
        } break;
        }
    } break;
    }
}

@end
