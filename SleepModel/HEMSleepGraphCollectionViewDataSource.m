
#import <SenseKit/SENSettings.h>
#import <SenseKit/SENSensor.h>
#import <SenseKit/SENSleepResult.h>
#import <JBChartView/JBLineChartView.h>

#import "HEMSleepGraphCollectionViewDataSource.h"
#import "HEMSleepGraphCollectionViewController.h"
#import "HEMAggregateGraphCollectionViewCell.h"
#import "HEMSleepSummaryCollectionViewCell.h"
#import "HEMSleepEventCollectionViewCell.h"
#import "HEMSleepSegmentCollectionViewCell.h"
#import "HEMSensorDataHeaderView.h"
#import "HEMFakeDataGenerator.h"
#import "HEMSensorGraphDataSource.h"
#import "HelloStyleKit.h"
#import "HEMColorUtils.h"

@interface HEMSleepGraphCollectionViewDataSource ()

@property (nonatomic, weak) UICollectionView* collectionView;
@property (nonatomic, weak, readwrite) HEMSensorDataHeaderView* sensorDataHeaderView;
@property (nonatomic, strong) NSDateFormatter* timeDateFormatter;
@property (nonatomic, strong) NSDateFormatter* rangeDateFormatter;
@property (nonatomic, strong) NSMutableArray* expandedIndexPaths;
@property (nonatomic, strong) NSDate* dateForNightOfSleep;
@property (nonatomic, strong) SENSleepResult* sleepResult;
@property (nonatomic, strong) NSArray* aggregateDataSources;
@end

@implementation HEMSleepGraphCollectionViewDataSource

static NSString* const sleepSegmentReuseIdentifier = @"sleepSegmentCell";
static NSString* const sleepSummaryReuseIdentifier = @"sleepSummaryCell";
static NSString* const aggregateGraphReuseIdentifier = @"aggregateCell";
static NSString* const sleepEventReuseIdentifier = @"sleepEventCell";
static NSString* const sensorDataReuseIdentifier = @"sensorDataView";

+ (NSDateFormatter*)sleepDateFormatter
{
    static NSDateFormatter* formatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSDateFormatter alloc] init];
        formatter.dateStyle = NSDateFormatterShortStyle;
    });
    return formatter;
}

- (instancetype)initWithCollectionView:(UICollectionView*)collectionView sleepDate:(NSDate*)date
{
    if (self = [super init]) {
        _collectionView = collectionView;
        _dateForNightOfSleep = date;
        _expandedIndexPaths = [NSMutableArray new];
        _timeDateFormatter = [NSDateFormatter new];
        _timeDateFormatter.dateFormat = ([SENSettings timeFormat] == SENTimeFormat12Hour) ? @"h:mm a" : @"H:mm";
        _rangeDateFormatter = [NSDateFormatter new];
        _rangeDateFormatter.dateFormat = @"MMM dd";
        [self configureCollectionView];
        [self updateDataForDate];
    }
    return self;
}

- (void)updateDataForDate
{
    self.sleepResult = [SENSleepResult sleepResultForDate:self.dateForNightOfSleep];
    [self.sleepResult updateWithDictionary:[HEMFakeDataGenerator sleepDataForDate:self.dateForNightOfSleep]];
    [self fetchAggregateData];
    // todo: update data with latest from API
    [self.collectionView reloadData];
}

- (void)configureCollectionView
{
    NSBundle* bundle = [NSBundle mainBundle];
    [self.collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([HEMSensorDataHeaderView class]) bundle:bundle]
          forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                 withReuseIdentifier:sensorDataReuseIdentifier];
    [self.collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([HEMSleepSegmentCollectionViewCell class]) bundle:bundle]
          forCellWithReuseIdentifier:sleepSegmentReuseIdentifier];
    [self.collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([HEMSleepSummaryCollectionViewCell class]) bundle:bundle]
          forCellWithReuseIdentifier:sleepSummaryReuseIdentifier];
    [self.collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([HEMSleepEventCollectionViewCell class]) bundle:bundle]
          forCellWithReuseIdentifier:sleepEventReuseIdentifier];
    [self.collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([HEMAggregateGraphCollectionViewCell class]) bundle:bundle]
          forCellWithReuseIdentifier:aggregateGraphReuseIdentifier];
}

