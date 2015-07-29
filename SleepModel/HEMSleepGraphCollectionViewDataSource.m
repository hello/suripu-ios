
#import <SenseKit/SENPreference.h>
#import <SenseKit/SENSensor.h>
#import <SenseKit/SENTimeline.h>
#import <SenseKit/SENAPITimeline.h>
#import <SenseKit/SENAuthorizationService.h>
#import <markdown_peg.h>

#import "HEMSleepGraphCollectionViewDataSource.h"
#import "HEMSleepGraphViewController.h"
#import "HEMSleepSummaryCollectionViewCell.h"
#import "HEMSleepEventCollectionViewCell.h"
#import "HEMTimelineTopBarCollectionReusableView.h"
#import "HEMTimelineFooterCollectionReusableView.h"
#import "HEMSleepScoreGraphView.h"
#import "NSAttributedString+HEMUtils.h"
#import "HelloStyleKit.h"
#import "UIFont+HEMStyle.h"
#import "UIColor+HEMStyle.h"
#import "HEMTimelineFeedbackViewController.h"
#import "HEMMarkdown.h"
#import "NSDate+HEMRelative.h"
#import "HEMSplitTextFormatter.h"
#import "HEMRootViewController.h"
#import "HEMEventBubbleView.h"
#import "HEMWaveform.h"

@interface HEMSleepGraphCollectionViewDataSource ()

@property (nonatomic, weak) UICollectionView *collectionView;
@property (nonatomic, strong) NSDateFormatter *hourDateFormatter;
@property (nonatomic, strong) NSDateFormatter *timeDateFormatter;
@property (nonatomic, strong) NSDateFormatter *meridiemFormatter;
@property (nonatomic, strong) NSDate *dateForNightOfSleep;
@property (nonatomic, strong, readwrite) SENTimeline *sleepResult;
@property (nonatomic, strong) NSArray *aggregateDataSources;
@property (nonatomic, getter=shouldBeLoading) BOOL beLoading;
@property (nonatomic, strong) NSCalendar *calendar;
@property (nonatomic, strong) HEMSplitTextFormatter *inlineNumberFormatter;
@property (nonatomic, weak) HEMTimelineTopBarCollectionReusableView *topBarView;

@end

@implementation HEMSleepGraphCollectionViewDataSource

static NSString *const sleepSegmentReuseIdentifier = @"sleepSegmentCell";
static NSString *const sleepSummaryReuseIdentifier = @"sleepSummaryCell";
static NSString *const presleepHeaderReuseIdentifier = @"presleepCell";
static NSString *const timelineTopBarReuseIdentifier = @"timelineTopBarCell";
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

- (instancetype)initWithCollectionView:(UICollectionView *)collectionView sleepDate:(NSDate *)date {
    if (self = [super init]) {
        _collectionView = collectionView;
        _dateForNightOfSleep = date;
        _timeDateFormatter = [NSDateFormatter new];
        _hourDateFormatter = [NSDateFormatter new];
        _meridiemFormatter = [NSDateFormatter new];
        _inlineNumberFormatter = [HEMSplitTextFormatter new];
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
        _hourDateFormatter.dateFormat = @"HH";
    }
    _calendar = [NSCalendar currentCalendar];
}

- (void)refreshData {
    self.sleepResult = [SENTimeline timelineForDate:self.dateForNightOfSleep];
    [self reloadDateFormatters];
    [self.collectionView reloadData];
}

