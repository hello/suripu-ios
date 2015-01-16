
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
#import "HEMPresleepItemCollectionViewCell.h"
#import "HEMSleepScoreGraphView.h"
#import "HelloStyleKit.h"
#import "UIFont+HEMStyle.h"
#import "UIColor+HEMStyle.h"
#import "HEMMarkdown.h"

NSString* const HEMSleepEventTypeWakeUp = @"WAKE_UP";

@interface HEMSleepGraphCollectionViewDataSource ()

@property (nonatomic, weak) UICollectionView* collectionView;
@property (nonatomic, strong) NSDateFormatter* timeDateFormatter;
@property (nonatomic, strong) NSDateFormatter* rangeDateFormatter;
@property (nonatomic, strong) NSDate* dateForNightOfSleep;
@property (nonatomic, strong, readwrite) SENSleepResult* sleepResult;
@property (nonatomic, strong) NSArray* aggregateDataSources;
@property (nonatomic, getter=shouldBeLoading) BOOL beLoading;
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
static NSString* const sleepEventNameFindCharacter = @"_";
static NSString* const sleepEventNameReplaceCharacter = @" ";
static NSString* const sleepEventNameFormat = @"sleep-event.type.%@.name";

+ (NSDateFormatter*)sleepDateFormatter
{
    static NSDateFormatter* formatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"MMMM d";
    });
    return formatter;
}

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
    NSString* message = self.sleepResult.message;
    NSNumber* score = self.sleepResult.score;
    NSDictionary* timeline = [timelines firstObject];
    [self.sleepResult updateWithDictionary:timeline];
    [self.sleepResult save];
    [self hideLoadingViewAnimated:YES];
    if ([self.sleepResult.message isEqualToString:message] && [self.sleepResult.score isEqual:score]) {
        NSMutableIndexSet* set = [NSMutableIndexSet indexSetWithIndex:HEMSleepGraphCollectionViewSegmentSection];
        [set addIndex:HEMSleepGraphCollectionViewPresleepSection];
        [self.collectionView reloadSections:set];
    } else {
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
    [self.collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([HEMPresleepItemCollectionViewCell class]) bundle:bundle]
          forCellWithReuseIdentifier:presleepItemReuseIdentifier];
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
    return 3;
}

