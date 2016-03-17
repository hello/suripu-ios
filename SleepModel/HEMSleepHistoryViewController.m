
#import <SenseKit/SenseKit.h>
#import "HEMSleepHistoryViewController.h"
#import "HEMMiniGraphCollectionViewCell.h"
#import "HEMMiniSleepHistoryView.h"
#import "HEMMiniSleepScoreGraphView.h"
#import "SENSensorAccessibility.h"
#import "NSDate+HEMRelative.h"
#import "HEMOnboardingService.h"
#import "HEMAccountService.h"
#import "HEMTimelineService.h"

@interface HEMSleepHistoryViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) IBOutlet UICollectionView* historyCollectionView;
@property (weak, nonatomic) IBOutlet UILabel* timeFrameLabel;
@property (weak, nonatomic) IBOutlet UIButton *lastNightButton;
@property (strong, nonatomic) NSDateFormatter* dayOfWeekFormatter;
@property (strong, nonatomic) NSDateFormatter* dayFormatter;
@property (strong, nonatomic) NSDateFormatter* readerDateFormatter;
@property (strong, nonatomic) NSDateFormatter* monthFormatter;
@property (strong, nonatomic) NSDateFormatter* monthYearFormatter;
@property (strong, nonatomic) NSMutableArray* sleepDataSummaries;
@property (strong, nonatomic) NSDate* startDate;
@property (strong, nonatomic) NSMutableSet* pendingDataFetches;
@property (nonatomic) NSInteger numberOfDays;
@property (nonatomic, strong) NSCalendar* calendar;
@property (nonatomic, getter=didLayoutSubviews) BOOL laidOutSubviews;
@property (nonatomic, strong) HEMTimelineService* timelineService;
@end

@implementation HEMSleepHistoryViewController

static CGFloat const HEMSleepHistoryCellWidthRatio = 0.359375f;
static NSUInteger const HEMSleepDataCapacity = 400;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.historyCollectionView.delegate = nil;
    [self configureDateFormatters];
    [self configureCollectionView];
    [self loadData];
    self.historyCollectionView.delegate = self;
    [self setTimelineService:[HEMTimelineService new]];
    [SENAnalytics track:HEMAnalyticsEventTimelineZoomOut];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self configureBackgroundColors];
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
    self.readerDateFormatter = [NSDateFormatter new];
    self.readerDateFormatter.dateFormat = @"EEEE, d MMMM";
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
    if ([[today previousDay] shouldCountAsPreviousDay])
        today = [today previousDay];
    
    HEMAccountService* accountService = [HEMAccountService sharedService];
    HEMOnboardingService* onboardingService = [HEMOnboardingService sharedService];
    SENAccount* account = [accountService account] ?: [onboardingService currentAccount];

    if (![[self timelineService] canViewTimelinesBefore:today forAccount:account]) {
        NSDateComponents *difference = [self.calendar components:NSCalendarUnitDay
                                                        fromDate:[account createdAt]
                                                          toDate:today
                                                         options:0];
        capacity = MIN(MAX(1, difference.day + 1), HEMSleepDataCapacity);
    }
    
    self.sleepDataSummaries = [[NSMutableArray alloc] initWithCapacity:capacity];
    self.pendingDataFetches = [NSMutableSet new];

    NSDate* previousSelectedDate = [[self selectedDate] previousDay];
    NSDate* nextSelectedDate = [[self selectedDate] nextDay];
    NSDateComponents* components = [NSDateComponents new];

    for (NSUInteger i = capacity; i > 0; i--) {
        components.day = -i;
        SENTimeline* timeline = nil;
        NSDate* date = [self.calendar dateByAddingComponents:components
                                                      toDate:today
                                                     options:0];
        if ([date isOnSameDay:[self selectedDate]]
            || [date isOnSameDay:previousSelectedDate]
            || [date isOnSameDay:nextSelectedDate]) {
            timeline = [SENTimeline timelineForDate:date];
            // TODO (jimmy:) if timeline is not cached, we need to load it!
            // currently, if timeline is not loaded, but this is the selected date,
            // a spinner is forever shown
        } else {
            timeline = [SENTimeline new];
            timeline.date = date;
        }
        [self.sleepDataSummaries addObject:timeline];
    }
}

- (void)scrollToSelectedDateAnimated:(BOOL)animated
{
    NSDate* initialDate = [(SENTimeline*)[self.sleepDataSummaries firstObject] date];
    NSDateComponents *components = [self.calendar components:NSCalendarUnitDay
                                                    fromDate:initialDate
                                                      toDate:self.selectedDate
                                                     options:0];
    NSInteger index = components.day + 1;
    NSInteger item = MIN(index, [self collectionView:self.historyCollectionView numberOfItemsInSection:0] - 1);
    NSIndexPath* indexPath = [NSIndexPath indexPathForItem:item inSection:0];
    if (index == 1) {
        [self.historyCollectionView setContentOffset:CGPointMake(10.0f, 0.0f) animated:YES];
    } else {
        [self.historyCollectionView scrollToItemAtIndexPath:indexPath
                                           atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally
                                                   animated:animated];
    }
    UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, [self.historyCollectionView cellForItemAtIndexPath:indexPath]);
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
    NSCalendarUnit units = NSCalendarUnitYear;
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
    cell.hidden = indexPath.row == 0;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView
       willDisplayCell:(UICollectionViewCell *)cell
    forItemAtIndexPath:(NSIndexPath *)indexPath {
    
    SENTimeline* timeline = [self resultAtIndexPath:indexPath];
    if (timeline) {
        HEMMiniGraphCollectionViewCell* graphCell = (id)cell;
        [self updateCell:graphCell atIndexPath:indexPath];
        
        if (![timeline score]) {
            [self fetchTimelineForResultAtRow:[indexPath row]];
        }
    }
}

