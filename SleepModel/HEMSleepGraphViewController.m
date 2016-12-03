
#import <SenseKit/SenseKit.h>
#import <AVFoundation/AVFoundation.h>
#import <UIImageEffects/UIImage+ImageEffects.h>
#import "UIActivityViewController+HEMSharing.h"

#import "HEMActionSheetViewController.h"
#import "HEMAlertViewController.h"
#import "HEMAudioCache.h"
#import "HEMBreakdownViewController.h"
#import "HEMEventAdjustConfirmationView.h"
#import "HEMEventBubbleView.h"
#import "HEMFadingParallaxLayout.h"
#import "HEMMainStoryboard.h"
#import "HEMPopupView.h"
#import "HEMPopupMaskView.h"
#import "HEMSleepEventCollectionViewCell.h"
#import "HEMSleepGraphCollectionViewDataSource.h"
#import "HEMSleepGraphViewController.h"
#import "HEMSleepHistoryViewController.h"
#import "HEMSleepSummaryCollectionViewCell.h"
#import "HEMSleepSummarySlideViewController.h"
#import "HEMTimelineFeedbackViewController.h"
#import "HEMTutorial.h"
#import "HEMZoomAnimationTransitionDelegate.h"
#import "NSDate+HEMRelative.h"
#import "UIFont+HEMStyle.h"
#import "UIView+HEMSnapshot.h"
#import "HEMActionSheetTitleView.h"
#import "HEMAppUsage.h"
#import "HEMAudioService.h"
#import "HEMSupportUtil.h"
#import "HEMTappableView.h"
#import "HEMScreenUtils.h"
#import "HEMOnboardingService.h"
#import "HEMAccountService.h"
#import "HEMTimelineService.h"
#import "HEMTimelineHandHoldingPresenter.h"
#import "HEMHandHoldingService.h"
#import "HEMNavigationShadowView.h"
#import "HEMStyle.h"

CGFloat const HEMTimelineHeaderCellHeight = 8.f;
CGFloat const HEMTimelineFooterCellHeight = 74.f;

@interface HEMSleepGraphViewController () <
    UICollectionViewDelegateFlowLayout,
    UIGestureRecognizerDelegate,
    HEMSleepGraphActionDelegate,
    AVAudioPlayerDelegate,
    HEMTapDelegate,
    HEMTimelineHandHoldingDelegate
>

@property (nonatomic, strong) HEMSleepGraphCollectionViewDataSource *dataSource;
@property (nonatomic, strong) UIPanGestureRecognizer *panGestureRecognizer;
@property (nonatomic, strong) UITapGestureRecognizer *tapGestureRecognizer;
@property (nonatomic, weak) IBOutlet UINavigationBar *navigationBar;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *popupViewTop;
@property (nonatomic, weak) IBOutlet HEMPopupView *popupView;
@property (nonatomic, weak) IBOutlet HEMPopupMaskView *popupMaskView;
@property (nonatomic, weak) IBOutlet UIImageView *errorImageView;
@property (nonatomic, weak) IBOutlet UILabel *errorTitleLabel;
@property (nonatomic, weak) IBOutlet UILabel *errorMessageLabel;
@property (nonatomic, weak) IBOutlet UIButton *errorSupportButton;
@property (nonatomic, weak) IBOutlet UIView *errorViewsContainerView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *errorImageHeightConstraint;
@property (nonatomic, assign, getter=isVisible) BOOL visible;
@property (nonatomic, assign, getter=isDismissing) BOOL dismissing;
@property (nonatomic, assign, getter=isCheckingForTutorials) BOOL checkingForTutorials;
@property (nonatomic, assign, getter=isLoaded) BOOL loaded;

@property (nonatomic, strong) HEMSleepHistoryViewController *historyViewController;
@property (nonatomic, strong) HEMZoomAnimationTransitionDelegate *zoomAnimationDelegate;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *navigationBarTopConstraint;
@property (nonatomic, strong) AVAudioPlayer *audioPlayer;
@property (nonatomic, weak) UIButton *playingButton;
@property (nonatomic, weak) UIButton* shareButton;
@property (nonatomic, strong) NSIndexPath *playingIndexPath;
@property (nonatomic, strong) NSIndexPath *selectedIndexPath;
@property (nonatomic, strong) NSTimer *playbackProgressTimer;
@property (nonatomic, strong) HEMTimelineService* timelineService;
@property (nonatomic, strong) HEMHandHoldingService* handHoldingService;
@property (nonatomic, weak) HEMTimelineHandHoldingPresenter* handHoldingPresenter;
@property (nonatomic, strong) HEMAudioService* audioService;
@property (nonatomic, strong) HEMNavigationShadowView* shadowView;

