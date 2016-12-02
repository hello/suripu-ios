
#import <SenseKit/SENPreference.h>
#import <SenseKit/SENSensor.h>
#import <SenseKit/SENTimeline.h>
#import <SenseKit/SENAPITimeline.h>
#import <SenseKit/SENAuthorizationService.h>
#import <SenseKit/SENAppUnreadStats.h>
#import "markdown_peg.h"

#import "HEMSleepGraphCollectionViewDataSource.h"
#import "HEMSleepGraphViewController.h"
#import "HEMSleepSummaryCollectionViewCell.h"
#import "HEMSleepEventCollectionViewCell.h"
#import "HEMTimelineFooterCollectionReusableView.h"
#import "HEMSleepScoreGraphView.h"
#import "NSAttributedString+HEMUtils.h"
#import "UIFont+HEMStyle.h"
#import "UIColor+HEMStyle.h"
#import "HEMTimelineFeedbackViewController.h"
#import "HEMMarkdown.h"
#import "NSDate+HEMRelative.h"
#import "HEMSplitTextFormatter.h"
#import "HEMEventBubbleView.h"
#import "HEMWaveform.h"
#import "HEMTimelineMessageContainerView.h"
#import "HEMTimelineService.h"

@interface HEMSleepGraphCollectionViewDataSource ()

@property (nonatomic, weak) UICollectionView *collectionView;
@property (nonatomic, strong) NSDateFormatter *hourDateFormatter;
@property (nonatomic, strong) NSDateFormatter *timeDateFormatter;
@property (nonatomic, strong) NSDateFormatter *meridiemFormatter;
@property (nonatomic, strong) NSDate *dateForNightOfSleep;
@property (nonatomic, strong, readwrite) SENTimeline *sleepResult;
@property (nonatomic, strong) NSArray *aggregateDataSources;
@property (nonatomic, getter=isLoading, readwrite) BOOL loading;
@property (nonatomic, strong) NSCalendar *calendar;
@property (nonatomic, strong) HEMSplitTextFormatter *inlineNumberFormatter;
@property (nonatomic, weak) HEMTimelineService* timelineService;
@property (nonatomic, copy) NSString* dateTitle;

@end

@implementation HEMSleepGraphCollectionViewDataSource

static NSString *const sleepSegmentReuseIdentifier = @"sleepSegmentCell";
static NSString *const sleepSummaryReuseIdentifier = @"sleepSummaryCell";
static NSString *const presleepHeaderReuseIdentifier = @"presleepCell";
static NSString *const timelineFooterReuseIdentifier = @"timelineFooterCell";
static NSString *const presleepItemReuseIdentifier = @"presleepItemCell";
static NSString *const sleepEventReuseIdentifier = @"sleepEventCell";

CGFloat const HEMTimelineMaxSleepDepth = 100.f;

+ (NSString *)localizedNameForSleepEventType:(NSString *)eventType {
    NSString *const sleepEventNameFindCharacter = @"_";
    NSString *const sleepEventNameReplaceCharacter = @" ";
    NSString *const sleepEventNameFormat = @"sleep-event.type.%@.name";
    NSString *localizedFormat = [NSString stringWithFormat:sleepEventNameFormat, [eventType lowercaseString]];
    NSString *eventName = NSLocalizedString(localizedFormat, nil);
    if ([eventName isEqualToString:localizedFormat]) {
        return [[eventType capitalizedString] stringByReplacingOccurrencesOfString:sleepEventNameFindCharacter
                                                                        withString:sleepEventNameReplaceCharacter];
    }
    return eventName;
}

- (instancetype)initWithCollectionView:(UICollectionView *)collectionView
                             sleepDate:(NSDate *)date
                       timelineService:(HEMTimelineService*)timelineService {
    if (self = [super init]) {
        _collectionView = collectionView;
        _dateForNightOfSleep = date;
        _timelineService = timelineService;
        _dateTitle = [timelineService stringValueForTimelineDate:date];
        _timeDateFormatter = [NSDateFormatter new];
        _hourDateFormatter = [NSDateFormatter new];
        _meridiemFormatter = [NSDateFormatter new];
        _inlineNumberFormatter = [HEMSplitTextFormatter new];
        _sleepResult = [SENTimeline timelineForDate:date];
        [self configureCollectionView];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(reloadData)
                                                     name:SENAuthorizationServiceDidAuthorizeNotification
                                                   object:nil];
    }
    return self;
}

