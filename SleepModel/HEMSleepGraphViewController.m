
#import <FCDynamicPanesNavigationController/FCDynamicPanesNavigationController.h>
#import <SenseKit/SENSettings.h>
#import <SenseKit/SENAuthorizationService.h>
#import <markdown_peg.h>
#import <SenseKit/SENSensor.h>
#import <SenseKit/SENSettings.h>
#import <SenseKit/SENSleepResult.h>
#import <UIImageEffects/UIImage+ImageEffects.h>

#import "HEMSleepGraphViewController.h"
#import "HelloStyleKit.h"
#import "HEMAlertController.h"
#import "HEMAppDelegate.h"
#import "HEMEventInfoView.h"
#import "HEMSleepGraphView.h"
#import "HEMSleepGraphUtils.h"
#import "HEMSleepGraphCollectionViewDataSource.h"
#import "HEMSleepSummaryCollectionViewCell.h"
#import "HEMSleepEventCollectionViewCell.h"
#import "UIFont+HEMStyle.h"
#import "UIView+HEMSnapshot.h"

CGFloat const HEMTimelineHeaderCellHeight = 50.f;

@interface HEMSleepGraphViewController () <UICollectionViewDelegateFlowLayout, FCDynamicPaneViewController, UIGestureRecognizerDelegate>

@property (strong, nonatomic) IBOutlet UICollectionView* collectionView;
@property (nonatomic, retain) HEMSleepGraphView* view;
@property (nonatomic, strong) HEMSleepGraphCollectionViewDataSource* dataSource;
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self configureCollectionView];
    [self reloadData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.view.backgroundColor = [UIColor whiteColor];
    self.panePanGestureRecognizer.delegate = self;
    [self.view addVerifyDataTarget:self action:@selector(didTapDataVerifyButton:)];
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
    [self.view.eventInfoView stopAudio];
    self.panePanGestureRecognizer.delegate = nil;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidPop
{
    [[UIApplication sharedApplication] setStatusBarStyle:self.oldBarStyle];
    self.collectionView.scrollEnabled = NO;
    HEMSleepSummaryCollectionViewCell* cell = self.dataSource.sleepSummaryCell;
    [UIView animateWithDuration:0.5f animations:^{
        self.collectionView.contentOffset = CGPointMake(0, 0);
        [cell.shareButton setHidden:YES];
        [cell.dateLabel setAlpha:0.5];
        [cell.drawerButton setImage:[UIImage imageNamed:@"caret up"] forState:UIControlStateNormal];
        cell.topItemsVerticalConstraint.constant = 0;
        [cell updateConstraintsIfNeeded];
    }];
    self.oldBarStyle = UIStatusBarStyleLightContent;
    [self setNeedsStatusBarAppearanceUpdate];
}

- (void)viewDidPush
{
    self.panePanGestureRecognizer.delegate = self;
    self.oldBarStyle = [UIApplication sharedApplication].statusBarStyle;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    self.collectionView.scrollEnabled = YES;
    HEMSleepSummaryCollectionViewCell* cell = self.dataSource.sleepSummaryCell;
    [UIView animateWithDuration:0.5f animations:^{
        [cell.shareButton setHidden:[self.dataSource.sleepResult.score integerValue] == 0];
        [cell.dateLabel setAlpha:1];
        [cell.drawerButton setImage:[UIImage imageNamed:@"Menu"] forState:UIControlStateNormal];
        cell.topItemsVerticalConstraint.constant = HEMTopItemsConstraintConstant;
        [cell updateConstraintsIfNeeded];
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
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark Top cell actions

- (void)drawerButtonTapped:(UIButton*)button
{
    [self toggleDrawer];
}

- (void)shareButtonTapped:(UIButton*)button
{
    long score = [self.dataSource.sleepResult.score longValue];
    if (score > 0) {
        NSString* message = [NSString stringWithFormat:NSLocalizedString(@"activity.share.format", nil), score];
        UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:@[message]
                                                                                         applicationActivities:nil];
        [self presentViewController:activityController animated:YES completion:nil];
    }
}

- (void)toggleDrawer
{
    HEMAppDelegate* delegate = (id)[UIApplication sharedApplication].delegate;
    [delegate toggleSettingsDrawer];
}

#pragma mark Event Info Popup

- (void)didTapEventButton:(UIButton*)sender
{
    [self positionEventInfoViewRelativeToView:sender];
}

- (void)didTapDataVerifyButton:(UIButton*)sender
{
    NSIndexPath* indexPath = [NSIndexPath indexPathForItem:self.eventIndex
                                                 inSection:HEMSleepGraphCollectionViewSegmentSection];
    [HEMSleepGraphUtils presentTimePickerForDate:self.dateForNightOfSleep
                                         segment:[self.dataSource sleepSegmentForIndexPath:indexPath]
                                  fromController:self];
}

- (void)positionEventInfoViewRelativeToView:(UIView*)view
{
    NSIndexPath* eventIndexPath = [self indexPathForEventCellWithSubview:view];
    SENSleepResultSegment* segment = [self.dataSource sleepSegmentForIndexPath:eventIndexPath];
    self.eventIndex = eventIndexPath.row;
    [self.view positionEventInfoViewRelativeToView:view
                                       withSegment:segment
                                 totalSegmentCount:[self.dataSource numberOfSleepSegments]];
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
    self.dataSource = [[HEMSleepGraphCollectionViewDataSource alloc] initWithCollectionView:self.collectionView
                                                                                  sleepDate:self.dateForNightOfSleep];
    self.collectionView.dataSource = self.dataSource;
    [self.collectionView reloadData];
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