- (NSInteger)collectionView:(UICollectionView*)collectionView numberOfItemsInSection:(NSInteger)section
{
    switch (section) {
    case HEMSleepGraphCollectionViewSummarySection:
        return 1;
    case HEMSleepGraphCollectionViewSegmentSection:
        return self.numberOfSleepSegments;
    case HEMSleepGraphCollectionViewPresleepSection:
        return self.numberOfSleepSegments > 0 && self.sleepResult.sensorInsights.count > 0 ? 1 : 0;
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
    switch (indexPath.section) {
    case HEMSleepGraphCollectionViewSummarySection: {
        return [self collectionView:collectionView sleepSummaryCellForItemAtIndexPath:indexPath];
    }
    case HEMSleepGraphCollectionViewSegmentSection: {
        if ([self segmentForSleepExistsAtIndexPath:indexPath]) {
            return [self collectionView:collectionView sleepSegmentCellForItemAtIndexPath:indexPath];
        }
        else {
            return [self collectionView:collectionView sleepEventCellForItemAtIndexPath:indexPath];
        }
    }
    case HEMSleepGraphCollectionViewPresleepSection: {
        return [self collectionView:collectionView presleepCellForItemAtIndexPath:indexPath];
    }
    default:
        return nil;
    }
}

- (UICollectionViewCell*)collectionView:(UICollectionView*)collectionView
     sleepSummaryCellForItemAtIndexPath:(NSIndexPath*)indexPath
{
    HEMSleepSummaryCollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:sleepSummaryReuseIdentifier forIndexPath:indexPath];
    NSInteger score = [self.sleepResult.score integerValue];
    [cell setSleepScore:score animated:YES];
    if (score == 0) {
        cell.messageTitleLabel.hidden = YES;
        cell.messageLabel.textAlignment = NSTextAlignmentCenter;
    } else {
        cell.messageTitleLabel.hidden = NO;
        cell.messageLabel.textAlignment = NSTextAlignmentLeft;
    }
    NSDictionary* attributes = [HEMMarkdown attributesForTimelineMessageText];
    cell.messageLabel.attributedText = markdown_to_attr_string(self.sleepResult.message, 0, attributes);
    NSString* dateText = [[[self class] sleepDateFormatter] stringFromDate:self.dateForNightOfSleep];
    NSString* lastNightDateText = [[[self class] sleepDateFormatter] stringFromDate:[NSDate dateWithTimeInterval:-60 * 60 * 24 sinceDate:[NSDate date]]];
    if ([dateText isEqualToString:lastNightDateText])
        dateText = NSLocalizedString(@"sleep-history.last-night", nil);

    [cell.dateButton setTitle:dateText forState:UIControlStateNormal];
    if ([self shouldBeLoading])
        [self performSelector:@selector(showLoadingView) withObject:nil afterDelay:0.5];

    if ([self.collectionView.delegate respondsToSelector:@selector(drawerButtonTapped:)])
        [cell.drawerButton addTarget:self.collectionView.delegate
                              action:@selector(drawerButtonTapped:)
                    forControlEvents:UIControlEventTouchUpInside];
    if ([self.collectionView.delegate respondsToSelector:@selector(shouldHideShareButton)])
        cell.shareButton.hidden = [(id<HEMSleepGraphActionDelegate>)self.collectionView.delegate
                                   shouldHideShareButton];
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
    return cell;
}

- (UICollectionViewCell*)collectionView:(UICollectionView*)collectionView
     sleepSegmentCellForItemAtIndexPath:(NSIndexPath*)indexPath
{
    SENSleepResultSegment* segment = [self sleepSegmentForIndexPath:indexPath];
    NSUInteger sleepDepth = segment.sleepDepth;
    HEMNoSleepEventCollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:sleepSegmentReuseIdentifier forIndexPath:indexPath];
    [cell setSegmentRatio:sleepDepth / (float)SENSleepResultSegmentDepthDeep withColor:[UIColor colorForSleepDepth:sleepDepth]];
    return cell;
}

