//
//  HEMTrendsViewController.m
//  Sense
//
//  Created by Delisa Mason on 12/13/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import <SenseKit/SENAPITrends.h>
#import <SenseKit/SENTrend.h>
#import <AttributedMarkdown/markdown_peg.h>
#import "HEMTrendsViewController.h"
#import "HelloStyleKit.h"
#import "HEMMainStoryboard.h"
#import "HEMTrendCollectionViewCell.h"
#import "HEMEmptyTrendCollectionViewCell.h"
#import "HEMGraphSectionOverlayView.h"
#import "UIFont+HEMStyle.h"
#import "HEMMarkdown.h"
#import "HEMTutorial.h"
#import "HEMSnazzBarController.h"
#import "HEMRootViewController.h"

@interface HEMTrendsViewController () <UICollectionViewDelegate, UICollectionViewDataSource, HEMTrendCollectionViewCellDelegate, HEMSnazzBarControllerChild>
@property (nonatomic, weak) IBOutlet UICollectionView* collectionView;
@property (nonatomic, strong) NSMutableArray* defaultTrends;
@property (nonatomic, assign, getter=isLoading) BOOL loading;
@end

@implementation HEMTrendsViewController

static CGFloat const HEMTrendsViewCellHeight = 198.0f;
static CGFloat const HEMTrendsNoDataCellHeight = 248.0f;
static CGFloat const HEMTrendsViewOptionsCellHeight = 255.f;

static NSString* const HEMScoreTrendType = @"SLEEP_SCORE";
static NSString* const HEMDurationTrendType = @"SLEEP_DURATION";
static NSString* const HEMDayOfWeekScopeType = @"DOW";
static NSString* const HEMMonthScopeType = @"M";
static NSString* const HEMWeekScopeType = @"W";
static NSString* const HEMAllScopeType = @"ALL";

- (id)initWithCoder:(NSCoder*)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        self.tabBarItem.title = NSLocalizedString(@"trends.title", nil);
        self.tabBarItem.image = [HelloStyleKit trendsBarIcon];
        self.tabBarItem.selectedImage = [UIImage imageNamed:@"trendsBarIconActive"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.collectionView setAlwaysBounceVertical:YES];
    UICollectionViewFlowLayout* layout = (id)self.collectionView.collectionViewLayout;
    CGSize size = layout.itemSize;
    size.height = HEMTrendsViewCellHeight;
    layout.itemSize = size;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refreshData)
                                                 name:SENAPIReachableNotification
                                               object:nil];
    [self refreshData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:SENAPIReachableNotification
                                                  object:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [SENAnalytics track:kHEMAnalyticsEventTrends];
}

- (void)didReceiveMemoryWarning
{
    if (![self isViewLoaded] || !self.view.window) {
        self.defaultTrends = nil;
    }
    [super didReceiveMemoryWarning];
}

- (void)refreshData
{
    if ([self isLoading])
        return;
    self.loading = YES;
    
    __weak typeof(self) weakSelf = self;
    [SENAPITrends defaultTrendsListWithCompletion:^(NSArray* data, NSError* error) {
        __strong typeof(weakSelf) strongSelf = self;
        if (error) {
            [strongSelf.collectionView reloadData];
            strongSelf.loading = NO;
            return;
        }
        NSMutableArray* trends = [data mutableCopy];
        if (![trends isEqualToArray:strongSelf.defaultTrends]) {
            strongSelf.defaultTrends = trends;
            [strongSelf.collectionView reloadData];
        }
        strongSelf.loading = NO;
        [strongSelf showTutorialIfSelectedWithData];
    }];
}

#pragma mark - Snazz Events

- (void)snazzViewDidAppear {
    [self showTutorialIfSelectedWithData];
}

#pragma mark - Tutorial

- (void)showTutorialIfSelectedWithData {
    HEMRootViewController* rootVC = [HEMRootViewController rootViewControllerForKeyWindow];
    HEMSnazzBarController* snazzVC = [rootVC barController];
    if ([[snazzVC selectedViewController] isEqual:self.parentViewController]
        && self.isViewLoaded
        && self.view.window) {
        [HEMTutorial showTutorialForTrendsIfNeeded];
    }
}

#pragma mark HEMTrendCollectionViewCellDelegate

- (void)didTapTimeScopeInCell:(HEMTrendCollectionViewCell*)cell withText:(NSString*)text
{
    NSIndexPath* indexPath = [self.collectionView indexPathForCell:cell];
    if (!indexPath)
        return;
    cell.userInteractionEnabled = NO;
    SENTrend* trend = self.defaultTrends[indexPath.row];
    void (^completion)(NSArray*, NSError*) = ^(NSArray* data, NSError* error) {
        if (error) {
            [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
        } else if (![[data firstObject] isKindOfClass:[SENTrend class]]) {
            cell.statusLabel.hidden = NO;
            cell.statusLabel.text = NSLocalizedString(@"trends.not-enough-data.message", nil);
        } else {
            SENTrend* trend = [data firstObject];
            [self.defaultTrends replaceObjectAtIndex:indexPath.row withObject:trend];
            [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
        }
        cell.userInteractionEnabled = YES;
        self.loading = NO;
    };
    self.loading = YES;
    [cell showGraphOfType:HEMTrendCellGraphTypeNone withData:nil];
    cell.statusLabel.text = NSLocalizedString(@"activity.loading", nil);
    cell.statusLabel.hidden = NO;
    if ([trend.dataType isEqualToString:HEMScoreTrendType]) {
        [SENAPITrends sleepScoreTrendForTimePeriod:text completion:completion];
    }
    else if ([trend.dataType isEqualToString:HEMDurationTrendType]) {
        [SENAPITrends sleepDurationTrendForTimePeriod:text completion:completion];
    }
    else {
        cell.statusLabel.text = NSLocalizedString(@"trends.not-enough-data.message", nil);
    }
}

#pragma mark UICollectionViewDelegate

- (BOOL)collectionView:(UICollectionView*)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath*)indexPath
{
    return NO;
}

- (CGSize)collectionView:(UICollectionView*)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath*)indexPath
{
    UICollectionViewFlowLayout* layout = (id)collectionViewLayout;
    CGFloat width = layout.itemSize.width;
    if (self.defaultTrends.count == 0) {
        return CGSizeMake(width, HEMTrendsNoDataCellHeight);
    }
    SENTrend* trend = self.defaultTrends[indexPath.row];
    CGFloat height = trend.options.count > 0 ? HEMTrendsViewOptionsCellHeight : HEMTrendsViewCellHeight;
    return CGSizeMake(width, height);
}