- (void)fetchAggregateData
{
    NSMutableArray* agData = [[NSMutableArray alloc] initWithCapacity:3];
    for (int i = 0; i < 3; i++) {
        NSMutableArray* weekAgData = [[NSMutableArray alloc] initWithCapacity:7];
        for (int j = 0; j < 7; j++) {
            NSTimeInterval interval = -(60 * 60 * 24 * 7 * i) - (60 * 60 * 24 * j);
            NSDate* date = [NSDate dateWithTimeInterval:interval sinceDate:self.dateForNightOfSleep];
            SENSleepResult* result = [SENSleepResult sleepResultForDate:date];
            NSDictionary* fakeData = [HEMFakeDataGenerator sleepDataForDate:date];
            while (!fakeData) {
                fakeData = [HEMFakeDataGenerator sleepDataForDate:date];
            }
            [result updateWithDictionary:fakeData];
            [weekAgData addObject:@{ @"value" : [NSString stringWithFormat:@"%0.f", [result.score floatValue]],
                                     @"label" : @"",
                                     @"date" : date }];
        }
        HEMSensorGraphDataSource* dataSource = [[HEMSensorGraphDataSource alloc] initWithDataSeries:[[weekAgData reverseObjectEnumerator] allObjects]];
        [agData addObject:dataSource];
    }
    self.aggregateDataSources = agData;
}

#pragma mark - Event Cell Size Toggling

- (void)toggleExpansionOfEventCellAtIndexPath:(NSIndexPath*)indexPath
{
    if (indexPath.section == HEMSleepGraphCollectionViewSegmentSection) {
        if ([self eventCellAtIndexPathIsExpanded:indexPath]) {
            [self.expandedIndexPaths removeObject:indexPath];
        } else {
            [self.expandedIndexPaths addObject:indexPath];
        }
        [self.collectionView reloadItemsAtIndexPaths:@[ indexPath ]];
    }
}

- (BOOL)eventCellAtIndexPathIsExpanded:(NSIndexPath*)indexPath
{
    return [self.expandedIndexPaths containsObject:indexPath];
}

#pragma mark - Sensor Header View

- (void)updateSensorViewText
{
    CGFloat contentOffsetY = self.collectionView.contentOffset.y;
    if (contentOffsetY > CGRectGetMidY(self.sensorDataHeaderView.timeLabel.bounds)) {
        contentOffsetY += CGRectGetHeight(self.sensorDataHeaderView.bounds);
    }
    for (UICollectionViewCell* cell in self.collectionView.visibleCells) {
        if (CGRectGetMinY(cell.frame) <= contentOffsetY && CGRectGetMaxY(cell.frame) >= contentOffsetY) {
            NSIndexPath* indexPath = [self.collectionView indexPathForCell:cell];
            if (indexPath.section == HEMSleepGraphCollectionViewSegmentSection) {
                SENSleepResultSegment* segment = [self sleepSegmentForIndexPath:indexPath];
                CGFloat fill = contentOffsetY - CGRectGetMinY(cell.frame);
                CGFloat total = CGRectGetMaxY(cell.frame) - CGRectGetMinY(cell.frame);
                CGFloat ratio = fill / total;
                [self updateSensorViewTextWithSleepData:segment forCellFillRatio:ratio];
            }
        }
    }
}

/**
 *  Update the sensor data view with info from a given moment of sleep data
 *
 *  @param sleepData the data to use in the update
 *  @param ratio     the scale of time passed between the start and end of the data
 */
- (void)updateSensorViewTextWithSleepData:(SENSleepResultSegment*)segment forCellFillRatio:(CGFloat)ratio
{
    if (segment) {
        for (SENSleepResultSegmentSensor* sensor in segment.sensors) {
            NSString* text = [SENSensor formatValue:sensor.value withUnit:[SENSensor unitFromValue:sensor.unit]];
            if ([sensor.name isEqualToString:@"temperature"]) {
                self.sensorDataHeaderView.temperatureLabel.text = text;
            } else if ([sensor.name isEqualToString:@"humidity"]) {
                self.sensorDataHeaderView.humidityLabel.text = text;
            } else if ([sensor.name isEqualToString:@"particulates"]) {
                self.sensorDataHeaderView.particulateLabel.text = text;
            }
        }
        NSTimeInterval topInterval = [segment.date timeIntervalSince1970];
        NSTimeInterval bottomInterval = topInterval + ([segment.duration doubleValue] / 1000);
        NSTimeInterval intervalAtContentOffsetY = bottomInterval - (ratio * (bottomInterval - topInterval));
        self.sensorDataHeaderView.timeLabel.text = [self textForTimeInterval:intervalAtContentOffsetY];
    } else {
        self.sensorDataHeaderView.temperatureLabel.text = @"0";
        self.sensorDataHeaderView.humidityLabel.text = @"0";
        self.sensorDataHeaderView.particulateLabel.text = @"0";
        self.sensorDataHeaderView.timeLabel.text = @"";
    }
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView*)collectionView
{
    return 3;
}