@end

@implementation HEMSleepGraphViewController

static NSString *const HEMSleepGraphSenseLearnsPref = @"one.time.senselearns";
static CGFloat const HEMSleepGraphActionSheetConfirmDuration = 0.5f;
static CGFloat const HEMSleepGraphCollectionViewEventMinimumHeight = 56.f;
static CGFloat const HEMSleepGraphCollectionViewMinimumHeight = 18.f;
static CGFloat const HEMSleepGraphCollectionViewNumberOfHoursOnscreen = 10.f;
static CGFloat const HEMSleepSegmentPopupAnimationDuration = 0.5f;
static CGFloat const HEMPopupAnimationDistance = 8.0f;
static CGFloat const HEMPopupAnimationDisplayInterval = 2.0f;
static BOOL hasLoadedBefore = NO;

- (void)viewDidLoad {
    [super viewDidLoad];

    [self configureServices];
    [self configurePresenters];
    [self configureCollectionView];
    [self configureTransitions];
    [self configureErrorProperties];

    [self loadData];

    [self configureNavigationBar];
    [self configureGestures];
    [self registerForNotifications];

    [SENAnalytics track:kHEMAnalyticsEventTimeline
             properties:@{
                 kHEMAnalyticsEventPropDate : [self dateForNightOfSleep] ?: @"undefined"
             }];
    if (!hasLoadedBefore) {
        [self prepareForInitialAnimation];
    }
    
    [self setAudioService:[HEMAudioService new]];
}

- (void)configureErrorProperties {
    [[self errorTitleLabel] setFont:[UIFont h5]];
    [[self errorTitleLabel] setTextColor:[UIColor grey6]];
    
    [[self errorMessageLabel] setFont:[UIFont body]];
    [[self errorMessageLabel] setTextColor:[UIColor grey4]];
    
    [[[self errorSupportButton] titleLabel] setFont:[UIFont button]];
}

- (void)adjustConstraintsForIPhone4 {
    [super adjustConstraintsForIPhone4];
    
    CGFloat height = [[self errorImageHeightConstraint] constant];
    [[self errorImageHeightConstraint] setConstant:2 * (height / 3.0f)];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self checkForDateChanges];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self setVisible:YES];
    [self checkIfInitialAnimationNeeded];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self clearPlayerState];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self setVisible:NO];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    CGFloat navY = CGRectGetMinY([[self navigationBar] frame]);
    CGFloat statusHeight = CGRectGetHeight([[UIApplication sharedApplication] statusBarFrame]);
    if (navY == 0.0f) {
        [[self navigationBarTopConstraint] setConstant:statusHeight];
        [[self navigationBar] layoutIfNeeded];
    } else if (navY > statusHeight) {
        [[self navigationBarTopConstraint] setConstant:0.0f];
        [[self navigationBar] layoutIfNeeded];
    }
}

- (void)configureServices {
    [self setTimelineService:[HEMTimelineService new]];
    [self setHandHoldingService:[HEMHandHoldingService new]];
}

- (void)configurePresenters {
    HEMTimelineHandHoldingPresenter* hhPresenter
        = [[HEMTimelineHandHoldingPresenter alloc] initWithHandHoldingService:[self handHoldingService]];
    [hhPresenter setDelegate:self];
    [hhPresenter bindWithContentView:[self collectionView]];
    
    [self setHandHoldingPresenter:hhPresenter];
    [self addPresenter:hhPresenter];
}

- (void)showTutorial {
    if ([self isCheckingForTutorials]) {
        return;
    }
    
    [self setCheckingForTutorials:YES];
    
    __weak typeof(self) weakSelf = self;
    
    CGFloat const DISPLAY_DELAY = 1.0f;
    int64_t delayInSecs = (int64_t)(DISPLAY_DELAY * NSEC_PER_SEC);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delayInSecs), dispatch_get_main_queue(), ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if ([strongSelf isFullyVisibleInWindow]) {
            [[strongSelf handHoldingPresenter] showIfNeeded];
        }
        [strongSelf setCheckingForTutorials:NO];
    });
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
}

- (void)handleAuthorization {
    if (![self isViewLoaded])
        [self view];
    [self reloadData];
}

