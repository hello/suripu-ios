
#import <SenseKit/SenseKit.h>
#import <UIImageEffects/UIImage+ImageEffects.h>

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
#import "HEMPopupMaskView.h"
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
#import "NSDate+HEMRelative.h"
#import "UIFont+HEMStyle.h"
#import "UIView+HEMSnapshot.h"
#import "HEMActionSheetTitleView.h"
#import "HEMAppUsage.h"

CGFloat const HEMTimelineHeaderCellHeight = 8.f;
CGFloat const HEMTimelineFooterCellHeight = 74.f;
CGFloat const HEMTimelineTopBarCellHeight = 64.0f;

@interface HEMSleepGraphViewController () <UICollectionViewDelegateFlowLayout, UIGestureRecognizerDelegate,
                                           HEMSleepGraphActionDelegate>

@property (nonatomic, strong) HEMSleepGraphCollectionViewDataSource *dataSource;
@property (nonatomic, strong) UIPanGestureRecognizer *panGestureRecognizer;
@property (nonatomic, strong) UITapGestureRecognizer *tapGestureRecognizer;
@property (nonatomic, strong) HEMBounceModalTransition *dataVerifyTransitionDelegate;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *popupViewTop;
@property (nonatomic, weak) IBOutlet HEMPopupView *popupView;
@property (nonatomic, weak) IBOutlet HEMPopupMaskView *popupMaskView;
@property (nonatomic, assign, getter=isLoadingData) BOOL loadingData;
@property (nonatomic, assign, getter=isVisible) BOOL visible;

@property (nonatomic, strong) HEMSleepHistoryViewController *historyViewController;
@property (nonatomic, strong) HEMZoomAnimationTransitionDelegate *zoomAnimationDelegate;

@end

@implementation HEMSleepGraphViewController

static NSString* const HEMSleepGraphSenseLearnsPref = @"one.time.senselearns";
static CGFloat const HEMSleepGraphActionSheetConfirmDuration = 0.5f;
static CGFloat const HEMSleepSummaryCellHeight = 298.f;
static CGFloat const HEMSleepGraphCollectionViewEventMinimumHeight = 56.f;
static CGFloat const HEMSleepGraphCollectionViewMinimumHeight = 18.f;
static CGFloat const HEMSleepGraphCollectionViewNumberOfHoursOnscreen = 10.f;
static BOOL hasLoadedBefore = NO;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureCollectionView];
    [self configureTransitions];

    [self loadData];

    [self configureGestures];
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
    [self checkForDateChanges];
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
                                             selector:@selector(refreshData)
                                                 name:HEMTimelineFeedbackSuccessNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refreshData)
                                                 name:SENLocalPrefDidChangeNotification
                                               object:[SENPreference nameFromType:SENPreferenceTypeTime24]];
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
}

- (void)configureGestures {
    self.panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(didPan)];
    self.panGestureRecognizer.delegate = self;
    self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTap)];
    self.tapGestureRecognizer.delegate = self;
    [self.view addGestureRecognizer:self.tapGestureRecognizer];
    [self.collectionView.panGestureRecognizer requireGestureRecognizerToFail:self.panGestureRecognizer];
    [self.view addGestureRecognizer:self.panGestureRecognizer];
}

