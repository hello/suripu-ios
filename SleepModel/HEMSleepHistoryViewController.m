
#import <SenseKit/SENSleepResult.h>
#import "HEMSleepHistoryViewController.h"
#import "HEMMiniGraphCollectionViewCell.h"
#import "HEMMiniSleepHistoryView.h"
#import "HEMMiniSleepScoreGraphView.h"

@interface HEMSleepHistoryViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) IBOutlet UIView *gradientView;

@property (weak, nonatomic) IBOutlet UICollectionView* historyCollectionView;
@property (weak, nonatomic) IBOutlet UILabel* timeFrameLabel;
@property (strong, nonatomic) NSDateFormatter* dayOfWeekFormatter;
@property (strong, nonatomic) NSDateFormatter* dayFormatter;
@property (strong, nonatomic) NSDateFormatter* monthYearFormatter;
@property (strong, nonatomic) NSMutableArray* sleepDataSummaries;
@property (strong, nonatomic) NSDate* startDate;
@property (nonatomic) NSInteger numberOfDays;
@property (nonatomic, strong) NSCalendar* calendar;
@end

@implementation HEMSleepHistoryViewController

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
    [self updateForSelectedDate];
}

- (void)configureCollectionView
{
    UICollectionViewFlowLayout* layout = (id)self.historyCollectionView.collectionViewLayout;
    layout.itemSize = CGSizeMake(90.f, CGRectGetHeight(self.historyCollectionView.bounds) - 20.f);
}

- (void)configureDateFormatters
{
    self.calendar = [NSCalendar currentCalendar];
    self.dayFormatter = [NSDateFormatter new];
    self.dayFormatter.dateFormat = @"d";
    self.dayOfWeekFormatter = [NSDateFormatter new];
    self.dayOfWeekFormatter.dateFormat = @"EEE";
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

    UIColor* color = [UIColor colorWithHue:0 saturation:0 brightness:0.9f alpha:0];
    NSArray* colors = @[(id)[color colorWithAlphaComponent:0.3].CGColor,
                        (id)color.CGColor,
                        (id)color.CGColor,
                        (id)color.CGColor,
                        (id)[color colorWithAlphaComponent:0.5].CGColor];
    CAGradientLayer *shadowGradient = [CAGradientLayer layer];
    CGRect gradientRect = [[UIScreen mainScreen] bounds];
    shadowGradient.frame = gradientRect;
    shadowGradient.startPoint = CGPointMake(0.0, 0.5);
    shadowGradient.endPoint = CGPointMake(1.0, 0.5);
    shadowGradient.colors = colors;
    [self.gradientView.layer insertSublayer:shadowGradient atIndex:0];
}

- (void)loadData
{
    static NSInteger const sleepDataCapacity = 80;
    self.sleepDataSummaries = [[NSMutableArray alloc] initWithCapacity:sleepDataCapacity];
    for (int i = sleepDataCapacity - 1; i >= 0; i--) {
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
    [self.historyCollectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:animated];
}

- (void)updateForSelectedDate
{
    if (self.selectedDate) {
        [self scrollToDate:self.selectedDate animated:YES];
        self.timeFrameLabel.text = [self.monthYearFormatter stringFromDate:self.selectedDate];
    } else {
        NSDate* date = [(SENSleepResult*)[self.sleepDataSummaries firstObject] date];
        self.timeFrameLabel.text = [self.monthYearFormatter stringFromDate:date];
    }
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
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
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

@end
