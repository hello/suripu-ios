
#import <SenseKit/SenseKit.h>
#import <UIImageEffects/UIImage+ImageEffects.h>

#import "HelloStyleKit.h"
#import "HEMRootViewController.h"
#import "HEMAudioCache.h"
#import "HEMMainStoryboard.h"
#import "HEMSleepEventCollectionViewCell.h"
#import "HEMSleepGraphCollectionViewDataSource.h"
#import "HEMSleepGraphView.h"
#import "HEMSleepGraphViewController.h"
#import "HEMSleepHistoryViewController.h"
#import "HEMSleepSummaryCollectionViewCell.h"
#import "HEMNoSleepEventCollectionViewCell.h"
#import "HEMSleepSummarySlideViewController.h"
#import "UIFont+HEMStyle.h"
#import "UIView+HEMSnapshot.h"
#import "HEMSleepEventButton.h"
#import "HEMZoomAnimationTransitionDelegate.h"
#import "HEMBounceModalTransition.h"
#import "HEMTimelineFeedbackViewController.h"
#import "HEMAlertViewController.h"
#import "HEMTutorial.h"
#import "HEMPopupView.h"

CGFloat const HEMTimelineHeaderCellHeight = 50.f;
CGFloat const HEMTimelineFooterCellHeight = 50.f;

@interface HEMSleepGraphViewController () <UICollectionViewDelegateFlowLayout, UIGestureRecognizerDelegate>

@property (nonatomic, retain) HEMSleepGraphView* view;
@property (nonatomic, strong) HEMSleepHistoryViewController* historyViewController;
@property (nonatomic, strong) HEMSleepGraphCollectionViewDataSource* dataSource;
@property (nonatomic, strong) HEMZoomAnimationTransitionDelegate* animationDelegate;
@property (nonatomic, strong) NSIndexPath* expandedIndexPath;
@property (nonatomic, getter=presleepSectionIsExpanded) BOOL presleepExpanded;
@property (nonatomic, strong) UIPanGestureRecognizer* panGestureRecognizer;
@property (nonatomic, strong) HEMBounceModalTransition* dataVerifyTransitionDelegate;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint* shortcutButtonTrailing;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint* shortcutButtonBottom;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint* popupViewTop;
@property (nonatomic, weak) IBOutlet UIButton* shortcutButton;
@property (nonatomic, weak) IBOutlet HEMPopupView* popupView;
@property (nonatomic, assign, getter=isLastNight) BOOL lastNight;
@end

@implementation HEMSleepGraphViewController

static CGFloat const HEMSleepSummaryCellHeight = 384.f;
static CGFloat const HEMSleepGraphCollectionViewEventTitleOnlyHeight = 86.f;
static CGFloat const HEMSleepGraphCollectionViewEventMinimumHeight = 44.f;
static CGFloat const HEMSleepGraphCollectionViewNumberOfHoursOnscreen = 10.f;
static CGFloat const HEMTopItemsConstraintConstant = 4.f;
static CGFloat const HEMTopItemsMinimumConstraintConstant = -6.f;
static CGFloat const HEMEventOverlayZPosition = 30.f;
static CGFloat const HEMAlarmShortcutDefaultTrailing = 8.f;
static CGFloat const HEMAlarmShortcutHiddenTrailing = -60.f;
static CGFloat const HEMAlarmShortcutBottomOffset = 20.f;
static CGFloat const HEMAlarmShortcutDefaultBottom = 10.f;

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self configureCollectionView];
    [self reloadData];
    self.animationDelegate = [HEMZoomAnimationTransitionDelegate new];
    self.dataVerifyTransitionDelegate = [HEMBounceModalTransition new];
    self.dataVerifyTransitionDelegate.message = NSLocalizedString(@"sleep-event.feedback.success.message", nil);
    self.transitioningDelegate = self.animationDelegate;
    self.panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(didPan)];
    self.panGestureRecognizer.delegate = self;
    [self.collectionView.panGestureRecognizer requireGestureRecognizerToFail:self.panGestureRecognizer];
    [self.view addGestureRecognizer:self.panGestureRecognizer];
    [self registerForNotifications];
    [self adjustHeight];

    [SENAnalytics track:kHEMAnalyticsEventTimeline
             properties:@{ kHEMAnalyticsEventPropDate : [self dateForNightOfSleep] ?: @"undefined" }];
}

