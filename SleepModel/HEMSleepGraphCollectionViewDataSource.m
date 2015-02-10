
#import <SenseKit/SENSettings.h>
#import <SenseKit/SENSensor.h>
#import <SenseKit/SENSleepResult.h>
#import <SenseKit/SENAPITimeline.h>
#import <SenseKit/SENAuthorizationService.h>
#import <SpinKit/RTSpinKitView.h>
#import <FDWaveformView/FDWaveformView.h>
#import <markdown_peg.h>

#import "HEMSleepGraphCollectionViewDataSource.h"
#import "HEMSleepGraphViewController.h"
#import "HEMSleepSummaryCollectionViewCell.h"
#import "HEMSleepEventCollectionViewCell.h"
#import "HEMNoSleepEventCollectionViewCell.h"
#import "HEMTimelineHeaderCollectionReusableView.h"
#import "HEMTimelineFooterCollectionReusableView.h"
#import "HEMSleepScoreGraphView.h"
#import "NSAttributedString+HEMUtils.h"
#import "HelloStyleKit.h"
#import "UIFont+HEMStyle.h"
#import "UIColor+HEMStyle.h"
#import "HEMSleepEventButton.h"
#import "HEMMarkdown.h"
#import "NSDate+HEMRelative.h"

NSString* const HEMSleepEventTypeWakeUp = @"WAKE_UP";

@interface HEMSleepGraphCollectionViewDataSource ()

@property (nonatomic, weak) UICollectionView* collectionView;
@property (nonatomic, strong) NSDateFormatter* timeDateFormatter;
@property (nonatomic, strong) NSDateFormatter* rangeDateFormatter;
@property (nonatomic, strong) NSDateFormatter* weekdayDateFormatter;
@property (nonatomic, strong) NSDate* dateForNightOfSleep;
@property (nonatomic, strong, readwrite) SENSleepResult* sleepResult;
@property (nonatomic, strong) NSArray* aggregateDataSources;
@property (nonatomic, getter=shouldBeLoading) BOOL beLoading;
@property (nonatomic, strong) NSCalendar* calendar;
@end

@implementation HEMSleepGraphCollectionViewDataSource

static NSString* const HEMSleepEventTypeLight = @"LIGHT";
static NSString* const HEMSleepEventTypeMotion = @"MOTION";
static NSString* const HEMSleepEventTypeNoise = @"NOISE";
static NSString* const HEMSleepEventTypeSunrise = @"SUNRISE";
static NSString* const HEMSleepEventTypeSunset = @"SUNSET";
static NSString* const HEMSleepEventTypeFallAsleep = @"SLEEP";
static NSString* const HEMSleepEventTypePartnerMotion = @"PARTNER_MOTION";
static NSString* const HEMSleepEventTypeLightsOut = @"LIGHTS_OUT";
static NSString* const HEMSleepEventTypeInBed = @"IN_BED";
static NSString* const HEMSleepEventTypeOutOfBed = @"OUT_OF_BED";
static NSString* const HEMSleepEventTypeAlarm = @"ALARM";
static NSString* const HEMSleepEventTypeSleeping = @"SLEEPING";

static NSString* const sleepSegmentReuseIdentifier = @"sleepSegmentCell";
static NSString* const sleepSummaryReuseIdentifier = @"sleepSummaryCell";
static NSString* const presleepHeaderReuseIdentifier = @"presleepCell";
static NSString* const timelineHeaderReuseIdentifier = @"timelineHeaderCell";
static NSString* const timelineFooterReuseIdentifier = @"timelineHeaderCell";
static NSString* const presleepItemReuseIdentifier = @"presleepItemCell";
static NSString* const sleepEventReuseIdentifier = @"sleepEventCell";
static NSString* const sensorTypeTemperature = @"temperature";
static NSString* const sensorTypeHumidity = @"humidity";
static NSString* const sensorTypeParticulates = @"particulates";
static NSString* const sensorTypeLight = @"light";
static NSString* const sensorTypeSound = @"sound";
static NSString* const sleepEventNameFindCharacter = @"_";
static NSString* const sleepEventNameReplaceCharacter = @" ";
static NSString* const sleepEventNameFormat = @"sleep-event.type.%@.name";