- (void)reloadDateFormatters {
    NSString *localeIdentifier = [[NSLocale currentLocale] localeIdentifier];
    NSLocale *standardLocale = [NSLocale localeWithLocaleIdentifier:localeIdentifier];
    _meridiemFormatter.locale = standardLocale;
    _timeDateFormatter.locale = standardLocale;
    _hourDateFormatter.locale = standardLocale;
    _meridiemFormatter.dateFormat = @"a";
    if ([SENPreference timeFormat] == SENTimeFormat12Hour) {
        _timeDateFormatter.dateFormat = @"h:mm";
        _hourDateFormatter.dateFormat = @"h";
    } else {
        _timeDateFormatter.dateFormat = @"HH:mm";
        _hourDateFormatter.dateFormat = @"HH:00";
    }
    _calendar = [NSCalendar currentCalendar];
}

- (void)refreshData {
    self.sleepResult = [SENTimeline timelineForDate:self.dateForNightOfSleep];
    [self reloadDateFormatters];
    [self.collectionView reloadData];
}

- (void)reloadData {
    [self reloadData:nil];
}

- (void)reloadData:(void (^)(NSError*))completion {
    self.loading = YES;
    [self reloadDateFormatters];
    self.sleepResult = [SENTimeline timelineForDate:self.dateForNightOfSleep];
    if (self.dateForNightOfSleep) {
        [SENAnalytics track:HEMAnalyticsEventTimelineDataRequest
                 properties:@{ kHEMAnalyticsEventPropDate : self.dateForNightOfSleep }];
    }

    __weak typeof(self) weakSelf = self;
    [self fetchTimelineForDate:self.dateForNightOfSleep
                    completion:^(SENTimeline *timeline, NSError *error) {
                      __strong typeof(weakSelf) strongSelf = weakSelf;
                      if (!error) {
                          if (!timeline.date) {
                              timeline.date = strongSelf.dateForNightOfSleep;
                          }
                          [strongSelf refreshWithTimeline:timeline];
                          [strongSelf prefetchAdjacentTimelinesForDate:strongSelf.dateForNightOfSleep];
                      }
                      strongSelf.loading = NO;
                      if (completion)
                          completion(error);
                    }];
}

- (void)fetchTimelineForDate:(NSDate *)date completion:(void (^)(SENTimeline *, NSError *))completion {
    [SENAPITimeline timelineForDate:date
                         completion:^(SENTimeline *timeline, NSError *error) {
                           if (error) {
                               [SENAnalytics trackError:error];
                               DDLogVerbose(@"Failed to fetch timeline: %@", error.localizedDescription);
                           }
                           if (completion)
                               completion(timeline, error);
                         }];
}

- (void)prefetchAdjacentTimelinesForDate:(NSDate *)date {
    [self prefetchTimelineForDate:[date previousDay]];
    if (![self dateIsLastNight])
        [self prefetchTimelineForDate:[date nextDay]];
}

- (void)prefetchTimelineForDate:(NSDate *)date {
    SENTimeline *timeline = [SENTimeline timelineForDate:date];
    if ([timeline.score integerValue] == 0) {
        [self fetchTimelineForDate:date
                        completion:^(SENTimeline *timeline, NSError *error) {
                          if (!error)
                              [timeline save];
                        }];
    }
}

- (void)refreshWithTimeline:(SENTimeline *)timeline {
    if (![timeline isKindOfClass:[SENTimeline class]])
        return;
    BOOL didChange = ![self.sleepResult isEqual:timeline];
    if (didChange) {
        self.sleepResult = timeline;
        [self.sleepResult save];
        [self.collectionView reloadData];
    }
}

