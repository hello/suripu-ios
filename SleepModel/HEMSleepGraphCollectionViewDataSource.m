
#import <SenseKit/SENPreference.h>
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
#import "HEMTimelineFeedbackViewController.h"
#import "HEMMarkdown.h"
#import "NSDate+HEMRelative.h"

NSString *const HEMSleepEventTypeWakeUp = @"WAKE_UP";
NSString *const HEMSleepEventTypeLight = @"LIGHT";
NSString *const HEMSleepEventTypeMotion = @"MOTION";
NSString *const HEMSleepEventTypeNoise = @"NOISE";
NSString *const HEMSleepEventTypeSunrise = @"SUNRISE";
NSString *const HEMSleepEventTypeSunset = @"SUNSET";
NSString *const HEMSleepEventTypeFallAsleep = @"SLEEP";
NSString *const HEMSleepEventTypePartnerMotion = @"PARTNER_MOTION";
NSString *const HEMSleepEventTypeLightsOut = @"LIGHTS_OUT";
NSString *const HEMSleepEventTypeInBed = @"IN_BED";
NSString *const HEMSleepEventTypeOutOfBed = @"OUT_OF_BED";
NSString *const HEMSleepEventTypeAlarm = @"ALARM";
NSString *const HEMSleepEventTypeSmartAlarm = @"SMART_ALARM";
NSString *const HEMSleepEventTypeSleeping = @"SLEEPING";

@interface HEMSleepGraphCollectionViewDataSource ()

@property (nonatomic, weak) UICollectionView *collectionView;
@property (nonatomic, strong) NSDateFormatter *hourDateFormatter;
@property (nonatomic, strong) NSDateFormatter *timeDateFormatter;
@property (nonatomic, strong) NSDateFormatter *rangeDateFormatter;
@property (nonatomic, strong) NSDateFormatter *weekdayDateFormatter;
@property (nonatomic, strong) NSDate *dateForNightOfSleep;
@property (nonatomic, strong, readwrite) SENSleepResult *sleepResult;
@property (nonatomic, strong) NSArray *aggregateDataSources;
@property (nonatomic, getter=shouldBeLoading) BOOL beLoading;
@property (nonatomic, strong) NSCalendar *calendar;
@end

@implementation HEMSleepGraphCollectionViewDataSource

static NSString *const sleepSegmentReuseIdentifier = @"sleepSegmentCell";
static NSString *const sleepSummaryReuseIdentifier = @"sleepSummaryCell";
static NSString *const presleepHeaderReuseIdentifier = @"presleepCell";
static NSString *const timelineHeaderReuseIdentifier = @"timelineHeaderCell";
static NSString *const timelineFooterReuseIdentifier = @"timelineHeaderCell";
static NSString *const presleepItemReuseIdentifier = @"presleepItemCell";
static NSString *const sleepEventReuseIdentifier = @"sleepEventCell";
static NSString *const sensorTypeTemperature = @"temperature";
static NSString *const sensorTypeHumidity = @"humidity";
static NSString *const sensorTypeParticulates = @"particulates";
static NSString *const sensorTypeLight = @"light";
static NSString *const sensorTypeSound = @"sound";
static NSString *const sleepEventNameFindCharacter = @"_";
static NSString *const sleepEventNameReplaceCharacter = @" ";
static NSString *const sleepEventNameFormat = @"sleep-event.type.%@.name";
static CGFloat const HEMSleepGraphEventZPositionOffset = 3;

+ (NSString *)localizedNameForSleepEventType:(NSString *)eventType {
    NSString *localizedFormat = [NSString stringWithFormat:sleepEventNameFormat, [eventType lowercaseString]];
    NSString *eventName = NSLocalizedString(localizedFormat, nil);
    if ([eventName isEqualToString:localizedFormat]) {
        return [[eventType capitalizedString] stringByReplacingOccurrencesOfString:sleepEventNameFindCharacter
                                                                        withString:sleepEventNameReplaceCharacter];
    }
    return eventName;
}