- (NSInteger)collectionView:(UICollectionView*)collectionView numberOfItemsInSection:(NSInteger)section
{
    switch (section) {
    case HEMSleepGraphCollectionViewSummarySection:
        return 1;
    case HEMSleepGraphCollectionViewSegmentSection:
        return self.sleepResult.segments.count;
    case HEMSleepGraphCollectionViewHistorySection:
        return self.aggregateDataSources.count;
    default:
        return 0;
    }
}

- (UICollectionReusableView*)collectionView:(UICollectionView*)collectionView viewForSupplementaryElementOfKind:(NSString*)kind atIndexPath:(NSIndexPath*)indexPath
{
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        HEMSensorDataHeaderView* headerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:sensorDataReuseIdentifier forIndexPath:indexPath];
        if (indexPath.section == HEMSleepGraphCollectionViewSegmentSection) {
            headerView.hidden = self.sleepResult.segments.count == 0;
            self.sensorDataHeaderView = headerView;
            [self updateSensorViewTextWithSleepData:[self.sleepResult.segments firstObject] forCellFillRatio:0];
        } else {
            headerView.hidden = YES;
        }
        return headerView;
    }
    return [UICollectionReusableView new];
}

- (UICollectionViewCell*)collectionView:(UICollectionView*)collectionView cellForItemAtIndexPath:(NSIndexPath*)indexPath
{
    switch (indexPath.section) {
    case HEMSleepGraphCollectionViewSummarySection: {
        return [self collectionView:collectionView sleepSummaryCellForItemAtIndexPath:indexPath];
    } break;
    case HEMSleepGraphCollectionViewSegmentSection: {
        SENSleepResultSegment* segment = [self sleepSegmentForIndexPath:indexPath];
        if ([segment.eventType isEqualToString:@"none"]) {
            return [self collectionView:collectionView sleepSegmentCellForItemAtIndexPath:indexPath];
        } else {
            return [self collectionView:collectionView sleepEventCellForItemAtIndexPath:indexPath];
        }
    }
    case HEMSleepGraphCollectionViewHistorySection: {
        return [self collectionView:collectionView historyCellForItemAtIndexPath:indexPath];
    }
    default:
        return nil;
    }
}

- (UICollectionViewCell*)collectionView:(UICollectionView*)collectionView sleepSummaryCellForItemAtIndexPath:(NSIndexPath*)indexPath
{
    HEMSleepSummaryCollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:sleepSummaryReuseIdentifier forIndexPath:indexPath];
    [cell setSleepScore:[self.sleepResult.score integerValue]];
    cell.messageLabel.text = self.sleepResult.message;
    NSString* dateText = [[[self class] sleepDateFormatter] stringFromDate:self.dateForNightOfSleep];
    NSString* lastNightDateText = [[[self class] sleepDateFormatter] stringFromDate:[NSDate dateWithTimeInterval:-60 * 60 * 24 sinceDate:[NSDate date]]];
    if ([dateText isEqualToString:lastNightDateText]) {
        cell.dateLabel.text = NSLocalizedString(@"sleep-history.last-night", nil);
    } else {
        cell.dateLabel.text = dateText;
    }
    return cell;
}

- (UICollectionViewCell*)collectionView:(UICollectionView*)collectionView sleepSegmentCellForItemAtIndexPath:(NSIndexPath*)indexPath
{
    SENSleepResultSegment* segment = [self sleepSegmentForIndexPath:indexPath];
    NSUInteger sleepDepth = segment.sleepDepth;
    HEMSleepSegmentCollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:sleepSegmentReuseIdentifier forIndexPath:indexPath];
    [cell setSegmentRatio:sleepDepth / 3.f withColor:[HEMColorUtils colorForSleepDepth:sleepDepth]];
    return cell;
}

