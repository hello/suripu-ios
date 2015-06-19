
#import <SenseKit/SenseKit.h>
#import <UIImageEffects/UIImage+ImageEffects.h>

#import "HelloStyleKit.h"
#import "HEMActionSheetViewController.h"
#import "HEMAlertViewController.h"
#import "HEMAudioCache.h"
#import "HEMBounceModalTransition.h"
#import "HEMBreakdownViewController.h"
#import "HEMEventBubbleView.h"
#import "HEMFadingParallaxLayout.h"
#import "HEMMainStoryboard.h"
#import "HEMNoSleepEventCollectionViewCell.h"
#import "HEMPopupView.h"
#import "HEMRootViewController.h"
#import "HEMSleepEventCollectionViewCell.h"
#import "HEMSleepGraphCollectionViewDataSource.h"
#import "HEMSleepGraphView.h"
#import "HEMSleepGraphViewController.h"
#import "HEMSleepHistoryViewController.h"
#import "HEMSleepSummaryCollectionViewCell.h"
#import "HEMSleepSummarySlideViewController.h"
#import "HEMTimelineContainerViewController.h"
#import "HEMTimelineFeedbackViewController.h"
#import "HEMTutorial.h"
#import "HEMZoomAnimationTransitionDelegate.h"
#import "UIFont+HEMStyle.h"
#import "UIView+HEMSnapshot.h"

CGFloat const HEMTimelineHeaderCellHeight = 24.f;
CGFloat const HEMTimelineFooterCellHeight = 50.f;

@interface HEMSleepGraphViewController () <UICollectionViewDelegateFlowLayout, UIGestureRecognizerDelegate>

@property (nonatomic, retain) HEMSleepGraphView *view;
@property (nonatomic, strong) HEMSleepGraphCollectionViewDataSource *dataSource;
@property (nonatomic, strong) UIPanGestureRecognizer *panGestureRecognizer;
@property (nonatomic, strong) HEMBounceModalTransition *dataVerifyTransitionDelegate;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *popupViewTop;
@property (nonatomic, weak) IBOutlet HEMPopupView *popupView;
@property (nonatomic, assign, getter=isLastNight) BOOL lastNight;
@end

@implementation HEMSleepGraphViewController

static CGFloat const HEMSleepSummaryCellHeight = 364.f;
static CGFloat const HEMSleepGraphCollectionViewEventMinimumHeight = 56.f;
static CGFloat const HEMSleepGraphCollectionViewMinimumHeight = 18.f;
static CGFloat const HEMSleepGraphCollectionViewNumberOfHoursOnscreen = 10.f;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureCollectionView];
    [self reloadData];

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
}

- (void)showTutorial {
    if (![HEMTutorial shouldShowTutorialForTimeline])
        return;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.65f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
      if (![self isViewFullyVisible] || self.dataSource.numberOfSleepSegments == 0)
          return;
      [HEMTutorial showTutorialForTimelineIfNeeded];
    });
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self showTutorial];
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

#pragma mark HEMSleepGraphActionDelegate

- (BOOL)shouldEnableZoomButton {
    return [self isViewFullyVisible];
}

- (BOOL)shouldHideShareButton {
    return ![self isViewFullyVisible] || [self.dataSource.sleepResult.score integerValue] == 0;
}

#pragma mark Event Info

- (void)updateTimeOfEventOnSegment:(SENSleepResultSegment *)segment {
    UINavigationController *navController = [HEMMainStoryboard instantiateTimelineFeedbackViewController];
    navController.transitioningDelegate = self.dataVerifyTransitionDelegate;
    navController.modalPresentationStyle = UIModalPresentationCustom;
    HEMTimelineFeedbackViewController *feedbackController = (id)navController.topViewController;
    feedbackController.dateForNightOfSleep = self.dateForNightOfSleep;
    feedbackController.segment = segment;
    [self presentViewController:navController animated:YES completion:NULL];
}

- (void)didTapActionSheetButton:(UIButton *)sender {
    NSIndexPath *indexPath = [self indexPathForEventCellWithSubview:sender];
    SENSleepResultSegment *segment = [self.dataSource sleepSegmentForIndexPath:indexPath];
    HEMActionSheetViewController *sheet = [HEMMainStoryboard instantiateActionSheetViewController];
    [sheet setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
    [sheet setTitle:[segment.message stringByReplacingOccurrencesOfString:@"*" withString:@""]];
    [sheet addOptionWithTitle:NSLocalizedString(@"sleep-event.action.approve.title", nil)
                   titleColor:[UIColor darkGrayColor]
                  description:nil
                    imageName:@"timeline_action_approve"
                       action:^{
                       }];
    [sheet addOptionWithTitle:NSLocalizedString(@"sleep-event.action.adjust.title", nil)
                   titleColor:[UIColor darkGrayColor]
                  description:nil
                    imageName:@"timeline_action_adjust"
                       action:^{
                         [self updateTimeOfEventOnSegment:segment];
                       }];
    [sheet addOptionWithTitle:NSLocalizedString(@"sleep-event.action.delete.title", nil)
                   titleColor:[UIColor darkGrayColor]
                  description:nil
                    imageName:@"timeline_action_delete"
                       action:^{
                       }];

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

- (void)feedbackFailedToSend:(NSNotification *)note {
    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
      [HEMAlertViewController showInfoDialogWithTitle:NSLocalizedString(@"sleep-event.feedback.failed.title", nil)
                                              message:NSLocalizedString(@"sleep-event.feedback.failed.message", nil)
                                           controller:weakSelf];
    });
}