- (void)showTutorial
{
    if (![HEMTutorial shouldShowTutorialForTimeline])
        return;
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.65f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        if (![self isViewFullyVisible] || self.dataSource.numberOfSleepSegments == 0)
//            return;
//        [HEMTutorial showTutorialForTimelineIfNeeded];
//    });
    [HEMTutorial showTutorialForTimelineIfNeeded];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.view.backgroundColor = [UIColor whiteColor];
    [self checkForDateChanges];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self showTutorial];
}

- (void)drawerDidOpen
{
    [UIView animateWithDuration:0.5f animations:^{
        [self updateTopBarActionsWithState:NO];
    }];
}

- (void)drawerDidClose
{
    [self showTutorial];
    [UIView animateWithDuration:0.5f animations:^{
        [self updateTopBarActionsWithState:YES];
    }];
}

- (void)registerForNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadData)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadData)
                                                 name:SENAPIReachableNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadData)
                                                 name:HEMTimelineFeedbackSuccessNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleAuthorization)
                                                 name:SENAuthorizationServiceDidAuthorizeNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(drawerDidOpen)
                                                 name:HEMRootDrawerMayOpenNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(drawerDidClose)
                                                 name:HEMRootDrawerMayCloseNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(drawerDidOpen)
                                                 name:HEMRootDrawerDidOpenNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(drawerDidClose)
                                                 name:HEMRootDrawerDidCloseNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(adjustHeight)
                                                 name:UIApplicationDidChangeStatusBarFrameNotification
                                               object:nil];
}

- (void)adjustHeight
{
    CGRect statusBarFrame = [[UIApplication sharedApplication] statusBarFrame];
    CGFloat statusBarHeight = MIN(CGRectGetHeight(statusBarFrame), CGRectGetWidth(statusBarFrame));
    CGFloat bottomOffset = HEMAlarmShortcutDefaultBottom + (statusBarHeight - HEMAlarmShortcutBottomOffset);
    self.shortcutButtonBottom.constant = bottomOffset;
    [self.view setNeedsUpdateConstraints];
    [self.shortcutButton layoutIfNeeded];
}

- (void)handleAuthorization
{
    if (![self isViewLoaded])
        [self view];
    [self reloadData];
}

