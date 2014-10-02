
#import <SenseKit/SENSettings.h>
#import <SenseKit/SENSensor.h>
#import <SenseKit/SENSleepResult.h>
#import <SenseKit/SENAPITimeline.h>
#import <SenseKit/SENAuthorizationService.h>
#import <JBChartView/JBLineChartView.h>
#import <markdown_peg.h>

#import "HEMSleepGraphCollectionViewDataSource.h"
#import "HEMSleepGraphCollectionViewController.h"
#import "HEMAggregateGraphCollectionViewCell.h"
#import "HEMSleepSummaryCollectionViewCell.h"
#import "HEMSleepEventCollectionViewCell.h"
#import "HEMSleepSegmentCollectionViewCell.h"
#import "HEMSensorDataHeaderView.h"
#import "HEMSensorGraphDataSource.h"
#import "HelloStyleKit.h"
#import "HEMColorUtils.h"

NSString* const HEMSleepEventTypeWakeUp = @"WAKE_UP";
NSString* const HEMSleepEventTypeLight = @"LIGHT";
NSString* const HEMSleepEventTypeMotion = @"MOTION";
NSString* const HEMSleepEventTypeNoise = @"NOISE";
NSString* const HEMSleepEventTypeFallAsleep = @"SLEEP";

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
static NSString* const sleepEventReuseIdentifier = @"sleepEventCell";
static NSString* const sensorDataReuseIdentifier = @"sensorDataView";

static NSString* const sensorTypeTemperature = @"temperature";
static NSString* const sensorTypeHumidity = @"humidity";
static NSString* const sensorTypeParticulates = @"particulates";

+ (NSDateFormatter*)sleepDateFormatter
{
    static NSDateFormatter* formatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"MMMM d, yyyy";
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
        [self reloadData];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData) name:SENAuthorizationServiceDidAuthorizeNotification object:nil];
    }
    return self;
}

- (void)reloadData
{
    self.sleepResult = [SENSleepResult sleepResultForDate:self.dateForNightOfSleep];
    [SENAPITimeline timelineForDate:self.dateForNightOfSleep completion:^(NSArray* timelines, NSError* error) {
        if (error) {
            NSLog(@"Failed to fetch timeline: %@", error.localizedDescription);
            return;
        }
        [self refreshWithTimelines:timelines];
    }];
}

- (void)refreshWithTimelines:(NSArray*)timelines
{
    NSDictionary* timeline = [timelines firstObject];
    [self.sleepResult updateWithDictionary:timeline];
    [self.sleepResult save];
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
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SENAuthorizationServiceDidAuthorizeNotification object:nil];
}

#pragma mark - Event Cell Size Toggling

- (BOOL)toggleExpansionOfEventCellAtIndexPath:(NSIndexPath*)indexPath
{
    if (indexPath.section == HEMSleepGraphCollectionViewSegmentSection) {
        if ([self eventCellAtIndexPathIsExpanded:indexPath]) {
            [self.expandedIndexPaths removeObject:indexPath];
            return NO;
        } else {
            [self.expandedIndexPaths addObject:indexPath];
            return YES;
        }
    }
    return NO;
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
            if ([sensor.name isEqualToString:sensorTypeTemperature]) {
                self.sensorDataHeaderView.temperatureLabel.text = text;
            } else if ([sensor.name isEqualToString:sensorTypeHumidity]) {
                self.sensorDataHeaderView.humidityLabel.text = text;
            } else if ([sensor.name isEqualToString:sensorTypeParticulates]) {
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
    return 2;
}

- (NSInteger)collectionView:(UICollectionView*)collectionView numberOfItemsInSection:(NSInteger)section
{
    switch (section) {
    case HEMSleepGraphCollectionViewSummarySection:
        return 1;
    case HEMSleepGraphCollectionViewSegmentSection:
        return self.sleepResult.segments.count;
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
        if ([self segmentForSleepExistsAtIndexPath:indexPath]) {
            return [self collectionView:collectionView sleepSegmentCellForItemAtIndexPath:indexPath];
        } else {
            return [self collectionView:collectionView sleepEventCellForItemAtIndexPath:indexPath];
        }
    }
    default:
        return nil;
    }
}

- (UICollectionViewCell*)collectionView:(UICollectionView*)collectionView sleepSummaryCellForItemAtIndexPath:(NSIndexPath*)indexPath
{
    HEMSleepSummaryCollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:sleepSummaryReuseIdentifier forIndexPath:indexPath];
    UIFont* emFont = [UIFont fontWithName:@"Agile-Medium" size:cell.messageLabel.font.pointSize];
    [cell setSleepScore:[self.sleepResult.score integerValue] animated:YES];
    NSDictionary* attributes = @{
        @(EMPH) : @{
            NSFontAttributeName : emFont,
        }
    };
    cell.messageLabel.attributedText = markdown_to_attr_string(self.sleepResult.message, 0, attributes);
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
    [cell setSegmentRatio:sleepDepth / (float)SENSleepResultSegmentDepthDeep withColor:[HEMColorUtils colorForSleepDepth:sleepDepth]];
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
    cell.playButton.hidden = ![segment.eventType isEqualToString:HEMSleepEventTypeNoise];
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
    NSString* localizedFormat = [NSString stringWithFormat:@"sleep-event.type.%@.name", [eventType lowercaseString]];
    NSString* eventName = NSLocalizedString(localizedFormat, nil);
    if ([eventName isEqualToString:localizedFormat]) {
        return [eventType capitalizedString];
    }
    return eventName;
}

- (UIImage*)imageForEventType:(NSString*)eventType
{
    if ([eventType isEqualToString:HEMSleepEventTypeWakeUp]) {
        return [HelloStyleKit wakeupEventIcon];
    } else if ([eventType isEqualToString:HEMSleepEventTypeFallAsleep]) {
        return [HelloStyleKit sleepEventIcon];
    } else if ([eventType isEqualToString:HEMSleepEventTypeLight]) {
        return [HelloStyleKit lightEventIcon];
    } else if ([eventType isEqualToString:HEMSleepEventTypeNoise]) {
        return [HelloStyleKit noiseEventIcon];
    } else if ([eventType isEqualToString:HEMSleepEventTypeMotion]) {
        return [HelloStyleKit motionEventIcon];
    }
    return nil;
}

- (NSString*)textForTimeInterval:(NSTimeInterval)timeInterval
{
    return [[self.timeDateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:timeInterval]] lowercaseString];
}

- (BOOL)segmentForSleepExistsAtIndexPath:(NSIndexPath*)indexPath
{
    SENSleepResultSegment* segment = [self sleepSegmentForIndexPath:indexPath];
    return !segment.eventType || [segment.eventType isEqual:[NSNull null]];
}

- (BOOL)segmentForEventExistsAtIndexPath:(NSIndexPath*)indexPath
{
    SENSleepResultSegment* segment = [self sleepSegmentForIndexPath:indexPath];
    return segment.eventType && ![segment.eventType isEqual:[NSNull null]];
}

@end