- (void)dealloc {
    _dataSource = nil;
    [_audioPlayer stop];
    [_playbackProgressTimer invalidate];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Hand holding delegate

- (UIView*)timelineContainerViewForPresenter:(HEMTimelineHandHoldingPresenter *)presenter {
    return [[self parentViewController] view];
}

#pragma mark Initial load animation

- (void)prepareForInitialAnimation {
    self.collectionView.scrollEnabled = NO;
}

- (void)finishInitialAnimation {
    if ([self.dataSource hasTimelineData])
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

- (void)toggleAudio:(UIButton *)button {
    if (button == self.playingButton) {
        if ([self.audioPlayer isPlaying]) {
            [self.playbackProgressTimer invalidate];
            [self.audioPlayer pause];
            [self.playingButton setImage:[UIImage imageNamed:@"playSound"] forState:UIControlStateNormal];
        } else {
            [self.audioPlayer play];
            [self monitorPlaybackProgress];
            [self.playingButton setImage:[UIImage imageNamed:@"pauseSound"] forState:UIControlStateNormal];
        }
    } else {
        [self clearPlayerState];
        [self playAudioWithButton:button];
    }
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    [self clearPlayerState];
}

- (void)audioPlayerBeginInterruption:(AVAudioPlayer *)player {
    [self clearPlayerState];
}

- (void)playAudioWithButton:(UIButton *)button {
    NSIndexPath *indexPath = [self indexPathForView:button];
    if (!indexPath)
        return;
    if (![self loadAudioForIndexPath:indexPath])
        return;
    
    __weak typeof(self) weakSelf = self;
    [[self audioService] activateSession:YES completion:^(NSError * _Nullable error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (error)
            return;
        [strongSelf.audioPlayer play];
        [strongSelf monitorPlaybackProgress];
        [button setImage:[UIImage imageNamed:@"pauseSound"] forState:UIControlStateNormal];
        strongSelf.playingButton = button;
    }];
}

- (BOOL)loadAudioForIndexPath:(NSIndexPath *)indexPath {
    NSError *error = nil;
    NSData *data = [self.dataSource audioDataForIndexPath:indexPath];
    if (!data)
        return NO;
    self.audioPlayer = [[AVAudioPlayer alloc] initWithData:data error:&error];
    if (error != nil)
        return NO;

    self.playingIndexPath = indexPath;
    return YES;
}

- (void)monitorPlaybackProgress {
    [self.playbackProgressTimer invalidate];
    self.playbackProgressTimer = [NSTimer timerWithTimeInterval:1
                                                         target:self
                                                       selector:@selector(updatePlaybackProgress)
                                                       userInfo:nil
                                                        repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.playbackProgressTimer forMode:NSDefaultRunLoopMode];
}

- (void)clearPlayerState {
    [self.audioPlayer stop];
    [self updatePlaybackProgress];
    self.playingIndexPath = nil;
    [self.playbackProgressTimer invalidate];
    self.playbackProgressTimer = nil;
    [self.playingButton setImage:[UIImage imageNamed:@"playSound"] forState:UIControlStateNormal];
    self.playingButton = nil;
    self.audioPlayer = nil;
}

- (void)updatePlaybackProgress {
    if (!self.playingIndexPath)
        return;
    CGFloat progress = 0;
    if ([self.audioPlayer isPlaying])
        progress = self.audioPlayer.currentTime / self.audioPlayer.duration;

    HEMSleepEventCollectionViewCell *cell = (id)[self.collectionView cellForItemAtIndexPath:self.playingIndexPath];
    if ([cell isKindOfClass:[HEMSleepEventCollectionViewCell class]])
        [cell updateAudioDisplayProgressWithRatio:progress];
}

- (NSIndexPath *)indexPathForView:(UIView *)view {
    UIView *superview = view;
    while (superview != nil) {
        if ([superview isKindOfClass:[UICollectionViewCell class]]) {
            return [self.collectionView indexPathForCell:(id)superview];
        }
        superview = [superview superview];
    }
    return nil;
}

#pragma mark Event Info

- (void)processFeedbackResponse:(id)updatedTimeline
                          error:(NSError *)error
                     forSegment:(SENTimelineSegment *)segment
                analyticsAction:(NSString *)analyticsAction {

    if (error) {
        [SENAnalytics trackError:error];
    } else {
        NSString *segmentType = SENTimelineSegmentTypeNameFromType(segment.type);
        NSDictionary *props = @{ kHEMAnalyticsEventPropType : segmentType ?: @"undefined" };
        [SENAnalytics track:analyticsAction properties:props];
    }
}

- (void)verifySegment:(SENTimelineSegment *)segment {
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

- (void)removeSegment:(SENTimelineSegment *)segment {
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
    SENLocalPreferences *preferences = [SENLocalPreferences sharedPreferences];
    return ![[preferences sessionPreferenceForKey:HEMSleepGraphSenseLearnsPref] boolValue];
}

- (void)markSenseLearnsAsShown {
    SENLocalPreferences *preferences = [SENLocalPreferences sharedPreferences];
    [preferences setSessionPreference:@(YES) forKey:HEMSleepGraphSenseLearnsPref];
}

- (UIView *)confirmationViewForActionSheetWithOptions:(NSInteger)numberOfOptions {

    NSString *title = NSLocalizedString(@"sleep-event.feedback.success.message", nil);

    CGRect confirmFrame = CGRectZero;
    confirmFrame.size.height = numberOfOptions * HEMActionSheetDefaultCellHeight;
    confirmFrame.size.width = CGRectGetWidth([[self view] bounds]);

    HEMEventAdjustConfirmationView *confirmView =
        [[HEMEventAdjustConfirmationView alloc] initWithTitle:title subtitle:nil frame:confirmFrame];
    return confirmView;
}

- (UIView *)senseLearnsTitleView {
    NSString *title = NSLocalizedString(@"sleep-event.feedback.action-sheet.title", nil);
    NSString *desc = NSLocalizedString(@"sleep-event.feedback.action-sheet.description", nil);
    NSAttributedString* attrDesc = [HEMActionSheetTitleView attributedDescriptionFromText:desc];
    return [[HEMActionSheetTitleView alloc] initWithTitle:title andDescription:attrDesc];
}

- (void)activateActionSheetAtIndexPath:(NSIndexPath *)indexPath {
    SENTimelineSegment *segment = [self.dataSource sleepSegmentForIndexPath:indexPath];
    if (segment.possibleActions == SENTimelineSegmentActionNone) {
        return;
    }

    HEMActionSheetViewController *sheet = [HEMMainStoryboard instantiateActionSheetViewController];
    UIColor *optionTitleColor = [UIColor colorWithWhite:0.0f alpha:0.4f];
    NSString *approveTitle = NSLocalizedString(@"sleep-event.action.approve.title", nil);
    NSString *negativeTitle = nil;

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
    if ([segment canPerformAction:SENTimelineSegmentActionRemove]
        || [segment canPerformAction:SENTimelineSegmentActionIncorrect]) {
        [sheet addOptionWithTitle:negativeTitle
                       titleColor:optionTitleColor
                      description:nil
                        imageName:@"timeline_action_delete"
                           action:^{
                             [self removeSegment:segment];
                             [self markSenseLearnsAsShown];
                           }];
    }

    // add title, if needed
    if ([self shouldShowSenseLearnsInActionSheet]) {
        [sheet setCustomTitleView:[self senseLearnsTitleView]];
    }
    // confirmations
    CGFloat confirmDuration = HEMSleepGraphActionSheetConfirmDuration;
    UIView *confirmationView = [self confirmationViewForActionSheetWithOptions:[sheet numberOfOptions]];
    if ([segment canPerformAction:SENTimelineSegmentActionRemove]
        || [segment canPerformAction:SENTimelineSegmentActionIncorrect]) {
        [sheet addConfirmationView:confirmationView displayFor:confirmDuration forOptionWithTitle:negativeTitle];
    }

    if ([segment canPerformAction:SENTimelineSegmentActionApprove]) {
        [sheet addConfirmationView:confirmationView displayFor:confirmDuration forOptionWithTitle:approveTitle];
    }

    UIViewController *root = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
    UIModalPresentationStyle origStyle = [root modalPresentationStyle];
    [root setModalPresentationStyle:UIModalPresentationCurrentContext];
    [sheet addDismissAction:^{
      [root setModalPresentationStyle:origStyle];
    }];

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

- (void)showSleepDepthPopupForIndexPath:(NSIndexPath *)indexPath {
    if ([self.collectionView isDecelerating] || [self.dataSource segmentForEventExistsAtIndexPath:indexPath])
        return;

    [self setSelectedIndexPath:indexPath];
    self.popupView.attributedText = [self.dataSource summaryForSegmentAtIndexPath:indexPath];
    CGFloat top = [self topOfSelectedTimelineSleepSegment];
    [self.popupView showPointer:top > 0];
    self.popupViewTop.constant = top + HEMPopupAnimationDistance;
    [self.popupView setNeedsUpdateConstraints];
    [self.popupView layoutIfNeeded];
    self.popupViewTop.constant = top;
    [self.popupView setNeedsUpdateConstraints];
    self.popupView.alpha = 0;
    self.popupView.hidden = NO;
    self.popupMaskView.alpha = 0;
    self.popupMaskView.hidden = NO;
    [UIView animateWithDuration:HEMSleepSegmentPopupAnimationDuration
        animations:^{
          [self emphasizeCellAtIndexPath:indexPath];
          [self.popupView layoutIfNeeded];
          self.popupView.alpha = 1;
        }
        completion:^(BOOL finished) {
          __weak typeof(self) weakSelf = self;
          int64_t delayInSec = (int64_t)(HEMPopupAnimationDisplayInterval * NSEC_PER_SEC);
          dispatch_time_t delay = dispatch_time(DISPATCH_TIME_NOW, delayInSec);
          dispatch_after(delay, dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if ([[strongSelf selectedIndexPath] isEqual:indexPath]) {
                [strongSelf dismissTimelineSegmentPopup:YES];
            }
          });
        }];
}

- (CGFloat)topOfSelectedTimelineSleepSegment {
    UICollectionViewLayoutAttributes *attributes =
        [self.collectionView layoutAttributesForItemAtIndexPath:[self selectedIndexPath]];
    CGRect cellLocation = [self.collectionView convertRect:attributes.frame
                                                    toView:self.popupMaskView];
    CGFloat popupHeight = floorf([self.popupView intrinsicContentSize].height);
    return MAX(0, CGRectGetMinY(cellLocation) - popupHeight);
}

- (void)dismissTimelineSegmentPopup:(BOOL)animated {
    if (![self selectedIndexPath]) {
        return;
    }

    if ([self isDismissing]) {
        [self.popupMaskView.layer removeAllAnimations];
        [self.popupView.layer removeAllAnimations];
    }

    self.popupViewTop.constant = [self topOfSelectedTimelineSleepSegment] + HEMPopupAnimationDistance;
    void (^animations)(void) = ^{
      if ([self selectedIndexPath]) {
          self.popupView.alpha = 0;
          self.popupMaskView.alpha = 0;
          [self.popupView layoutIfNeeded];
      }
    };

    void (^completion)(BOOL finish) = ^(BOOL finished) {
      [self setSelectedIndexPath:nil];
      // remove all animations in case the animation is running already, with
      // a delay, which would cause problems if dimissing the timeline without
      // animation was reqeusted before
      [self.popupView.layer removeAllAnimations];
      [self.popupMaskView.layer removeAllAnimations];
      self.popupView.hidden = YES;
      self.popupMaskView.hidden = YES;
      [self setDismissing:NO];
    };

    [self setDismissing:YES];

    if (animated) {
        [UIView animateWithDuration:HEMSleepSegmentPopupAnimationDuration
                              delay:0.0f
                            options:UIViewAnimationOptionBeginFromCurrentState
                         animations:animations
                         completion:completion];
    } else {
        animations();
        completion(YES);
    }
}

- (void)emphasizeCellAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section != HEMSleepGraphCollectionViewSegmentSection)
        return;
    CGRect maskArea = CGRectZero;
    HEMSleepSegmentCollectionViewCell *cell = (id)[self.collectionView cellForItemAtIndexPath:indexPath];
    maskArea = [cell convertRect:[cell fillArea] toView:self.popupMaskView];
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

#pragma mark - HEMTapDelegate

- (void)didTapOnView:(HEMTappableView *)tappableView {
    HEMBreakdownViewController *controller = [HEMMainStoryboard instantiateBreakdownController];
    controller.result = self.dataSource.sleepResult;
    [self presentViewController:controller animated:YES completion:NULL];
}

#pragma mark - Navigation Bar Actions

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
        
        UIActivityViewController* activityController
            = [UIActivityViewController share:message ofType:@"timeline" fromView:[self view]];
        [self presentViewController:activityController animated:YES completion:nil];
    }
}