- (instancetype)initWithCollectionView:(UICollectionView *)collectionView sleepDate:(NSDate *)date {
    if (self = [super init]) {
        _collectionView = collectionView;
        _dateForNightOfSleep = date;
        _timeDateFormatter = [NSDateFormatter new];
        _hourDateFormatter = [NSDateFormatter new];
        if ([SENPreference timeFormat] == SENTimeFormat12Hour) {
            _timeDateFormatter.dateFormat = @"h:mm a";
            _hourDateFormatter.dateFormat = @"h a";
        } else {
            _timeDateFormatter.dateFormat = @"H:mm";
            _hourDateFormatter.dateFormat = @"H";
        }
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

- (void)reloadData {
    self.sleepResult = [SENSleepResult sleepResultForDate:self.dateForNightOfSleep];
    if ([self shouldShowLoadingView]) {
        self.beLoading = YES;
        [self showLoadingView];
    } else {
        self.beLoading = NO;
        [self hideLoadingViewAnimated:NO];
    }
    if ([self isTitleOutOfSync])
        [self.collectionView reloadData];

    if (self.dateForNightOfSleep) {
        [SENAnalytics track:HEMAnalyticsEventTimelineDataRequest
                 properties:@{ kHEMAnalyticsEventPropDate : self.dateForNightOfSleep }];
    }

    __weak typeof(self) weakSelf = self;
    [SENAPITimeline timelineForDate:self.dateForNightOfSleep
                         completion:^(NSArray *timelines, NSError *error) {
                           __strong HEMSleepGraphCollectionViewDataSource *strongSelf = weakSelf;
                           if (error) {
                               [SENAnalytics trackError:error withEventName:kHEMAnalyticsEventError];
                               DDLogVerbose(@"Failed to fetch timeline: %@", error.localizedDescription);
                               [strongSelf hideLoadingViewAnimated:YES];
                               return;
                           }
                           [strongSelf refreshWithTimelines:timelines];
                         }];
}

- (void)refreshWithTimelines:(NSArray *)timelines {
    if (![timelines isKindOfClass:[NSArray class]])
        return;
    NSDictionary *timeline = [timelines firstObject];
    BOOL didChange = [self.sleepResult updateWithDictionary:timeline];
    [self hideLoadingViewAnimated:YES];
    if (didChange || [self isTitleOutOfSync]) {
        [self.sleepResult save];
        [self.collectionView reloadData];
    }
}

- (BOOL)isTitleOutOfSync {
    NSString *currentTitleText = [self.sleepSummaryCell.dateButton titleForState:UIControlStateNormal];
    return ![currentTitleText isEqualToString:[self titleTextForDate]];
}

- (void)configureCollectionView {
    NSBundle *bundle = [NSBundle mainBundle];
    [self.collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([HEMNoSleepEventCollectionViewCell class])
                                                    bundle:bundle]
          forCellWithReuseIdentifier:sleepSegmentReuseIdentifier];
    [self.collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([HEMSleepSummaryCollectionViewCell class])
                                                    bundle:bundle]
          forCellWithReuseIdentifier:sleepSummaryReuseIdentifier];
    [self.collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([HEMSleepEventCollectionViewCell class])
                                                    bundle:bundle]
          forCellWithReuseIdentifier:sleepEventReuseIdentifier];
    [self.collectionView registerNib:[UINib nibWithNibName:NSStringFromClass(
                                                               [HEMTimelineFooterCollectionReusableView class])
                                                    bundle:bundle]
          forSupplementaryViewOfKind:UICollectionElementKindSectionFooter
                 withReuseIdentifier:timelineFooterReuseIdentifier];
    [self.collectionView registerNib:[UINib nibWithNibName:NSStringFromClass(
                                                                             [HEMTimelineFooterCollectionReusableView class])
                                                    bundle:bundle]
          forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                 withReuseIdentifier:timelineFooterReuseIdentifier];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:SENAuthorizationServiceDidAuthorizeNotification
                                                  object:nil];
}

- (NSUInteger)numberOfSleepSegments {
    return self.sleepResult.segments.count;
}

- (HEMSleepSummaryCollectionViewCell *)sleepSummaryCell {
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:HEMSleepGraphCollectionViewSummarySection];
    return (id)[self.collectionView cellForItemAtIndexPath:indexPath];
}

#pragma mark - Loading