+ (NSString*)localizedNameForSleepEventType:(NSString*)eventType
{
    NSString* localizedFormat = [NSString stringWithFormat:sleepEventNameFormat, [eventType lowercaseString]];
    NSString* eventName = NSLocalizedString(localizedFormat, nil);
    if ([eventName isEqualToString:localizedFormat]) {
        return [[eventType capitalizedString] stringByReplacingOccurrencesOfString:sleepEventNameFindCharacter
                                                                        withString:sleepEventNameReplaceCharacter];
    }
    return eventName;
}

- (instancetype)initWithCollectionView:(UICollectionView*)collectionView
                             sleepDate:(NSDate*)date
{
    if (self = [super init]) {
        _collectionView = collectionView;
        _dateForNightOfSleep = date;
        _timeDateFormatter = [NSDateFormatter new];
        _timeDateFormatter.dateFormat = ([SENSettings timeFormat] == SENTimeFormat12Hour) ? @"h:mm a" : @"H:mm";
        _rangeDateFormatter = [NSDateFormatter new];
        _rangeDateFormatter.dateFormat = @"MMMM d";
        _weekdayDateFormatter = [NSDateFormatter new];
        _weekdayDateFormatter.dateFormat = @"EEEE";
        _calendar = [NSCalendar currentCalendar];
        [self configureCollectionView];
        [self reloadData];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(reloadData)
                                                     name:SENAuthorizationServiceDidAuthorizeNotification
                                                   object:nil];
    }
    return self;
}

- (void)reloadData
{
    self.sleepResult = [SENSleepResult sleepResultForDate:self.dateForNightOfSleep];
    if ([self shouldShowLoadingView]) {
        self.beLoading = YES;
        [self showLoadingView];
    } else {
        self.beLoading = NO;
        [self hideLoadingViewAnimated:NO];
    }
    __weak typeof(self) weakSelf = self;
    [SENAPITimeline timelineForDate:self.dateForNightOfSleep completion:^(NSArray* timelines, NSError* error) {
        __strong HEMSleepGraphCollectionViewDataSource* strongSelf = weakSelf;
        if (error) {
            DDLogVerbose(@"Failed to fetch timeline: %@", error.localizedDescription);
            [strongSelf hideLoadingViewAnimated:YES];
            return;
        }
        [strongSelf refreshWithTimelines:timelines];
    }];
}

- (void)refreshWithTimelines:(NSArray*)timelines
{
    NSDictionary* timeline = [timelines firstObject];
    BOOL didChange = [self.sleepResult updateWithDictionary:timeline];
    [self hideLoadingViewAnimated:YES];
    if (didChange) {
        [self.sleepResult save];
        [self.collectionView reloadData];
    }
}

- (void)configureCollectionView
{
    NSBundle* bundle = [NSBundle mainBundle];
    [self.collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([HEMNoSleepEventCollectionViewCell class]) bundle:bundle]
          forCellWithReuseIdentifier:sleepSegmentReuseIdentifier];
    [self.collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([HEMSleepSummaryCollectionViewCell class]) bundle:bundle]
          forCellWithReuseIdentifier:sleepSummaryReuseIdentifier];
    [self.collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([HEMSleepEventCollectionViewCell class]) bundle:bundle]
          forCellWithReuseIdentifier:sleepEventReuseIdentifier];
    [self.collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([HEMTimelineHeaderCollectionReusableView class]) bundle:bundle]
          forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                 withReuseIdentifier:timelineHeaderReuseIdentifier];
    [self.collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([HEMTimelineFooterCollectionReusableView class]) bundle:bundle]
          forSupplementaryViewOfKind:UICollectionElementKindSectionFooter
                 withReuseIdentifier:timelineFooterReuseIdentifier];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SENAuthorizationServiceDidAuthorizeNotification object:nil];
}

- (NSUInteger)numberOfSleepSegments
{
    return self.sleepResult.segments.count;
}