- (void)configureTransitions {
    self.zoomAnimationDelegate = [HEMZoomAnimationTransitionDelegate new];
    self.transitioningDelegate = self.zoomAnimationDelegate;

    self.dataVerifyTransitionDelegate = [HEMBounceModalTransition new];
    self.dataVerifyTransitionDelegate.message = NSLocalizedString(@"sleep-event.feedback.success.message", nil);
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

- (void)processFeedbackResponse:(id)updatedTimeline
                          error:(NSError*)error
                     forSegment:(SENTimelineSegment*)segment
                analyticsAction:(NSString*)analyticsAction {
    
    if (error) {
        [SENAnalytics trackError:error];
    } else {
        NSString* segmentType = SENTimelineSegmentTypeNameFromType(segment.type);
        NSDictionary* props = @{kHEMAnalyticsEventPropType : segmentType ?: @"undefined"};
        [SENAnalytics track:analyticsAction properties:props];
    }
}

- (void)verifySegment:(SENTimelineSegment*)segment {
    __weak typeof(self) weakSelf = self;
    [SENAPITimeline verifySleepEvent:segment
                      forDateOfSleep:self.dateForNightOfSleep
                          completion:^(id updatedTimeline, NSError *error) {
                              [weakSelf processFeedbackResponse:updatedTimeline
                                                          error:error
                                                     forSegment:segment
                                                analyticsAction:HEMAnalyticsEventTimelineEventCorrect];
                          }];
}

- (void)removeSegment:(SENTimelineSegment*)segment {
    __weak typeof(self) weakSelf = self;
    [SENAPITimeline removeSleepEvent:segment
                      forDateOfSleep:self.dateForNightOfSleep
                          completion:^(id updatedTimeline, NSError *error) {
                              [weakSelf processFeedbackResponse:updatedTimeline
                                                          error:error
                                                     forSegment:segment
                                                analyticsAction:HEMAnalyticsEventTimelineEventIncorrect];
                          }];
}

- (void)updateTimeOfEventOnSegment:(SENTimelineSegment *)segment {
    HEMTimelineFeedbackViewController *feedbackController =
        [HEMMainStoryboard instantiateTimelineFeedbackViewController];
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
    SENTimelineSegment *segment = [self.dataSource sleepSegmentForIndexPath:indexPath];
    HEMActionSheetViewController *sheet = [HEMMainStoryboard instantiateActionSheetViewController];
    UIColor* optionTitleColor = [UIColor colorWithWhite:0.0f alpha:0.4f];
    NSString* approveTitle = NSLocalizedString(@"sleep-event.action.approve.title", nil);
    NSString* negativeTitle = nil;
    
    if ([segment canPerformAction:SENTimelineSegmentActionRemove]) {
        negativeTitle = NSLocalizedString(@"sleep-event.action.remove.title", nil);
    } else if ([segment canPerformAction:SENTimelineSegmentActionIncorrect]) {
        negativeTitle = NSLocalizedString(@"sleep-event.action.incorrect.title", nil);
    }

    if ([segment canPerformAction:SENTimelineSegmentActionApprove]) {
        [sheet addOptionWithTitle:approveTitle
                       titleColor:optionTitleColor
                      description:nil
                        imageName:@"timeline_action_approve"
                           action:^{
                               [self verifySegment:segment];
                               [self markSenseLearnsAsShown];
                           }];
    }

    if ([segment canPerformAction:SENTimelineSegmentActionAdjustTime]) {
        [sheet addOptionWithTitle:NSLocalizedString(@"sleep-event.action.adjust.title", nil)
                       titleColor:optionTitleColor
                      description:nil
                        imageName:@"timeline_action_adjust"
                           action:^{
                             [self updateTimeOfEventOnSegment:segment];
                             [self markSenseLearnsAsShown];
                           }];
    }

    // only show 1 or the other, both calls removeSegment.  Incorrect will eventually
    // go away once server implements the code to do so.  Once the server returns the
    // remove capability, only the 'negativeTitle' will be changed to signify the more
    // destructive action
    if ([segment canPerformAction:SENTimelineSegmentActionRemove] ||
        [segment canPerformAction:SENTimelineSegmentActionIncorrect]) {
        [sheet addOptionWithTitle:negativeTitle
                       titleColor:optionTitleColor
                      description:nil
                        imageName:@"timeline_action_delete"
                           action:^{
                               [self removeSegment:segment];
                               [self markSenseLearnsAsShown];
                           }];
    }

    if (segment.possibleActions == SENTimelineSegmentActionNone) {
        [sheet addOptionWithTitle:NSLocalizedString(@"sleep-event.action.none.title", nil)
                       titleColor:[UIColor grayColor]
                      description:nil
                        imageName:nil
                           action:^{}];
    }

    // add title, if needed
    if ([self shouldShowSenseLearnsInActionSheet]) {
        [sheet setCustomTitleView:[self senseLearnsTitleView]];
    }
    // confirmations
    CGFloat confirmDuration = HEMSleepGraphActionSheetConfirmDuration;
    UIView *confirmationView = [self confirmationViewForActionSheetWithOptions:[sheet numberOfOptions]];
    if ([segment canPerformAction:SENTimelineSegmentActionRemove]||
        [segment canPerformAction:SENTimelineSegmentActionIncorrect]) {
        [sheet addConfirmationView:confirmationView displayFor:confirmDuration forOptionWithTitle:negativeTitle];
    }

    if ([segment canPerformAction:SENTimelineSegmentActionApprove]) {
        [sheet addConfirmationView:confirmationView displayFor:confirmDuration forOptionWithTitle:approveTitle];
    }

    UIViewController *root = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
    if (![root respondsToSelector:@selector(presentationController)]) {
        UIModalPresentationStyle origStyle = [root modalPresentationStyle];
        [root setModalPresentationStyle:UIModalPresentationCurrentContext];
        [sheet addDismissAction:^{
          [root setModalPresentationStyle:origStyle];
        }];
    }

    [root presentViewController:sheet animated:NO completion:nil];
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
    CGFloat const HEMPopupAnimationDistance = 8.f;
    CGFloat const HEMPopupSpacingDistance = 8.f;
    if ([self.collectionView isDecelerating])
        return;
    SENTimelineSegment *segment = [self.dataSource sleepSegmentForIndexPath:indexPath];
    [self.popupView setText:[self summaryPopupTextForSegment:segment]];
    UICollectionViewLayoutAttributes *attributes = [self.collectionView layoutAttributesForItemAtIndexPath:indexPath];
    CGRect cellLocation = [self.collectionView convertRect:attributes.frame toView:self.view];
    CGFloat popupHeight = floorf([self.popupView intrinsicContentSize].height);
    CGFloat top = MAX(0, CGRectGetMinY(cellLocation) - popupHeight - HEMPopupSpacingDistance);
    [self.popupView showPointer:top > 0];
    self.popupViewTop.constant = top - HEMPopupAnimationDistance;
    [self.popupView setNeedsUpdateConstraints];
    [self.popupView layoutIfNeeded];
    self.popupViewTop.constant = top;
    [self.popupView setNeedsUpdateConstraints];
    self.popupView.alpha = 0;
    self.popupView.hidden = NO;
    [UIView animateWithDuration:0.3f
                     animations:^{
                       [self emphasizeCellAtIndexPath:indexPath];
                       [self.popupView layoutIfNeeded];
                       self.popupView.alpha = 1;
                       [UIView animateWithDuration:0.15f
                                             delay:HEMPopupDismissDelay
                                           options:0
                                        animations:^{
                                          self.popupView.alpha = 0;
                                          self.popupMaskView.alpha = 0;
                                        }
                                        completion:NULL];
                     }];
}

- (void)emphasizeCellAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section != HEMSleepGraphCollectionViewSegmentSection)
        return;
    CGRect maskArea = CGRectZero;
    HEMSleepSegmentCollectionViewCell *cell = (id)[self.collectionView cellForItemAtIndexPath:indexPath];
    maskArea = [cell convertRect:[cell fillArea] toView:self.view];
    if (indexPath.item < [self.dataSource numberOfSleepSegments] - 1) {
        NSIndexPath *prefillPath = [NSIndexPath indexPathForItem:indexPath.item + 1 inSection:indexPath.section];
        HEMSleepSegmentCollectionViewCell *cell = (id)[self.collectionView cellForItemAtIndexPath:prefillPath];
        CGRect preFillArea = [cell convertRect:[cell preFillArea] toView:self.view];
        maskArea.size.height += CGRectGetHeight(preFillArea);
    }
    [self.popupMaskView showUnderlyingViewRect:maskArea];
    self.popupMaskView.alpha = 0.7f;
    self.popupMaskView.hidden = NO;
}

