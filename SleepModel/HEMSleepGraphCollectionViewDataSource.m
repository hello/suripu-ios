
#import <SenseKit/SENSettings.h>
#import <SenseKit/SENSensor.h>
#import <SenseKit/SENSleepResult.h>
#import <SenseKit/SENAPITimeline.h>
#import <SenseKit/SENAuthorizationService.h>
#import <SpinKit/RTSpinKitView.h>
#import <markdown_peg.h>

#import "HEMSleepGraphCollectionViewDataSource.h"
#import "HEMSleepGraphViewController.h"
#import "HEMSleepSummaryCollectionViewCell.h"
#import "HEMSleepEventCollectionViewCell.h"
#import "HEMNoSleepEventCollectionViewCell.h"
#import "HEMTimelineHeaderCollectionReusableView.h"
#import "HEMPresleepHeaderCollectionReusableView.h"
#import "HEMPresleepItemCollectionViewCell.h"
#import "HEMSleepScoreGraphView.h"
#import "HelloStyleKit.h"
#import "UIFont+HEMStyle.h"
#import "UIColor+HEMStyle.h"
#import "HEMMarkdown.h"

NSString* const HEMSleepEventTypeWakeUp = @"WAKE_UP";
NSString* const HEMSleepEventTypeLight = @"LIGHT";
NSString* const HEMSleepEventTypeMotion = @"MOTION";
NSString* const HEMSleepEventTypeNoise = @"NOISE";
NSString* const HEMSleepEventTypeSunrise = @"SUNRISE";
NSString* const HEMSleepEventTypeSunset = @"SUNSET";
NSString* const HEMSleepEventTypeFallAsleep = @"SLEEP";

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

