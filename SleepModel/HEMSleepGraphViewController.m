
#import <SenseKit/SenseKit.h>
#import <UIImageEffects/UIImage+ImageEffects.h>

#import "HelloStyleKit.h"
#import "HEMActionSheetViewController.h"
#import "HEMAlertViewController.h"
#import "HEMAudioCache.h"
#import "HEMBounceModalTransition.h"
#import "HEMBreakdownViewController.h"
#import "HEMEventAdjustConfirmationView.h"
#import "HEMEventBubbleView.h"
#import "HEMFadingParallaxLayout.h"
#import "HEMMainStoryboard.h"
#import "HEMPopupView.h"
#import "HEMRootViewController.h"
#import "HEMSleepEventCollectionViewCell.h"
#import "HEMSleepGraphCollectionViewDataSource.h"
#import "HEMSleepGraphViewController.h"
#import "HEMSleepHistoryViewController.h"
#import "HEMSleepSummaryCollectionViewCell.h"
#import "HEMSleepSummarySlideViewController.h"
#import "HEMTimelineContainerViewController.h"
#import "HEMTimelineFeedbackViewController.h"
#import "HEMTutorial.h"
#import "HEMZoomAnimationTransitionDelegate.h"
#import "HEMTimelineTopBarView.h"
#import "UIFont+HEMStyle.h"
#import "UIView+HEMSnapshot.h"
#import "HEMActionSheetTitleView.h"

CGFloat const HEMTimelineHeaderCellHeight = 8.f;
CGFloat const HEMTimelineFooterCellHeight = 74.f;

@interface HEMSleepGraphViewController () <UICollectionViewDelegateFlowLayout, UIGestureRecognizerDelegate,
                                           HEMSleepGraphActionDelegate>

@property (nonatomic, strong) HEMSleepGraphCollectionViewDataSource *dataSource;
@property (nonatomic, strong) UIPanGestureRecognizer *panGestureRecognizer;
@property (nonatomic, strong) HEMBounceModalTransition *dataVerifyTransitionDelegate;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *popupViewTop;
@property (nonatomic, weak) IBOutlet HEMPopupView *popupView;
@property (nonatomic, assign, getter=isLastNight) BOOL lastNight;
@property (nonatomic, assign, getter=isLoadingData) BOOL loadingData;
@property (nonatomic, assign, getter=isVisible) BOOL visible;
@end

@implementation HEMSleepGraphViewController

static NSString* const HEMSleepGraphSenseLearnsPref = @"one.time.senselearns";
static CGFloat const HEMSleepGraphActionSheetConfirmDuration = 1.0f;
static CGFloat const HEMSleepSummaryCellHeight = 364.f;
static CGFloat const HEMSleepGraphCollectionViewEventMinimumHeight = 56.f;
static CGFloat const HEMSleepGraphCollectionViewMinimumHeight = 18.f;
static CGFloat const HEMSleepGraphCollectionViewNumberOfHoursOnscreen = 10.f;
static BOOL hasLoadedBefore = NO;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureCollectionView];
    [self loadData];

    self.dataVerifyTransitionDelegate = [HEMBounceModalTransition new];
    self.dataVerifyTransitionDelegate.message = NSLocalizedString(@"sleep-event.feedback.success.message", nil);
    self.panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(didPan)];
    self.panGestureRecognizer.delegate = self;
    [self.collectionView.panGestureRecognizer requireGestureRecognizerToFail:self.panGestureRecognizer];
    [self.view addGestureRecognizer:self.panGestureRecognizer];
    [self registerForNotifications];

    [SENAnalytics track:kHEMAnalyticsEventTimeline
             properties:@{
                 kHEMAnalyticsEventPropDate : [self dateForNightOfSleep] ?: @"undefined"
             }];
    if (!hasLoadedBefore) {
        [self prepareForInitialAnimation];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self setVisible:YES];
    [self showTutorial];
    [self checkIfInitialAnimationNeeded];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self setVisible:NO];
}

- (void)showTutorial {
    if (![HEMTutorial shouldShowTutorialForTimeline]) {
        [self showHandholding];
        return;
    }

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.65f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
      if (![self isViewFullyVisible] || self.dataSource.numberOfSleepSegments == 0) {
          return;
      }
      [HEMTutorial showTutorialForTimelineIfNeeded];
    });
}

