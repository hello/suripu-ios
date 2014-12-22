
#import <FCDynamicPanesNavigationController/FCDynamicPanesNavigationController.h>
#import <SenseKit/SENSettings.h>
#import <SenseKit/SENAuthorizationService.h>
#import <markdown_peg.h>
#import <SenseKit/SENSensor.h>
#import <SenseKit/SENSettings.h>
#import <SenseKit/SENSleepResult.h>
#import <UIImageEffects/UIImage+ImageEffects.h>

#import "HelloStyleKit.h"
#import "HEMAlertController.h"
#import "HEMAppDelegate.h"
#import "HEMRootViewController.h"
#import "HEMAudioCache.h"
#import "HEMEventInfoView.h"
#import "HEMMainStoryboard.h"
#import "HEMPaddedRoundedLabel.h"
#import "HEMPresleepHeaderCollectionReusableView.h"
#import "HEMSleepEventCollectionViewCell.h"
#import "HEMSleepGraphCollectionViewDataSource.h"
#import "HEMSleepGraphUtils.h"
#import "HEMSleepGraphView.h"
#import "HEMSleepGraphViewController.h"
#import "HEMSleepHistoryViewController.h"
#import "HEMSleepSummaryCollectionViewCell.h"
#import "HEMSleepSummarySlideViewController.h"
#import "UIFont+HEMStyle.h"
#import "UIView+HEMSnapshot.h"
#import "HEMZoomAnimationTransitionDelegate.h"

CGFloat const HEMTimelineHeaderCellHeight = 50.f;

@interface HEMSleepGraphViewController () <UICollectionViewDelegateFlowLayout, FCDynamicPaneViewController, UIGestureRecognizerDelegate>

@property (nonatomic, strong) IBOutlet UICollectionView* collectionView;
@property (nonatomic, retain) HEMSleepGraphView* view;
@property (nonatomic, strong) HEMSleepHistoryViewController* historyViewController;
@property (nonatomic, strong) HEMSleepGraphCollectionViewDataSource* dataSource;
@property (nonatomic, strong) HEMZoomAnimationTransitionDelegate* animationDelegate;
@property (nonatomic) UIStatusBarStyle oldBarStyle;
@property (nonatomic) NSInteger eventIndex;
@end

@implementation HEMSleepGraphViewController

static CGFloat const HEMSleepSummaryCellHeight = 350.f;
static CGFloat const HEMPresleepHeaderCellHeight = 70.f;
static CGFloat const HEMPresleepItemCellHeight = 68.f;
static CGFloat const HEMSleepGraphCollectionViewEventMinimumHeight = 30.f;
static CGFloat const HEMSleepGraphCollectionViewNumberOfHoursOnscreen = 10.f;
static CGFloat const HEMTopItemsConstraintConstant = 10.f;
static CGFloat const HEMTopItemsMinimumConstraintConstant = -6.f;

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self configureCollectionView];
    [self reloadData];
    self.animationDelegate = [HEMZoomAnimationTransitionDelegate new];
    self.transitioningDelegate = self.animationDelegate;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.view.backgroundColor = [UIColor whiteColor];
    self.panePanGestureRecognizer.delegate = self;
    [self.view addVerifyDataTarget:self action:@selector(didTapDataVerifyButton:)];
    [self checkForDateChanges];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.panePanGestureRecognizer.delegate = self;
    [self registerForNotifications];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.panePanGestureRecognizer.delegate = nil;
    [self.view hideEventInfoView];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidPop
{
    [[UIApplication sharedApplication] setStatusBarStyle:self.oldBarStyle];
    [UIView animateWithDuration:0.5f animations:^{
        self.collectionView.contentOffset = CGPointMake(0, 0);
        [self updateTopBarActionsWithState:NO];
    }];
    self.oldBarStyle = UIStatusBarStyleLightContent;
    [self setNeedsStatusBarAppearanceUpdate];
}

- (void)viewDidPush
{
    self.panePanGestureRecognizer.delegate = self;
    self.oldBarStyle = [UIApplication sharedApplication].statusBarStyle;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    [UIView animateWithDuration:0.5f animations:^{
        [self updateTopBarActionsWithState:YES];
    }];
    [self setNeedsStatusBarAppearanceUpdate];
}