static NSString* const sleepSegmentReuseIdentifier = @"sleepSegmentCell";
static NSString* const sleepSummaryReuseIdentifier = @"sleepSummaryCell";
static NSString* const presleepHeaderReuseIdentifier = @"presleepCell";
static NSString* const timelineHeaderReuseIdentifier = @"timelineHeaderCell";
static NSString* const presleepItemReuseIdentifier = @"presleepItemCell";
static NSString* const sleepEventReuseIdentifier = @"sleepEventCell";
static NSString* const sensorTypeTemperature = @"temperature";
static NSString* const sensorTypeHumidity = @"humidity";
static NSString* const sensorTypeParticulates = @"particulates";

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
    NSString* localizedFormat = [NSString stringWithFormat:@"sleep-event.type.%@.name", [eventType lowercaseString]];
    NSString* eventName = NSLocalizedString(localizedFormat, nil);
    if ([eventName isEqualToString:localizedFormat]) {
        return [eventType capitalizedString];
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
    }
    __weak typeof(self) weakSelf = self;
    [SENAPITimeline timelineForDate:self.dateForNightOfSleep completion:^(NSArray* timelines, NSError* error) {
        __strong HEMSleepGraphCollectionViewDataSource* strongSelf = weakSelf;
        if (error) {
            DDLogVerbose(@"Failed to fetch timeline: %@", error.localizedDescription);
            [strongSelf hideLoadingView];
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
    [self hideLoadingView];
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
    [self.collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([HEMPresleepHeaderCollectionReusableView class]) bundle:bundle]
          forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                 withReuseIdentifier:presleepHeaderReuseIdentifier];
    [self.collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([HEMTimelineHeaderCollectionReusableView class]) bundle:bundle]
          forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                 withReuseIdentifier:timelineHeaderReuseIdentifier];
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

- (void)hideLoadingView
{
    self.beLoading = NO;
    [UIView animateWithDuration:0.25f animations:^{
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
        return self.numberOfSleepSegments > 0 ? self.sleepResult.sensorInsights.count : 0;
    default:
        return 0;
    }
}

- (UICollectionReusableView*)collectionView:(UICollectionView*)collectionView viewForSupplementaryElementOfKind:(NSString*)kind atIndexPath:(NSIndexPath*)indexPath
{
    UICollectionReusableView* view = nil;
    switch (indexPath.section) {
        case HEMSleepGraphCollectionViewPresleepSection: {
            view = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:presleepHeaderReuseIdentifier forIndexPath:indexPath];
            view.hidden = !([kind isEqualToString:UICollectionElementKindSectionHeader] && [collectionView numberOfItemsInSection:HEMSleepGraphCollectionViewPresleepSection] > 0);
        } break;

        case HEMSleepGraphCollectionViewSegmentSection:
        default: {
            view = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:timelineHeaderReuseIdentifier forIndexPath:indexPath];
            view.hidden = !([kind isEqualToString:UICollectionElementKindSectionHeader] && [collectionView numberOfItemsInSection:HEMSleepGraphCollectionViewSegmentSection] > 0);
        }    break;
    }
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
        [cell.eventTypeButton addTarget:collectionView.delegate action:@selector(didTapEventButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    [cell.eventTypeButton setImage:[self imageForEventType:segment.eventType] forState:UIControlStateNormal];
    BOOL showLargeButton = [segment.eventType isEqualToString:HEMSleepEventTypeWakeUp]
        || [segment.eventType isEqualToString:HEMSleepEventTypeFallAsleep];
    [cell showLargeButton:showLargeButton];
    cell.eventTypeButton.layer.borderColor = [UIColor colorForSleepDepth:sleepDepth].CGColor;
    cell.eventTimeLabel.text = [self textForTimeInterval:[segment.date timeIntervalSince1970]];

    cell.eventTitleLabel.text = [[self class] localizedNameForSleepEventType:segment.eventType];
    cell.firstSegment = [self.sleepResult.segments indexOfObject:segment] == 0;
    cell.lastSegment = [self.sleepResult.segments indexOfObject:segment] == self.sleepResult.segments.count - 1;
    [cell setSegmentRatio:sleepDepth / (float)SENSleepResultSegmentDepthDeep withColor:[UIColor colorForSleepDepth:sleepDepth]];
    return cell;
}

- (UICollectionViewCell*)collectionView:(UICollectionView*)collectionView
         presleepCellForItemAtIndexPath:(NSIndexPath*)indexPath
{
    HEMPresleepItemCollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:presleepItemReuseIdentifier forIndexPath:indexPath];
    SENSleepResultSensorInsight* insight = self.sleepResult.sensorInsights[indexPath.row];
    cell.messageLabel.text = insight.message;
    [self configureImageView:cell.typeImageView forInsight:insight];
    return cell;
}

- (void)configureImageView:(UIImageView*)imageView forInsight:(SENSleepResultSensorInsight*)insight
{
    NSString* suffix = nil;
    UIColor* color = nil;
    switch (insight.condition) {
        case SENSensorConditionIdeal:
            suffix = @"good";
            color = [HelloStyleKit idealSensorColor];
            break;
        case SENSensorConditionWarning:
            suffix = @"bad";
            color = [HelloStyleKit warningSensorColor];
            break;
        case SENSensorConditionUnknown:
        case SENSensorConditionAlert:
        default:
            suffix = @"medium";
            color = [HelloStyleKit alertSensorColor];
            break;
    }
    if (suffix && color) {
        imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@-%@", insight.name, suffix]];
        imageView.layer.borderColor = color.CGColor;
    } else {
        imageView.image = nil;
        imageView.layer.borderColor = [HelloStyleKit alertSensorColor].CGColor;
    }
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

- (UIImage*)imageForEventType:(NSString*)eventType
{
    if ([eventType isEqualToString:HEMSleepEventTypeWakeUp]) {
        return [UIImage imageNamed:@"wakeup"];
    }
    else if ([eventType isEqualToString:HEMSleepEventTypeFallAsleep]) {
        return [UIImage imageNamed:@"asleep"];
    }
    else if ([eventType isEqualToString:HEMSleepEventTypeLight]) {
        return [UIImage imageNamed:@"light"];
    }
    else if ([eventType isEqualToString:HEMSleepEventTypeNoise]) {
        return [UIImage imageNamed:@"sound"];
    }
    else if ([eventType isEqualToString:HEMSleepEventTypeMotion]) {
        return [UIImage imageNamed:@"movement"];
    }
    else if ([eventType isEqualToString:HEMSleepEventTypeSunrise]) {
        return [UIImage imageNamed:@"sunrise"];
    }
    else if ([eventType isEqualToString:HEMSleepEventTypeSunset]) {
        return [UIImage imageNamed:@"sunset"];
    }
    return nil;
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