#pragma mark UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView*)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView*)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.defaultTrends.count > 0 ? self.defaultTrends.count : 1;
}

- (UICollectionViewCell*)collectionView:(UICollectionView*)collectionView cellForItemAtIndexPath:(NSIndexPath*)indexPath
{
    if (self.defaultTrends.count == 0) {
        return [self collectionView:collectionView emptyCellForItemAtIndexPath:indexPath];
    }
    SENTrend* trend = self.defaultTrends[indexPath.row];
    NSDictionary* attributes = @{ NSKernAttributeName : @(1.2),
        NSFontAttributeName : [UIFont backViewTitleFont] };
    NSAttributedString* attributedTitle = [[NSAttributedString alloc] initWithString:trend.title attributes:attributes];
    if (trend.dataPoints.count <= 2) {
        return [self collectionView:collectionView emptyCellForItemAtIndexPath:indexPath];
    }
    NSString* identifier = [HEMMainStoryboard trendGraphReuseIdentifier];
    HEMTrendCollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier
                                                                                 forIndexPath:indexPath];
    cell.titleLabel.attributedText = attributedTitle;
    cell.statusLabel.hidden = YES;
    cell.delegate = self;
    [self configureGraphForCell:cell withTrend:trend];
    return cell;
}

- (HEMEmptyTrendCollectionViewCell*)collectionView:(UICollectionView*)collectionView emptyCellForItemAtIndexPath:(NSIndexPath*)indexPath
{
    NSString* identifier = [HEMMainStoryboard overTimeReuseIdentifier];
    HEMEmptyTrendCollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier
                                                                                      forIndexPath:indexPath];
    if ([self isLoading]) {
        [cell showActivity:YES withText:NSLocalizedString(@"activity.loading", nil)];
    }
    else {
        [cell showActivity:NO withText:nil];
        cell.detailLabel.text = NSLocalizedString(@"trends.not-enough-data.message", nil);
    }
    
    return cell;
}

- (void)configureGraphForCell:(HEMTrendCollectionViewCell*)cell withTrend:(SENTrend*)trend
{
    NSString* period = trend.timePeriod;
    HEMTrendCellGraphType type = trend.graphType == SENTrendGraphTypeTimeSeriesLine
        ? HEMTrendCellGraphTypeLine
        : HEMTrendCellGraphTypeBar;
    BOOL useBarGraph = (type == HEMTrendCellGraphTypeBar);
    [cell setTimeScopesWithOptions:trend.options selectedOptionIndex:[trend.options indexOfObject:period]];
    cell.numberOfGraphSections = type == HEMTrendCellGraphTypeBar ? trend.dataPoints.count : 7;
    if ([period isEqualToString:HEMDayOfWeekScopeType]) {
        cell.showGraphLabels = YES;
        cell.topLabelType = HEMTrendCellGraphLabelTypeDayOfWeek;
        cell.bottomLabelType = [trend.dataType isEqualToString:HEMDurationTrendType]
            ? HEMTrendCellGraphLabelTypeHourValue
            : HEMTrendCellGraphLabelTypeValue;
    }
    else if ([period hasSuffix:HEMMonthScopeType] && period.length == 2) {
        cell.showGraphLabels = YES;
        cell.topLabelType = HEMTrendCellGraphLabelTypeNone;
        NSInteger months = [[period substringWithRange:NSMakeRange(0, 1)] integerValue];
        if (months > 1) {
            cell.bottomLabelType = HEMTrendCellGraphLabelTypeMonth;
            if (!useBarGraph)
                cell.numberOfGraphSections = months;
        }
        else {
            cell.bottomLabelType = HEMTrendCellGraphLabelTypeDate;
        }
    }
    else if ([period hasSuffix:HEMWeekScopeType] && period.length == 2) {
        NSInteger weeks = [[period substringWithRange:NSMakeRange(0, 1)] integerValue];
        cell.showGraphLabels = YES;
        cell.topLabelType = HEMTrendCellGraphLabelTypeNone;
        cell.bottomLabelType = weeks < 2 ? HEMTrendCellGraphLabelTypeDayOfWeek : HEMTrendCellGraphLabelTypeDate;
    }
    else {
        cell.topLabelType = HEMTrendCellGraphLabelTypeNone;
        cell.bottomLabelType = HEMTrendCellGraphLabelTypeNone;
        cell.showGraphLabels = useBarGraph;
    }
    [cell showGraphOfType:type withData:trend.dataPoints];
}

#pragma mark - Clean Up

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_collectionView setDelegate:nil];
    [_collectionView setDataSource:nil];
}

@end
