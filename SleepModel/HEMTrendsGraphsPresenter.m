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
#import "HEMMultiTitleView.h"
#import "HEMTrendsBubbleViewCell.h"
#import "HEMSubNavigationView.h"
#import "HEMTrendsSleepDepthView.h"
#import "HEMTrendsService.h"
#import "HEMMainStoryboard.h"
#import "HEMStyle.h"

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

- (CGFloat)heightForCalendarViewForGraphData:(SENTrendsGraph*)graph itemWidth:(CGFloat)itemWidth {
    BOOL averages = [[graph annotations] count] == HEMTrendsGraphAverageRequirement;
    
    HEMTrendsCalendarType type = HEMTrendsCalendarTypeMonth;
    if ([graph timeScale] == SENTrendsTimeScaleQuarter) {
        type = HEMTrendsCalendarTypeQuarter;
    }
    
    return [HEMTrendsCalendarViewCell heightWithNumberOfSections:[[graph sections] count]
                                                         forType:type
                                                    withAverages:averages
                                                           width:itemWidth];
}

- (CGFloat)heightForBarGraphWithData:(SENTrendsGraph*)graph {
    return [HEMTrendsBarGraphCell heightWithAverages:[[graph annotations] count] > 0];
}

- (CGFloat)heightForBubbleGraphWithData:(SENTrendsGraph*)graph {
    return [HEMTrendsBubbleViewCell height];
}

- (NSAttributedString*)attributedSubtitleTextFromString:(NSString*)string
                                            highlighted:(BOOL)highlighted {
    NSMutableParagraphStyle* paraStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    [paraStyle setAlignment:NSTextAlignmentCenter];
    
    UIColor* textColor = highlighted ? [UIColor blackColor] : [UIColor trendsSubtitleColor];
    NSDictionary* attributes = @{NSFontAttributeName : [UIFont trendSubtitleLabelFont],
                                 NSForegroundColorAttributeName : textColor,
                                 NSKernAttributeName : @1,
                                 NSParagraphStyleAttributeName : paraStyle};
    
    return [[NSAttributedString alloc] initWithString:string attributes:attributes];
}

- (NSArray<NSAttributedString*>*)graphTitlesFrom:(SENTrendsGraph*)graph {
    NSMutableArray* titles = [NSMutableArray arrayWithCapacity:[[graph sections] count]];
    for (SENTrendsGraphSection* section in [graph sections]) {
        for (NSString* title in [section titles]) {
            BOOL highlighted = [[section highlightedTitles] containsObject:title];
            [titles addObject:[self attributedSubtitleTextFromString:title highlighted:highlighted]];
        }
    }
    return titles;
}

- (NSAttributedString*)attributedTitleFromAnnotation:(SENTrendsAnnotation*)annotation {
    NSDictionary* attributes = @{NSForegroundColorAttributeName : [UIColor trendsAverageTitleColor],
                                 NSFontAttributeName : [UIFont trendAverageTitleFont]};
    NSString* title = [annotation title];
    if (!title) {
        title = NSLocalizedString(@"empty-data", nil);
    }
    return [[NSAttributedString alloc] initWithString:title
                                           attributes:attributes];
}

- (NSAttributedString*)attributedScoreFromAnnotation:(SENTrendsAnnotation*)annotation
                                             inGraph:(SENTrendsGraph*)graph{
    SENCondition condition = [[self trendService] conditionForValue:[annotation value] inGraph:graph];
    NSDictionary* attributes = @{NSFontAttributeName : [UIFont trendAverageValueFont],
                                 NSForegroundColorAttributeName : [UIColor colorForCondition:condition]};
    NSInteger averageValue = [[annotation value] integerValue];
    NSString* valueText = nil;
    if (averageValue >= 0) {
        valueText = [NSString stringWithFormat:@"%ld", (long)averageValue];
    } else {
        valueText = NSLocalizedString(@"empty-data", nil);
    }
    return [[NSAttributedString alloc] initWithString:valueText attributes:attributes];
}

