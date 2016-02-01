//
//  HEMTrendsGraphsPresenter.m
//  Sense
//
//  Created by Jimmy Lu on 1/29/16.
//  Copyright © 2016 Hello. All rights reserved.
//
#import <SenseKit/SENTrends.h>
#import <SenseKit/SENTrendsGraph.h>

#import "HEMTrendsGraphsPresenter.h"
#import "HEMTrendsCalendarViewCell.h"
#import "HEMTrendsBarGraphCell.h"
#import "HEMTrendsBubbleViewCell.h"
#import "HEMSubNavigationView.h"
#import "HEMTrendsService.h"
#import "HEMMainStoryboard.h"

@interface HEMTrendsGraphsPresenter() <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, weak) HEMTrendsService* trendService;
@property (nonatomic, weak) UICollectionView* collectionView;
@property (nonatomic, assign) HEMSubNavigationView* subNav;

@end

@implementation HEMTrendsGraphsPresenter

- (instancetype)initWithTrendsService:(HEMTrendsService*)trendService {
    self = [super init];
    if (self) {
        _trendService = trendService;
    }
    return self;
}

- (void)bindWithCollectionView:(UICollectionView*)collectionView {
    [collectionView setDataSource:self];
    [collectionView setDelegate:self];
    [self setCollectionView:collectionView];
}

- (void)bindWithSubNav:(HEMSubNavigationView*)subNav {
    [self setSubNav:subNav];
}

- (SENTrends*)selectedTrends {
    SENTrendsTimeScale currentTimeScale = [[self subNav] selectedControlTag];
    return [[self trendService] cachedTrendsForTimeScale:currentTimeScale];
}

- (SENTrendsGraph*)selectedTrendsGraphAtIndexPath:(NSIndexPath*)indexPath {
    SENTrends* trends  = [self selectedTrends];
    return [trends graphs][[indexPath row]];
}

- (CGFloat)heightForCalendarViewForGraphData:(SENTrendsGraph*)graph {
    BOOL averages = [[graph annotations] count] > 0;
    switch ([[self subNav] selectedControlTag]) {
        case SENTrendsTimeScaleWeek:
        case SENTrendsTimeScaleMonth:{
            NSInteger rows = [[graph sections] count];
            return [HEMTrendsCalendarViewCell heightForMonthWithNumberOfRows:rows
                                                                showAverages:averages];
        }
        case SENTrendsTimeScaleQuarter:
            return [HEMTrendsCalendarViewCell heightForMultiMonthWithAverages:averages];
        default:
            return 0.0f;
    }
}

- (CGFloat)heightForBarGraphWithData:(SENTrendsGraph*)graph {
    return [HEMTrendsBarGraphCell heightWithAverages:[[graph annotations] count] > 0];
}

#pragma mark - Configuring Cells

- (void)configureCalendarCell:(HEMTrendsCalendarViewCell*)calendarCell forTrendsGraph:(SENTrendsGraph*)graph {
    HEMTrendsCalendarType cellType = HEMTrendsCalendarTypeMonth;
    if ([graph timeScale] == SENTrendsTimeScaleQuarter) {
        cellType = HEMTrendsCalendarTypeQuarter;
    }
    [calendarCell setAverages:[[graph annotations] count] > 0];
    [calendarCell setRows:[[graph sections] count]];
    [calendarCell setType:cellType];
    [[calendarCell titleLabel] setText:[graph title]];
}

- (void)configureBarCell:(HEMTrendsBarGraphCell*)barCell forTrendsGraph:(SENTrendsGraph*)graph {
    [[barCell titleLabel] setText:[graph title]];
}

- (void)configureBubblesCell:(HEMTrendsBubbleViewCell*)bubbleCell forTrendsGraph:(SENTrendsGraph*)graph {
    [[bubbleCell titleLabel] setText:[graph title]];
}

#pragma mark - UICollectionView Data Source

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [[[self selectedTrends] graphs] count];
}

- (CGSize)collectionView:(UICollectionView*)collectionView
                  layout:(UICollectionViewFlowLayout *)layout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CGSize itemSize = [layout itemSize];
    
    SENTrendsGraph* graph  = [self selectedTrendsGraphAtIndexPath:indexPath];
    switch ([graph displayType]) {
        case SENTrendsDisplayTypeOverview:
        case SENTrendsDisplayTypeGrid:
            itemSize.height = [self heightForCalendarViewForGraphData:graph];
            break;
        case SENTrendsDisplayTypeBubble: {
            itemSize.height = [HEMTrendsBubbleViewCell height];
            break;
        }
        case SENTrendsDisplayTypeBar:
            itemSize.height = [self heightForBarGraphWithData:graph];
            break;
        default:
            break;
    }

    return itemSize;
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView
                 cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionViewCell* cell = nil;
    NSString* reuseId = nil;
    SENTrendsGraph* graph  = [self selectedTrendsGraphAtIndexPath:indexPath];
    switch ([graph displayType]) {
        case SENTrendsDisplayTypeBubble: {
            reuseId = [HEMMainStoryboard bubblesReuseIdentifier];
            HEMTrendsBubbleViewCell* bubbleCell =
                [collectionView dequeueReusableCellWithReuseIdentifier:reuseId
                                                          forIndexPath:indexPath];
            [self configureBubblesCell:bubbleCell forTrendsGraph:graph];
            cell = bubbleCell;
            break;
        }
        case SENTrendsDisplayTypeBar: {
            reuseId = [HEMMainStoryboard barReuseIdentifier];
            HEMTrendsBarGraphCell* barCell =
                [collectionView dequeueReusableCellWithReuseIdentifier:reuseId
                                                          forIndexPath:indexPath];
            [self configureBarCell:barCell forTrendsGraph:graph];
            cell = barCell;
            break;
        }
        case SENTrendsDisplayTypeOverview:
        case SENTrendsDisplayTypeGrid:
        default: {
            reuseId = [HEMMainStoryboard calendarReuseIdentifier];
            HEMTrendsCalendarViewCell* calendarCell =
                [collectionView dequeueReusableCellWithReuseIdentifier:reuseId
                                                          forIndexPath:indexPath];
            [self configureCalendarCell:calendarCell forTrendsGraph:graph];
            cell = calendarCell;
            break;
        }
    }
    
    return cell;
}

#pragma mark - UICollectionView Delegate

@end