- (void)didTapOnHistoryButton:(UIButton *)sender {
    [[self handHoldingPresenter] didZoomOutOnTimeline];
    
    self.historyViewController = (id)[HEMMainStoryboard instantiateSleepHistoryController];
    self.historyViewController.selectedDate = self.dateForNightOfSleep;
    self.historyViewController.transitioningDelegate = self.zoomAnimationDelegate;
    [self presentViewController:self.historyViewController animated:YES completion:NULL];
}

- (void)checkForDateChanges {
    if (self.historyViewController.selectedDate) {
        if ([self.parentViewController isKindOfClass:[HEMSleepSummarySlideViewController class]]) {
            HEMSleepSummarySlideViewController* sliderVC = (id)self.parentViewController;
            [sliderVC reloadWithDate:self.historyViewController.selectedDate];
        }
    }
    self.historyViewController = nil;
}

#pragma mark - UIGestureRecognizerDelegate

- (void)didPan {
}

- (void)didTap {
    if ([self selectedIndexPath]) {
        [self dismissTimelineSegmentPopup:YES];
        return;
    }

    CGPoint location = [self.tapGestureRecognizer locationInView:self.view];
    CGPoint locationInCell = [self.view convertPoint:location toView:self.collectionView];
    NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:locationInCell];
    if ([self shouldAcceptTapAtLocation:location]) {
        UICollectionViewLayoutAttributes *attrs = [self.collectionView layoutAttributesForItemAtIndexPath:indexPath];
        if (locationInCell.y - CGRectGetMinY(attrs.frame) <= HEMSegmentPrefillTimeInset && indexPath.item > 0) {
            NSIndexPath *previousItem =
                [NSIndexPath indexPathForItem:indexPath.item - 1 inSection:HEMSleepGraphCollectionViewSegmentSection];
            [self showSleepDepthPopupForIndexPath:previousItem];
        } else {
            [self showSleepDepthPopupForIndexPath:indexPath];
        }
    }
}