- (void)showHandholding {
    if ([self isViewFullyVisible]) {
        UIView *view = [[self containerViewController] view];
        [HEMTutorial showHandholdingForTimelineDaySwitchIfNeededIn:view];
    }
}

- (void)registerForNotifications {
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
}

- (void)handleAuthorization {
    if (![self isViewLoaded])
        [self view];
    [self reloadData];
}

- (void)dealloc {
    _dataSource = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark Initial load animation

- (void)prepareForInitialAnimation {
    self.collectionView.scrollEnabled = NO;
}

- (void)finishInitialAnimation {
    self.collectionView.scrollEnabled = YES;
}

- (void)performInitialAnimation {
    CGFloat const eventAnimationDuration = 0.25f;
    CGFloat const eventAnimationCrossfadeRatio = 0.9f;
    hasLoadedBefore = YES;
    NSArray *indexPaths = [[self.collectionView indexPathsForVisibleItems]
        sortedArrayUsingComparator:^NSComparisonResult(NSIndexPath *obj1, NSIndexPath *obj2) {
          return [@(obj1.item) compare:@(obj2.item)];
        }];

    int eventsFound = 0;
    for (int i = 0; i < indexPaths.count; i++) {
        NSIndexPath *indexPath = indexPaths[i];
        if (indexPath.section != HEMSleepGraphCollectionViewSegmentSection)
            continue;
        HEMSleepSegmentCollectionViewCell *cell = (id)[self.collectionView cellForItemAtIndexPath:indexPath];
        CGFloat delay = (eventAnimationDuration * eventsFound * eventAnimationCrossfadeRatio);
        if ([self.dataSource segmentForEventExistsAtIndexPath:indexPath]) {
            eventsFound++;
        }
        [cell performEntryAnimationWithDuration:eventAnimationDuration delay:delay];
    }
    int64_t delay = eventAnimationDuration * MAX(0, eventsFound - 1) * NSEC_PER_SEC;
    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delay), dispatch_get_main_queue(), ^{
      [weakSelf finishInitialAnimation];
    });
}

#pragma mark HEMSleepGraphActionDelegate

- (BOOL)shouldHideSegmentCellContents {
    return !hasLoadedBefore;
}

#pragma mark Event Info

- (void)updateTimeOfEventOnSegment:(SENSleepResultSegment *)segment {
    HEMTimelineFeedbackViewController *feedbackController = [HEMMainStoryboard instantiateTimelineFeedbackViewController];
    feedbackController.dateForNightOfSleep = self.dateForNightOfSleep;
    feedbackController.segment = segment;
    [self presentViewController:feedbackController animated:YES completion:NULL];
}

- (BOOL)shouldShowSenseLearnsInActionSheet {
    SENLocalPreferences* preferences = [SENLocalPreferences sharedPreferences];
    return ![[preferences sessionPreferenceForKey:HEMSleepGraphSenseLearnsPref] boolValue];
}

- (void)markSenseLearnsAsShown {
    SENLocalPreferences* preferences = [SENLocalPreferences sharedPreferences];
    [preferences setSessionPreference:@(YES) forKey:HEMSleepGraphSenseLearnsPref];
}

- (UIView *)confirmationViewForActionSheetWithOptions:(NSInteger)numberOfOptions {

    NSString *title = NSLocalizedString(@"sleep-event.feedback.success.message", nil);

    CGRect confirmFrame = CGRectZero;
    confirmFrame.size.height = numberOfOptions * HEMActionSheetDefaultCellHeight;
    confirmFrame.size.width = CGRectGetWidth([[self view] bounds]);

    HEMEventAdjustConfirmationView* confirmView
        = [[HEMEventAdjustConfirmationView alloc] initWithTitle:title
                                                       subtitle:nil
                                                          frame:confirmFrame];
    return confirmView;
}

- (UIView*)senseLearnsTitleView {
    NSString* title = NSLocalizedString(@"sleep-event.feedback.action-sheet.title", nil);
    NSString* desc = NSLocalizedString(@"sleep-event.feedback.action-sheet.description", nil);
    return [[HEMActionSheetTitleView alloc] initWithTitle:title andDescription:desc];
}