- (void)configureCollectionView {
    NSBundle *bundle = [NSBundle mainBundle];
    [self.collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([HEMSleepSegmentCollectionViewCell class])
                                                    bundle:bundle]
          forCellWithReuseIdentifier:sleepSegmentReuseIdentifier];
    [self.collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([HEMSleepSummaryCollectionViewCell class])
                                                    bundle:bundle]
          forCellWithReuseIdentifier:sleepSummaryReuseIdentifier];
    [self.collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([HEMSleepEventCollectionViewCell class])
                                                    bundle:bundle]
          forCellWithReuseIdentifier:sleepEventReuseIdentifier];
    
    NSString* footerClazzName = NSStringFromClass([HEMTimelineFooterCollectionReusableView class]);
    [self.collectionView registerNib:[UINib nibWithNibName:footerClazzName bundle:bundle]
          forSupplementaryViewOfKind:UICollectionElementKindSectionFooter
                 withReuseIdentifier:timelineFooterReuseIdentifier];

    [self.collectionView registerNib:[UINib nibWithNibName:footerClazzName bundle:bundle]
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

- (BOOL)hasTimelineData {
    return self.sleepResult.scoreCondition != SENConditionUnknown
        && self.sleepResult.scoreCondition != SENConditionIncomplete
        && [self numberOfSleepSegments] > 0;
}

- (BOOL)hasSleepScore {
    return [self.sleepResult.score integerValue] > 0;
}

#pragma mark - Top Bar

- (void)scrollToTop {
    if (!CGPointEqualToPoint(CGPointZero, self.collectionView.contentOffset)
        && [self.collectionView numberOfSections] > 0
        && [self.collectionView numberOfItemsInSection:0] > 0) {
        [self.collectionView setContentOffset:CGPointZero animated:YES];
    }
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
    UICollectionReusableView *view = nil;

    if (indexPath.section == HEMSleepGraphCollectionViewSegmentSection) {

        view = [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                  withReuseIdentifier:timelineFooterReuseIdentifier
                                                         forIndexPath:indexPath];
        view.hidden = [collectionView numberOfItemsInSection:HEMSleepGraphCollectionViewSegmentSection] == 0;
    }

    return view;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = nil;
    switch (indexPath.section) {
        case HEMSleepGraphCollectionViewSummarySection:
            cell = [self collectionView:collectionView sleepSummaryCellForItemAtIndexPath:indexPath];
            break;
        case HEMSleepGraphCollectionViewSegmentSection: {
            if ([self segmentForSleepExistsAtIndexPath:indexPath]) {
                cell = [self collectionView:collectionView sleepSegmentCellForItemAtIndexPath:indexPath];
            } else {
                cell = [self collectionView:collectionView sleepEventCellForItemAtIndexPath:indexPath];
            }
            break;
        }
    }

    cell.layer.shouldRasterize = YES;
    cell.layer.rasterizationScale = [UIScreen mainScreen].scale;
    return cell;
}

- (BOOL)dateIsLastNight {
    NSDateComponents *diff = [self.calendar components:NSCalendarUnitDay
                                              fromDate:self.dateForNightOfSleep
                                                toDate:[[NSDate date] previousDay]
                                               options:0];
    return diff.day == 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
      sleepSummaryCellForItemAtIndexPath:(NSIndexPath *)indexPath {
    HEMSleepSummaryCollectionViewCell *cell =
        [collectionView dequeueReusableCellWithReuseIdentifier:sleepSummaryReuseIdentifier forIndexPath:indexPath];
    NSInteger score = [self.sleepResult.score integerValue];
    [cell setLoading:self.sleepResult.message.length == 0];
    [cell setScore:score message:self.sleepResult.message condition:self.sleepResult.scoreCondition animated:YES];
    if (score > 0 && [collectionView.delegate conformsToProtocol:@protocol(HEMTapDelegate)]) {
        [cell.messageContainerView setTapDelegate:(id)collectionView.delegate];
        [cell.sleepScoreGraphView setTapDelegate:(id)collectionView.delegate];
    }
    cell.messageChevronView.hidden = ![self hasTimelineData];
    cell.messageContainerView.hidden = ![self hasTimelineData];
    return cell;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
      sleepSegmentCellForItemAtIndexPath:(NSIndexPath *)indexPath {
    SENTimelineSegment *segment = [self sleepSegmentForIndexPath:indexPath];
    NSUInteger sleepDepth = segment.sleepDepth;
    HEMSleepSegmentCollectionViewCell *cell =
        [collectionView dequeueReusableCellWithReuseIdentifier:sleepSegmentReuseIdentifier forIndexPath:indexPath];
    if ([collectionView.delegate respondsToSelector:@selector(shouldHideSegmentCellContents)]) {
        id<HEMSleepGraphActionDelegate> delegate = (id)collectionView.delegate;
        if ([delegate shouldHideSegmentCellContents])
            [cell prepareForEntryAnimation];
    }
    UIColor *color = nil, *previousColor = nil;
    CGFloat fillRatio = sleepDepth / HEMTimelineMaxSleepDepth;
    CGFloat previousFillRatio = 0;
    color = [UIColor colorForSleepState:segment.sleepState];
    if (indexPath.row > 0) {
        NSIndexPath *previousIndexPath = [NSIndexPath indexPathForRow:indexPath.row - 1 inSection:indexPath.section];
        SENTimelineSegment *previousSegment = [self sleepSegmentForIndexPath:previousIndexPath];
        previousColor = [UIColor colorForSleepState:previousSegment.sleepState];
        previousFillRatio = previousSegment.sleepDepth / HEMTimelineMaxSleepDepth;
    } else {
        previousColor = [UIColor clearColor];
    }
    [self configureTimeLabelsForCell:cell withSegment:segment indexPath:indexPath];
    [cell setSegmentRatio:fillRatio withFillColor:color previousRatio:previousFillRatio previousColor:previousColor];
    cell.accessibilityValue = [self accessibleSummaryForSegmentAtIndexPath:indexPath];
    cell.accessibilityLabel = NSLocalizedString(@"sleep-segment.accessibility-label", nil);
    cell.isAccessibilityElement = YES;
    return cell;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
        sleepEventCellForItemAtIndexPath:(NSIndexPath *)indexPath {
    HEMSleepEventCollectionViewCell *cell =
        [collectionView dequeueReusableCellWithReuseIdentifier:sleepEventReuseIdentifier forIndexPath:indexPath];
    SENTimelineSegment *segment = [self sleepSegmentForIndexPath:indexPath];
    if (!segment)
        return cell;
    NSUInteger sleepDepth = segment.sleepDepth;
    if ([collectionView.delegate respondsToSelector:@selector(shouldHideSegmentCellContents)]) {
        id<HEMSleepGraphActionDelegate> delegate = (id)collectionView.delegate;
        if ([delegate shouldHideSegmentCellContents])
            [cell prepareForEntryAnimation];
    }
    [cell.eventTypeImageView setImage:[self imageForEventType:segment.type]];
    NSAttributedString *timeText = nil;
    if (segment.type != SENTimelineSegmentTypeAlarmRang) {
        timeText = [self formattedTextForInlineTimestamp:segment.date withFormatter:self.timeDateFormatter];
    }
    cell.contentContainerView.userInteractionEnabled = segment.possibleActions != SENTimelineSegmentActionNone;
    [cell layoutWithImage:[self imageForEventType:segment.type]
                  message:segment.message
                     time:timeText
                 waveform:[self waveformForIndexPath:indexPath]];
    cell.firstSegment = [self.sleepResult.segments indexOfObject:segment] == 0;
    cell.lastSegment = [self.sleepResult.segments indexOfObject:segment] == self.sleepResult.segments.count - 1;
    UIColor *previousColor = nil;
    CGFloat previousRatio = 0;
    if (indexPath.row > 0) {
        NSIndexPath *previousIndexPath = [NSIndexPath indexPathForRow:indexPath.row - 1 inSection:indexPath.section];
        SENTimelineSegment *previousSegment = [self sleepSegmentForIndexPath:previousIndexPath];
        previousColor = [UIColor colorForSleepState:previousSegment.sleepState];
        previousRatio = previousSegment.sleepDepth / HEMTimelineMaxSleepDepth;
    } else {
        previousColor = [UIColor clearColor];
    }
    [self configureTimeLabelsForCell:cell withSegment:segment indexPath:indexPath];
    [cell setSegmentRatio:sleepDepth / HEMTimelineMaxSleepDepth
            withFillColor:[UIColor colorForSleepState:segment.sleepState]
            previousRatio:previousRatio
            previousColor:previousColor];
    [cell.playButton addTarget:collectionView.delegate
                        action:@selector(toggleAudio:)
              forControlEvents:UIControlEventTouchUpInside];
    return cell;
}

- (void)configureTimeLabelsForCell:(HEMSleepSegmentCollectionViewCell *)cell
                       withSegment:(SENTimelineSegment *)segment
                         indexPath:(NSIndexPath *)indexPath {
    [cell removeAllTimeLabels];
    if (!segment)
        return;
    NSCalendarUnit units = (NSCalendarUnitSecond | NSCalendarUnitMinute | NSCalendarUnitHour | NSCalendarUnitDay);
    NSDateComponents *components = [self.calendar components:units fromDate:segment.date];
    self.hourDateFormatter.timeZone = segment.timezone;
    self.timeDateFormatter.timeZone = segment.timezone;
    if (components.minute == 0 && components.second == 0) {
        NSAttributedString *text =
            [self formattedTextForInlineTimestamp:segment.date withFormatter:self.hourDateFormatter];
        [cell addTimeLabelWithText:text atHeightRatio:0];
    }
    NSTimeInterval segmentInterval = [segment.date timeIntervalSince1970];
    NSDate *endDate = [NSDate dateWithTimeIntervalSince1970:segmentInterval + segment.duration];
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
            NSAttributedString *text =
                [self formattedTextForInlineTimestamp:hourDate withFormatter:self.hourDateFormatter];
            [cell addTimeLabelWithText:text atHeightRatio:ratio];
        }
        i++;
    }
}

- (NSAttributedString *)formattedTextForInlineTimestamp:(NSDate *)date {
    return [self formattedTextForInlineTimestamp:date withFormatter:self.timeDateFormatter];
}

- (NSAttributedString *)formattedTextForInlineTimestamp:(NSDate *)date withFormatter:(NSDateFormatter *)formatter {
    NSString *timeText = [formatter stringFromDate:date];
    NSString *unit = nil;
    if ([SENPreference timeFormat] == SENTimeFormat12Hour) {
        self.meridiemFormatter.timeZone = formatter.timeZone;
        unit = [self.meridiemFormatter stringFromDate:date];
    }
    HEMSplitTextObject *obj = [[HEMSplitTextObject alloc] initWithValue:timeText unit:unit];
    NSDictionary *attrs = [HEMMarkdown attributesForTimelineTimeLabelsText][@(PARA)];
    return [self.inlineNumberFormatter attributedStringForObjectValue:obj withDefaultAttributes:attrs];
}

#pragma mark - Data Parsing

- (NSString *)localizationKeyForSleepState:(SENTimelineSegmentSleepState)state {
    switch (state) {
        case SENTimelineSegmentSleepStateSound:
            return @"deep";
        case SENTimelineSegmentSleepStateMedium:
            return @"medium";
        case SENTimelineSegmentSleepStateLight:
            return @"light";
        case SENTimelineSegmentSleepStateAwake:
        default:
            return @"awake";
    }
}

- (NSString *)accessibleSummaryForSegmentAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *const HEMAccessibleSegmentSummaryFormat = @"sleep-stat.accessibility.sleep-state.%@.format";
    SENTimelineSegment* segment = [self sleepSegmentForIndexPath:indexPath];
    NSString* depthKey = [self localizationKeyForSleepState:segment.sleepState];
    NSString* localizedKey = [NSString stringWithFormat:HEMAccessibleSegmentSummaryFormat, depthKey];
    return [NSString stringWithFormat:NSLocalizedString(localizedKey, nil), (long)segment.duration / 60, (long)segment.sleepDepth];
}

- (NSAttributedString *)summaryForSegmentAtIndexPath:(NSIndexPath *)indexPath {
    if (!indexPath)
        return nil;
    static NSString *const HEMPopupTextFormat = @"sleep-stat.sleep-duration.%@";
    SENTimelineSegment* segment = [self sleepSegmentForIndexPath:indexPath];
    NSString *depthKey = [self localizationKeyForSleepState:segment.sleepState];
    NSString *format = [NSString stringWithFormat:HEMPopupTextFormat, depthKey];
    NSString *text = [NSString stringWithFormat:NSLocalizedString(format, nil)];
    return [markdown_to_attr_string(text, 0, [HEMMarkdown attributesForTimelineSegmentPopup]) trim];
}

- (SENTimelineSegment *)sleepSegmentForIndexPath:(NSIndexPath *)indexPath {
    NSArray *segments = self.sleepResult.segments;
    if (indexPath.row < 0 || indexPath.row >= segments.count
        || indexPath.section != HEMSleepGraphCollectionViewSegmentSection)
        return nil;
    return segments[indexPath.row];
}

- (UIImage *)imageForEventType:(SENTimelineSegmentType)eventType {
    switch (eventType) {
        case SENTimelineSegmentTypeAlarmRang:
            return [UIImage imageNamed:@"alarmEventIcon"];
        case SENTimelineSegmentTypeFellAsleep:
            return [UIImage imageNamed:@"sleepEventIcon"];
        case SENTimelineSegmentTypeGenericMotion:
            return [UIImage imageNamed:@"motionEventIcon"];
        case SENTimelineSegmentTypeGotInBed:
            return [UIImage imageNamed:@"inBedEventIcon"];
        case SENTimelineSegmentTypeGotOutOfBed:
            return [UIImage imageNamed:@"outOfBedEventIcon"];
        case SENTimelineSegmentTypeLight:
            return [UIImage imageNamed:@"lightEventIcon"];
        case SENTimelineSegmentTypeLightsOut:
            return [UIImage imageNamed:@"lightsOutEventIcon"];
        case SENTimelineSegmentTypePartnerMotion:
            return [UIImage imageNamed:@"partnerEventIcon"];
        case SENTimelineSegmentTypeSunrise:
            return [UIImage imageNamed:@"sunriseEventIcon"];
        case SENTimelineSegmentTypeSunset:
            return [UIImage imageNamed:@"sunsetEventIcon"];
        case SENTimelineSegmentTypeWokeUp:
            return [UIImage imageNamed:@"wakeupEventIcon"];

        case SENTimelineSegmentTypeSleepTalked:
        case SENTimelineSegmentTypeSnored:
            return [UIImage imageNamed:@"snoringEventIcon"];
        case SENTimelineSegmentTypeGenericSound:
            return [UIImage imageNamed:@"noiseEventIcon"];
        case SENTimelineSegmentTypeInBed:
        case SENTimelineSegmentTypeUnknown:
        default:
            return [UIImage imageNamed:@"unknownEventIcon"];
    }
}

- (BOOL)segmentForSleepExistsAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath.section == HEMSleepGraphCollectionViewSegmentSection
           && ![self segmentForEventExistsAtIndexPath:indexPath];
}

- (BOOL)segmentForEventExistsAtIndexPath:(NSIndexPath *)indexPath {
    SENTimelineSegment *segment = [self sleepSegmentForIndexPath:indexPath];
    return segment.type != SENTimelineSegmentTypeUnknown && segment.type != SENTimelineSegmentTypeInBed;
}

- (BOOL)segmentForSoundExistsAtIndexPath:(NSIndexPath *)indexPath {
    SENTimelineSegment *segment = [self sleepSegmentForIndexPath:indexPath];
    return segment.type == SENTimelineSegmentTypeGenericSound || segment.type == SENTimelineSegmentTypeSnored;
}

- (HEMWaveform *)waveformForIndexPath:(NSIndexPath *)indexPath {
    return nil; // not supported.  meant for snoring playback
}

- (NSData *)audioDataForIndexPath:(NSIndexPath *)indexPath {
    return nil; // not supported.  meant for snoring playback
}

@end