- (NSString *)summaryPopupTextForSegment:(SENTimelineSegment *)segment {
    static NSString *const HEMPopupTextFormat = @"sleep-stat.sleep-duration.%@";
    NSString *depth;
    switch (segment.sleepState) {
        case SENTimelineSegmentSleepStateSound:
            depth = @"deep";
            break;
        case SENTimelineSegmentSleepStateMedium:
            depth = @"medium";
            break;
        case SENTimelineSegmentSleepStateLight:
            depth = @"light";
            break;
        case SENTimelineSegmentSleepStateAwake:
        default:
            depth = @"awake";
            break;
    }

    NSString *format = [NSString stringWithFormat:HEMPopupTextFormat, depth];
    return NSLocalizedString(format, nil);
}

#pragma mark - Top Bar

- (void)didTapDrawerButton:(UIButton *)button {
    HEMRootViewController *root = [HEMRootViewController rootViewControllerForKeyWindow];
    [root toggleSettingsDrawer];
}

- (void)didTapShareButton:(UIButton *)button {
    long score = [self.dataSource.sleepResult.score longValue];
    if (score > 0) {
        NSString *message;
        if ([self.dataSource dateIsLastNight]) {
            message = [NSString stringWithFormat:NSLocalizedString(@"activity.share.last-night.format", nil), score];
        } else {
            message = [NSString stringWithFormat:NSLocalizedString(@"activity.share.other-days.format", nil), score,
                                                 [[self dataSource] dateTitle]];
        }
        UIActivityViewController *activityController =
            [[UIActivityViewController alloc] initWithActivityItems:@[ message ] applicationActivities:nil];
        [self presentViewController:activityController animated:YES completion:nil];
    }
}