- (void)activateActionSheetAtIndexPath:(NSIndexPath *)indexPath {
    SENSleepResultSegment *segment = [self.dataSource sleepSegmentForIndexPath:indexPath];

    HEMActionSheetViewController *sheet = [HEMMainStoryboard instantiateActionSheetViewController];
    [sheet setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];

    NSString* approveTitle = NSLocalizedString(@"sleep-event.action.approve.title", nil);
    [sheet addOptionWithTitle:approveTitle
                   titleColor:[UIColor darkGrayColor]
                  description:nil
                    imageName:@"timeline_action_approve"
                       action:^{
                         // TODO (jimmy): not yet implemented, but we want to show it for now
                         [self markSenseLearnsAsShown];
                       }];

    if ([self canAdjustEventWithType:segment.eventType]) {
        [sheet addOptionWithTitle:NSLocalizedString(@"sleep-event.action.adjust.title", nil)
                       titleColor:[UIColor darkGrayColor]
                      description:nil
                        imageName:@"timeline_action_adjust"
                           action:^{
                             [self updateTimeOfEventOnSegment:segment];
                             [self markSenseLearnsAsShown];
                           }];
    }

    NSString* deleteTitle = NSLocalizedString(@"sleep-event.action.delete.title", nil);
    [sheet addOptionWithTitle:deleteTitle
                   titleColor:[UIColor darkGrayColor]
                  description:nil
                    imageName:@"timeline_action_delete"
                       action:^{
                          // TODO (jimmy): not yet implemented, but we want to show it for now
                          [self markSenseLearnsAsShown];
                       }];
    
    // add title, if needed
    if ([self shouldShowSenseLearnsInActionSheet]) {
        [sheet setCustomTitleView:[self senseLearnsTitleView]];
    }

    // add title, if needed
    if ([self shouldShowSenseLearnsInActionSheet]) {
        [sheet setCustomTitleView:[self senseLearnsTitleView]];
    }
    // confirmations
    CGFloat confirmDuration = HEMSleepGraphActionSheetConfirmDuration;
    UIView* confirmationView = [self confirmationViewForActionSheetWithOptions:[sheet numberOfOptions]];
    [sheet addConfirmationView:confirmationView displayFor:confirmDuration forOptionWithTitle:approveTitle];
    [sheet addConfirmationView:confirmationView displayFor:confirmDuration forOptionWithTitle:deleteTitle];

    UIViewController *root = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
    if (![root respondsToSelector:@selector(presentationController)]) {
        UIModalPresentationStyle origStyle = [root modalPresentationStyle];
        [root setModalPresentationStyle:UIModalPresentationCurrentContext];
        [sheet addDismissAction:^{
          [root setModalPresentationStyle:origStyle];
        }];
    }

    [root presentViewController:sheet animated:YES completion:nil];
}

- (BOOL)canAdjustEventWithType:(NSString *)eventType {
    NSArray *adjustableTypes =
        @[ HEMSleepEventTypeWakeUp, HEMSleepEventTypeFallAsleep, HEMSleepEventTypeInBed, HEMSleepEventTypeOutOfBed ];
    return [adjustableTypes containsObject:eventType];
}

- (void)feedbackFailedToSend:(NSNotification *)note {
    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
      [HEMAlertViewController showInfoDialogWithTitle:NSLocalizedString(@"sleep-event.feedback.failed.title", nil)
                                              message:NSLocalizedString(@"sleep-event.feedback.failed.message", nil)
                                           controller:weakSelf];
    });
}

- (void)didTapSummaryButton:(UIButton *)sender {
    HEMBreakdownViewController *controller = [HEMMainStoryboard instantiateBreakdownViewController];
    controller.result = self.dataSource.sleepResult;
    [self presentViewController:controller animated:YES completion:NULL];
}