- (BOOL)shouldAcceptTapAtLocation:(CGPoint)location {
    CGPoint locationInCell = [self.view convertPoint:location toView:self.collectionView];
    NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:locationInCell];
    return indexPath.section == HEMSleepGraphCollectionViewSegmentSection
           && ![self.dataSource segmentForEventExistsAtIndexPath:indexPath];
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

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self dismissTimelineSegmentPopup:NO];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGPoint offset = scrollView.contentOffset;
    [self adjustLayoutWithScrollOffset:offset.y];
    [[self shadowView] updateVisibilityWithContentOffset:[scrollView contentOffset].y];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        [self adjustLayoutWithScrollOffset:scrollView.contentOffset.y];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self adjustLayoutWithScrollOffset:scrollView.contentOffset.y];
}

- (void)adjustLayoutWithScrollOffset:(CGFloat)yOffset {
    self.collectionView.bounces = yOffset > CGRectGetMaxY([[self navigationBar] frame]);
    [self dismissTimelineSegmentPopup:NO];
}

#pragma mark - Navigation Bar

- (void)configureNavigationBar {
    UINavigationBar* bar = [UINavigationBar appearanceWhenContainedInInstancesOfClasses:@[[self class]]];
    ApplyDefaultStyleForNavBarAppearance(bar);
    
    UINavigationItem* navItem = self.navigationBar.topItem;
    navItem.title = [[self timelineService] stringValueForTimelineDate:[self dateForNightOfSleep]];
    
    CGRect buttonFrame = CGRectZero;
    buttonFrame.size.height = CGRectGetHeight([[self navigationBar] bounds]);
    buttonFrame.size.width = HEMStyleDefaultNavBarButtonItemWidth;
    
    UIImage* shareImage = [UIImage imageNamed:@"timelineShareIcon"];
    UIButton* shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
    CGFloat shareLeftInset = HEMStyleDefaultNavBarButtonItemWidth - shareImage.size.width;
    [shareButton setImage:shareImage forState:UIControlStateNormal];
    [shareButton setFrame:buttonFrame];
    [shareButton setImageEdgeInsets:UIEdgeInsetsMake(0.0f, shareLeftInset, 0.0f, 0.0f)];
    [shareButton addTarget:self
                    action:@selector(didTapShareButton:)
          forControlEvents:UIControlEventTouchUpInside];
    [shareButton setHidden:![self.dataSource hasSleepScore]];
    UIBarButtonItem* shareItem = [[UIBarButtonItem alloc] initWithCustomView:shareButton];
    [navItem setRightBarButtonItem:shareItem];
    [self setShareButton:shareButton];
    
    UIImage* historyImage = [UIImage imageNamed:@"timelineCalendarIcon"];
    UIButton* historyButton = [UIButton buttonWithType:UIButtonTypeCustom];
    CGFloat historyRightInset = HEMStyleDefaultNavBarButtonItemWidth - historyImage.size.width;
    [historyButton setImage:historyImage forState:UIControlStateNormal];
    [historyButton setFrame:buttonFrame];
    [historyButton setImageEdgeInsets:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, historyRightInset)];
    [historyButton addTarget:self
                      action:@selector(didTapOnHistoryButton:)
            forControlEvents:UIControlEventTouchUpInside];
    [navItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithCustomView:historyButton]];
    
    HEMNavigationShadowView* shadowView = [[HEMNavigationShadowView alloc] initWithNavigationBar:[self navigationBar]];
    [[self navigationBar] setClipsToBounds:NO];
    [[self navigationBar] addSubview:shadowView];
    [self setShadowView:shadowView];
}