- (HEMSleepSummaryCollectionViewCell *)sleepSummaryCell
{
    NSIndexPath* indexPath = [NSIndexPath indexPathForItem:0 inSection:HEMSleepGraphCollectionViewSummarySection];
    return (id)[self.collectionView cellForItemAtIndexPath:indexPath];
}

#pragma mark - Loading

- (RTSpinKitView *)loadingView
{
    return self.sleepSummaryCell.spinnerView;
}

- (BOOL)shouldShowLoadingView
{
    return [self numberOfSleepSegments] == 0;
}

- (void)showLoadingView
{
    if (![self shouldBeLoading])
        return;

    if (self.loadingView) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
        [self.loadingView startAnimating];
    } else {
        self.beLoading = YES;
    }
}

- (void)hideLoadingViewAnimated:(BOOL)animated
{
    self.beLoading = NO;
    CGFloat duration = animated ? 0.25f : 0;
    [UIView animateWithDuration:duration animations:^{
        self.loadingView.alpha = 0;
    } completion:^(BOOL finished) {
        [self.loadingView stopAnimating];
        self.loadingView.alpha = 1;
    }];
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
        return self.numberOfSleepSegments;
    default:
        return 0;
    }
}

- (UICollectionReusableView*)collectionView:(UICollectionView*)collectionView viewForSupplementaryElementOfKind:(NSString*)kind atIndexPath:(NSIndexPath*)indexPath
{
    NSString* identifier = [kind isEqualToString:UICollectionElementKindSectionHeader]
        ? timelineHeaderReuseIdentifier : timelineFooterReuseIdentifier;
    UICollectionReusableView* view = [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                                        withReuseIdentifier:identifier
                                                                               forIndexPath:indexPath];
    view.hidden = !(indexPath.section == HEMSleepGraphCollectionViewSegmentSection
                    && [collectionView numberOfItemsInSection:HEMSleepGraphCollectionViewSegmentSection] > 0);
    return view;
}

- (UICollectionViewCell*)collectionView:(UICollectionView*)collectionView cellForItemAtIndexPath:(NSIndexPath*)indexPath
{
    UICollectionViewCell* cell = nil;

    switch (indexPath.section) {
    case HEMSleepGraphCollectionViewSummarySection:
        cell = [self collectionView:collectionView sleepSummaryCellForItemAtIndexPath:indexPath];
        break;
    case HEMSleepGraphCollectionViewSegmentSection: {
        if ([self segmentForSleepExistsAtIndexPath:indexPath]) {
            cell = [self collectionView:collectionView sleepSegmentCellForItemAtIndexPath:indexPath];
        }
        else {
            cell = [self collectionView:collectionView sleepEventCellForItemAtIndexPath:indexPath];
        }
        break;
    }
    }
    CGFloat zPosition = indexPath.row + 1;
    if (cell.layer.zPosition != zPosition)
        [cell.layer setZPosition:zPosition];

    if ([collectionView.delegate respondsToSelector:@selector(didLoadCell:atIndexPath:)])
        [(id<HEMSleepGraphActionDelegate>)collectionView.delegate didLoadCell:cell atIndexPath:indexPath];
    return cell;
}

- (UICollectionViewCell*)collectionView:(UICollectionView*)collectionView
     sleepSummaryCellForItemAtIndexPath:(NSIndexPath*)indexPath
{
    HEMSleepSummaryCollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:sleepSummaryReuseIdentifier forIndexPath:indexPath];
    NSInteger score = [self.sleepResult.score integerValue];
    [cell setSleepScore:score animated:YES];
    cell.messageLabel.textAlignment = NSTextAlignmentCenter;
    NSDictionary* attributes = [HEMMarkdown attributesForTimelineMessageText];
    cell.messageLabel.attributedText = [markdown_to_attr_string(self.sleepResult.message, 0, attributes) trim];
    NSDateComponents* diff = [self.calendar components:NSDayCalendarUnit
                                              fromDate:self.dateForNightOfSleep
                                                toDate:[[NSDate date] previousDay] options:0];
    NSString* dateText;
    if (diff.day == 0)
        dateText = NSLocalizedString(@"sleep-history.last-night", nil);
    else if (diff.day < 7)
        dateText = [self.weekdayDateFormatter stringFromDate:self.dateForNightOfSleep];
    else
        dateText = [self.rangeDateFormatter stringFromDate:self.dateForNightOfSleep];;
    [self configurePresleepSummaryForCell:cell];
    [self configureActionsForSleepSummaryCell:cell];
    [self configureSummaryStatisticsForCell:cell];
    [cell.dateButton setTitle:dateText forState:UIControlStateNormal];
    if ([self shouldBeLoading])
        [self performSelector:@selector(showLoadingView) withObject:nil afterDelay:0.5];
    else
        [cell.spinnerView stopAnimating];
    return cell;
}