- (void)reloadData:(void (^)(void))completion {
    [self reloadDateFormatters];
    self.sleepResult = [SENTimeline timelineForDate:self.dateForNightOfSleep];
    if ([self shouldShowLoadingView]) {
        self.beLoading = YES;
        [self showLoadingView];
    } else {
        self.beLoading = NO;
        [self hideLoadingViewAnimated:NO];
    }

    if (self.dateForNightOfSleep) {
        [SENAnalytics track:HEMAnalyticsEventTimelineDataRequest
                 properties:@{ kHEMAnalyticsEventPropDate : self.dateForNightOfSleep }];
    }

    __weak typeof(self) weakSelf = self;
    [self fetchTimelineForDate:self.dateForNightOfSleep
                    completion:^(SENTimeline *timeline, NSError *error) {
                      __strong typeof(weakSelf) strongSelf = weakSelf;
                      if (error) {
                          [strongSelf hideLoadingViewAnimated:YES];
                      } else {
                          [strongSelf refreshWithTimeline:timeline];
                          [strongSelf prefetchAdjacentTimelinesForDate:strongSelf.dateForNightOfSleep];
                      }
                      if (completion)
                          completion();
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
    [self hideLoadingViewAnimated:YES];
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
    [self.collectionView registerNib:[UINib nibWithNibName:NSStringFromClass(
                                                               [HEMTimelineTopBarCollectionReusableView class])
                                                    bundle:bundle]
          forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                 withReuseIdentifier:timelineTopBarReuseIdentifier];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:SENAuthorizationServiceDidAuthorizeNotification
                                                  object:nil];
}

- (NSUInteger)numberOfSleepSegments {
    return self.sleepResult.segments.count;
}

#pragma mark - Top Bar

- (NSString *)dateTitle {
    return [[self topBarView] dateTitle];
}

- (void)updateTimelineState:(BOOL)isOpen {
    [[self topBarView] setOpened:isOpen];
    [[self topBarView] setShareEnabled:self.sleepResult.score > 0 && !isOpen animated:YES];
    if (isOpen)
        [self scrollToTop];
}

- (void)scrollToTop {
    if (!CGPointEqualToPoint(CGPointZero, self.collectionView.contentOffset)
        && [self.collectionView numberOfSections] > 0 && [self.collectionView numberOfItemsInSection:0] > 0) {
        NSIndexPath *indexPath = [NSIndexPath indexPathWithIndex:0];
        UICollectionViewLayoutAttributes *attrs =
            [self.collectionView layoutAttributesForSupplementaryElementOfKind:UICollectionElementKindSectionHeader
                                                                   atIndexPath:indexPath];
        if (!attrs)
            return;
        [self.collectionView scrollRectToVisible:attrs.frame animated:YES];
    }
}

#pragma mark - Loading

- (BOOL)shouldShowLoadingView {
    return [self numberOfSleepSegments] == 0;
}

- (void)showLoadingView {
}

- (void)hideLoadingViewAnimated:(BOOL)animated {
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
                topBarHeaderViewForIndexPath:(NSIndexPath *)indexPath {

    HEMTimelineTopBarCollectionReusableView *view = nil;
    view = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                              withReuseIdentifier:timelineTopBarReuseIdentifier
                                                     forIndexPath:indexPath];
    id delegate = [collectionView delegate];

    if ([delegate respondsToSelector:@selector(didTapDrawerButton:)]) {
        [[view drawerButton] addTarget:delegate
                                action:@selector(didTapDrawerButton:)
                      forControlEvents:UIControlEventTouchUpInside];
    }

    if ([delegate respondsToSelector:@selector(didTapShareButton:)]) {
        [[view shareButton] addTarget:delegate
                               action:@selector(didTapShareButton:)
                     forControlEvents:UIControlEventTouchUpInside];
    }

    if ([delegate respondsToSelector:@selector(didTapDateButton:)]) {
        [[view dateButton] addTarget:delegate
                              action:@selector(didTapDateButton:)
                    forControlEvents:UIControlEventTouchUpInside];
    }

    NSInteger score = [[[self sleepResult] score] integerValue];
    BOOL drawerClosed = ![[HEMRootViewController rootViewControllerForKeyWindow] drawerIsVisible];
    [view setShareEnabled:score > 0 && drawerClosed animated:YES];

    [view setDate:[self dateForNightOfSleep]];

    [self setTopBarView:view];

    return view;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath {
    UICollectionReusableView *view = nil;

    if (indexPath.section == HEMSleepGraphCollectionViewSummarySection) {

        if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
            view = [self collectionView:collectionView topBarHeaderViewForIndexPath:indexPath];
        }

    } else if (indexPath.section == HEMSleepGraphCollectionViewSegmentSection) {

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
    NSDateComponents *diff = [self.calendar components:NSDayCalendarUnit
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
    NSDictionary *attributes = [HEMMarkdown attributesForTimelineMessageText];
    cell.messageLabel.attributedText = [markdown_to_attr_string(self.sleepResult.message, 0, attributes) trim];
    [cell setLoading:self.sleepResult.message.length == 0];
    [cell setScore:score condition:self.sleepResult.scoreCondition animated:YES];
    if (score > 0 && [collectionView.delegate respondsToSelector:@selector(didTapSummaryButton:)]) {
        [cell.summaryButton addTarget:collectionView.delegate
                               action:@selector(didTapSummaryButton:)
                     forControlEvents:UIControlEventTouchUpInside];
    }
    cell.messageChevronView.hidden = score == 0 && self.sleepResult.segments.count == 0;
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
        timeText = [self formattedTextForInlineTimestamp:segment.date withFormatter:self.timeDateFormatter useUnit:NO];
    }
    [cell layoutWithImage:[self imageForEventType:segment.type] message:segment.message time:timeText];
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
    if ([self segmentForSoundExistsAtIndexPath:indexPath]) {
        [cell displayAudioViewsWithWaveform:[[HEMWaveform alloc] initWithDictionary:@{}]];
    }
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
            [self formattedTextForInlineTimestamp:segment.date withFormatter:self.hourDateFormatter useUnit:YES];
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
                [self formattedTextForInlineTimestamp:hourDate withFormatter:self.hourDateFormatter useUnit:YES];
            [cell addTimeLabelWithText:text atHeightRatio:ratio];
        }
        i++;
    }
}