#pragma mark - UICollectionView

- (void)configureCollectionView {
    self.collectionView.backgroundColor = [UIColor timelineBackgroundColor];
    self.collectionView.collectionViewLayout = [HEMFadingParallaxLayout new];
    self.collectionView.delegate = self;
}

- (void)loadData {
    if (![SENAuthorizationService isAuthorized])
        return;

    [self loadDataSourceForDate:self.dateForNightOfSleep];
}

- (void)refreshData {
    [self.dataSource refreshData];
}

- (void)reloadData {
    if (![self.dataSource isLoading])
        [self loadData];
}

- (BOOL)isLastNight {
    return [self.dataSource dateIsLastNight];
}

- (void)loadDataSourceForDate:(NSDate *)date {
    self.dateForNightOfSleep = date;
    self.dataSource =
        [[HEMSleepGraphCollectionViewDataSource alloc] initWithCollectionView:self.collectionView
                                                                    sleepDate:date
                                                              timelineService:self.timelineService];
    self.collectionView.dataSource = self.dataSource;

    __weak typeof(self) weakSelf = self;
    [self.dataSource reloadData:^(NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf updateTabBarIcon];
        [[strongSelf shareButton] setHidden:![strongSelf.dataSource hasSleepScore]];
        [strongSelf updateAppUsageIfNeeded];
        [strongSelf updateLayoutWithError:error];
        [strongSelf showTutorial];
    }];
    [self updateLayoutWithError:nil];
}