- (UICollectionViewCell*)collectionView:(UICollectionView*)collectionView
       sleepEventCellForItemAtIndexPath:(NSIndexPath*)indexPath
{
    SENSleepResultSegment* segment = [self sleepSegmentForIndexPath:indexPath];
    NSUInteger sleepDepth = segment.sleepDepth;
    HEMSleepEventCollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:sleepEventReuseIdentifier forIndexPath:indexPath];
    if ([collectionView.delegate respondsToSelector:@selector(didTapEventButton:)]) {
        [cell.eventTypeButton addTarget:collectionView.delegate
                                 action:@selector(didTapEventButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    if (segment.sound) {
        cell.waveformView.hidden = NO;
        cell.playSoundButton.hidden = NO;
        [cell setAudioURL:[NSURL URLWithString:segment.sound.URLPath]];
    } else if ([collectionView.delegate respondsToSelector:@selector(didTapDataVerifyButton:)]
               && [segment.eventType isEqualToString:HEMSleepEventTypeWakeUp]) {
        cell.verifyDataButton.hidden = NO;
        [cell.verifyDataButton addTarget:collectionView.delegate
                                  action:@selector(didTapDataVerifyButton:) forControlEvents:UIControlEventTouchUpInside];
    }

    [cell.eventTypeButton setImage:[self imageForEventType:segment.eventType] forState:UIControlStateNormal];
    cell.eventTimeLabel.text = [self textForTimeInterval:[segment.date timeIntervalSince1970]];
    BOOL isImportantEvent = [segment.eventType isEqualToString:HEMSleepEventTypeWakeUp]
        || [segment.eventType isEqualToString:HEMSleepEventTypeFallAsleep];
    cell.eventTimeLabel.font = isImportantEvent ? [UIFont timelineEventTimestampBoldFont] : [UIFont timelineEventTimestampFont];
    cell.eventTitleLabel.text = [[[self class] localizedNameForSleepEventType:segment.eventType] uppercaseString];
    cell.eventMessageLabel.attributedText = markdown_to_attr_string(segment.message, 0, [HEMMarkdown attributesForEventMessageText]);
    cell.firstSegment = [self.sleepResult.segments indexOfObject:segment] == 0;
    cell.lastSegment = [self.sleepResult.segments indexOfObject:segment] == self.sleepResult.segments.count - 1;
    [cell setSegmentRatio:sleepDepth / (float)SENSleepResultSegmentDepthDeep withColor:[UIColor colorForSleepDepth:sleepDepth]];
    return cell;
}

- (UICollectionViewCell*)collectionView:(UICollectionView*)collectionView
         presleepCellForItemAtIndexPath:(NSIndexPath*)indexPath
{
    HEMPresleepItemCollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:presleepItemReuseIdentifier forIndexPath:indexPath];
    [cell addButtonsForInsights:self.sleepResult.sensorInsights];
    if ([collectionView.delegate conformsToProtocol:@protocol(HEMPresleepActionDelegate)])
        cell.presleepActionDelegate = (id<HEMPresleepActionDelegate>)collectionView.delegate;
    return cell;
}

#pragma mark - Data Parsing

- (SENSleepResultSegment*)sleepSegmentForIndexPath:(NSIndexPath*)indexPath
{
    return indexPath.section == HEMSleepGraphCollectionViewSegmentSection ? self.sleepResult.segments[indexPath.row] : nil;
}

- (UIImage*)imageForEventType:(NSString*)eventType
{
    if ([eventType isEqualToString:HEMSleepEventTypeWakeUp]) {
        return [HelloStyleKit wakeupEventIcon];
    }
    else if ([eventType isEqualToString:HEMSleepEventTypeFallAsleep]) {
        return [HelloStyleKit sleepEventIcon];
    }
    else if ([eventType isEqualToString:HEMSleepEventTypeLight]) {
        return [HelloStyleKit lightEventIcon];
    }
    else if ([eventType isEqualToString:HEMSleepEventTypeNoise]) {
        return [HelloStyleKit noiseEventIcon];
    }
    else if ([eventType isEqualToString:HEMSleepEventTypeMotion]) {
        return [HelloStyleKit motionEventIcon];
    }
    else if ([eventType isEqualToString:HEMSleepEventTypeSunrise]) {
        return [HelloStyleKit sunriseEventIcon];
    }
    else if ([eventType isEqualToString:HEMSleepEventTypeSunset]) {
        return [HelloStyleKit sunsetEventIcon];
    }
    else if ([eventType isEqualToString:HEMSleepEventTypeLightsOut]) {
        return [HelloStyleKit lightsOutEventIcon];
    }
    else if ([eventType isEqualToString:HEMSleepEventTypePartnerMotion]) {
        return [HelloStyleKit partnerEventIcon];
    }
    return [HelloStyleKit unknownEventIcon];
}

- (NSString*)textForTimeInterval:(NSTimeInterval)timeInterval
{
    return [[self.timeDateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:timeInterval]] lowercaseString];
}

- (BOOL)segmentForSleepExistsAtIndexPath:(NSIndexPath*)indexPath
{
    return indexPath.section == HEMSleepGraphCollectionViewSegmentSection && ![self segmentForEventExistsAtIndexPath:indexPath];
}

- (BOOL)segmentForEventExistsAtIndexPath:(NSIndexPath*)indexPath
{
    SENSleepResultSegment* segment = [self sleepSegmentForIndexPath:indexPath];
    return ![segment.eventType isEqual:[NSNull null]] && segment.eventType.length > 0;
}

@end