- (void)showSleepDepthPopupForIndexPath:(NSIndexPath *)indexPath {
    CGFloat const HEMPopupDismissDelay = 1.75f;
    CGFloat const HEMPopupVerticalOffset = 8.f;
    SENSleepResultSegment *segment = [self.dataSource sleepSegmentForIndexPath:indexPath];
    [self.popupView setText:[self summaryPopupTextForSegment:segment]];
    UICollectionViewLayoutAttributes *attributes = [self.collectionView layoutAttributesForItemAtIndexPath:indexPath];
    CGRect cellLocation = [self.collectionView convertRect:attributes.frame toView:self.view];
    CGFloat top = CGRectGetMinY(cellLocation) - floorf([self.popupView intrinsicContentSize].height);
    self.popupViewTop.constant = top - HEMPopupVerticalOffset;
    [self.popupView setNeedsUpdateConstraints];
    [self.popupView layoutIfNeeded];
    self.popupViewTop.constant = top;
    [self.popupView setNeedsUpdateConstraints];
    self.popupView.alpha = 0;
    self.popupView.hidden = NO;
    [UIView animateWithDuration:0.3f
                     animations:^{
                       [self.popupView layoutIfNeeded];
                       self.popupView.alpha = 1;
                       [UIView animateWithDuration:0.15f
                                             delay:HEMPopupDismissDelay
                                           options:0
                                        animations:^{
                                          self.popupView.alpha = 0;
                                        }
                                        completion:NULL];
                     }];
}

- (NSString *)summaryPopupTextForSegment:(SENSleepResultSegment *)segment {
    static NSString *const HEMPopupTextFormat = @"sleep-stat.%@-duration.%@";
    NSString *segmentType = segment.eventType.length == 0 ? @"motion" : @"sleep";
    NSString *depth;
    if (segment.sleepDepth == SENSleepResultSegmentDepthAwake)
        depth = @"awake";
    else if (segment.sleepDepth >= SENSleepResultSegmentDepthDeep)
        depth = @"deep";
    else if (segment.sleepDepth >= SENSleepResultSegmentDepthMedium)
        depth = @"medium";
    else
        depth = @"light";

    NSString *format = [NSString stringWithFormat:HEMPopupTextFormat, segmentType, depth];
    return NSLocalizedString(format, nil);
}

#pragma mark UIGestureRecognizerDelegate

- (void)didPan {
}

- (BOOL)isViewFullyVisible {
    return ![[HEMRootViewController rootViewControllerForKeyWindow] drawerIsVisible];
}

- (BOOL)shouldAllowRecognizerToReceiveTouch:(UIPanGestureRecognizer *)recognizer {
    CGPoint velocity = [recognizer velocityInView:self.view];
    BOOL movingMostlyVertically = fabs(velocity.x) <= fabs(velocity.y);
    BOOL movingUpwards = velocity.y > 0;
    return [self isScrolledToTop] && movingUpwards && movingMostlyVertically;
}

- (BOOL)isScrolledToTop {
    return self.collectionView.contentOffset.y < 10;
}

- (BOOL)gestureRecognizer:(UIPanGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    return [self isScrolledToTop];
}

- (BOOL)gestureRecognizer:(UIPanGestureRecognizer *)gestureRecognizer
    shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return ![otherGestureRecognizer isEqual:self.collectionView.panGestureRecognizer];
}

- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)gestureRecognizer {
    return [self shouldAllowRecognizerToReceiveTouch:gestureRecognizer];
}

#pragma mark UIScrollViewDelegate

- (HEMTimelineContainerViewController *)containerViewController {
    return (id)self.parentViewController.parentViewController;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (![self.popupView isHidden]) {
        self.popupView.hidden = YES;
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGPoint offset = scrollView.contentOffset;
    [self.containerViewController showAlarmButton:offset.y == 0];
    [self adjustLayoutWithScrollOffset:offset.y];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [self.containerViewController showAlarmButton:!decelerate];
    if (!decelerate) {
        [self adjustLayoutWithScrollOffset:scrollView.contentOffset.y];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self.containerViewController showAlarmButton:YES];
    [self adjustLayoutWithScrollOffset:scrollView.contentOffset.y];
}

- (void)adjustLayoutWithScrollOffset:(CGFloat)yOffset {
    CGFloat const actionableOffset = 5.f;
    [self.containerViewController setBlurEnabled:yOffset > actionableOffset];
    self.collectionView.bounces = yOffset > 0;
}

#pragma mark UICollectionViewDelegate

- (void)loadData {
    if (![SENAuthorizationService isAuthorized])
        return;

    [self loadDataSourceForDate:self.dateForNightOfSleep];
    self.lastNight = [self.dataSource dateIsLastNight];
}

- (void)reloadData {
    if (![self isLoadingData]) {
        [self loadData];
    }
}

- (void)loadDataSourceForDate:(NSDate *)date {
    self.loadingData = YES;

    self.dateForNightOfSleep = date;
    self.dataSource =
        [[HEMSleepGraphCollectionViewDataSource alloc] initWithCollectionView:self.collectionView sleepDate:date];
    self.collectionView.dataSource = self.dataSource;

    __weak typeof(self) weakSelf = self;
    [self.dataSource reloadData:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        strongSelf.loadingData = NO;
        if ([strongSelf isVisible]) {
            [strongSelf checkIfInitialAnimationNeeded];
        }
    }];
}