- (void)dealloc
{
    _historyViewController = nil;
    _dataSource = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark HEMSleepGraphActionDelegate

- (void)toggleDrawer
{
    HEMRootViewController* root = [HEMRootViewController rootViewControllerForKeyWindow];
    [root toggleSettingsDrawer];
}

- (BOOL)shouldEnableZoomButton
{
    return [self isViewFullyVisible];
}

- (BOOL)shouldHideShareButton
{
    return ![self isViewFullyVisible] || [self.dataSource.sleepResult.score integerValue] == 0;
}

- (void)willShowDetailsForInsight:(SENSleepResultSensorInsight*)insight
{
    if (![self presleepSectionIsExpanded]) {
        self.presleepExpanded = YES;
        [self animateAllCellHeightChanges];
    }
}

- (void)willHideInsightDetails
{
    if ([self presleepSectionIsExpanded]) {
        self.presleepExpanded = NO;
        [self animateAllCellHeightChanges];
    }
}

- (void)didLoadCell:(UICollectionViewCell*)cell atIndexPath:(NSIndexPath*)indexPath
{
    if ([cell isKindOfClass:[HEMSleepEventCollectionViewCell class]]) {
        if (![self.expandedIndexPath isEqual:indexPath])
            return;
        HEMSleepEventCollectionViewCell* eventCell = (id)cell;
        CGSize size = [self collectionView:self.collectionView
                                    layout:self.collectionView.collectionViewLayout
                    sizeForItemAtIndexPath:indexPath];
        [eventCell useExpandedLayout:YES targetSize:size animated:NO];
        eventCell.layer.zPosition = indexPath.row + HEMEventOverlayZPosition;
    }
    else if ([cell isKindOfClass:[HEMSleepSummaryCollectionViewCell class]]) {
        HEMSleepSummaryCollectionViewCell* summaryCell = (id)cell;
        if (![self isViewFullyVisible])
            [self updateTopBarActionsInCell:summaryCell withState:NO];
    }
}

#pragma mark Top cell actions

- (void)updateTopBarActionsWithState:(BOOL)pushed
{
    HEMSleepSummaryCollectionViewCell* cell = self.dataSource.sleepSummaryCell;
    [self updateTopBarActionsInCell:cell withState:pushed];
}

- (void)updateTopBarActionsInCell:(HEMSleepSummaryCollectionViewCell*)cell withState:(BOOL)pushed
{
    if (!pushed)
        self.collectionView.contentOffset = CGPointMake(0, 0);
    self.collectionView.scrollEnabled = pushed;
    UIImage* drawerIcon = pushed ? [UIImage imageNamed:@"Menu"] : [UIImage imageNamed:@"caret up"];
    CGFloat constant = pushed ? HEMTopItemsConstraintConstant : HEMTopItemsMinimumConstraintConstant;
    [cell.dateButton setEnabled:pushed];
    [cell.drawerButton setImage:drawerIcon forState:UIControlStateNormal];
    cell.topItemsVerticalConstraint.constant = constant;
    [cell setNeedsUpdateConstraints];
    BOOL shouldHideShareButton = !pushed || self.dataSource.numberOfSleepSegments == 0;
    [UIView animateWithDuration:0.25f animations:^{
        [cell.shareButton setAlpha:shouldHideShareButton ? 0 : 1.f];
        [cell.dateButton setAlpha:pushed ? 1.f : 0.5f];
        [cell layoutIfNeeded];
    }];
}

- (void)drawerButtonTapped:(UIButton*)button
{
    [self toggleDrawer];
}

- (void)shareButtonTapped:(UIButton*)button
{
    long score = [self.dataSource.sleepResult.score longValue];
    if (score > 0) {
        NSString* message;
        if (self.lastNight) {
            message = [NSString stringWithFormat:NSLocalizedString(@"activity.share.last-night.format", nil), score];
        }
        else {
            message = [NSString stringWithFormat:NSLocalizedString(@"activity.share.other-days.format", nil), score, [self.dataSource titleTextForDate]];
        }
        UIActivityViewController* activityController = [[UIActivityViewController alloc] initWithActivityItems:@[ message ]
                                                                                         applicationActivities:nil];
        [self presentViewController:activityController animated:YES completion:nil];
    }
}

- (void)zoomButtonTapped:(UIButton*)sender
{
    if (![self isViewFullyVisible])
        return;
    self.historyViewController = (id)[HEMMainStoryboard instantiateSleepHistoryController];
    self.historyViewController.selectedDate = self.dateForNightOfSleep;
    self.historyViewController.transitioningDelegate = self.animationDelegate;
    [self presentViewController:self.historyViewController animated:YES completion:NULL];
}

- (void)checkForDateChanges
{
    if (self.historyViewController.selectedDate) {
        HEMRootViewController* root = [HEMRootViewController rootViewControllerForKeyWindow];
        [root reloadTimelineSlideViewControllerWithDate:self.historyViewController.selectedDate];
    }

    self.historyViewController = nil;
}

- (void)loadDataSourceForDate:(NSDate*)date
{
    self.dateForNightOfSleep = date;
    self.expandedIndexPath = nil;
    self.presleepExpanded = NO;
    self.dataSource = [[HEMSleepGraphCollectionViewDataSource alloc] initWithCollectionView:self.collectionView
                                                                                  sleepDate:date];
    self.collectionView.dataSource = self.dataSource;
}

#pragma mark Event Info

- (void)didTapEventButton:(UIButton*)sender
{
    NSIndexPath* indexPath = [self indexPathForEventCellWithSubview:sender];
    HEMSleepEventCollectionViewCell* cell = (id)[self.collectionView cellForItemAtIndexPath:indexPath];
    BOOL shouldExpand = ![self.expandedIndexPath isEqual:indexPath];
    if (shouldExpand) {
        if (self.expandedIndexPath) {
            HEMSleepEventCollectionViewCell* oldCell = (id)[self.collectionView cellForItemAtIndexPath:self.expandedIndexPath];
            oldCell.layer.zPosition = indexPath.row + 1;
            if ([oldCell isKindOfClass:[HEMSleepEventCollectionViewCell class]]) {
                [oldCell useExpandedLayout:NO targetSize:CGSizeZero animated:YES];
            }
        }
        self.expandedIndexPath = indexPath;

        NSMutableDictionary* properties
            = [@{ kHEMAnalyticsEventPropAction : kHEMAnalyticsEventPropEvent } mutableCopy];
        SENSleepResultSegment* segment = [self.dataSource sleepSegmentForIndexPath:indexPath];
        if ([segment eventType] != nil) {
            properties[kHEMAnalyticsEventPropType] = [segment eventType];
        }
        [SENAnalytics track:kHEMAnalyticsEventTimelineAction properties:properties];
    }
    else {
        self.expandedIndexPath = nil;
    }
    CGSize size = [self collectionView:self.collectionView
                                layout:self.collectionView.collectionViewLayout
                sizeForItemAtIndexPath:indexPath];

    if ([cell isKindOfClass:[HEMSleepEventCollectionViewCell class]]) {
        cell.layer.zPosition = indexPath.row + HEMEventOverlayZPosition;
        [cell useExpandedLayout:shouldExpand targetSize:size animated:YES];
    }
    [self animateAllCellHeightChanges];
    CGRect cellRect = [self.collectionView convertRect:cell.frame toView:self.collectionView.superview];
    if (shouldExpand && !CGRectContainsRect(self.collectionView.frame, cellRect))
        [self.collectionView scrollToItemAtIndexPath:indexPath
                                    atScrollPosition:UICollectionViewScrollPositionCenteredVertically
                                            animated:YES];
}

- (void)didTapDataVerifyButton:(UIButton*)sender
{
    NSIndexPath* indexPath = [self indexPathForEventCellWithSubview:sender];
    UINavigationController* navController = [HEMMainStoryboard instantiateTimelineFeedbackViewController];
    navController.transitioningDelegate = self.dataVerifyTransitionDelegate;
    navController.modalPresentationStyle = UIModalPresentationCustom;
    HEMTimelineFeedbackViewController* feedbackController = (id)navController.topViewController;
    feedbackController.dateForNightOfSleep = self.dateForNightOfSleep;
    feedbackController.segment = [self.dataSource sleepSegmentForIndexPath:indexPath];
    [self presentViewController:navController animated:YES completion:NULL];
}

- (void)feedbackFailedToSend:(NSNotification*)note
{
    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [HEMAlertViewController showInfoDialogWithTitle:NSLocalizedString(@"sleep-event.feedback.failed.title", nil)
                                                message:NSLocalizedString(@"sleep-event.feedback.failed.message", nil)
                                             controller:weakSelf];
    });
}