- (void)didTapDateButton:(UIButton *)sender {
    self.historyViewController = (id)[HEMMainStoryboard instantiateSleepHistoryController];
    self.historyViewController.selectedDate = self.dateForNightOfSleep;
    self.historyViewController.transitioningDelegate = self.zoomAnimationDelegate;
    [self presentViewController:self.historyViewController animated:YES completion:NULL];
}

- (void)checkForDateChanges {
    if (self.historyViewController.selectedDate) {
        HEMRootViewController *root = [HEMRootViewController rootViewControllerForKeyWindow];
        [root reloadTimelineSlideViewControllerWithDate:self.historyViewController.selectedDate];
    }

    self.historyViewController = nil;
}

#pragma mark Drawer

- (void)drawerDidOpen {
    [UIView animateWithDuration:0.5f
                     animations:^{
                         [[self dataSource] updateTimelineState:YES];
                     }];
}

- (void)drawerDidClose {
    [UIView animateWithDuration:0.5f
                     animations:^{
                         [[self dataSource] updateTimelineState:NO];
                     }];
}

#pragma mark - UIGestureRecognizerDelegate

- (void)didPan {
}

- (void)didTap {
    CGPoint location = [self.tapGestureRecognizer locationInView:self.view];
    CGPoint locationInCell = [self.view convertPoint:location toView:self.collectionView];
    NSIndexPath* indexPath = [self.collectionView indexPathForItemAtPoint:locationInCell];
    if ([self shouldAcceptTapAtLocation:location]) {
        UICollectionViewLayoutAttributes *attrs = [self.collectionView layoutAttributesForItemAtIndexPath:indexPath];
        if (locationInCell.y - CGRectGetMinY(attrs.frame) <= HEMSegmentPrefillTimeInset && indexPath.item > 0) {
            NSIndexPath* previousItem = [NSIndexPath indexPathForItem:indexPath.item - 1
                                                            inSection:HEMSleepGraphCollectionViewSegmentSection];
            [self showSleepDepthPopupForIndexPath:previousItem];
        } else {
            [self showSleepDepthPopupForIndexPath:indexPath];
        }
    }
}

- (BOOL)shouldAcceptTapAtLocation:(CGPoint)location {
    CGPoint locationInCell = [self.view convertPoint:location toView:self.collectionView];
    NSIndexPath* indexPath = [self.collectionView indexPathForItemAtPoint:locationInCell];
    return indexPath.section == HEMSleepGraphCollectionViewSegmentSection
        && ![self.dataSource segmentForEventExistsAtIndexPath:indexPath];
}

- (BOOL)isViewFullyVisible {
    return ![[HEMRootViewController rootViewControllerForKeyWindow] drawerIsVisible];
}