- (NSAttributedString *)formattedTextForInlineTimestamp:(NSDate *)date {
    return [self formattedTextForInlineTimestamp:date withFormatter:self.timeDateFormatter useUnit:NO];
}

- (NSAttributedString *)formattedTextForInlineTimestamp:(NSDate *)date
                                          withFormatter:(NSDateFormatter *)formatter
                                                useUnit:(BOOL)shouldUseUnit {
    NSString *timeText = [formatter stringFromDate:date];
    NSString *unit = nil;
    if ([SENPreference timeFormat] == SENTimeFormat12Hour) {
        self.meridiemFormatter.timeZone = formatter.timeZone;
        unit = [self.meridiemFormatter stringFromDate:date];
    } else if (shouldUseUnit) {
        unit = NSLocalizedString(@"sleep-event.time.24-hour.suffix", nil);
    }
    HEMSplitTextObject *obj = [[HEMSplitTextObject alloc] initWithValue:timeText unit:unit];
    NSDictionary *attrs = [HEMMarkdown attributesForTimelineTimeLabelsText][@(PARA)];
    return [self.inlineNumberFormatter attributedStringForObjectValue:obj withDefaultAttributes:attrs];
}

#pragma mark - Data Parsing

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
            return [HelloStyleKit alarmEventIcon];
        case SENTimelineSegmentTypeFellAsleep:
            return [HelloStyleKit sleepEventIcon];
        case SENTimelineSegmentTypeGenericMotion:
            return [HelloStyleKit motionEventIcon];
        case SENTimelineSegmentTypeGotInBed:
            return [HelloStyleKit inBedEventIcon];
        case SENTimelineSegmentTypeGotOutOfBed:
            return [HelloStyleKit outOfBedEventIcon];
        case SENTimelineSegmentTypeLight:
            return [HelloStyleKit lightEventIcon];
        case SENTimelineSegmentTypeLightsOut:
            return [HelloStyleKit lightsOutEventIcon];
        case SENTimelineSegmentTypePartnerMotion:
            return [HelloStyleKit partnerEventIcon];
        case SENTimelineSegmentTypeSunrise:
            return [HelloStyleKit sunriseEventIcon];
        case SENTimelineSegmentTypeSunset:
            return [HelloStyleKit sunsetEventIcon];
        case SENTimelineSegmentTypeWokeUp:
            return [HelloStyleKit wakeupEventIcon];

        case SENTimelineSegmentTypeSleepTalked:
        case SENTimelineSegmentTypeSnored:
        case SENTimelineSegmentTypeGenericSound:
            return [HelloStyleKit noiseEventIcon];
        case SENTimelineSegmentTypeInBed:
        case SENTimelineSegmentTypeUnknown:
        default:
            return [HelloStyleKit unknownEventIcon];
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

@end
