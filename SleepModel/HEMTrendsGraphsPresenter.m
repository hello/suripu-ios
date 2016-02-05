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
#import "HEMXAxisView.h"
#import "HEMTrendsBubbleViewCell.h"
#import "HEMSubNavigationView.h"
#import "HEMTrendsSleepDepthView.h"
#import "HEMTrendsService.h"
#import "HEMMainStoryboard.h"
#import "HEMStyle.h"
#import "HEMTrendsDisplayPoint.h"

static CGFloat const HEMTrendsGraphBarWeekBarSpacing = 5.0f;
static CGFloat const HEMTrendsGraphBarMonthBarSpacing = 2.0f;
static CGFloat const HEMTrendsGraphBarQuarterBarSpacing = 0.0f;
static NSInteger const HEMTrendsGraphAverageRequirement = 3;

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
    BOOL averages = [[graph annotations] count] == HEMTrendsGraphAverageRequirement;
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

- (CGFloat)heightForBubbleGraphWithData:(SENTrendsGraph*)graph {
    return [HEMTrendsBubbleViewCell height];
}

- (NSAttributedString*)attributedXAxisTextFromString:(NSString*)string
                                           alignment:(NSTextAlignment)alignment {
    NSMutableParagraphStyle* paraStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    [paraStyle setAlignment:alignment];
    
    NSDictionary* attributes = @{NSFontAttributeName : [UIFont trendXAxisLabelFont],
                                 NSForegroundColorAttributeName : [UIColor trendXAxisLabelColor],
                                 NSKernAttributeName : @1,
                                 NSParagraphStyleAttributeName : paraStyle};
    
    return [[NSAttributedString alloc] initWithString:string attributes:attributes];
}

- (NSArray<NSAttributedString*>*)barGraphTitlesFrom:(SENTrendsGraph*)graph {
    NSMutableArray* titles = [NSMutableArray arrayWithCapacity:[[graph sections] count]];
    for (SENTrendsGraphSection* section in [graph sections]) {
        for (NSString* title in [section titles]) {
            [titles addObject:[self attributedXAxisTextFromString:title
                                                        alignment:NSTextAlignmentCenter]];
        }
    }
    return titles;
}

- (NSArray<NSArray<HEMTrendsDisplayPoint*>*>*)segmentedDataPointsFrom:(SENTrendsGraph*)graph {
    NSInteger sections = [[graph sections] count];
    NSMutableArray* displayPoints = [NSMutableArray arrayWithCapacity:sections];
    NSMutableArray* sectionOfPoints = nil;
    // FIXME: find a better way or possibly move this on the a bg thread
    for (SENTrendsGraphSection* section in [graph sections]) {
        sectionOfPoints = [NSMutableArray arrayWithCapacity:[[section values] count]];
        NSInteger index = 0;
        for (NSNumber* dataPoint in [section values]) {
            BOOL highlighted = [[section highlightedValues] containsObject:@(index)];
            [sectionOfPoints addObject:[[HEMTrendsDisplayPoint alloc] initWithValue:dataPoint
                                                                        highlighted:highlighted]];
            index++;
        }
        [displayPoints addObject:sectionOfPoints];
    }
    return displayPoints;
}