- (void)configureActionsForSleepSummaryCell:(HEMSleepSummaryCollectionViewCell*)cell
{
    if ([self.collectionView.delegate respondsToSelector:@selector(drawerButtonTapped:)])
        [cell.drawerButton addTarget:self.collectionView.delegate
                              action:@selector(drawerButtonTapped:)
                    forControlEvents:UIControlEventTouchUpInside];
    if ([self.collectionView.delegate respondsToSelector:@selector(shouldHideShareButton)])
        cell.shareButton.alpha = [(id<HEMSleepGraphActionDelegate>)self.collectionView.delegate
                                  shouldHideShareButton] ? 0 : 1.f;
    if ([self.collectionView.delegate respondsToSelector:@selector(shouldEnableZoomButton)])
        cell.dateButton.enabled = [(id<HEMSleepGraphActionDelegate>)self.collectionView.delegate
                                   shouldEnableZoomButton];
    if ([self.collectionView.delegate respondsToSelector:@selector(shareButtonTapped:)])
        [cell.shareButton addTarget:self.collectionView.delegate
                             action:@selector(shareButtonTapped:)
                   forControlEvents:UIControlEventTouchUpInside];
    if ([self.collectionView.delegate respondsToSelector:@selector(zoomButtonTapped:)])
        [cell.dateButton addTarget:self.collectionView.delegate
                            action:@selector(zoomButtonTapped:)
                  forControlEvents:UIControlEventTouchUpInside];
}

- (void)configureSummaryStatisticsForCell:(HEMSleepSummaryCollectionViewCell*)cell
{
    static NSString* const HEMSummaryStatTitleFormat = @"sleep-stat.%@";
    UIColor* color = [UIColor colorForSleepScore:[self.sleepResult.score integerValue]];
    NSDictionary* titleAttributes = [HEMMarkdown attributesForTimelineBreakdownTitle][@(PARA)];
    NSDictionary* valueAttributes = [HEMMarkdown attributesForTimelineBreakdownValueWithColor:color][@(PARA)];
    for (SENSleepResultStatistic* stat in self.sleepResult.statistics) {
        NSString* titleFormat = [NSString stringWithFormat:HEMSummaryStatTitleFormat, stat.name];
        NSString* title = [NSLocalizedString(titleFormat, nil) uppercaseString];
        NSString* value = nil;
        UILabel* titleLabel = nil, * valueLabel = nil;
        switch (stat.type) {
            case SENSleepResultStatisticTypeTotalDuration:
                titleLabel = cell.metricTitleLabel1;
                valueLabel = cell.metricValueLabel1;
                value = [self shortValueForMinuteValue:stat.value];
                break;
            case SENSleepResultStatisticTypeSoundDuration:
                titleLabel = cell.metricTitleLabel2;
                valueLabel = cell.metricValueLabel2;
                value = [self shortValueForMinuteValue:stat.value];
                break;
            case SENSleepResultStatisticTypeTimeToSleep:
                titleLabel = cell.metricTitleLabel4;
                valueLabel = cell.metricValueLabel4;
                value = [self shortValueForMinuteValue:stat.value];
                break;
            case SENSleepResultStatisticTypeTimesAwake:
                titleLabel = cell.metricTitleLabel3;
                valueLabel = cell.metricValueLabel3;
                value = [NSString stringWithFormat:@"%.0f", [stat.value floatValue]];
                break;
            default:
                break;
        }
        titleLabel.attributedText = [[NSAttributedString alloc] initWithString:title
                                                                    attributes:titleAttributes];
        valueLabel.attributedText = [[NSAttributedString alloc] initWithString:value
                                                                    attributes:valueAttributes];
    }
}

