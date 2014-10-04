
#import <FCDynamicPanesNavigationController/FCDynamicPanesNavigationController.h>
#import <SenseKit/SENSettings.h>
#import <SenseKit/SENSensor.h>
#import <SenseKit/SENSleepResult.h>

#import "HEMSleepGraphCollectionViewController.h"
#import "HEMSleepSummaryCollectionViewCell.h"
#import "HEMSleepGraphCollectionViewFlowLayout.h"
#import "HEMSensorDataHeaderView.h"
#import "HEMSleepGraphCollectionViewDataSource.h"
#import "HelloStyleKit.h"

@interface HEMSleepGraphCollectionViewController () <UICollectionViewDelegateFlowLayout, FCDynamicPaneViewController, UIGestureRecognizerDelegate>

@property (nonatomic, strong) HEMSleepGraphCollectionViewDataSource* dataSource;
@property (nonatomic, weak) HEMSensorDataHeaderView* sensorDataHeaderView;
@property (nonatomic) UIStatusBarStyle oldBarStyle;
@end

@implementation HEMSleepGraphCollectionViewController

static CGFloat const HEMSleepSummaryCellHeight = 300.f;
static CGFloat const HEMSleepGraphCollectionViewSensorViewHeight = 65.f;
static CGFloat const HEMSleepGraphCollectionViewEventMinimumHeight = 30.f;
static CGFloat const HEMSleepGraphCollectionViewEventLightHeight = 95.f;
static CGFloat const HEMSleepGraphCollectionViewEventMaximumHeight = 165.f;
static CGFloat const HEMSleepGraphCollectionViewNumberOfHoursOnscreen = 4.f;

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self configureCollectionView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.view.backgroundColor = [UIColor whiteColor];
    self.panePanGestureRecognizer.delegate = self;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.panePanGestureRecognizer.delegate = self;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.panePanGestureRecognizer.delegate = nil;
}

- (void)viewDidPop
{
    [[UIApplication sharedApplication] setStatusBarStyle:self.oldBarStyle];
    self.collectionView.scrollEnabled = NO;
    [UIView animateWithDuration:0.5f animations:^{
        self.collectionView.contentOffset = CGPointMake(0, 0);
        self.view.backgroundColor = [HelloStyleKit lightestBlueColor];
    }];
    self.oldBarStyle = UIStatusBarStyleLightContent;
    [self setNeedsStatusBarAppearanceUpdate];
}

- (void)viewDidPush
{
    self.panePanGestureRecognizer.delegate = self;
    self.oldBarStyle = [UIApplication sharedApplication].statusBarStyle;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    [UIView animateWithDuration:0.1f animations:^{
        self.view.backgroundColor = [UIColor colorWithWhite:0.97f alpha:1.f];
    }];
    self.collectionView.scrollEnabled = YES;
    [self setNeedsStatusBarAppearanceUpdate];
}

#pragma mark - UIGestureRecognizerDelegate

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

- (void)scrollViewDidScroll:(UIScrollView*)scrollView
{
    [self.dataSource updateSensorViewText];
}

#pragma mark UICollectionViewDelegate

- (void)configureCollectionView
{
    self.collectionView.backgroundColor = [HelloStyleKit lightestBlueColor];
    self.dataSource = [[HEMSleepGraphCollectionViewDataSource alloc] initWithCollectionView:self.collectionView
                                                                                  sleepDate:self.dateForNightOfSleep];
    self.collectionView.dataSource = self.dataSource;
    self.collectionView.delegate = self;
    self.collectionView.collectionViewLayout = [HEMSleepGraphCollectionViewFlowLayout new];
}

- (BOOL)collectionView:(UICollectionView*)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath*)indexPath
{
    return NO;
}

- (BOOL)collectionView:(UICollectionView*)collectionView shouldSelectItemAtIndexPath:(NSIndexPath*)indexPath
{
    return NO;
}

- (void)collectionView:(UICollectionView*)cv didEndDisplayingCell:(UICollectionViewCell*)cell forItemAtIndexPath:(NSIndexPath*)indexPath
{
    if ([cell isKindOfClass:[HEMSleepSummaryCollectionViewCell class]]) {
        [(HEMSleepSummaryCollectionViewCell*)cell setSleepScore:0 animated:NO];
    }
}

#pragma mark UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView*)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath*)indexPath
{
    CGFloat width = CGRectGetWidth(self.view.bounds);
    switch (indexPath.section) {
    case HEMSleepGraphCollectionViewSummarySection:
        return CGSizeMake(width, HEMSleepSummaryCellHeight);

    case HEMSleepGraphCollectionViewSegmentSection: {
        SENSleepResultSegment* segment = [self.dataSource sleepSegmentForIndexPath:indexPath];

        CGFloat durationHeight = ([segment.duration doubleValue] / 3600) * (CGRectGetHeight([UIScreen mainScreen].bounds) / HEMSleepGraphCollectionViewNumberOfHoursOnscreen);
        if ([self.dataSource segmentForSleepExistsAtIndexPath:indexPath]) {
            return CGSizeMake(width, ceilf(durationHeight));
        } else {
            return CGSizeMake(width, MAX(durationHeight, HEMSleepGraphCollectionViewEventMinimumHeight));
        }
    }
    default:
        return CGSizeMake(width, HEMSleepGraphCollectionViewEventMinimumHeight);
    }
}

- (CGFloat)collectionView:(UICollectionView*)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}

- (CGSize)collectionView:(UICollectionView*)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    switch (section) {
    case HEMSleepGraphCollectionViewSegmentSection:
        return CGSizeMake(CGRectGetWidth(self.view.bounds), HEMSleepGraphCollectionViewSensorViewHeight);

    default:
        return CGSizeZero;
    }
}

@end