- (UICollectionViewCell*)collectionView:(UICollectionView*)collectionView sleepEventCellForItemAtIndexPath:(NSIndexPath*)indexPath
{
    SENSleepResultSegment* segment = [self sleepSegmentForIndexPath:indexPath];
    NSUInteger sleepDepth = segment.sleepDepth;
    HEMSleepEventCollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:sleepEventReuseIdentifier forIndexPath:indexPath];
    cell.eventTypeButton.layer.borderColor = [HEMColorUtils colorForSleepDepth:sleepDepth].CGColor;
    cell.eventTypeButton.layer.borderWidth = 2.f;
    cell.eventTypeButton.layer.cornerRadius = CGRectGetWidth(cell.eventTypeButton.bounds) / 2;
    cell.eventTimeLabel.text = [self textForTimeInterval:[segment.date timeIntervalSince1970]];
    [cell.eventTypeButton setImage:[self imageForEventType:segment.eventType] forState:UIControlStateNormal];
    cell.eventMessageLabel.text = segment.message;
    cell.eventTitleLabel.text = [self localizedNameForSleepEventType:segment.eventType];
    cell.expanded = [self eventCellAtIndexPathIsExpanded:indexPath];
    cell.playButton.hidden = ![segment.eventType isEqualToString:@"noise"];
    return cell;
}

- (UICollectionViewCell*)collectionView:(UICollectionView*)collectionView historyCellForItemAtIndexPath:(NSIndexPath*)indexPath
{
    HEMAggregateGraphCollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:aggregateGraphReuseIdentifier forIndexPath:indexPath];
    HEMSensorGraphDataSource* dataSource = self.aggregateDataSources[indexPath.row];
    cell.chartView.dataSource = dataSource;
    cell.chartView.sections = dataSource.dataSeries;
    NSArray* dates = [dataSource.dataSeries valueForKey:@"date"];
    cell.titleLabel.text = [NSString stringWithFormat:@"%@ - %@",
                                                      [self.rangeDateFormatter stringFromDate:[dates firstObject]],
                                                      [self.rangeDateFormatter stringFromDate:[dates lastObject]]];
    [cell.chartView reloadData];
    [cell.chartView setNeedsDisplay];
    return cell;
}

#pragma mark - Data Parsing

- (SENSleepResultSegment*)sleepSegmentForIndexPath:(NSIndexPath*)indexPath
{
    return indexPath.section == HEMSleepGraphCollectionViewSegmentSection ? self.sleepResult.segments[indexPath.row] : nil;
}

- (NSString*)localizedSleepDepth:(NSUInteger)sleepDepth
{
    switch (sleepDepth) {
    case 0:
        return NSLocalizedString(@"sleep-history.depth.awake", nil);
    case 1:
        return NSLocalizedString(@"sleep-history.depth.light", nil);
    case 2:
        return NSLocalizedString(@"sleep-history.depth.medium", nil);
    default:
        return NSLocalizedString(@"sleep-history.depth.deep", nil);
    }
}

- (NSString*)localizedNameForSleepEventType:(NSString*)eventType
{
    NSString* localizedFormat = [NSString stringWithFormat:@"sleep-event.type.%@.name", eventType];
    NSString* eventName = NSLocalizedString(localizedFormat, nil);
    if ([eventName isEqualToString:localizedFormat]) {
        return nil;
    }
    return eventName;
}

- (UIImage*)imageForEventType:(NSString*)eventType
{
    if ([eventType isEqualToString:@"awake"]) {
        return [HelloStyleKit wakeupEventIcon];
    } else if ([eventType isEqualToString:@"sleep"]) {
        return [HelloStyleKit sleepEventIcon];
    } else if ([eventType isEqualToString:@"light"]) {
        return [HelloStyleKit lightEventIcon];
    } else if ([eventType isEqualToString:@"noise"]) {
        return [HelloStyleKit noiseEventIcon];
    }
    return nil;
}

- (NSString*)textForTimeInterval:(NSTimeInterval)timeInterval
{
    return [[self.timeDateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:timeInterval]] lowercaseString];
}

@end