- (IBAction)didTapAlarmShortcut:(id)sender
{
    [SENAnalytics track:HEMAnalyticsEventTimelineAlarmShortcut properties:nil];
    HEMRootViewController* root = [HEMRootViewController rootViewControllerForKeyWindow];
    [root showSettingsDrawerTabAtIndex:HEMRootDrawerTabAlarms animated:YES];
}

- (NSIndexPath*)indexPathForEventCellWithSubview:(UIView*)view
{
    UIView* superview = view.superview;
    if (superview) {
        if ([superview isKindOfClass:[HEMSleepEventCollectionViewCell class]])
            return [self.collectionView indexPathForCell:(UICollectionViewCell*)superview];
        else
            return [self indexPathForEventCellWithSubview:superview];
    }
    return nil;
}

#pragma mark UIGestureRecognizerDelegate

- (IBAction)didLongPress:(UILongPressGestureRecognizer*)sender
{
    static CGFloat const HEMPopupAnimationDistance = 8.f;
    static CGFloat const HEMPopupSpacingDistance = 20.f;
    if (sender.state == UIGestureRecognizerStateBegan) {
        [SENAnalytics track:HEMAnalyticsEventTimelineBarLongPress];
        CGPoint cellLocation = [sender locationInView:self.collectionView];
        NSIndexPath* indexPath = [self.collectionView indexPathForItemAtPoint:cellLocation];
        UICollectionViewCell* cell = [self.collectionView cellForItemAtIndexPath:indexPath];
        if ([cell isKindOfClass:[HEMSleepSegmentCollectionViewCell class]] && ![indexPath isEqual:self.expandedIndexPath]) {
            [(HEMSleepSegmentCollectionViewCell*)cell emphasizeAppearance];
            SENSleepResultSegment* segment = [self.dataSource sleepSegmentForIndexPath:indexPath];
            [self.popupView setText:[self summaryPopupTextForSegment:segment]];
            UICollectionViewLayoutAttributes* attributes = [self.collectionView layoutAttributesForItemAtIndexPath:indexPath];
            CGRect cellLocation = [self.collectionView convertRect:attributes.frame toView:self.view];
            CGFloat top = CGRectGetMinY(cellLocation) - [self.popupView intrinsicContentSize].height - HEMPopupSpacingDistance;
            self.popupViewTop.constant = top - HEMPopupAnimationDistance;
            [self.popupView setNeedsUpdateConstraints];
            [self.popupView layoutIfNeeded];
            self.popupViewTop.constant = top;
            [self.popupView setNeedsUpdateConstraints];
            [UIView animateWithDuration:0.2f animations:^{
                [self.popupView layoutIfNeeded];
                self.popupView.alpha = 1;
            }];
        }
    }
    else if (sender.state == UIGestureRecognizerStateEnded || sender.state == UIGestureRecognizerStateCancelled) {
        [UIView animateWithDuration:0.15f animations:^{
            self.popupView.alpha = 0;
        }];
        for (HEMSleepSegmentCollectionViewCell* cell in self.collectionView.visibleCells) {
            if ([cell respondsToSelector:@selector(deemphasizeAppearance)])
                [cell deemphasizeAppearance];
        }
    }
}