- (NSString*)shortValueForMinuteValue:(NSNumber*)minuteValue
{
    CGFloat minutes = [minuteValue floatValue];
    NSString* format;
    if (minutes < 60)
        format = NSLocalizedString(@"sleep-stat.minute.format", nil);
    else
        format = NSLocalizedString(@"sleep-stat.hour.format", nil);
    return [NSString stringWithFormat:format, minutes/60];
}

- (void)configurePresleepSummaryForCell:(HEMSleepSummaryCollectionViewCell*)cell
{
    NSDictionary* attributes = [HEMMarkdown attributesForTimelineMessageText];
    if (self.sleepResult.sensorInsights.count > 4) {
        SENSleepResultSensorInsight* insight = self.sleepResult.sensorInsights[4];
        cell.presleepInsightLabel5.attributedText = [markdown_to_attr_string(insight.message, 0, attributes) trim];
        cell.presleepImageView5.image = [self imageForPresleepInsight:insight];
        cell.presleepImageView5.tintColor = [UIColor colorForSensorWithCondition:insight.condition];
    }

    if (self.sleepResult.sensorInsights.count > 3) {
        SENSleepResultSensorInsight* insight = self.sleepResult.sensorInsights[3];
        cell.presleepInsightLabel4.attributedText = [markdown_to_attr_string(insight.message, 0, attributes) trim];
        cell.presleepImageView4.image = [self imageForPresleepInsight:insight];
        cell.presleepImageView4.tintColor = [UIColor colorForSensorWithCondition:insight.condition];
    }

    if (self.sleepResult.sensorInsights.count > 2) {
        SENSleepResultSensorInsight* insight = self.sleepResult.sensorInsights[2];
        cell.presleepInsightLabel3.attributedText = [markdown_to_attr_string(insight.message, 0, attributes) trim];
        cell.presleepImageView3.image = [self imageForPresleepInsight:insight];
        cell.presleepImageView3.tintColor = [UIColor colorForSensorWithCondition:insight.condition];
    }

    if (self.sleepResult.sensorInsights.count > 1) {
        SENSleepResultSensorInsight* insight = self.sleepResult.sensorInsights[1];
        cell.presleepInsightLabel2.attributedText = [markdown_to_attr_string(insight.message, 0, attributes) trim];
        cell.presleepImageView2.image = [self imageForPresleepInsight:insight];
        cell.presleepImageView2.tintColor = [UIColor colorForSensorWithCondition:insight.condition];
    }

    if (self.sleepResult.sensorInsights.count > 0) {
        SENSleepResultSensorInsight* insight = self.sleepResult.sensorInsights[0];
        cell.presleepInsightLabel1.attributedText = [markdown_to_attr_string(insight.message, 0, attributes) trim];
        cell.presleepImageView1.image = [self imageForPresleepInsight:insight];
        cell.presleepImageView1.tintColor = [UIColor colorForSensorWithCondition:insight.condition];
    }
}

- (UIImage*)imageForPresleepInsight:(SENSleepResultSensorInsight*)insight
{
    UIImage* image = nil;
    if ([insight.name isEqualToString:sensorTypeTemperature]) {
        image = [HelloStyleKit presleepInsightTemperature];
    } else if ([insight.name isEqualToString:sensorTypeHumidity]) {
        image = [HelloStyleKit presleepInsightHumidity];
    } else if ([insight.name isEqualToString:sensorTypeParticulates]) {
        image = [HelloStyleKit presleepInsightParticulates];
    } else if ([insight.name isEqualToString:sensorTypeLight]) {
        image = [HelloStyleKit presleepInsightLight];
    } else if ([insight.name isEqualToString:sensorTypeSound]) {
        image = [HelloStyleKit presleepInsightSound];
    } else {
        image = [HelloStyleKit presleepInsightUnknown];
    }

    return [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
}

- (UICollectionViewCell*)collectionView:(UICollectionView*)collectionView
     sleepSegmentCellForItemAtIndexPath:(NSIndexPath*)indexPath
{
    SENSleepResultSegment* segment = [self sleepSegmentForIndexPath:indexPath];
    NSUInteger sleepDepth = segment.sleepDepth;
    HEMNoSleepEventCollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:sleepSegmentReuseIdentifier forIndexPath:indexPath];
    UIColor* color = nil, * lineColor = nil;
    CGFloat fillRatio = sleepDepth / (float)SENSleepResultSegmentDepthDeep;
    if ([segment.eventType isEqualToString:HEMSleepEventTypeSleeping]) {
        color = [UIColor colorForSleepDepth:sleepDepth];
        lineColor = [HelloStyleKit timelineLineColor];
    } else {
        color = [UIColor colorForGenericMotionDepth:sleepDepth];
        lineColor = [UIColor clearColor];
    }
    [cell setSegmentRatio:fillRatio withFillColor:color lineColor:lineColor];
    [self configureTimeLabelsForCell:cell withSegment:segment];
    return cell;
}

