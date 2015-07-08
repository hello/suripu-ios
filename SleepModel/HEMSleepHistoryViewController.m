
#import <SenseKit/SENSleepResult.h>
#import <SenseKit/SENAPITimeline.h>
#import "HEMSleepHistoryViewController.h"
#import "HEMMiniGraphCollectionViewCell.h"
#import "HEMMiniSleepHistoryView.h"
#import "HEMMiniSleepScoreGraphView.h"
#import "NSDate+HEMRelative.h"

@interface HEMSleepHistoryViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) IBOutlet UICollectionView* historyCollectionView;
@property (weak, nonatomic) IBOutlet UILabel* timeFrameLabel;
@property (strong, nonatomic) NSDateFormatter* dayOfWeekFormatter;
@property (strong, nonatomic) NSDateFormatter* dayFormatter;
@property (strong, nonatomic) NSDateFormatter* monthFormatter;
@property (strong, nonatomic) NSDateFormatter* monthYearFormatter;
@property (strong, nonatomic) NSMutableArray* sleepDataSummaries;
@property (strong, nonatomic) NSDate* startDate;
@property (nonatomic) NSInteger numberOfDays;
@property (nonatomic, strong) NSCalendar* calendar;
@property (nonatomic, getter=didLayoutSubviews) BOOL laidOutSubviews;
@end

@implementation HEMSleepHistoryViewController

static CGFloat const HEMSleepHistoryCellWidthRatio = 0.359375f;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.historyCollectionView.delegate = nil;
    [self configureDateFormatters];
    [self configureCollectionView];
    [self loadData];
    self.historyCollectionView.delegate = self;
    
    [SENAnalytics track:HEMAnalyticsEventTimelineZoomOut];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self configureBackgroundColors];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    if (![self didLayoutSubviews]) {
        [self updateForSelectedDate];
        self.laidOutSubviews = YES;
    }
}

- (void)configureCollectionView
{
    UICollectionViewFlowLayout* layout = (id)self.historyCollectionView.collectionViewLayout;
    layout.sectionInset = UIEdgeInsetsMake(10.f, 0, 10.f, 0);
    CGFloat cellHeight = (CGRectGetHeight(self.view.bounds) * 0.65f) - layout.sectionInset.top - layout.sectionInset.bottom;
    CGFloat cellWidth = CGRectGetWidth(self.view.bounds) * HEMSleepHistoryCellWidthRatio;
    [self.historyCollectionView setContentInset: UIEdgeInsetsMake(0, cellWidth, 0, cellWidth)];
    layout.itemSize = CGSizeMake(cellWidth, cellHeight);
}

- (void)configureDateFormatters
{
    self.calendar = [NSCalendar autoupdatingCurrentCalendar];
    self.dayFormatter = [NSDateFormatter new];
    self.dayFormatter.dateFormat = @"d";
    self.dayOfWeekFormatter = [NSDateFormatter new];
    self.dayOfWeekFormatter.dateFormat = @"EEEE";
    self.monthFormatter = [NSDateFormatter new];
    self.monthFormatter.dateFormat = @"MMMM";
    self.monthYearFormatter = [NSDateFormatter new];
    self.monthYearFormatter.dateFormat = @"MMMM yyyy";
}

- (void)configureBackgroundColors
{
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.view.bounds;
    gradient.colors = @[(id)[UIColor whiteColor].CGColor,
                        (id)[UIColor colorWithHue:0 saturation:0 brightness:0.94 alpha:1].CGColor];
    [self.view.layer insertSublayer:gradient atIndex:0];
}

- (void)loadData
{
    static NSInteger const sleepDataCapacity = 200;
    self.sleepDataSummaries = [[NSMutableArray alloc] initWithCapacity:sleepDataCapacity];
    NSDateComponents* components = [NSDateComponents new];
    NSDate* today = [[NSDate date] dateAtMidnight];
    for (int i = sleepDataCapacity; i > 0; i--) {
        components.day = -i;
        NSDate* date = [self.calendar dateByAddingComponents:components
                                                      toDate:today
                                                     options:0];
        [self.sleepDataSummaries addObject:[SENSleepResult sleepResultForDate:date]];
    }
}

- (void)scrollToSelectedDateAnimated:(BOOL)animated
{
    NSDate* initialDate = [(SENSleepResult*)[self.sleepDataSummaries firstObject] date];
    NSDateComponents *components = [self.calendar components:NSDayCalendarUnit
                                                    fromDate:initialDate
                                                      toDate:self.selectedDate
                                                     options:0];
    NSInteger index = components.day + 1;
    NSInteger item = MIN(index, [self collectionView:self.historyCollectionView numberOfItemsInSection:0] - 1);
    NSIndexPath* indexPath = [NSIndexPath indexPathForItem:item inSection:0];
    [self.historyCollectionView scrollToItemAtIndexPath:indexPath
                                       atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally
                                               animated:animated];
}

- (void)updateForSelectedDate
{
    if (self.selectedDate) {
        [self scrollToSelectedDateAnimated:NO];
        [self updateTimeFrameLabelWithDate:self.selectedDate];
    } else {
        NSDate* date = [(SENSleepResult*)[self.sleepDataSummaries firstObject] date];
        [self updateTimeFrameLabelWithDate:date];
    }
}

- (BOOL)currentDateHasSameYearAsDate:(NSDate*)date
{
    NSCalendarUnit units = NSYearCalendarUnit;
    NSDateComponents* dateComponents = [self.calendar components:units fromDate:date];
    NSDateComponents* currentDateComponents = [self.calendar components:units fromDate:[NSDate date]];
    return dateComponents.year == currentDateComponents.year;
}

