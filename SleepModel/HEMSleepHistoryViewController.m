
#import <SenseKit/SenseKit.h>
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
static NSUInteger const HEMSleepDataCapacity = 200;

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
    NSUInteger capacity = HEMSleepDataCapacity;
    NSDate* today = [[NSDate date] dateAtMidnight];
    NSDate* creationDate = [[[SENServiceAccount sharedService] account] createdAt];
    if (creationDate && [creationDate compare:today] == NSOrderedAscending) {
        NSDateComponents *difference = [self.calendar components:NSDayCalendarUnit fromDate:creationDate  toDate:today options:0];
        capacity = MIN(MAX(1, difference.day), HEMSleepDataCapacity);
    }
    self.sleepDataSummaries = [[NSMutableArray alloc] initWithCapacity:capacity];
    NSDateComponents* components = [NSDateComponents new];
    for (int i = capacity; i > 0; i--) {
        components.day = -i;
        NSDate* date = [self.calendar dateByAddingComponents:components
                                                      toDate:today
                                                     options:0];
        [self.sleepDataSummaries addObject:[SENTimeline timelineForDate:date]];
    }
}

- (void)scrollToSelectedDateAnimated:(BOOL)animated
{
    NSDate* initialDate = [(SENTimeline*)[self.sleepDataSummaries firstObject] date];
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
        NSDate* date = [(SENTimeline*)[self.sleepDataSummaries firstObject] date];
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
    if (!date)
        return;
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
        SENTimeline* sleepResult = [self resultAtIndexPath:indexPath];
        [cell.sleepScoreView setSleepScore:[sleepResult.score integerValue]];
        [cell.graphView setSleepDataSegments:sleepResult.segments];
        cell.dayLabel.text = [self.dayFormatter stringFromDate:sleepResult.date];
        cell.dayOfWeekLabel.text = [[self.dayOfWeekFormatter stringFromDate:sleepResult.date] uppercaseString];
        cell.rightBorderView.hidden = indexPath.row == HEMSleepDataCapacity;
        cell.leftBorderView.hidden = indexPath.row == 1;
    }
    cell.hidden = indexPath.row == 0;
    return cell;
}

- (SENTimeline*)resultAtIndexPath:(NSIndexPath*)indexPath {
    NSInteger index = [self indexAtIndexPath:indexPath];
    if (index == NSNotFound)
        return nil;
    return [self.sleepDataSummaries objectAtIndex:index];
}

- (NSInteger)indexAtIndexPath:(NSIndexPath*)indexPath {
    if (indexPath.row == 0)
        return NSNotFound;
    return indexPath.row - 1;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView*)collectionView didSelectItemAtIndexPath:(NSIndexPath*)indexPath
{
    [collectionView deselectItemAtIndexPath:indexPath animated:NO];
    SENTimeline* sleepResult = [self resultAtIndexPath:indexPath];
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
    if (indexPath.row > 0) {
        SENTimeline* sleepResult = [self resultAtIndexPath:indexPath];
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
    SENTimeline* sleepResult = [self resultAtIndexPath:indexPath];
    if (!sleepResult.date || sleepResult.segments.count > 0)
        return;

    __weak typeof(self) weakSelf = self;
    [SENAPITimeline timelineForDate:sleepResult.date completion:^(SENTimeline* timeline, NSError* error) {
        typeof(weakSelf) strongSelf = weakSelf;
        if (error || !timeline.date)
            return;

        BOOL didUpdate = ![sleepResult isEqual:timeline];
        if (didUpdate) {
            [timeline save];
            NSInteger index = [self indexAtIndexPath:indexPath];
            if (index != NSNotFound) {
                self.sleepDataSummaries[[self indexAtIndexPath:indexPath]] = timeline;
                [strongSelf.historyCollectionView reloadItemsAtIndexPaths:@[indexPath]];
            }
        }
    }];
}

@end