- (void)configureTimeLabelsForCell:(HEMSleepSegmentCollectionViewCell*)cell
                       withSegment:(SENSleepResultSegment*)segment
{
    [cell removeAllTimeLabels];
    if (!segment)
        return;
    NSCalendarUnit units = (NSCalendarUnitMinute|NSCalendarUnitHour|NSCalendarUnitDay);
    NSDateComponents* components = [self.calendar components:units fromDate:segment.date];
    self.timeDateFormatter.timeZone = segment.timezone;
    if (components.minute == 0) {
        [cell addTimeLabelWithText:[[self.timeDateFormatter stringFromDate:segment.date] lowercaseString]
                     atHeightRatio:0];
    }
    NSTimeInterval segmentInterval = [segment.date timeIntervalSince1970];
    NSDate* endDate = [NSDate dateWithTimeIntervalSince1970:segmentInterval + [segment.duration doubleValue]];
    NSTimeInterval endInterval = [endDate timeIntervalSince1970];
    int i = 1;
    NSTimeInterval hourInterval = 0;
    while (hourInterval < endInterval) {
        NSDateComponents* hourComponents = [NSDateComponents new];
        hourComponents.hour = i;
        hourComponents.minute = -components.minute;
        NSDate* hourDate = [self.calendar dateByAddingComponents:hourComponents toDate:segment.date options:0];
        hourInterval = [hourDate timeIntervalSince1970];
        if (hourInterval < endInterval) {
            CGFloat ratio = ([hourDate timeIntervalSince1970] - segmentInterval)/(endInterval - segmentInterval);
            NSString* timeText = [[self.timeDateFormatter stringFromDate:hourDate] lowercaseString];
            [cell addTimeLabelWithText:timeText atHeightRatio:ratio];
        }
        i++;
    }
}