- (RTSpinKitView *)loadingView {
    return self.sleepSummaryCell.spinnerView;
}

- (BOOL)shouldShowLoadingView {
    return [self numberOfSleepSegments] == 0;
}

- (void)showLoadingView {
    if (![self shouldBeLoading])
        return;

    if (self.loadingView) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
        [self.loadingView startAnimating];
    } else { self.beLoading = YES; }
}

- (void)hideLoadingViewAnimated:(BOOL)animated {
    self.beLoading = NO;
    CGFloat duration = animated ? 0.25f : 0;
    [UIView animateWithDuration:duration
        animations:^{ self.loadingView.alpha = 0; }
        completion:^(BOOL finished) {
          [self.loadingView stopAnimating];
          self.loadingView.alpha = 1;
        }];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 2;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    switch (section) {
        case HEMSleepGraphCollectionViewSummarySection:
            return 1;
        case HEMSleepGraphCollectionViewSegmentSection:
            return self.numberOfSleepSegments;
        default:
            return 0;
    }
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath {
    UICollectionReusableView *view = [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                                        withReuseIdentifier:timelineFooterReuseIdentifier
                                                                               forIndexPath:indexPath];
    view.hidden = !(indexPath.section == HEMSleepGraphCollectionViewSegmentSection
                    && [collectionView numberOfItemsInSection:HEMSleepGraphCollectionViewSegmentSection] > 0);
    return view;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = nil;
    CGFloat zPosition = indexPath.row + 1;
    switch (indexPath.section) {
        case HEMSleepGraphCollectionViewSummarySection:
            cell = [self collectionView:collectionView sleepSummaryCellForItemAtIndexPath:indexPath];
            break;
        case HEMSleepGraphCollectionViewSegmentSection: {
            if ([self segmentForSleepExistsAtIndexPath:indexPath]) {
                cell = [self collectionView:collectionView sleepSegmentCellForItemAtIndexPath:indexPath];
            } else {
                cell = [self collectionView:collectionView sleepEventCellForItemAtIndexPath:indexPath];
                zPosition += HEMSleepGraphEventZPositionOffset;
            }
            break;
        }
    }

    if (cell.layer.zPosition != zPosition)
        [cell.layer setZPosition:zPosition];

    if ([collectionView.delegate respondsToSelector:@selector(didLoadCell:atIndexPath:)])
        [(id<HEMSleepGraphActionDelegate>)collectionView.delegate didLoadCell:cell atIndexPath:indexPath];
    return cell;
}

- (BOOL)dateIsLastNight {
    NSDateComponents *diff = [self.calendar components:NSDayCalendarUnit
                                              fromDate:self.dateForNightOfSleep
                                                toDate:[[NSDate date] previousDay]
                                               options:0];
    return diff.day == 0;
}

- (NSString *)titleTextForDate {
    NSDateComponents *diff = [self.calendar components:NSDayCalendarUnit
                                              fromDate:self.dateForNightOfSleep
                                                toDate:[[NSDate date] previousDay]
                                               options:0];
    if (diff.day == 0)
        return NSLocalizedString(@"sleep-history.last-night", nil);
    else if (diff.day < 7)
        return [self.weekdayDateFormatter stringFromDate:self.dateForNightOfSleep];
    else
        return [self.rangeDateFormatter stringFromDate:self.dateForNightOfSleep];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
      sleepSummaryCellForItemAtIndexPath:(NSIndexPath *)indexPath {
    HEMSleepSummaryCollectionViewCell *cell =
        [collectionView dequeueReusableCellWithReuseIdentifier:sleepSummaryReuseIdentifier forIndexPath:indexPath];
    NSInteger score = [self.sleepResult.score integerValue];
    [cell setSleepScore:score animated:YES];
    cell.messageLabel.textAlignment = NSTextAlignmentCenter;
    NSDictionary *attributes = [HEMMarkdown attributesForTimelineMessageText];
    cell.messageLabel.attributedText = [markdown_to_attr_string(self.sleepResult.message, 0, attributes) trim];
    [self configurePresleepSummaryForCell:cell];
    [self configureActionsForSleepSummaryCell:cell];
    [cell.dateButton setTitle:[self titleTextForDate] forState:UIControlStateNormal];
    if ([self shouldBeLoading])
        [self performSelector:@selector(showLoadingView) withObject:nil afterDelay:0.5];
    else
        [cell.spinnerView stopAnimating];
    return cell;
}

- (void)configureActionsForSleepSummaryCell:(HEMSleepSummaryCollectionViewCell *)cell {
    if ([self.collectionView.delegate respondsToSelector:@selector(drawerButtonTapped:)])
        [cell.drawerButton addTarget:self.collectionView.delegate
                              action:@selector(drawerButtonTapped:)
                    forControlEvents:UIControlEventTouchUpInside];
    if ([self.collectionView.delegate respondsToSelector:@selector(shouldHideShareButton)])
        cell.shareButton.alpha =
            [(id<HEMSleepGraphActionDelegate>)self.collectionView.delegate shouldHideShareButton] ? 0 : 1.f;
    if ([self.collectionView.delegate respondsToSelector:@selector(shouldEnableZoomButton)])
        cell.dateButton.enabled =
            [(id<HEMSleepGraphActionDelegate>)self.collectionView.delegate shouldEnableZoomButton];
    if ([self.collectionView.delegate respondsToSelector:@selector(shareButtonTapped:)])
        [cell.shareButton addTarget:self.collectionView.delegate
                             action:@selector(shareButtonTapped:)
                   forControlEvents:UIControlEventTouchUpInside];
    if ([self.collectionView.delegate respondsToSelector:@selector(zoomButtonTapped:)])
        [cell.dateButton addTarget:self.collectionView.delegate
                            action:@selector(zoomButtonTapped:)
                  forControlEvents:UIControlEventTouchUpInside];
}

- (NSString *)shortValueForMinuteValue:(NSNumber *)minuteValue {
    if (!minuteValue)
        return NSLocalizedString(@"empty-data", nil);

    CGFloat minutes = [minuteValue floatValue];
    NSString *format;
    if (minutes < 60) {
        format = NSLocalizedString(@"sleep-stat.minute.format", nil);
        return [NSString stringWithFormat:format, minutes];
    } else {
        format = NSLocalizedString(@"sleep-stat.hour.format", nil);
        return [NSString stringWithFormat:format, minutes / 60];
    }
}

- (void)configurePresleepSummaryForCell:(HEMSleepSummaryCollectionViewCell *)cell {
    NSDictionary *attributes = [HEMMarkdown attributesForTimelineMessageText];
    if (self.sleepResult.sensorInsights.count > 4) {
        SENSleepResultSensorInsight *insight = self.sleepResult.sensorInsights[4];
        cell.presleepInsightLabel5.attributedText = [markdown_to_attr_string(insight.message, 0, attributes) trim];
        cell.presleepImageView5.image = [self imageForPresleepInsight:insight];
        cell.presleepImageView5.tintColor = [UIColor colorForSensorWithCondition:insight.condition];
    }

    if (self.sleepResult.sensorInsights.count > 3) {
        SENSleepResultSensorInsight *insight = self.sleepResult.sensorInsights[3];
        cell.presleepInsightLabel4.attributedText = [markdown_to_attr_string(insight.message, 0, attributes) trim];
        cell.presleepImageView4.image = [self imageForPresleepInsight:insight];
        cell.presleepImageView4.tintColor = [UIColor colorForSensorWithCondition:insight.condition];
    }

    if (self.sleepResult.sensorInsights.count > 2) {
        SENSleepResultSensorInsight *insight = self.sleepResult.sensorInsights[2];
        cell.presleepInsightLabel3.attributedText = [markdown_to_attr_string(insight.message, 0, attributes) trim];
        cell.presleepImageView3.image = [self imageForPresleepInsight:insight];
        cell.presleepImageView3.tintColor = [UIColor colorForSensorWithCondition:insight.condition];
    }

    if (self.sleepResult.sensorInsights.count > 1) {
        SENSleepResultSensorInsight *insight = self.sleepResult.sensorInsights[1];
        cell.presleepInsightLabel2.attributedText = [markdown_to_attr_string(insight.message, 0, attributes) trim];
        cell.presleepImageView2.image = [self imageForPresleepInsight:insight];
        cell.presleepImageView2.tintColor = [UIColor colorForSensorWithCondition:insight.condition];
    }

    if (self.sleepResult.sensorInsights.count > 0) {
        SENSleepResultSensorInsight *insight = self.sleepResult.sensorInsights[0];
        cell.presleepInsightLabel1.attributedText = [markdown_to_attr_string(insight.message, 0, attributes) trim];
        cell.presleepImageView1.image = [self imageForPresleepInsight:insight];
        cell.presleepImageView1.tintColor = [UIColor colorForSensorWithCondition:insight.condition];
    }
}

- (UIImage *)imageForPresleepInsight:(SENSleepResultSensorInsight *)insight {
    UIImage *image = nil;
    if ([insight.name isEqualToString:sensorTypeTemperature]) {
        image = [HelloStyleKit presleepInsightTemperature];
    } else if ([insight.name isEqualToString:sensorTypeHumidity]) {
        image = [HelloStyleKit presleepInsightHumidity];
    } else if ([insight.name isEqualToString:sensorTypeParticulates]) {
        image = [HelloStyleKit presleepInsightParticulates];
    } else if ([insight.name isEqualToString:sensorTypeLight]) {
        image = [HelloStyleKit presleepInsightLight];
    } else if ([insight.name isEqualToString:sensorTypeSound]) { image = [HelloStyleKit presleepInsightSound]; } else {
        image = [HelloStyleKit presleepInsightUnknown];
    }

    return [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
      sleepSegmentCellForItemAtIndexPath:(NSIndexPath *)indexPath {
    SENSleepResultSegment *segment = [self sleepSegmentForIndexPath:indexPath];
    NSUInteger sleepDepth = segment.sleepDepth;
    HEMNoSleepEventCollectionViewCell *cell =
        [collectionView dequeueReusableCellWithReuseIdentifier:sleepSegmentReuseIdentifier forIndexPath:indexPath];
    UIColor *color = nil, *lineColor = nil;
    CGFloat fillRatio = sleepDepth / (float)SENSleepResultSegmentDepthDeep;
    if ([segment.eventType isEqualToString:HEMSleepEventTypeSleeping]) {
        color = [UIColor colorForSleepDepth:sleepDepth];
        lineColor = [HelloStyleKit timelineLineColor];
    } else {
        color = [UIColor colorForGenericMotionDepth:sleepDepth];
        lineColor = [UIColor clearColor];
    }
    [cell setSegmentRatio:fillRatio withFillColor:color lineColor:lineColor];
    [self configureTimeLabelsForCell:cell withSegment:segment indexPath:indexPath];
    return cell;
}

- (void)configureTimeLabelsForCell:(HEMSleepSegmentCollectionViewCell *)cell
                       withSegment:(SENSleepResultSegment *)segment
                         indexPath:(NSIndexPath *)indexPath {
    static CGFloat const HEMTimeLabelZPositionOffset = 2;
    NSInteger zPosition = indexPath.row + HEMTimeLabelZPositionOffset;
    [cell removeAllTimeLabels];
    if (!segment)
        return;
    NSCalendarUnit units = (NSCalendarUnitSecond | NSCalendarUnitMinute | NSCalendarUnitHour | NSCalendarUnitDay);
    NSDateComponents *components = [self.calendar components:units fromDate:segment.date];
    self.hourDateFormatter.timeZone = segment.timezone;
    self.timeDateFormatter.timeZone = segment.timezone;
    if (components.minute == 0 && components.second == 0) {
        [cell addTimeLabelWithText:[self.timeDateFormatter stringFromDate:segment.date] atHeightRatio:0];
        if (cell.layer.zPosition != zPosition)
            cell.layer.zPosition = zPosition;
    }
    NSTimeInterval segmentInterval = [segment.date timeIntervalSince1970];
    NSDate *endDate = [NSDate dateWithTimeIntervalSince1970:segmentInterval + [segment.duration doubleValue]];
    NSTimeInterval endInterval = [endDate timeIntervalSince1970];
    int i = 1;
    NSTimeInterval hourInterval = 0;
    while (hourInterval < endInterval) {
        NSDateComponents *hourComponents = [NSDateComponents new];
        hourComponents.hour = i;
        hourComponents.minute = -components.minute;
        hourComponents.second = -components.second;
        NSDate *hourDate = [self.calendar dateByAddingComponents:hourComponents toDate:segment.date options:0];
        hourInterval = [hourDate timeIntervalSince1970];
        if (hourInterval < endInterval) {
            CGFloat ratio = ([hourDate timeIntervalSince1970] - segmentInterval) / (endInterval - segmentInterval);
            NSString *timeText = [self.hourDateFormatter stringFromDate:hourDate];
            [cell addTimeLabelWithText:timeText atHeightRatio:ratio];
            if (cell.layer.zPosition != zPosition)
                cell.layer.zPosition = zPosition;
        }
        i++;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
        sleepEventCellForItemAtIndexPath:(NSIndexPath *)indexPath {
    HEMSleepEventCollectionViewCell *cell =
        [collectionView dequeueReusableCellWithReuseIdentifier:sleepEventReuseIdentifier forIndexPath:indexPath];
    SENSleepResultSegment *segment = [self sleepSegmentForIndexPath:indexPath];
    if (!segment)
        return cell;
    NSUInteger sleepDepth = segment.sleepDepth;
    if (segment.sound) {
        cell.audioPlayerView.hidden = NO;
        [cell setAudioURL:[NSURL URLWithString:segment.sound.URLPath]];
    } else if ([HEMTimelineFeedbackViewController canAdjustTimeForSegment:segment]
               && [collectionView.delegate respondsToSelector:@selector(didTapDataVerifyButton:)]) {
        cell.verifyDataButton.hidden = NO;
        [cell.verifyDataButton addTarget:collectionView.delegate
                                  action:@selector(didTapDataVerifyButton:)
                        forControlEvents:UIControlEventTouchUpInside];
    }

    [cell.eventTypeImageView setImage:[self imageForEventType:segment.eventType]];
    NSString *timeText = [self timeTextForSegment:segment];
    cell.eventTimeLabel.text = timeText;
    cell.eventMessageLabel.attributedText = [HEMSleepEventCollectionViewCell attributedMessageFromText:segment.message];
    cell.firstSegment = [self.sleepResult.segments indexOfObject:segment] == 0;
    cell.lastSegment = [self.sleepResult.segments indexOfObject:segment] == self.sleepResult.segments.count - 1;
    [cell setSegmentRatio:sleepDepth / (float)SENSleepResultSegmentDepthDeep
            withFillColor:[UIColor colorForSleepDepth:sleepDepth]
                lineColor:[HelloStyleKit timelineLineColor]];
    [self configureTimeLabelsForCell:cell withSegment:segment indexPath:indexPath];
    cell.layer.masksToBounds = NO;
    return cell;
}

#pragma mark - Data Parsing

- (SENSleepResultSegment *)sleepSegmentForIndexPath:(NSIndexPath *)indexPath {
    NSArray *segments = self.sleepResult.segments;
    if (indexPath.row >= segments.count || indexPath.section != HEMSleepGraphCollectionViewSegmentSection)
        return nil;
    return segments[indexPath.row];
}

- (UIImage *)imageForEventType:(NSString *)eventType {
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
    else if ([eventType isEqualToString:HEMSleepEventTypeAlarm]
             || [eventType isEqualToString:HEMSleepEventTypeSmartAlarm])
        return [HelloStyleKit alarmEventIcon];

    return [HelloStyleKit unknownEventIcon];
}

- (NSString *)timeTextForSegment:(SENSleepResultSegment *)segment {
    self.timeDateFormatter.timeZone = segment.timezone;
    return [self.timeDateFormatter stringFromDate:segment.date];
}

- (BOOL)segmentForSleepExistsAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath.section == HEMSleepGraphCollectionViewSegmentSection
           && ![self segmentForEventExistsAtIndexPath:indexPath];
}

- (BOOL)segmentForEventExistsAtIndexPath:(NSIndexPath *)indexPath {
    SENSleepResultSegment *segment = [self sleepSegmentForIndexPath:indexPath];
    return ![segment.eventType isEqual:[NSNull null]] && segment.eventType.length > 0
           && ![segment.eventType isEqualToString:HEMSleepEventTypeSleeping];
}

@end