- (void)registerForNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData)
                                                 name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData)
                                                 name:SENAuthorizationServiceDidAuthorizeNotification object:nil];
}

- (void)dealloc {
    _historyViewController = nil;
    _dataSource = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark HEMSleepGraphActionDelegate

- (void)toggleDrawer
{
    HEMAppDelegate* delegate = (id)[UIApplication sharedApplication].delegate;
    HEMRootViewController* root = (id)delegate.window.rootViewController;
    [root toggleSettingsDrawer];
}

- (BOOL)shouldEnableZoomButton
{
    return [self isViewPushed];
}

- (BOOL)shouldHideShareButton
{
    return ![self isViewPushed] || [self.dataSource.sleepResult.score integerValue] == 0;
}

#pragma mark Top cell actions

- (void)updateTopBarActionsWithState:(BOOL)pushed
{
    self.collectionView.scrollEnabled = !pushed;
    UIImage* drawerIcon = pushed ? [UIImage imageNamed:@"Menu"] : [UIImage imageNamed:@"caret up"];
    CGFloat constant = pushed ? HEMTopItemsConstraintConstant : HEMTopItemsMinimumConstraintConstant;
    HEMSleepSummaryCollectionViewCell* cell = self.dataSource.sleepSummaryCell;
    [cell.shareButton setHidden:!pushed || self.dataSource.numberOfSleepSegments == 0];
    [cell.dateButton setAlpha:pushed ? 1.f : 0.5f];
    [cell.dateButton setEnabled:pushed];
    [cell.drawerButton setImage:drawerIcon forState:UIControlStateNormal];
    cell.topItemsVerticalConstraint.constant = constant;
    [cell updateConstraintsIfNeeded];
}

- (void)drawerButtonTapped:(UIButton*)button
{
    [self toggleDrawer];
}

- (void)shareButtonTapped:(UIButton*)button
{
    long score = [self.dataSource.sleepResult.score longValue];
    if (score > 0) {
        NSString* message = [NSString stringWithFormat:NSLocalizedString(@"activity.share.format", nil), score];
        UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:@[message] applicationActivities:nil];
        [self presentViewController:activityController animated:YES completion:nil];
    }
}

- (void)zoomButtonTapped:(UIButton*)sender
{
    if (![self isViewPushed])
        return;
    self.historyViewController = (id)[HEMMainStoryboard instantiateSleepHistoryController];
    self.historyViewController.selectedDate = self.dateForNightOfSleep;
    self.historyViewController.transitioningDelegate = self.animationDelegate;
    [self presentViewController:self.historyViewController animated:YES completion:NULL];
}

- (void)checkForDateChanges
{
    if (self.historyViewController.selectedDate) {
        [self loadDataSourceForDate:self.historyViewController.selectedDate];
//        HEMSleepSummarySlideViewController* parent = (id)self.parentViewController;
//        [parent reloadData];
    }

    self.historyViewController = nil;
}

- (void)loadDataSourceForDate:(NSDate*)date
{
    self.dateForNightOfSleep = date;
    self.dataSource = [[HEMSleepGraphCollectionViewDataSource alloc] initWithCollectionView:self.collectionView
                                                                                  sleepDate:date];
    self.collectionView.dataSource = self.dataSource;
    [self.collectionView reloadData];
}

#pragma mark Event Info Popup

- (void)didTapEventButton:(UIButton*)sender
{
    NSIndexPath* eventIndexPath = [self indexPathForEventCellWithSubview:sender];
    SENSleepResultSegment* segment = [self.dataSource sleepSegmentForIndexPath:eventIndexPath];
    self.eventIndex = eventIndexPath.row;
    [self.view positionEventInfoViewRelativeToView:sender
                                       withSegment:segment
                                 totalSegmentCount:[self.dataSource numberOfSleepSegments]];
}