- (void)updateTabBarIcon {
    if ([self isLastNight] &&
        [[self parentViewController] isKindOfClass:[HEMSleepSummarySlideViewController class]]) {
        HEMSleepSummarySlideViewController* parentVC = (id) [self parentViewController];
        [parentVC updateLastNightSleepScore:[[[self dataSource] sleepResult].score integerValue]];
    }
}

- (void)updateLayoutWithError:(NSError *)error {
    BOOL hasTimelineData = [self.dataSource hasTimelineData];

    HEMAccountService* accountService = [HEMAccountService sharedService];
    HEMOnboardingService* onboardingService = [HEMOnboardingService sharedService];
    SENAccount* account = [accountService account] ?: [onboardingService currentAccount];

    BOOL firstNight = [[self timelineService] isFirstNightOfSleep:self.dateForNightOfSleep forAccount:account];
    
    self.errorSupportButton.hidden = YES;
    if (hasTimelineData || [self.dataSource isLoading]) {
        [self setErrorViewsVisible:NO];
        if ([self isVisible])
            [self checkIfInitialAnimationNeeded];
        return;
    } else if (error) {
        self.errorTitleLabel.text = NSLocalizedString(@"sleep-data.error.title", nil);
        self.errorMessageLabel.text = NSLocalizedString(@"sleep-data.error.message", nil);
        self.errorImageView.image = [UIImage imageNamed:@"timelineErrorIcon"];
    } else if (firstNight) {
        self.errorTitleLabel.text = NSLocalizedString(@"sleep-data.first-night.title", nil);
        self.errorMessageLabel.text = NSLocalizedString(@"sleep-data.first-night.message", nil);
        self.errorImageView.image = [UIImage imageNamed:@"timelineJustSleepIcon"];
    } else if (self.dataSource.sleepResult.scoreCondition == SENConditionUnknown) {
        self.errorTitleLabel.text = NSLocalizedString(@"sleep-data.none.title", nil);
        self.errorMessageLabel.text = NSLocalizedString(@"sleep-data.none.message", nil);
        self.errorImageView.image = [UIImage imageNamed:@"timelineNoDataIcon"];
        [self.errorSupportButton setTitle:[NSLocalizedString(@"sleep-data.not-enough.contact-support", nil) uppercaseString]
                                 forState:UIControlStateNormal];
        self.errorSupportButton.hidden = NO;
    } else {
        self.errorTitleLabel.text = NSLocalizedString(@"sleep-data.not-enough.title", nil);
        self.errorMessageLabel.text = NSLocalizedString(@"sleep-data.not-enough.message", nil);
        self.errorImageView.image = [UIImage imageNamed:@"timelineNotEnoughDataIcon"];
        [self.errorSupportButton setTitle:[NSLocalizedString(@"sleep-data.not-enough.contact-support", nil) uppercaseString]
                                 forState:UIControlStateNormal];
        self.errorSupportButton.hidden = NO;
    }
    [self setErrorViewsVisible:YES];
}