- (UICollectionViewCell*)collectionView:(UICollectionView*)collectionView
       sleepEventCellForItemAtIndexPath:(NSIndexPath*)indexPath
{
    HEMSleepEventCollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:sleepEventReuseIdentifier
                                                                                      forIndexPath:indexPath];
    SENSleepResultSegment* segment = [self sleepSegmentForIndexPath:indexPath];
    if (!segment)
        return cell;
    NSUInteger sleepDepth = segment.sleepDepth;
    if ([collectionView.delegate respondsToSelector:@selector(didTapEventButton:)]) {
        [cell.eventTypeButton addTarget:collectionView.delegate
                                 action:@selector(didTapEventButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    if (segment.sound) {
        cell.waveformView.hidden = NO;
        cell.playSoundButton.hidden = NO;
        [cell setAudioURL:[NSURL URLWithString:segment.sound.URLPath]];
    } else if ([segment.eventType isEqualToString:HEMSleepEventTypeWakeUp] &&
               [collectionView.delegate respondsToSelector:@selector(didTapDataVerifyButton:)]) {
        cell.verifyDataButton.hidden = NO;
        [cell.verifyDataButton addTarget:collectionView.delegate
                                  action:@selector(didTapDataVerifyButton:) forControlEvents:UIControlEventTouchUpInside];
    }

    [cell.eventTypeButton setImage:[self imageForEventType:segment.eventType] forState:UIControlStateNormal];
    NSString* titleFormat = NSLocalizedString(@"sleep-event.title.format", nil);
    NSString* titleText = [[self class] localizedNameForSleepEventType:segment.eventType];
    NSString* timeText = [self timeTextForSegment:segment];
    cell.eventTimeLabel.text = timeText;
    cell.eventTitleLabel.text = [[NSString stringWithFormat:titleFormat, titleText, timeText] uppercaseString];
    cell.eventMessageLabel.attributedText = [markdown_to_attr_string(segment.message, 0, [HEMMarkdown attributesForEventMessageText]) trim];
    cell.firstSegment = [self.sleepResult.segments indexOfObject:segment] == 0;
    cell.lastSegment = [self.sleepResult.segments indexOfObject:segment] == self.sleepResult.segments.count - 1;
    [cell setSegmentRatio:sleepDepth / (float)SENSleepResultSegmentDepthDeep
            withFillColor:[UIColor colorForSleepDepth:sleepDepth]
                lineColor:[HelloStyleKit timelineLineColor]];
    [self configureTimeLabelsForCell:cell withSegment:segment];
    return cell;
}

#pragma mark - Data Parsing

- (SENSleepResultSegment*)sleepSegmentForIndexPath:(NSIndexPath*)indexPath
{
    NSArray* segments = self.sleepResult.segments;
    if (indexPath.row >= segments.count || indexPath.section != HEMSleepGraphCollectionViewSegmentSection)
        return nil;
    return segments[indexPath.row];
}

- (UIImage*)imageForEventType:(NSString*)eventType
{
    if ([eventType isEqualToString:HEMSleepEventTypeWakeUp])
        return [HelloStyleKit wakeupEventIcon];
    else if ([eventType isEqualToString:HEMSleepEventTypeFallAsleep])
        return [HelloStyleKit sleepEventIcon];
    else if ([eventType isEqualToString:HEMSleepEventTypeLight])
        return [HelloStyleKit lightEventIcon];
    else if ([eventType isEqualToString:HEMSleepEventTypeNoise])
        return [HelloStyleKit noiseEventIcon];
    else if ([eventType isEqualToString:HEMSleepEventTypeMotion])
        return [HelloStyleKit motionEventIcon];
    else if ([eventType isEqualToString:HEMSleepEventTypeSunrise])
        return [HelloStyleKit sunriseEventIcon];
    else if ([eventType isEqualToString:HEMSleepEventTypeSunset])
        return [HelloStyleKit sunsetEventIcon];
    else if ([eventType isEqualToString:HEMSleepEventTypeLightsOut])
        return [HelloStyleKit lightsOutEventIcon];
    else if ([eventType isEqualToString:HEMSleepEventTypePartnerMotion])
        return [HelloStyleKit partnerEventIcon];
    else if ([eventType isEqualToString:HEMSleepEventTypeInBed])
        return [HelloStyleKit inBedEventIcon];
    else if ([eventType isEqualToString:HEMSleepEventTypeOutOfBed])
        return [HelloStyleKit outOfBedEventIcon];
    else if ([eventType isEqualToString:HEMSleepEventTypeAlarm])
        return [HelloStyleKit alarmEventIcon];

    return [HelloStyleKit unknownEventIcon];
}

- (NSString*)timeTextForSegment:(SENSleepResultSegment*)segment
{
    self.timeDateFormatter.timeZone = segment.timezone;
    return [[self.timeDateFormatter stringFromDate:segment.date] lowercaseString];
}

- (BOOL)segmentForSleepExistsAtIndexPath:(NSIndexPath*)indexPath
{
    return indexPath.section == HEMSleepGraphCollectionViewSegmentSection && ![self segmentForEventExistsAtIndexPath:indexPath];
}

- (BOOL)segmentForEventExistsAtIndexPath:(NSIndexPath*)indexPath
{
    SENSleepResultSegment* segment = [self sleepSegmentForIndexPath:indexPath];
    return ![segment.eventType isEqual:[NSNull null]]
        && segment.eventType.length > 0
        && ![segment.eventType isEqualToString:HEMSleepEventTypeSleeping];
}

@end