- (IBAction)scrollToLastNight:(id)sender {
    self.selectedDate = [NSDate date];
    [self scrollToSelectedDateAnimated:YES];
}

- (void)updateTimeFrameLabelWithDate:(NSDate*)date
{
    if ([self currentDateHasSameYearAsDate:date]) {
        self.timeFrameLabel.text = [self.monthFormatter stringFromDate:date];
    } else {
        self.timeFrameLabel.text = [self.monthYearFormatter stringFromDate:date];
    }
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView*)collectionView
{
    return 1;
}

// offsets number of rows by one to fudge the first cell not being selectable
- (NSInteger)collectionView:(UICollectionView*)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.sleepDataSummaries.count + 1;
}

- (UICollectionViewCell*)collectionView:(UICollectionView*)collectionView cellForItemAtIndexPath:(NSIndexPath*)indexPath
{
    return [self collectionView:collectionView sleepHistoryCellForItemAtIndexPath:indexPath];
}

- (UICollectionViewCell*)collectionView:(UICollectionView*)collectionView sleepHistoryCellForItemAtIndexPath:(NSIndexPath*)indexPath
{
    HEMMiniGraphCollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"timeSliceCell" forIndexPath:indexPath];
    if (indexPath.row > 0) {
        SENSleepResult* sleepResult = [self resultAtIndexPath:indexPath];
        [cell.sleepScoreView setSleepScore:[sleepResult.score integerValue]];
        [cell.graphView setSleepDataSegments:sleepResult.segments];
        cell.dayLabel.text = [self.dayFormatter stringFromDate:sleepResult.date];
        cell.dayOfWeekLabel.text = [[self.dayOfWeekFormatter stringFromDate:sleepResult.date] uppercaseString];
    }
    cell.hidden = indexPath.row == 0;
    return cell;
}

- (SENSleepResult*)resultAtIndexPath:(NSIndexPath*)indexPath {
    if (indexPath.row == 0)
        return nil;
    return [self.sleepDataSummaries objectAtIndex:indexPath.row - 1];
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView*)collectionView didSelectItemAtIndexPath:(NSIndexPath*)indexPath
{
    [collectionView deselectItemAtIndexPath:indexPath animated:NO];
    SENSleepResult* sleepResult = [self resultAtIndexPath:indexPath];
    self.selectedDate = sleepResult.date;
    NSIndexPath* centeredIndexPath = [self indexPathAtCenter];
    if ([indexPath isEqual:centeredIndexPath]) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [collectionView scrollToItemAtIndexPath:indexPath
                               atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally
                                       animated:YES];

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self dismissViewControllerAnimated:YES completion:nil];
        });
    }
    [SENAnalytics track:HEMAnalyticsEventTimelineZoomIn];
}

#pragma mark - UIScrollViewDelegate

- (NSIndexPath*)indexPathAtCenter
{
    UICollectionView* collectionView = self.historyCollectionView;
    CGPoint centerPoint = CGPointMake(collectionView.center.x + collectionView.contentOffset.x,
                                      collectionView.center.y + collectionView.contentOffset.y);
    return [collectionView indexPathForItemAtPoint:centerPoint];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSIndexPath* indexPath = [self indexPathAtCenter];
    if (indexPath) {
        SENSleepResult* sleepResult = [self resultAtIndexPath:indexPath];
        [self updateTimeFrameLabelWithDate:sleepResult.date];
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity
              targetContentOffset:(inout CGPoint *)targetContentOffset
{
    UICollectionViewLayout* layout = self.historyCollectionView.collectionViewLayout;
    CGRect rect = CGRectMake((*targetContentOffset).x, 0, 10, CGRectGetHeight(self.historyCollectionView.bounds));
    UICollectionViewLayoutAttributes *attribute = [[layout layoutAttributesForElementsInRect:rect] firstObject];
    NSIndexPath* indexPath = attribute.indexPath;
    if (indexPath) {
        [self fetchTimelineForResultAtRow:indexPath.row];
        if (indexPath.row > 0)
            [self fetchTimelineForResultAtRow:indexPath.row - 1];
        if (indexPath.row < [self.historyCollectionView numberOfItemsInSection:indexPath.section] - 1)
            [self fetchTimelineForResultAtRow:indexPath.row + 1];
    }
}

- (void)fetchTimelineForResultAtRow:(NSUInteger)row
{
    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:row inSection:0];
    SENSleepResult* sleepResult = [self resultAtIndexPath:indexPath];
    if (!sleepResult || sleepResult.segments.count > 0)
        return;

    __weak typeof(self) weakSelf = self;
    [SENAPITimeline timelineForDate:sleepResult.date completion:^(NSArray* timelines, NSError* error) {
        typeof(weakSelf) strongSelf = weakSelf;
        if (error)
            return;

        NSDictionary* timeline = [timelines firstObject];
        NSArray* segments = timeline[@"segments"];
        if (segments.count == 0)
            return;

        BOOL didUpdate = [sleepResult updateWithDictionary:[timelines firstObject]];
        if (didUpdate) {
            [sleepResult save];
            NSIndexPath* indexPath = [NSIndexPath indexPathForRow:row inSection:0];
            [strongSelf.historyCollectionView reloadItemsAtIndexPaths:@[indexPath]];
        }
    }];
}

@end