// TODO (jimmy): commenting this out until we want to display duration again.
// In which case, we should also update the localizable.strings files too to
// remove unnecessary strings

//- (NSString*)summaryPopupTextForSegment:(SENSleepResultSegment*)segment
//{
//    static NSString* const HEMPopupTextFormat = @"sleep-stat.%@-duration.%@.%@.format";
//    long minutes = (long)([segment.duration floatValue]/60);
//    NSString* pluralize = minutes == 1 ? @"single" : @"plural";
//    NSString* segmentType = segment.eventType.length == 0 ? @"motion" : @"sleep";
//    NSString* depth;
//    if (segment.sleepDepth == SENSleepResultSegmentDepthAwake)
//        depth = @"awake";
//    else if (segment.sleepDepth >= SENSleepResultSegmentDepthDeep)
//        depth = @"deep";
//    else if (segment.sleepDepth >= SENSleepResultSegmentDepthMedium)
//        depth = @"medium";
//    else
//        depth = @"light";
//
//    NSString* format = [NSString stringWithFormat:HEMPopupTextFormat, segmentType, depth, pluralize];
//    NSString* localizedFormat = NSLocalizedString(format, nil);
//    return minutes == 1 ? localizedFormat : [NSString stringWithFormat:localizedFormat, minutes];
//}