- (void)didTapDataVerifyButton:(UIButton*)sender
{
    NSIndexPath* indexPath = [NSIndexPath indexPathForItem:self.eventIndex
                                                 inSection:HEMSleepGraphCollectionViewSegmentSection];
    [HEMSleepGraphUtils presentTimePickerForDate:self.dateForNightOfSleep
                                         segment:[self.dataSource sleepSegmentForIndexPath:indexPath]
                                  fromController:self];
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

- (BOOL)isViewPushed
{
    CGPoint location = [self.view.superview convertPoint:self.view.frame.origin fromView:nil];
    return location.y > -10.f;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer*)gestureRecognizer shouldReceiveTouch:(UITouch*)touch
{
    return self.collectionView.contentOffset.y < 20.f;
}

- (BOOL)gestureRecognizer:(UIPanGestureRecognizer*)gestureRecognizer
    shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer*)otherGestureRecognizer
{
    return [self.collectionView contentSize].height > CGRectGetHeight([self.collectionView bounds]);
}

- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer*)gestureRecognizer
{
    CGPoint translation = [gestureRecognizer translationInView:[self view]];
    return fabsf(translation.y) > fabsf(translation.x);
}

#pragma mark UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.view hideEventInfoView];
}

#pragma mark UICollectionViewDelegate

- (void)reloadData
{
    if (![SENAuthorizationService isAuthorized])
        return;

    [self loadDataSourceForDate:self.dateForNightOfSleep];
}

- (void)configureCollectionView
{
    self.view.collectionView = self.collectionView;
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.delegate = self;
}

- (BOOL)collectionView:(UICollectionView*)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath*)indexPath
{
    UICollectionViewCell* cell = [collectionView cellForItemAtIndexPath:indexPath];
    return [cell isKindOfClass:[HEMSleepEventCollectionViewCell class]];
}

- (BOOL)collectionView:(UICollectionView*)collectionView shouldSelectItemAtIndexPath:(NSIndexPath*)indexPath
{
    UICollectionViewCell* cell = [collectionView cellForItemAtIndexPath:indexPath];
    if ([cell isKindOfClass:[HEMSleepEventCollectionViewCell class]]) {
        HEMSleepEventCollectionViewCell* eventCell = (HEMSleepEventCollectionViewCell*)cell;
        [eventCell.eventTypeButton sendActionsForControlEvents:UIControlEventTouchUpInside];
    }
    return NO;
}

#pragma mark UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView*)collectionView
                  layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath*)indexPath
{
    BOOL hasSegments = [self.dataSource numberOfSleepSegments] > 0;
    CGFloat width = CGRectGetWidth(self.view.bounds);
    switch (indexPath.section) {
    case HEMSleepGraphCollectionViewSummarySection:
        return CGSizeMake(width, hasSegments ? HEMSleepSummaryCellHeight : CGRectGetHeight(self.view.bounds));

    case HEMSleepGraphCollectionViewPresleepSection:
        return CGSizeMake(width, HEMPresleepItemCellHeight);

    case HEMSleepGraphCollectionViewSegmentSection: {
        SENSleepResultSegment* segment = [self.dataSource sleepSegmentForIndexPath:indexPath];
        CGFloat durationHeight = ([segment.duration doubleValue] / 3600) * (CGRectGetHeight([UIScreen mainScreen].bounds) / HEMSleepGraphCollectionViewNumberOfHoursOnscreen);
        if ([self.dataSource segmentForSleepExistsAtIndexPath:indexPath]) {
            return CGSizeMake(width, ceilf(durationHeight));
        }
        else {
            return CGSizeMake(width, MAX(durationHeight, HEMSleepGraphCollectionViewEventMinimumHeight));
        }
    }

    default:
        return CGSizeMake(width, HEMSleepGraphCollectionViewEventMinimumHeight);
    }
}

- (CGSize)collectionView:(UICollectionView*)collectionView
                  layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    BOOL hasSegments = [self.dataSource numberOfSleepSegments] > 0;
    if (!hasSegments)
        return CGSizeZero;

    switch (section) {
    case HEMSleepGraphCollectionViewPresleepSection:
        return CGSizeMake(CGRectGetWidth(self.view.bounds), HEMPresleepHeaderCellHeight);
    case HEMSleepGraphCollectionViewSegmentSection:
        return CGSizeMake(CGRectGetWidth(self.view.bounds), HEMTimelineHeaderCellHeight);
    default:
        return CGSizeZero;
    }
}

- (CGFloat)collectionView:(UICollectionView*)collectionView
                   layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}

@end
