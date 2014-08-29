
#import <SenseKit/SENSettings.h>
#import <SenseKit/SENSensor.h>
#import "HEMSleepGraphCollectionViewDataSource.h"
#import "HEMSleepGraphCollectionViewController.h"
#import "HEMAggregateGraphCollectionViewCell.h"
#import "HEMSleepSummaryCollectionViewCell.h"
#import "HEMSleepEventCollectionViewCell.h"
#import "HEMSleepSegmentCollectionViewCell.h"
#import "HEMSensorDataHeaderView.h"
#import "HelloStyleKit.h"
#import "HEMColorUtils.h"

@interface HEMSleepGraphCollectionViewDataSource ()

@property (nonatomic, strong) NSArray* sleepSegments;
@property (nonatomic, weak) UICollectionView* collectionView;
@property (nonatomic, weak, readwrite) HEMSensorDataHeaderView* sensorDataHeaderView;
@property (nonatomic, strong) NSDateFormatter* timeDateFormatter;
@property (nonatomic, strong) NSMutableArray* expandedIndexPaths;
@property (nonatomic, strong) NSNumber* sleepScore;
@property (nonatomic, strong) NSString* sleepMessage;
@property (nonatomic, strong) NSDate* dateForNightOfSleep;
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

- (instancetype)initWithCollectionView:(UICollectionView*)collectionView sleepData:(NSDictionary*)sleepData
{
    if (self = [super init]) {
        _collectionView = collectionView;
        _sleepSegments = sleepData[@"segments"];
        _sleepScore = sleepData[@"score"];
        _sleepMessage = sleepData[@"message"];
        _expandedIndexPaths = [NSMutableArray new];
        _timeDateFormatter = [NSDateFormatter new];
        _timeDateFormatter.dateFormat = ([SENSettings timeFormat] == SENTimeFormat12Hour) ? @"h:mm a" : @"H:mm";
        _dateForNightOfSleep = [NSDate dateWithTimeIntervalSince1970:[sleepData[@"date"] doubleValue] / 1000];
        [self configureCollectionView];
    }
    return self;
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
                NSDictionary* sleepData = [self sleepSegmentForIndexPath:indexPath];
                CGFloat fill = contentOffsetY - CGRectGetMinY(cell.frame);
                CGFloat total = CGRectGetMaxY(cell.frame) - CGRectGetMinY(cell.frame);
                CGFloat ratio = fill / total;
                [self updateSensorViewTextWithSleepData:sleepData forCellFillRatio:ratio];
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
- (void)updateSensorViewTextWithSleepData:(NSDictionary*)sleepData forCellFillRatio:(CGFloat)ratio
{
    NSDictionary* temperatureData = sleepData[@"sensors"][@"temperature"];
    NSDictionary* humidityData = sleepData[@"sensors"][@"humidity"];
    NSDictionary* particleData = sleepData[@"sensors"][@"particulates"];
    self.sensorDataHeaderView.temperatureLabel.text = temperatureData ? [SENSensor formatValue:temperatureData[@"value"] withUnit:[SENSensor unitFromValue:temperatureData[@"unit"]]] : @"0";
    self.sensorDataHeaderView.humidityLabel.text = humidityData ? [SENSensor formatValue:humidityData[@"value"] withUnit:[SENSensor unitFromValue:humidityData[@"unit"]]] : @"0";
    self.sensorDataHeaderView.particulateLabel.text = particleData ? [SENSensor formatValue:particleData[@"value"] withUnit:[SENSensor unitFromValue:particleData[@"unit"]]] : @"0";
    NSTimeInterval topInterval = [sleepData[@"timestamp"] doubleValue] / 1000;
    NSTimeInterval bottomInterval = topInterval + ([sleepData[@"duration"] doubleValue] / 1000);
    NSTimeInterval intervalAtContentOffsetY = bottomInterval - (ratio * (bottomInterval - topInterval));
    self.sensorDataHeaderView.timeLabel.text = [self textForTimeInterval:intervalAtContentOffsetY];
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
        return self.sleepSegments.count;
    case HEMSleepGraphCollectionViewHistorySection:
        return 3; // number of weeks?
    default:
        return 0;
    }
}