- (NSString*)summaryPopupTextForSegment:(SENSleepResultSegment*)segment
{
    static NSString* const HEMPopupTextFormat = @"sleep-stat.%@-duration.%@";
    NSString* segmentType = segment.eventType.length == 0 ? @"motion" : @"sleep";
    NSString* depth;
    if (segment.sleepDepth == SENSleepResultSegmentDepthAwake)
        depth = @"awake";
    else if (segment.sleepDepth >= SENSleepResultSegmentDepthDeep)
        depth = @"deep";
    else if (segment.sleepDepth >= SENSleepResultSegmentDepthMedium)
        depth = @"medium";
    else
        depth = @"light";

    NSString* format = [NSString stringWithFormat:HEMPopupTextFormat, segmentType, depth];
    return NSLocalizedString(format, nil);
}

- (void)didPan
{
}

- (BOOL)isViewFullyVisible
{
    return ![[HEMRootViewController rootViewControllerForKeyWindow] drawerIsVisible];
}

- (BOOL)shouldAllowRecognizerToReceiveTouch:(UIPanGestureRecognizer*)recognizer
{
    CGPoint velocity = [recognizer velocityInView:self.view];
    BOOL movingMostlyVertically = fabs(velocity.x) <= fabs(velocity.y);
    BOOL movingUpwards = velocity.y > 0;
    return [self isScrolledToTop] && movingUpwards && movingMostlyVertically;
}

- (BOOL)isScrolledToTop
{
    return self.collectionView.contentOffset.y < 10;
}

- (BOOL)gestureRecognizer:(UIPanGestureRecognizer*)gestureRecognizer shouldReceiveTouch:(UITouch*)touch
{
    return [self isScrolledToTop];
}

- (BOOL)gestureRecognizer:(UIPanGestureRecognizer*)gestureRecognizer
    shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer*)otherGestureRecognizer
{
    return ![otherGestureRecognizer isEqual:self.collectionView.panGestureRecognizer];
}

- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer*)gestureRecognizer
{
    return [self shouldAllowRecognizerToReceiveTouch:gestureRecognizer];
}

#pragma mark UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView*)scrollView
{
    CGPoint offset = scrollView.contentOffset;
    CGFloat constant = offset.y > 0 ? HEMAlarmShortcutHiddenTrailing : HEMAlarmShortcutDefaultTrailing;
    [self moveShortcutButtonWithOffset:constant];
}

- (void)scrollViewDidEndDragging:(UIScrollView*)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate) {
        [self moveShortcutButtonWithOffset:HEMAlarmShortcutDefaultTrailing];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView*)scrollView
{
    [self moveShortcutButtonWithOffset:HEMAlarmShortcutDefaultTrailing];
}

- (void)moveShortcutButtonWithOffset:(CGFloat)constant
{
    if (self.shortcutButtonTrailing.constant != constant) {
        if (constant > 0)
            self.shortcutButton.hidden = NO;
        self.shortcutButtonTrailing.constant = constant;
        [self.view setNeedsUpdateConstraints];
        [UIView animateWithDuration:0.2f animations:^{
            [self.view layoutIfNeeded];
        } completion:^(BOOL finished) {
            if (constant < 0)
                self.shortcutButton.hidden = YES;
        }];
    }
}

#pragma mark UICollectionViewDelegate

- (void)reloadData
{
    if (![SENAuthorizationService isAuthorized])
        return;

    [self loadDataSourceForDate:self.dateForNightOfSleep];
    self.lastNight = [self.dataSource dateIsLastNight];
}

- (void)configureCollectionView
{
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.delegate = self;
}

- (BOOL)collectionView:(UICollectionView*)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath*)indexPath
{
    return NO;
}

- (BOOL)collectionView:(UICollectionView*)collectionView shouldSelectItemAtIndexPath:(NSIndexPath*)indexPath
{
    return NO;
}

#pragma mark UICollectionViewDelegateFlowLayout

- (void)animateAllCellHeightChanges
{
    [self.collectionView setCollectionViewLayout:[UICollectionViewFlowLayout new] animated:YES];
}