- (CGFloat)barSpacingForTimeScale:(SENTrendsTimeScale)timeScale {
    switch (timeScale) {
        case SENTrendsTimeScaleWeek:
            return HEMTrendsGraphBarWeekBarSpacing;
        case SENTrendsTimeScaleMonth:
            return HEMTrendsGraphBarMonthBarSpacing;
        case SENTrendsTimeScaleQuarter:
        case SENTrendsTimeScaleUnknown:
        default:
            return HEMTrendsGraphBarQuarterBarSpacing;
    }
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
    NSMutableArray<NSString*>* averageTitles = nil;
    NSMutableArray<NSString*>* averageValues = nil;
    NSInteger annotationCount = [[graph annotations] count];
    if (annotationCount > 0) {
        averageTitles = [NSMutableArray arrayWithCapacity:annotationCount];
        averageValues = [NSMutableArray arrayWithCapacity:annotationCount];
        NSString* avgFormat = NSLocalizedString(@"trends.sleep-duration.average.format", nil);
        for (SENTrendsAnnotation* annotation in [graph annotations]) {
            if ([annotation title]) {
                [averageTitles addObject:[annotation title]];
            }
            CGFloat averageValue = [[annotation value] CGFloatValue];
            [averageValues addObject:[NSString stringWithFormat:avgFormat, averageValue]];
        }
    }
    
    NSArray<NSAttributedString*>* attributedTitles = [self barGraphTitlesFrom:graph];
    NSString* highlightFormat = NSLocalizedString(@"trends.sleep-duration.highlight.format", nil);
    [[barCell titleLabel] setText:[graph title]];
    [barCell setHighlightedBarColor:[UIColor sleepStateSoundColor]];
    [barCell setNormalBarColor:[UIColor sleepStateLightColor]];
    [barCell setMaxValue:[[graph maxValue] CGFloatValue]];
    [barCell setMinValue:[[graph minValue] CGFloatValue]];
    [barCell setAverageTitleColor:[UIColor trendXAxisLabelColor]];
    [barCell setAverageValueColor:[UIColor sleepStateSoundColor]];
    [barCell setAverageTitles:averageTitles values:averageValues];
    [barCell setHighlightLabelTextFormat:highlightFormat];
    [barCell setHighlightTextFont:[UIFont trendsHighlightLabelFont]];
    [barCell updateGraphWithTitles:attributedTitles
                     displayPoints:[self segmentedDataPointsFrom:graph]
                           spacing:[self barSpacingForTimeScale:[graph timeScale]]];
}

- (void)configureBubblesCell:(HEMTrendsBubbleViewCell*)bubbleCell forTrendsGraph:(SENTrendsGraph*)graph {
    CGFloat light, medium, deep = 0.0f;
    [[self trendService] sleepDepthLightPercentage:&light mediumPercentage:&medium deepPercentage:&deep forGraph:graph];
    
    [[bubbleCell titleLabel] setText:[graph title]];
    
    HEMTrendsSleepDepthView* contentView = [bubbleCell mainContentView];
    [contentView setLightPercentage:light localizedTitle:NSLocalizedString(@"trends.sleep-depth.light", nil)];
    [contentView setMediumPercentage:medium localizedTitle:NSLocalizedString(@"trends.sleep-depth.medium", nil)];
    [contentView setDeepPercentage:deep localizedTitle:NSLocalizedString(@"trends.sleep-depth.deep", nil)];
    [contentView render];
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
            itemSize.height = [self heightForBubbleGraphWithData:graph];
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
    
    NSString* reuseId = nil;
    SENTrendsGraph* graph  = [self selectedTrendsGraphAtIndexPath:indexPath];
    
    switch ([graph displayType]) {
        case SENTrendsDisplayTypeBubble:
            reuseId = [HEMMainStoryboard bubblesReuseIdentifier];
            break;
        case SENTrendsDisplayTypeBar:
            reuseId = [HEMMainStoryboard barReuseIdentifier];
            break;
        case SENTrendsDisplayTypeOverview:
        case SENTrendsDisplayTypeGrid:
        default:
            reuseId = [HEMMainStoryboard calendarReuseIdentifier];
            break;
    }
    
    return [collectionView dequeueReusableCellWithReuseIdentifier:reuseId
                                                     forIndexPath:indexPath];
}

#pragma mark - UICollectionView Delegate

- (void)collectionView:(UICollectionView *)collectionView
       willDisplayCell:(UICollectionViewCell *)cell
    forItemAtIndexPath:(NSIndexPath *)indexPath {
    
    SENTrendsGraph* graph  = [self selectedTrendsGraphAtIndexPath:indexPath];
    if ([cell isKindOfClass:[HEMTrendsCalendarViewCell class]]) {
        [self configureCalendarCell:(id)cell forTrendsGraph:graph];
    } else if ([cell isKindOfClass:[HEMTrendsBarGraphCell class]]) {
        [self configureBarCell:(id)cell forTrendsGraph:graph];
    } else if ([cell isKindOfClass:[HEMTrendsBubbleViewCell class]]) {
        [self configureBubblesCell:(id)cell forTrendsGraph:graph];
    }
    
}

@end