- (UICollectionReusableView*)collectionView:(UICollectionView*)collectionView viewForSupplementaryElementOfKind:(NSString*)kind atIndexPath:(NSIndexPath*)indexPath
{
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        HEMSensorDataHeaderView* headerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:sensorDataReuseIdentifier forIndexPath:indexPath];
        if (indexPath.section == HEMSleepGraphCollectionViewSegmentSection) {
            headerView.hidden = NO;
            self.sensorDataHeaderView = headerView;
            [self updateSensorViewTextWithSleepData:[self.sleepSegments firstObject] forCellFillRatio:0];
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
        NSDictionary* sleepData = [self sleepSegmentForIndexPath:indexPath];
        if ([sleepData[@"type"] isEqualToString:@"none"]) {
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
    [cell setSleepScore:[self.sleepScore integerValue]];
    cell.messageLabel.text = self.sleepMessage;
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
    NSDictionary* sleepData = [self sleepSegmentForIndexPath:indexPath];
    NSUInteger sleepDepth = [sleepData[@"sleep_depth"] integerValue];
    HEMSleepSegmentCollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:sleepSegmentReuseIdentifier forIndexPath:indexPath];
    [cell setSegmentRatio:sleepDepth / 3.f withColor:[HEMColorUtils colorForSleepDepth:sleepDepth]];
    return cell;
}

- (UICollectionViewCell*)collectionView:(UICollectionView*)collectionView sleepEventCellForItemAtIndexPath:(NSIndexPath*)indexPath
{
    NSDictionary* sleepData = [self sleepSegmentForIndexPath:indexPath];
    NSUInteger sleepDepth = [sleepData[@"sleep_depth"] integerValue];
    HEMSleepEventCollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:sleepEventReuseIdentifier forIndexPath:indexPath];
    cell.eventTypeButton.layer.borderColor = [HEMColorUtils colorForSleepDepth:sleepDepth].CGColor;
    cell.eventTypeButton.layer.borderWidth = 2.f;
    cell.eventTypeButton.layer.cornerRadius = CGRectGetWidth(cell.eventTypeButton.bounds) / 2;
    cell.eventTimeLabel.text = [self textForTimeInterval:[sleepData[@"timestamp"] doubleValue] / 1000];
    [cell.eventTypeButton setImage:[self imageForEvent:sleepData] forState:UIControlStateNormal];
    cell.eventMessageLabel.text = sleepData[@"message"];
    cell.eventTitleLabel.text = [self localizedNameForSleepEvent:sleepData];
    cell.expanded = [self eventCellAtIndexPathIsExpanded:indexPath];
    cell.playButton.hidden = ![sleepData[@"type"] isEqualToString:@"noise"];
    return cell;
}

- (UICollectionViewCell*)collectionView:(UICollectionView*)collectionView historyCellForItemAtIndexPath:(NSIndexPath*)indexPath
{
    HEMAggregateGraphCollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:aggregateGraphReuseIdentifier forIndexPath:indexPath];
    return cell;
}

#pragma mark - Data Parsing

- (NSDictionary*)sleepSegmentForIndexPath:(NSIndexPath*)indexPath
{
    return indexPath.section == HEMSleepGraphCollectionViewSegmentSection ? self.sleepSegments[indexPath.row] : nil;
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

- (NSString*)localizedNameForSleepEvent:(NSDictionary*)event
{
    NSString* localizedFormat = [NSString stringWithFormat:@"sleep-event.type.%@.name", event[@"type"]];
    NSString* eventName = NSLocalizedString(localizedFormat, nil);
    if ([eventName isEqualToString:localizedFormat]) {
        return nil;
    }
    return eventName;
}

- (UIImage*)imageForEvent:(NSDictionary*)event
{
    if ([event[@"type"] isEqualToString:@"awake"]) {
        return [HelloStyleKit wakeupEventIcon];
    } else if ([event[@"type"] isEqualToString:@"sleep"]) {
        return [HelloStyleKit sleepEventIcon];
    } else if ([event[@"type"] isEqualToString:@"light"]) {
        return [HelloStyleKit lightEventIcon];
    } else if ([event[@"type"] isEqualToString:@"noise"]) {
        return [HelloStyleKit noiseEventIcon];
    }
    return nil;
}

- (NSString*)textForTimeInterval:(NSTimeInterval)timeInterval
{
    return [[self.timeDateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:timeInterval]] lowercaseString];
}

@end