- (CGSize)collectionView:(UICollectionView*)collectionView
                    layout:(UICollectionViewLayout*)collectionViewLayout
    sizeForItemAtIndexPath:(NSIndexPath*)indexPath
{
    static CGFloat const HEMEventSoundPlayerHeight = 48.f;
    static CGFloat const HEMEventAdjustTimeHeight = 48.f;
    static CGFloat const HEMEventMessageInset = 64.f;
    static CGFloat const HEMEventBottomPadding = 38.f;
    static CGFloat const HEMEventItemSpacing = 10.f;
    BOOL hasSegments = [self.dataSource numberOfSleepSegments] > 0;
    CGFloat width = CGRectGetWidth(self.view.bounds);
    switch (indexPath.section) {
    case HEMSleepGraphCollectionViewSummarySection:
        return CGSizeMake(width, hasSegments ? HEMSleepSummaryCellHeight : CGRectGetHeight(self.view.bounds));

    case HEMSleepGraphCollectionViewSegmentSection: {
        SENSleepResultSegment* segment = [self.dataSource sleepSegmentForIndexPath:indexPath];
        CGFloat durationHeight = [self heightForCellWithSegment:segment];
        if ([self.expandedIndexPath isEqual:indexPath]) {
            CGFloat height = HEMSleepGraphCollectionViewEventTitleOnlyHeight;
            NSAttributedString* message = [HEMSleepEventCollectionViewCell attributedMessageFromText:segment.message];
            NSStringDrawingOptions options = (NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading);
            CGRect textBounds = [message boundingRectWithSize:CGSizeMake(width - HEMEventMessageInset, CGFLOAT_MAX)
                                                      options:options
                                                      context:nil];
            height += ceilf(CGRectGetHeight(textBounds));
            if (segment.sound)
                height += HEMEventSoundPlayerHeight + (HEMEventItemSpacing * 2) + HEMEventBottomPadding;
            else if ([HEMTimelineFeedbackViewController canAdjustTimeForSegment:segment])
                height += HEMEventAdjustTimeHeight + HEMEventBottomPadding;
            else if (message.length > 0)
                height += HEMEventBottomPadding + HEMEventItemSpacing;
            return CGSizeMake(width, height);
        }
        else if ([self.dataSource segmentForEventExistsAtIndexPath:indexPath]) {
            return CGSizeMake(width, MAX(ceilf(durationHeight), HEMSleepGraphCollectionViewEventMinimumHeight));
        }
        else {
            return CGSizeMake(width, ceilf(durationHeight));
        }
    }

    default:
        return CGSizeZero;
    }
}

- (CGFloat)heightForCellWithSegment:(SENSleepResultSegment*)segment
{
    return ([segment.duration doubleValue] / 3600) * (CGRectGetHeight([UIScreen mainScreen].bounds)
                                                         / HEMSleepGraphCollectionViewNumberOfHoursOnscreen);
}

- (CGSize)collectionView:(UICollectionView*)collectionView
                             layout:(UICollectionViewLayout*)collectionViewLayout
    referenceSizeForHeaderInSection:(NSInteger)section
{
    BOOL hasSegments = [self.dataSource numberOfSleepSegments] > 0;
    if (!hasSegments || section != HEMSleepGraphCollectionViewSegmentSection)
        return CGSizeZero;

    return CGSizeMake(CGRectGetWidth(self.view.bounds), HEMTimelineHeaderCellHeight);
}

- (CGSize)collectionView:(UICollectionView*)collectionView
                             layout:(UICollectionViewLayout*)collectionViewLayout
    referenceSizeForFooterInSection:(NSInteger)section
{
    BOOL hasSegments = [self.dataSource numberOfSleepSegments] > 0;
    if (!hasSegments || section != HEMSleepGraphCollectionViewSegmentSection)
        return CGSizeZero;

    return CGSizeMake(CGRectGetWidth(self.view.bounds), HEMTimelineFooterCellHeight);
}

- (CGFloat)collectionView:(UICollectionView*)collectionView
                                 layout:(UICollectionViewLayout*)collectionViewLayout
    minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}

@end
