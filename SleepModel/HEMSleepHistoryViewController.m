
#import "HEMSleepHistoryViewController.h"
#import "HEMMiniGraphCollectionViewCell.h"
#import "HEMMiniSleepHistoryView.h"
#import "HEMMiniSleepScoreGraphView.h"
#import "HEMFakeDataGenerator.h"

@interface HEMSleepHistoryViewController () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView* historyCollectionView;
@property (weak, nonatomic) IBOutlet UICollectionView* insightCollectionView;
@property (weak, nonatomic) IBOutlet UILabel* timeFrameLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl* timeScopeSegmentedControl;
@property (strong, nonatomic) NSDateFormatter* dayOfWeekFormatter;
@property (strong, nonatomic) NSDateFormatter* dayFormatter;
@property (strong, nonatomic) NSDateFormatter* monthYearFormatter;
@property (strong, nonatomic) NSMutableArray* sleepDataSummaries;
@end

@implementation HEMSleepHistoryViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self configureCollectionView];
    [self configureDateFormatters];
    [self loadData];
}

- (void)configureCollectionView
{
    CGSize windowSize = [[UIScreen mainScreen] bounds].size;
    UICollectionViewFlowLayout* layout = (UICollectionViewFlowLayout*)self.insightCollectionView.collectionViewLayout;
    layout.itemSize = CGSizeMake(CGRectGetWidth(self.insightCollectionView.bounds) - 40, CGRectGetHeight(self.insightCollectionView.bounds) - 20);
    CGFloat sideInset = floorf((windowSize.width - layout.itemSize.width) / 2);
    layout.sectionInset = UIEdgeInsetsMake(0, sideInset, 0, sideInset);
}

- (void)configureDateFormatters
{
    self.dayFormatter = [NSDateFormatter new];
    self.dayFormatter.dateFormat = @"d";
    self.dayOfWeekFormatter = [NSDateFormatter new];
    self.dayOfWeekFormatter.dateFormat = @"EEE";
    self.monthYearFormatter = [NSDateFormatter new];
    self.monthYearFormatter.dateFormat = @"MMMM yyyy";
}

- (void)loadData
{
    static NSInteger const sleepDataCapacity = 80;
    self.sleepDataSummaries = [[NSMutableArray alloc] initWithCapacity:sleepDataCapacity];
    for (int i = sleepDataCapacity - 1; i >= 0; i--) {
        NSDate* date = [NSDate dateWithTimeIntervalSinceNow:i * -(60 * 60 * 24)];
        [self.sleepDataSummaries addObject:[HEMFakeDataGenerator sleepDataForDate:date]];
    }
    NSDate* date = [NSDate dateWithTimeIntervalSince1970:[[self.sleepDataSummaries firstObject][@"date"] doubleValue] / 1000];
    self.timeFrameLabel.text = [self.monthYearFormatter stringFromDate:date];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView*)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView*)collectionView numberOfItemsInSection:(NSInteger)section
{
    if ([collectionView isEqual:self.insightCollectionView]) {
        return 4;
    }
    return self.sleepDataSummaries.count;
}

- (UICollectionViewCell*)collectionView:(UICollectionView*)collectionView cellForItemAtIndexPath:(NSIndexPath*)indexPath
{
    if ([collectionView isEqual:self.insightCollectionView])
        return [self collectionView:collectionView insightCellForItemAtIndexPath:indexPath];

    return [self collectionView:collectionView sleepHistoryCellForItemAtIndexPath:indexPath];
}

- (UICollectionViewCell*)collectionView:(UICollectionView*)collectionView insightCellForItemAtIndexPath:(NSIndexPath*)indexPath
{
    UICollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"insightCell" forIndexPath:indexPath];
    return cell;
}

- (UICollectionViewCell*)collectionView:(UICollectionView*)collectionView sleepHistoryCellForItemAtIndexPath:(NSIndexPath*)indexPath
{
    NSDictionary* sleepData = [self.sleepDataSummaries objectAtIndex:indexPath.row];
    NSDate* date = [NSDate dateWithTimeIntervalSince1970:[sleepData[@"date"] doubleValue] / 1000];
    HEMMiniGraphCollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"timeSliceCell" forIndexPath:indexPath];
    [cell.sleepScoreView setSleepScore:[sleepData[@"score"] integerValue]];
    [cell.graphView setSleepDataSegments:sleepData[@"segments"]];
    cell.dayLabel.text = [self.dayFormatter stringFromDate:date];
    cell.dayOfWeekLabel.text = [[self.dayOfWeekFormatter stringFromDate:date] uppercaseString];
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView*)collectionView didSelectItemAtIndexPath:(NSIndexPath*)indexPath
{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
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
    NSDictionary* sleepData = [self.sleepDataSummaries objectAtIndex:indexPath.row];
    NSDate* date = [NSDate dateWithTimeIntervalSince1970:[sleepData[@"date"] doubleValue] / 1000];
    self.timeFrameLabel.text = [self.monthYearFormatter stringFromDate:date];
}

@end