- (SENTimeline*)resultAtIndexPath:(NSIndexPath*)indexPath {
    NSInteger index = [self indexAtIndexPath:indexPath];
    if (index == NSNotFound || index >= [self.sleepDataSummaries count])
        return nil;
    return [self.sleepDataSummaries objectAtIndex:index];
}

- (NSInteger)indexAtIndexPath:(NSIndexPath*)indexPath {
    NSInteger numberOfItems = [self.historyCollectionView numberOfItemsInSection:indexPath.section] - 1;
    if (indexPath.row == 0 || indexPath.row - 1 >= numberOfItems) {
        return NSNotFound;
    }
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
        if ([indexPath item] == 1) {
            [collectionView setContentOffset:CGPointMake(10.0f, 0.0f) animated:YES];
        } else {
            [collectionView scrollToItemAtIndexPath:indexPath
                                   atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally
                                           animated:YES];
        }

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
        self.lastNightButton.hidden = indexPath.row >= self.sleepDataSummaries.count;
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
        if (indexPath.row > 0) {
            // make sure we fetch at least what is visible which will be 3 cells
            if (velocity.x <= 0.0f) { // moving left
                [self fetchTimelineForResultAtRow:indexPath.row + 1];
                [self fetchTimelineForResultAtRow:indexPath.row + 2];
            } else {
                [self fetchTimelineForResultAtRow:indexPath.row - 1];
                [self fetchTimelineForResultAtRow:indexPath.row - 2];
            }
        }
    }
}

- (HEMMiniGraphCollectionViewCell*)showLoadingIndicator:(BOOL)show onCellAtIndexPath:(NSIndexPath*)indexPath {
    HEMMiniGraphCollectionViewCell* cell = nil;
    NSInteger index = [self indexAtIndexPath:indexPath];
    if (index != NSNotFound) {
        cell = (id)[self.historyCollectionView cellForItemAtIndexPath:indexPath];
        [cell showLoadingActivity:show];
    }
    return cell;
}

- (void)updateCell:(HEMMiniGraphCollectionViewCell*)cell atIndexPath:(NSIndexPath*)indexPath {
    SENTimeline* timeline = [self resultAtIndexPath:indexPath];
    if (!timeline) {
        return;
    }
    NSInteger score = [timeline.score integerValue];
    [cell.sleepScoreView setSleepScore:score];
    [cell.graphView setSleepDataSegments:timeline.segments];
    cell.dayLabel.text = [self.dayFormatter stringFromDate:timeline.date];
    cell.dayOfWeekLabel.text = [[self.dayOfWeekFormatter stringFromDate:timeline.date] uppercaseString];
    cell.rightBorderView.hidden = indexPath.row == HEMSleepDataCapacity;
    cell.leftBorderView.hidden = indexPath.row == 1;
    cell.isAccessibilityElement = YES;
    cell.accessibilityValue = [NSString stringWithFormat:NSLocalizedString(@"sleep-history.accessibility-value.timeline.format", nil),
                                    [self.readerDateFormatter stringFromDate:timeline.date],
                                    (long)score,
                                    SENConditionReadableValue(timeline.scoreCondition)];
    [cell showLoadingActivity:!timeline.score];
}

- (void)fetchTimelineForResultAtRow:(NSUInteger)row
{
    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:row inSection:0];
    SENTimeline* sleepResult = [self resultAtIndexPath:indexPath];
    if (!sleepResult.date || sleepResult.score) {
        [self showLoadingIndicator:NO onCellAtIndexPath:indexPath];
        return;
    }
    
    if ([self.pendingDataFetches containsObject:sleepResult.date]) {
        return;
    }
    
    [self.pendingDataFetches addObject:sleepResult.date];
    
    DDLogVerbose(@"pending data fetches are now at %ld", (long)[self.pendingDataFetches count]);
    
    __weak typeof(self) weakSelf = self;
    [SENAPITimeline timelineForDate:sleepResult.date completion:^(SENTimeline* timeline, NSError* error) {
        typeof(weakSelf) strongSelf = weakSelf;
        
        if (error) {
            [strongSelf showLoadingIndicator:NO onCellAtIndexPath:indexPath];
            return;
        }
        
        [strongSelf.pendingDataFetches removeObject:sleepResult.date];
        DDLogVerbose(@"pending data fetches are now at %ld", (long)[strongSelf.pendingDataFetches count]);
        // ix the issue where timeline response from server may not return with
        // a date.  doing it here to reduce risk else where that depends on this logic.
        if (!timeline.date) {
            timeline.date = sleepResult.date;
        }
        
        NSInteger index = [strongSelf indexAtIndexPath:indexPath];
        BOOL didUpdate = ![sleepResult isEqual:timeline];
        if (didUpdate) {
            [timeline save];
            if (index != NSNotFound) {
                strongSelf.sleepDataSummaries[[strongSelf indexAtIndexPath:indexPath]] = timeline;
            }
        }
        
        if (index != NSNotFound) {
            HEMMiniGraphCollectionViewCell* graphCell = (id)[strongSelf.historyCollectionView cellForItemAtIndexPath:indexPath];
            [strongSelf updateCell:graphCell atIndexPath:indexPath];
        }
    }];
}

@end
