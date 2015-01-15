//
//  HEMTrendsViewController.m
//  Sense
//
//  Created by Delisa Mason on 12/13/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import <SenseKit/SENAPITrends.h>
#import <SenseKit/SENTrend.h>
#import "HEMTrendsViewController.h"
#import "HelloStyleKit.h"
#import "HEMMainStoryboard.h"
#import "HEMCardFlowLayout.h"
#import "HEMTrendCollectionViewCell.h"

@interface HEMTrendsViewController ()<UICollectionViewDelegate, UICollectionViewDataSource>
@property (nonatomic, weak) IBOutlet UICollectionView* collectionView;
@property (nonatomic, strong) NSArray* trends;
@property (nonatomic, assign, getter=isLoading) BOOL loading;
@end

@implementation HEMTrendsViewController

static CGFloat const HEMTrendsViewCellHeight = 184.f;
static CGFloat const HEMTrendsViewOptionsCellHeight = 235.f;

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        self.tabBarItem.image = [HelloStyleKit trendsBarIcon];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.collectionView setAlwaysBounceVertical:YES];
    HEMCardFlowLayout* layout = (id)self.collectionView.collectionViewLayout;
    [layout setItemHeight:184];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self refreshData];
}

- (void)refreshData
{
    if ([self isLoading])
        return;
    self.loading = YES;
    [SENAPITrends defaultTrendsListWithCompletion:^(id data, NSError *error) {
        if (error)
            return;
        self.trends = data;
        [self.collectionView reloadData];
        self.loading = NO;
    }];
}

#pragma mark UICollectionViewDelegate

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    HEMCardFlowLayout* layout = (id)collectionViewLayout;
    CGFloat width = layout.itemSize.width;
    if (self.trends.count == 0) {
        return CGSizeMake(width, layout.itemSize.height);
    }
    SENTrend* trend = self.trends[indexPath.row];
    CGFloat height = trend.options.count > 0 ? HEMTrendsViewOptionsCellHeight : HEMTrendsViewCellHeight;
    return CGSizeMake(width, height);
}

#pragma mark UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.trends.count > 0 ? self.trends.count : 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.trends.count == 0) {
        NSString* identifier = [HEMMainStoryboard overTimeReuseIdentifier];
        return [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    }
    SENTrend* trend = self.trends[indexPath.row];
    NSString* identifier = [HEMMainStoryboard trendGraphReuseIdentifier];
    HEMTrendCollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier
                                                                                 forIndexPath:indexPath];
    cell.titleLabel.text = trend.title;
    if (trend.graphType == SENTrendGraphTypeTimeSeriesLine) {
        [cell showLineGraphWithData:trend.dataPoints max:0 min:100];
    } else if (trend.graphType == SENTrendGraphTypeHistogram) {
        [cell showBarGraphWithData:trend.dataPoints max:0 min:100];
    }
    [cell setTimeScopesWithOptions:trend.options];
    return cell;
}

@end