- (BOOL)shouldAllowRecognizerToReceiveTouch:(UIGestureRecognizer *)recognizer {
    if ([recognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        CGPoint velocity = [(UIPanGestureRecognizer *)recognizer velocityInView:self.view];
        BOOL movingMostlyVertically = fabs(velocity.x) <= fabs(velocity.y);
        BOOL movingUpwards = velocity.y > 0;
        return [self isScrolledToTop] && movingUpwards && movingMostlyVertically;
    }
    return YES;
}

- (BOOL)isScrolledToTop {
    return self.collectionView.contentOffset.y < 10;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        return [self isScrolledToTop];
    }
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
    shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        return ![otherGestureRecognizer isEqual:self.collectionView.panGestureRecognizer];
    }
    return YES;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        return [self shouldAllowRecognizerToReceiveTouch:gestureRecognizer];
    } else if ([gestureRecognizer isEqual:self.tapGestureRecognizer]) {
        return [self shouldAcceptTapAtLocation:[self.tapGestureRecognizer locationInView:self.view]];
    }
    return YES;
}

#pragma mark - UIScrollViewDelegate

- (HEMTimelineContainerViewController *)containerViewController {
    return (id)self.parentViewController.parentViewController;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.containerViewController showAlarmButton:NO];
    if (![self.popupView isHidden]) {
        self.popupView.hidden = YES;
        self.popupMaskView.hidden = YES;
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    [self.containerViewController showAlarmButton:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGPoint offset = scrollView.contentOffset;
    [self adjustLayoutWithScrollOffset:offset.y];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        [self.containerViewController showAlarmButton:YES];
        [self adjustLayoutWithScrollOffset:scrollView.contentOffset.y];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self.containerViewController showAlarmButton:YES];
    [self adjustLayoutWithScrollOffset:scrollView.contentOffset.y];
}

- (void)adjustLayoutWithScrollOffset:(CGFloat)yOffset {
    self.collectionView.bounces = yOffset > 0;
    if (![self.popupView isHidden]) {
        self.popupView.hidden = YES;
    }
}

#pragma mark - UICollectionViewDelegate

- (void)loadData {
    if (![SENAuthorizationService isAuthorized])
        return;

    [self loadDataSourceForDate:self.dateForNightOfSleep];
}

- (void)refreshData {
    [self.dataSource refreshData];
}

- (void)reloadData {
    if (![self isLoadingData]) {
        [self loadData];
    }
}

- (BOOL)isLastNight {
    return [self.dataSource dateIsLastNight];
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
        
        if ([strongSelf.dataSource.sleepResult.score integerValue] > 0) {
            HEMAppUsage* appUsage = [HEMAppUsage appUsageForIdentifier:HEMAppUsageTimelineShownWithData];
            NSDate* updatedAtMidnight = [[appUsage updated] dateAtMidnight];
            if (!updatedAtMidnight || [updatedAtMidnight compare:strongSelf.dateForNightOfSleep] == NSOrderedAscending) {
                [HEMAppUsage incrementUsageForIdentifier:HEMAppUsageTimelineShownWithData];
            }
        }
        
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
    return [self.dataSource segmentForEventExistsAtIndexPath:indexPath];
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return [self.dataSource segmentForEventExistsAtIndexPath:indexPath];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.dataSource segmentForEventExistsAtIndexPath:indexPath]) {
        self.popupMaskView.hidden = YES;
        [self activateActionSheetAtIndexPath:indexPath];
        [collectionView deselectItemAtIndexPath:indexPath animated:YES];
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
            SENTimelineSegment *segment = [self.dataSource sleepSegmentForIndexPath:indexPath];
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

- (CGFloat)heightForCellWithSegment:(SENTimelineSegment *)segment {
    return (segment.duration / 3600)
           * (CGRectGetHeight([UIScreen mainScreen].bounds) / HEMSleepGraphCollectionViewNumberOfHoursOnscreen);
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                             layout:(UICollectionViewLayout *)collectionViewLayout
    referenceSizeForHeaderInSection:(NSInteger)section {

    CGFloat bWidth = CGRectGetWidth(collectionView.bounds);

    if (section == HEMSleepGraphCollectionViewSummarySection) {
        return CGSizeMake(bWidth, HEMTimelineTopBarCellHeight);
    } else if (section == HEMSleepGraphCollectionViewSegmentSection) {
        if ([self.dataSource numberOfSleepSegments] > 0) {
            return CGSizeMake(bWidth, HEMTimelineHeaderCellHeight);
        }
    }

    return CGSizeZero;
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
