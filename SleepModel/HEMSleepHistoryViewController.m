
#import <SenseKit/SENSleepResult.h>
#import <SenseKit/SENAPITimeline.h>
#import "HEMSleepHistoryViewController.h"
#import "HEMMiniGraphCollectionViewCell.h"
#import "HEMMiniSleepHistoryView.h"
#import "HEMMiniSleepScoreGraphView.h"

@interface HEMSleepHistoryViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) IBOutlet UICollectionView* historyCollectionView;
@property (weak, nonatomic) IBOutlet UILabel* timeFrameLabel;
@property (strong, nonatomic) NSDateFormatter* dayOfWeekFormatter;
@property (strong, nonatomic) NSDateFormatter* dayFormatter;
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
    [self configureDateFormatters];
    [self configureCollectionView];
    [self loadData];
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
    self.calendar = [NSCalendar currentCalendar];
    self.dayFormatter = [NSDateFormatter new];
    self.dayFormatter.dateFormat = @"d";
    self.dayOfWeekFormatter = [NSDateFormatter new];
    self.dayOfWeekFormatter.dateFormat = @"EEEE";
    self.monthYearFormatter = [NSDateFormatter new];
    self.monthYearFormatter.dateFormat = @"MMMM";
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
    static NSInteger const sleepDataCapacity = 80;
    self.sleepDataSummaries = [[NSMutableArray alloc] initWithCapacity:sleepDataCapacity];
    for (int i = sleepDataCapacity; i > 0; i--) {
        NSDate* date = [NSDate dateWithTimeIntervalSinceNow:i * -(60 * 60 * 24)];
        [self.sleepDataSummaries addObject:[SENSleepResult sleepResultForDate:date]];
    }
}

- (void)scrollToDate:(NSDate*)date animated:(BOOL)animated
{
    NSDate* initialDate = [(SENSleepResult*)[self.sleepDataSummaries firstObject] date];
    NSDateComponents *components = [self.calendar components:NSDayCalendarUnit
                                                    fromDate:initialDate
                                                      toDate:self.selectedDate
                                                     options:0];
    NSInteger index = components.day + 1;
    NSIndexPath* indexPath = [NSIndexPath indexPathForItem:index inSection:0];
    [self.historyCollectionView scrollToItemAtIndexPath:indexPath
                                       atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally
                                               animated:animated];
}

- (void)updateForSelectedDate
{
    if (self.selectedDate) {
        [self scrollToDate:self.selectedDate animated:NO];
        self.timeFrameLabel.text = [self.monthYearFormatter stringFromDate:self.selectedDate];
    } else {
        NSDate* date = [(SENSleepResult*)[self.sleepDataSummaries firstObject] date];
        self.timeFrameLabel.text = [self.monthYearFormatter stringFromDate:date];
    }
}

- (IBAction)scrollToLastNight:(id)sender {
    self.selectedDate = [NSDate dateWithTimeIntervalSinceNow:-86400];
    [self scrollToDate:self.selectedDate animated:YES];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView*)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView*)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.sleepDataSummaries.count;
}

- (UICollectionViewCell*)collectionView:(UICollectionView*)collectionView cellForItemAtIndexPath:(NSIndexPath*)indexPath
{
    return [self collectionView:collectionView sleepHistoryCellForItemAtIndexPath:indexPath];
}

- (UICollectionViewCell*)collectionView:(UICollectionView*)collectionView sleepHistoryCellForItemAtIndexPath:(NSIndexPath*)indexPath
{
    SENSleepResult* sleepResult = [self.sleepDataSummaries objectAtIndex:indexPath.row];
    HEMMiniGraphCollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"timeSliceCell" forIndexPath:indexPath];
    [cell.sleepScoreView setSleepScore:[sleepResult.score integerValue]];
    [cell.graphView setSleepDataSegments:sleepResult.segments];
    cell.dayLabel.text = [self.dayFormatter stringFromDate:sleepResult.date];
    cell.dayOfWeekLabel.text = [[self.dayOfWeekFormatter stringFromDate:sleepResult.date] uppercaseString];
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView*)collectionView didSelectItemAtIndexPath:(NSIndexPath*)indexPath
{
    [collectionView deselectItemAtIndexPath:indexPath animated:NO];
    if (indexPath.row == [collectionView numberOfItemsInSection:0] - 1)
        return;

    [collectionView scrollToItemAtIndexPath:indexPath
                           atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally
                                   animated:YES];
    SENSleepResult* sleepResult = [self.sleepDataSummaries objectAtIndex:indexPath.row];
    self.selectedDate = sleepResult.date;
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat midX = CGRectGetMidX(self.view.frame);
    NSArray* cells = [self.historyCollectionView.visibleCells sortedArrayUsingComparator:^NSComparisonResult(UICollectionViewCell* cell1, UICollectionViewCell* cell2) {
        NSNumber* diff1 = @(ABS(CGRectGetMidX(cell1.frame) - midX));
        NSNumber* diff2 = @(ABS(CGRectGetMidX(cell2.frame) - midX));
        return [diff2 compare:diff1];
    }];
    NSIndexPath* indexPath = [self.historyCollectionView indexPathForCell:[cells firstObject]];
    SENSleepResult* sleepResult = [self.sleepDataSummaries objectAtIndex:indexPath.row];
    self.timeFrameLabel.text = [self.monthYearFormatter stringFromDate:sleepResult.date];
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity
              targetContentOffset:(inout CGPoint *)targetContentOffset
{
    UICollectionViewLayout* layout = self.historyCollectionView.collectionViewLayout;
    CGRect rect = CGRectMake((*targetContentOffset).x, 0, 10, CGRectGetHeight(self.historyCollectionView.bounds));
    UICollectionViewLayoutAttributes *attribute = [[layout layoutAttributesForElementsInRect:rect] firstObject];
    NSIndexPath* indexPath = attribute.indexPath;
    if (indexPath) {
        SENSleepResult* sleepResult = [self.sleepDataSummaries objectAtIndex:indexPath.row];
        if (sleepResult.segments.count > 0)
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

            [sleepResult updateWithDictionary:[timelines firstObject]];
            [sleepResult save];
            [strongSelf.historyCollectionView reloadItemsAtIndexPaths:@[indexPath]];
        }];
    }
}

@end