- (IBAction)handleErrorSupportTap:(id)sender {
    if (self.dataSource.sleepResult.scoreCondition == SENConditionIncomplete) {
        [HEMSupportUtil openHelpToPage:NSLocalizedString(@"help.url.slug.not-enough-data-recorded", nil)
                        fromController:self];
    } else {
        [HEMSupportUtil openHelpToPage:NSLocalizedString(@"help.url.slug.no-data-recorded", nil) fromController:self];
    }
}

- (void)setErrorViewsVisible:(BOOL)isVisible {
    self.collectionView.scrollEnabled = !isVisible;
    if (isVisible && self.collectionView.contentOffset.y > 0)
        self.collectionView.contentOffset = CGPointZero;
    [UIView animateWithDuration:0.2f
                     animations:^{
                       self.errorViewsContainerView.alpha = isVisible;
                     }];
}

- (void)updateAppUsageIfNeeded {
    if ([self.dataSource.sleepResult.score integerValue] > 0) {
        HEMAppUsage *appUsage = [HEMAppUsage appUsageForIdentifier:HEMAppUsageTimelineShownWithData];
        NSDate *updatedAtMidnight = [[appUsage updated] dateAtMidnight];
        if (!updatedAtMidnight || [updatedAtMidnight compare:self.dateForNightOfSleep] == NSOrderedAscending) {
            [HEMAppUsage incrementUsageForIdentifier:HEMAppUsageTimelineShownWithData];
        }
    }
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

#pragma mark UICollectionViewDelegate

- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.dataSource segmentForEventExistsAtIndexPath:indexPath]) {
        SENTimelineSegment *segment = [self.dataSource sleepSegmentForIndexPath:indexPath];
        return segment.possibleActions != SENTimelineSegmentActionNone;
    }
    return NO;
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
    CGFloat const HEMSoundHeightOffset = 26.f;
    BOOL hasSegments = [self.dataSource numberOfSleepSegments] > 0;
    CGFloat width = CGRectGetWidth(self.view.bounds);
    switch (indexPath.section) {
        case HEMSleepGraphCollectionViewSummarySection: {
            CGFloat height = CGRectGetHeight(self.view.bounds);
            if (hasSegments) {
                NSString* message = [self.dataSource sleepResult].message;
                height = [HEMSleepSummaryCollectionViewCell heightWithMessage:message itemWidth:width];
            }
            return CGSizeMake(width, height);
        }
        case HEMSleepGraphCollectionViewSegmentSection: {
            SENTimelineSegment *segment = [self.dataSource sleepSegmentForIndexPath:indexPath];
            CGFloat durationHeight = [self heightForCellWithSegment:segment];
            if ([self.dataSource segmentForEventExistsAtIndexPath:indexPath]) {
                NSAttributedString *message =
                    [HEMSleepEventCollectionViewCell attributedMessageFromText:segment.message];
                NSAttributedString *time = [self.dataSource formattedTextForInlineTimestamp:segment.date];
                BOOL hasSound = [self.dataSource segmentForSoundExistsAtIndexPath:indexPath];
                CGSize minSize =
                    [HEMEventBubbleView sizeWithAttributedText:message timeText:time showWaveform:hasSound];
                CGFloat height = MAX(MAX(ceilf(durationHeight), HEMSleepGraphCollectionViewEventMinimumHeight),
                                     minSize.height + HEMMinimumEventSpacing);
                if (hasSound) {
                    height += HEMSoundHeightOffset;
                }
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
           * (CGRectGetHeight(HEMKeyWindowBounds()) / HEMSleepGraphCollectionViewNumberOfHoursOnscreen);
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                             layout:(UICollectionViewLayout *)collectionViewLayout
    referenceSizeForHeaderInSection:(NSInteger)section {

    if (section == HEMSleepGraphCollectionViewSegmentSection) {
        if ([self.dataSource numberOfSleepSegments] > 0) {
            CGFloat bWidth = CGRectGetWidth(collectionView.bounds);
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