- (void)checkIfInitialAnimationNeeded {
    if (!hasLoadedBefore) {
        if (self.dataSource.sleepResult.score > 0) {
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                __weak typeof(self) weakSelf = self;
                int64_t delay = (int64_t)(0.6f * NSEC_PER_SEC);
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delay), dispatch_get_main_queue(), ^{
                    [weakSelf performInitialAnimation];
                });
            });
        } else {
            [self finishInitialAnimation];
        }
    } else {
        [self finishInitialAnimation];
    }
}

- (void)configureCollectionView {
    self.collectionView.collectionViewLayout = [HEMFadingParallaxLayout new];
    self.collectionView.delegate = self;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath.section == HEMSleepGraphCollectionViewSegmentSection;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath.section == HEMSleepGraphCollectionViewSegmentSection;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.dataSource segmentForEventExistsAtIndexPath:indexPath]) {
        [self activateActionSheetAtIndexPath:indexPath];
    } else if (indexPath.section == HEMSleepGraphCollectionViewSegmentSection) {
        [self showSleepDepthPopupForIndexPath:indexPath];
    }
}

#pragma mark UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat const HEMMinimumEventSpacing = 6.f;
    BOOL hasSegments = [self.dataSource numberOfSleepSegments] > 0;
    CGFloat width = CGRectGetWidth(self.view.bounds);
    switch (indexPath.section) {
        case HEMSleepGraphCollectionViewSummarySection:
            return CGSizeMake(width, hasSegments ? HEMSleepSummaryCellHeight : CGRectGetHeight(self.view.bounds));

        case HEMSleepGraphCollectionViewSegmentSection: {
            SENSleepResultSegment *segment = [self.dataSource sleepSegmentForIndexPath:indexPath];
            CGFloat durationHeight = [self heightForCellWithSegment:segment];
            if ([self.dataSource segmentForEventExistsAtIndexPath:indexPath]) {
                NSAttributedString *message =
                    [HEMSleepEventCollectionViewCell attributedMessageFromText:segment.message];
                NSAttributedString *time = [self.dataSource formattedTextForInlineTimestamp:segment.date];
                CGSize minSize = [HEMEventBubbleView sizeWithAttributedText:message timeText:time];
                CGFloat height = MAX(MAX(ceilf(durationHeight), HEMSleepGraphCollectionViewEventMinimumHeight),
                                     minSize.height + HEMMinimumEventSpacing);
                return CGSizeMake(width, height);
            } else {
                return CGSizeMake(width, MAX(ceilf(durationHeight), HEMSleepGraphCollectionViewMinimumHeight));
            }
        }

        default:
            return CGSizeZero;
    }
}

- (CGFloat)heightForCellWithSegment:(SENSleepResultSegment *)segment {
    return ([segment.duration doubleValue] / 3600)
           * (CGRectGetHeight([UIScreen mainScreen].bounds) / HEMSleepGraphCollectionViewNumberOfHoursOnscreen);
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                             layout:(UICollectionViewLayout *)collectionViewLayout
    referenceSizeForHeaderInSection:(NSInteger)section {
    BOOL hasSegments = [self.dataSource numberOfSleepSegments] > 0;
    if (!hasSegments || section != HEMSleepGraphCollectionViewSegmentSection)
        return CGSizeZero;
    return CGSizeMake(CGRectGetWidth(self.view.bounds), HEMTimelineHeaderCellHeight);
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                             layout:(UICollectionViewLayout *)collectionViewLayout
    referenceSizeForFooterInSection:(NSInteger)section {
    BOOL hasSegments = [self.dataSource numberOfSleepSegments] > 0;
    if (!hasSegments || section != HEMSleepGraphCollectionViewSegmentSection)
        return CGSizeZero;

    return CGSizeMake(CGRectGetWidth(self.view.bounds), HEMTimelineFooterCellHeight);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView
                                 layout:(UICollectionViewLayout *)collectionViewLayout
    minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

@end