- (IBAction)didTapAlarmShortcut:(id)sender {
    [SENAnalytics track:HEMAnalyticsEventTimelineAlarmShortcut properties:nil];
    HEMRootViewController *root = [HEMRootViewController rootViewControllerForKeyWindow];
    [root showSettingsDrawerTabAtIndex:HEMRootDrawerTabAlarms animated:YES];
}

- (NSIndexPath *)indexPathForEventCellWithSubview:(UIView *)view {
    UIView *superview = view.superview;
    if (superview) {
        if ([superview isKindOfClass:[HEMSleepEventCollectionViewCell class]])
            return [self.collectionView indexPathForCell:(UICollectionViewCell *)superview];
        else
            return [self indexPathForEventCellWithSubview:superview];
    }
    return nil;
}

- (void)didTapSummaryButton:(UIButton *)sender {
    HEMBreakdownViewController *controller = [HEMMainStoryboard instantiateBreakdownViewController];
    controller.result = self.dataSource.sleepResult;
    [self presentViewController:controller animated:YES completion:NULL];
}

#pragma mark UIGestureRecognizerDelegate

- (IBAction)didLongPress:(UILongPressGestureRecognizer *)sender {
    static CGFloat const HEMPopupAnimationDistance = 8.f;
    static CGFloat const HEMPopupSpacingDistance = 20.f;
    if (sender.state == UIGestureRecognizerStateBegan) {
        [SENAnalytics track:HEMAnalyticsEventTimelineBarLongPress];
        CGPoint cellLocation = [sender locationInView:self.collectionView];
        NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:cellLocation];
        UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:indexPath];
        if ([cell isKindOfClass:[HEMSleepSegmentCollectionViewCell class]]) {
            [(HEMSleepSegmentCollectionViewCell *)cell emphasizeAppearance];
            SENSleepResultSegment *segment = [self.dataSource sleepSegmentForIndexPath:indexPath];
            [self.popupView setText:[self summaryPopupTextForSegment:segment]];
            UICollectionViewLayoutAttributes *attributes =
                [self.collectionView layoutAttributesForItemAtIndexPath:indexPath];
            CGRect cellLocation = [self.collectionView convertRect:attributes.frame toView:self.view];
            CGFloat top = CGRectGetMinY(cellLocation) - [self.popupView intrinsicContentSize].height
                          - HEMPopupSpacingDistance;
            self.popupViewTop.constant = top - HEMPopupAnimationDistance;
            [self.popupView setNeedsUpdateConstraints];
            [self.popupView layoutIfNeeded];
            self.popupViewTop.constant = top;
            [self.popupView setNeedsUpdateConstraints];
            [UIView animateWithDuration:0.2f
                             animations:^{
                               [self.popupView layoutIfNeeded];
                               self.popupView.alpha = 1;
                             }];
        }
    } else if (sender.state == UIGestureRecognizerStateEnded || sender.state == UIGestureRecognizerStateCancelled) {
        [UIView animateWithDuration:0.15f
                         animations:^{
                           self.popupView.alpha = 0;
                         }];
        for (HEMSleepSegmentCollectionViewCell *cell in self.collectionView.visibleCells) {
            if ([cell respondsToSelector:@selector(deemphasizeAppearance)])
                [cell deemphasizeAppearance];
        }
    }
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

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView
                     withVelocity:(CGPoint)velocity
              targetContentOffset:(inout CGPoint *)targetContentOffset {
    [self adjustLayoutWithScrollOffset:targetContentOffset->y];
}

- (void)adjustLayoutWithScrollOffset:(CGFloat)yOffset {
    const CGFloat HEMContainerBlurMaxHeight = 32.f;
    HEMTimelineContainerViewController *controller = [self containerViewController];
    CGFloat blurHeight
        = yOffset == 0
              ? 0
              : MAX(MIN(HEMSleepSummaryCellHeight - yOffset - HEMContainerBlurMaxHeight, HEMContainerBlurMaxHeight), 0);
    [controller showBorder:yOffset >= HEMSleepSummaryCellHeight];
    [controller showBlurWithHeight:blurHeight];
    self.collectionView.bounces = yOffset > 0;
}

#pragma mark UICollectionViewDelegate

- (void)reloadData {
    if (![SENAuthorizationService isAuthorized])
        return;

    [self loadDataSourceForDate:self.dateForNightOfSleep];
    self.lastNight = [self.dataSource dateIsLastNight];
}

- (void)loadDataSourceForDate:(NSDate *)date {
    self.dateForNightOfSleep = date;
    self.dataSource =
        [[HEMSleepGraphCollectionViewDataSource alloc] initWithCollectionView:self.collectionView sleepDate:date];
    self.collectionView.dataSource = self.dataSource;
}

- (void)configureCollectionView {
    self.collectionView.collectionViewLayout = [HEMFadingParallaxLayout new];
    self.collectionView.backgroundColor = [HelloStyleKit lightTintColor];
    self.collectionView.delegate = self;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
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