- (NSAttributedString*)attributedSleepDurationFromAnnotation:(SENTrendsAnnotation*)annotation {
    NSDictionary* attributes = @{NSFontAttributeName : [UIFont trendAverageValueFont],
                                 NSForegroundColorAttributeName : [UIColor sleepStateSoundColor]};
    CGFloat averageValue = [[annotation value] CGFloatValue];
    NSString* avgFormat = NSLocalizedString(@"trends.sleep-duration.average.format", nil);
    NSString* valueText = [NSString stringWithFormat:avgFormat, averageValue];
    NSMutableAttributedString* attrValue = [[NSMutableAttributedString alloc] initWithString:valueText
                                                                                  attributes:attributes];
    NSRange unitRange = NSMakeRange([valueText length] - 1, 1);
    [attrValue addAttribute:NSFontAttributeName value:[UIFont trendAverageValueHourFont] range:unitRange];
    return attrValue;
}

- (void)averagesFromGraph:(SENTrendsGraph*)graph
                   titles:(NSArray<NSAttributedString*>**)titles
                   values:(NSArray<NSAttributedString*>**)values {
    
    NSMutableArray<NSAttributedString*>* averageTitles = nil;
    NSMutableArray<NSAttributedString*>* averageValues = nil;
    NSInteger annotationCount = [[graph annotations] count];
    if (annotationCount > 0) {
        averageTitles = [NSMutableArray arrayWithCapacity:annotationCount];
        averageValues = [NSMutableArray arrayWithCapacity:annotationCount];
        for (SENTrendsAnnotation* annotation in [graph annotations]) {
            [averageTitles addObject:[self attributedTitleFromAnnotation:annotation]];
            switch ([graph displayType]) {
                case SENTrendsDisplayTypeGrid:
                case SENTrendsDisplayTypeOverview:
                    [averageValues addObject:[self attributedScoreFromAnnotation:annotation inGraph:graph]];
                    break;
                case SENTrendsDisplayTypeBar:
                    [averageValues addObject:[self attributedSleepDurationFromAnnotation:annotation]];
                    break;
                default:
                    break;
            }
            
        }
    }
    *titles = averageTitles;
    *values = averageValues;
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

- (void)setAveragesIn:(HEMTrendsBaseCell*)cell fromGraph:(SENTrendsGraph*)graph {
    NSArray<NSAttributedString*>* averageTitles = nil;
    NSArray<NSAttributedString*>* averageValues = nil;
    [self averagesFromGraph:graph titles:&averageTitles values:&averageValues];
    [cell setAverageTitles:averageTitles values:averageValues];
}

- (void)configureCalendarCell:(HEMTrendsCalendarViewCell*)calendarCell forTrendsGraph:(SENTrendsGraph*)graph {
    [self setAveragesIn:calendarCell fromGraph:graph];
    
    HEMTrendsCalendarType type = HEMTrendsCalendarTypeMonth;
    if ([graph timeScale] == SENTrendsTimeScaleQuarter) {
        type = HEMTrendsCalendarTypeQuarter;
    }
    [calendarCell setType:type];
    [[calendarCell titleLabel] setText:[graph title]];
    
    // type must be set first!
    [calendarCell setSectionTitles:[self graphTitlesFrom:graph]
                            scores:[[self trendService] segmentedDataPointsFrom:graph]];
}

- (void)configureBarCell:(HEMTrendsBarGraphCell*)barCell forTrendsGraph:(SENTrendsGraph*)graph {
    [self setAveragesIn:barCell fromGraph:graph];
    
    NSArray<NSAttributedString*>* attributedTitles = [self graphTitlesFrom:graph];
    NSString* highlightFormat = NSLocalizedString(@"trends.sleep-duration.highlight.format", nil);
    [[barCell titleLabel] setText:[graph title]];
    [barCell setHighlightLabelColor:[UIColor sleepStateSoundColor]];
    [barCell setHighlightedBarColor:[UIColor trendsHighlightedSleepDurationColor]];
    [barCell setNormalBarColor:[UIColor trendsSleepDurationBarColor]];
    [barCell setMaxValue:[[graph maxValue] CGFloatValue]];
    [barCell setMinValue:[[graph minValue] CGFloatValue]];
    [barCell setDashLineColor:[UIColor trendsSectionDashLineColor]];
    [barCell setHighlightLabelTextFormat:highlightFormat];
    [barCell setHighlightTextFont:[UIFont trendsHighlightLabelFont]];
    [barCell updateGraphWithTitles:attributedTitles
                     displayPoints:[[self trendService] segmentedDataPointsFrom:graph]
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
            itemSize.height = [self heightForCalendarViewForGraphData:graph itemWidth:itemSize.width];
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
