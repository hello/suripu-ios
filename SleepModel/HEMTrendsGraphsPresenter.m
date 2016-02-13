//
//  HEMTrendsGraphsPresenter.m
//  Sense
//
//  Created by Jimmy Lu on 1/29/16.
//  Copyright © 2016 Hello. All rights reserved.
//
#import <SenseKit/SENTrends.h>
#import <SenseKit/SENTrendsGraph.h>

#import "NSString+HEMUtils.h"
#import "NSMutableAttributedString+HEMFormat.h"

#import "HEMTrendsGraphsPresenter.h"
#import "HEMTrendsCalendarViewCell.h"
#import "HEMTrendsBarGraphCell.h"
#import "HEMMultiTitleView.h"
#import "HEMTrendsBubbleViewCell.h"
#import "HEMSubNavigationView.h"
#import "HEMTrendsSleepDepthView.h"
#import "HEMTextCollectionViewCell.h"
#import "HEMTrendsMessageCell.h"
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
@property (nonatomic, assign, getter=isRefreshing) BOOL refreshing;
@property (nonatomic, assign, getter=hasDataError) BOOL dataError;

@end

@implementation HEMTrendsGraphsPresenter

- (instancetype)initWithTrendsService:(HEMTrendsService*)trendService {
    self = [super init];
    if (self) {
        _trendService = trendService;
        [self listenForTrendsDataEvents];
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

#pragma mark - Notifications

- (void)listenForTrendsDataEvents {
    if ([self trendService]) {
        NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
        [center addObserver:self
                   selector:@selector(trendsDataChange:)
                       name:nil
                     object:[self trendService]];
    }
}

- (void)trendsDataChange:(NSNotification*)note {
    NSString* noteName = [note name];
    [self setDataError:NO];
    
    if ([noteName isEqualToString:HEMTrendsServiceNotificationWillRefresh]) {
        DDLogVerbose(@"trends data is refreshing");
        [self setRefreshing:YES];
    } else if ([noteName isEqualToString:HEMTrendsServiceNotificationDidRefresh]
               || [noteName isEqualToString:HEMTrendsServiceNotificationHitCache]) {
        NSError* error = [note userInfo][HEMTrendsServiceNotificationInfoError];
        [self setRefreshing:NO];
        [self setDataError:error != nil];
    }
    
    [[self collectionView] reloadData];
}

#pragma mark - Data

- (BOOL)showTrendsMessage {
    return [[self trendService] daysUntilMoreTrends:[self selectedTrends]] > 0;
}

- (BOOL)areTrendsBeAvailable {
    return [self selectedTrends]
        && [[self subNav] hasControls];
}

- (SENTrends*)selectedTrends {
    SENTrendsTimeScale currentTimeScale = [[self subNav] selectedControlTag];
    if ([self isRefreshing]) {
        currentTimeScale = [[self subNav] previousControlTag];
    }
    return [[self trendService] cachedTrendsForTimeScale:currentTimeScale];
}

- (SENTrendsGraph*)selectedTrendsGraphAtIndexPath:(NSIndexPath*)indexPath {
    NSInteger index = [indexPath row];
    if ([self showTrendsMessage]) {
        index--; // adjust to accommodate for trends message
    }
    SENTrends* trends = [self selectedTrends];
    return index >=0 && index < [[trends graphs] count] ? [trends graphs][index] : nil;
}

- (void)partialDataTitle:(NSAttributedString**)attributedTitle
                 message:(NSAttributedString**)attributedMessage
                   image:(UIImage**)partialDataImage
               forTrends:(SENTrends*)trends {
    
    NSString* title = nil, *message = nil;
    
    if (!trends) {
        title = NSLocalizedString(@"trends.no-data.title", nil);
        message = NSLocalizedString(@"trends.no-data.message", nil);
        *attributedMessage = [self attributedPartialDataMessageWithText:message];
    } else {
        title = NSLocalizedString(@"trends.not-enough-data.title", nil);
        
        NSInteger daysToMore = [[self trendService] daysUntilMoreTrends:trends];
        NSString* messageFormat = NSLocalizedString(@"trends.not-enough-data.message.format", nil);
        *attributedMessage = [self attributedPartialDataMessageWithFormat:messageFormat
                                                              andDaysLeft:daysToMore];
    }
    
    *attributedTitle = [self attributedPartialDataTitleWithText:title];
    
    if (partialDataImage) {
        *partialDataImage = [UIImage imageNamed:@"partialTrends"];
    }
}

#pragma mark - Height Calculations

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

- (CGFloat)heightForPartialDataCellWithTrends:(SENTrends*)trends itemWidth:(CGFloat)itemWidth {
    NSAttributedString* attributedTitle = nil, *attributedMessage = nil;
    [self partialDataTitle:&attributedTitle message:&attributedMessage image:NULL forTrends:trends];
    return [HEMTrendsMessageCell heightWithTitle:attributedTitle
                                         message:attributedMessage
                                       withWidth:itemWidth];
}

- (CGFloat)heightForErrorMessageWithItemWidth:(CGFloat)itemWidth {
    NSString* message = NSLocalizedString(@"trends.loading.error.message", nil);
    UIFont* font = [UIFont errorStateDescriptionFont];
    CGFloat maxWidth = itemWidth - (HEMStyleCardErrorTextHorzMargin * 2);
    CGFloat textHeight = [message heightBoundedByWidth:maxWidth usingFont:font];
    return textHeight + (HEMStyleCardErrorTextVertMargin * 2);
}

#pragma mark - Attributed Text

- (NSAttributedString*)attributedPartialDataTitleWithText:(NSString*)text {
    if (!text) {
        return nil;
    }
    NSMutableParagraphStyle* style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    [style setLineHeightMultiple:1.25f];
    [style setAlignment:NSTextAlignmentCenter];
    
    NSDictionary* attributes = @{NSFontAttributeName : [UIFont partialDataTitleFont],
                                 NSForegroundColorAttributeName : [UIColor partialDataTitleColor],
                                 NSParagraphStyleAttributeName : style};
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

- (NSDictionary*)attributesForPartialDataMessageWithColor:(UIColor*)color {
    NSMutableParagraphStyle* style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    [style setLineHeightMultiple:1.29f];
    [style setAlignment:NSTextAlignmentCenter];
    
    return @{NSFontAttributeName : [UIFont partialDataMessageFont],
             NSForegroundColorAttributeName : color,
             NSParagraphStyleAttributeName : style};
}

- (NSAttributedString*)attributedPartialDataMessageWithText:(NSString*)message {
    if (!message) {
        return nil;
    }
    UIColor* textColor = [UIColor partialDataMessageColor];
    NSDictionary* attributes = [self attributesForPartialDataMessageWithColor:textColor];
    return [[NSAttributedString alloc] initWithString:message attributes:attributes];
}

- (NSAttributedString*)attributedPartialDataMessageWithFormat:(NSString*)format
                                                  andDaysLeft:(NSInteger)daysLeft {
    if (!format) {
        return nil;
    }
    
    UIColor* boldColor = [UIColor partialDataMessageBoldColor];
    UIColor* regColor = [UIColor partialDataMessageColor];
    NSDictionary* boldAttr = [self attributesForPartialDataMessageWithColor:boldColor];
    NSDictionary* regAttr = [self attributesForPartialDataMessageWithColor:regColor];
    UIFont* regFont = regAttr[NSFontAttributeName];
    NSParagraphStyle* para = regAttr[NSParagraphStyleAttributeName];
    
    NSString* dayNumberText = [NSString stringWithFormat:@"%ld", (long)daysLeft];
    NSAttributedString* boldNumber = [[NSAttributedString alloc] initWithString:dayNumberText
                                                                     attributes:boldAttr];
    
    NSString* daysText = NSLocalizedString(@"trends.days", nil);
    NSAttributedString* boldDays = [[NSAttributedString alloc] initWithString:daysText
                                                                   attributes:boldAttr];
    
    NSArray* args = @[boldNumber, boldDays];
    NSMutableAttributedString* message
        = [[NSMutableAttributedString alloc] initWithFormat:format
                                                       args:args
                                                  baseColor:regColor
                                                   baseFont:regFont];
    [message addAttribute:NSParagraphStyleAttributeName
                    value:para
                    range:NSMakeRange(0, [message length])];
    
    return message;
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

- (void)configureMessageCell:(HEMTrendsMessageCell*)messageCell forTrends:(SENTrends*)trends {
    UIImage* partialDataImage = nil;
    NSAttributedString* attributedTitle = nil, *attributedMessage = nil;
    [self partialDataTitle:&attributedTitle message:&attributedMessage image:&partialDataImage forTrends:trends];
    [[messageCell imageView] setImage:partialDataImage];
    [[messageCell titleLabel] setAttributedText:attributedTitle];
    [[messageCell messageLabel] setAttributedText:attributedMessage];
}

- (void)configureErrorCell:(HEMTextCollectionViewCell*)textCell {
    [[textCell textLabel] setText:NSLocalizedString(@"trends.loading.error.message", nil)];
    [textCell setBackgroundColor:[UIColor whiteColor]];
    [[textCell textLabel] setFont:[UIFont errorStateDescriptionFont]];
    [textCell displayAsACard:YES];
}

#pragma mark - UICollectionView Data Source

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    SENTrends* trends = [self selectedTrends];
    NSInteger items = 0;
    if (![self isRefreshing]) {
        items = [self showTrendsMessage] ? 1 : 0;
        items += [[trends graphs] count];
    }
    return items;
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
        case SENTrendsDisplayTypeUnknown:
        default: // no data or error
            if ([self hasDataError]) {
                itemSize.height = [self heightForErrorMessageWithItemWidth:itemSize.width];
            } else {
                itemSize.height = [self heightForPartialDataCellWithTrends:[self selectedTrends]
                                                                 itemWidth:itemSize.width];
            }
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
            reuseId = [HEMMainStoryboard calendarReuseIdentifier];
            break;
        case SENTrendsDisplayTypeUnknown:
        default: // no data
            if ([self hasDataError]) {
                reuseId = [HEMMainStoryboard errorReuseIdentifier];
            } else {
                reuseId = [HEMMainStoryboard messageReuseIdentifier];
            }
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
    
    if ([cell isKindOfClass:[HEMTrendsBaseCell class]]) {
        HEMTrendsBaseCell* baseCell = (id)cell;
        [baseCell setLoading:[self isRefreshing]];
        
        
        if ([cell isKindOfClass:[HEMTrendsCalendarViewCell class]]) {
            [self configureCalendarCell:(id)cell forTrendsGraph:graph];
        } else if ([cell isKindOfClass:[HEMTrendsBarGraphCell class]]) {
            [self configureBarCell:(id)cell forTrendsGraph:graph];
        } else if ([cell isKindOfClass:[HEMTrendsBubbleViewCell class]]) {
            [self configureBubblesCell:(id)cell forTrendsGraph:graph];
        }
    } else if ([cell isKindOfClass:[HEMTrendsMessageCell class]]) {
        [self configureMessageCell:(id)cell forTrends:[self selectedTrends]];
    } else if ([cell isKindOfClass:[HEMTextCollectionViewCell class]]) { // error
        [self configureErrorCell:(id)cell];
    }
    
}

#pragma mark - Clean up

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if (_collectionView) {
        [_collectionView setDataSource:nil];
        [_collectionView setDelegate:nil];
    }
}

@end
