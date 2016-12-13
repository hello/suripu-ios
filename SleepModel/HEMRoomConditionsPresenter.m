//
//  HEMRoomConditionsPresenter.m
//  Sense
//
//  Created by Jimmy Lu on 8/30/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import <Charts/Charts-Swift.h>
#import "LineChartView+HEMSensor.h"

#import <SenseKit/SENSensor.h>
#import <SenseKit/SENSensorStatus.h>

#import "NSAttributedString+HEMUtils.h"
#import "NSString+HEMUtils.h"

#import "HEMRoomConditionsPresenter.h"
#import "HEMSensorService.h"
#import "HEMIntroService.h"
#import "HEMDescriptionHeaderView.h"
#import "HEMActivityIndicatorView.h"
#import "HEMSenseRequiredCollectionViewCell.h"
#import "HEMSensorCollectionViewCell.h"
#import "HEMTextCollectionViewCell.h"
#import "HEMCardFlowLayout.h"
#import "HEMActionButton.h"
#import "HEMMainStoryboard.h"
#import "HEMSensorValueFormatter.h"
#import "HEMStyle.h"
#import "HEMSensorChartContainer.h"
#import "HEMSensorGroupCollectionViewCell.h"
#import "HEMSensorGroupMemberView.h"

static NSString* const kHEMRoomConditionsIntroReuseId = @"intro";
static CGFloat const kHEMRoomConditionsIntroDescriptionMargin = 32.0f;
static CGFloat const kHEMRoomConditionsPairViewHeight = 352.0f;

@interface HEMRoomConditionsPresenter() <
    UICollectionViewDelegate,
    UICollectionViewDataSource,
    UICollectionViewDelegateFlowLayout,
    ChartViewDelegate
>

@property (nonatomic, weak) HEMSensorService* sensorService;
@property (nonatomic, weak) HEMIntroService* introService;
@property (nonatomic, weak) UICollectionView* collectionView;
@property (nonatomic, assign) CGFloat headerViewHeight;
@property (nonatomic, strong) NSAttributedString* attributedIntroTitle;
@property (nonatomic, strong) NSAttributedString* attributedIntroDesc;
@property (nonatomic, weak) HEMActivityIndicatorView* activityIndicator;
@property (nonatomic, strong) NSError* sensorError;
@property (nonatomic, strong) NSMutableDictionary* chartDataBySensor;
@property (nonatomic, strong) NSMutableDictionary* chartMaxBySensor;
@property (nonatomic, strong) SENSensorStatus* sensorStatus;
@property (nonatomic, strong) NSArray* groupedSensors;
@property (nonatomic, strong) SENSensorDataCollection* sensorData;
@property (nonatomic, strong) HEMSensorValueFormatter* formatter;
@property (nonatomic, assign, getter=isIntroShowing) BOOL introShowing;

@end

@implementation HEMRoomConditionsPresenter

- (instancetype)initWithSensorService:(HEMSensorService*)sensorService
                         introService:(HEMIntroService*)introService {
    self = [super init];
    if (self) {
        _sensorService = sensorService;
        _introService = introService;
        _headerViewHeight = -1.0f;
        _chartDataBySensor = [NSMutableDictionary dictionaryWithCapacity:8];
        _chartMaxBySensor = [NSMutableDictionary dictionaryWithCapacity:8];
        _formatter = [HEMSensorValueFormatter new];
    }
    return self;
}

- (void)bindWithCollectionView:(UICollectionView*)collectionView {
    [collectionView setBackgroundColor:[UIColor backgroundColor]];
    [collectionView setDataSource:self];
    [collectionView setDelegate:self];
    [self setCollectionView:collectionView];
}

- (void)bindWithActivityIndicator:(HEMActivityIndicatorView*)activityIndicator {
    [activityIndicator setHidden:YES];
    [activityIndicator stop];
    [self setActivityIndicator:activityIndicator];
}

#pragma mark - Data Notifications

- (void)listenForSensorStatusChanges {
    NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
    [center addObserver:self
               selector:@selector(sensorStatusChangedOffscreen:)
                   name:kHEMSensorNotifyStatusChanged
                 object:nil];
}

- (void)stopListeningForSensorStatusChanges {
    NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self name:kHEMSensorNotifyStatusChanged object:nil];
}

- (void)sensorStatusChangedOffscreen:(NSNotification*)note {
    SENSensorStatus* status = [note userInfo][kHEMSensorNotifyStatusKey];
    if (status) {
        [self setSensorStatus:status];
        [self setGroupedSensors:[self groupedSensorsFrom:[status sensors]]];
        [self reloadUI];
    }
}

#pragma mark - Presenter Events

- (void)didAppear {
    [super didAppear];
    [self startPolling];
    
    if ([self isIntroShowing]) {
        [[self introService] incrementIntroViewsForType:HEMIntroTypeRoomConditions];
        if (![[self introService] shouldIntroduceType:HEMIntroTypeRoomConditions]) {
            [self reloadUI];
        }
    }

    // let the polling update the UI
    [self stopListeningForSensorStatusChanges];
    
    [SENAnalytics track:kHEMAnalyticsEventCurrentConditions];
}

- (void)didDisappear {
    [super didDisappear];
    [[self sensorService] stopPollingForData];
    // if offscreen and data is updated, make it update
    [self listenForSensorStatusChanges];
}

- (void)userDidSignOut {
    [super userDidSignOut];
    [[self sensorService] stopPollingForData];
}

- (void)didComeBackFromBackground {
    [super didComeBackFromBackground];
    [self startPolling];
}

- (void)didEnterBackground {
    [super didEnterBackground];
    [[self sensorService] stopPollingForData];
}

- (void)didGainConnectivity {
    [super didGainConnectivity];
    [self startPolling];
}

#pragma mark - Data

- (void)reloadUI {
    [[self activityIndicator] setHidden:YES];
    [[self activityIndicator] stop];
    [[self collectionView] reloadData];
}

- (void)startPolling {
    if (![self sensorStatus]) {
        [self setSensorError:nil];
        [[self collectionView] reloadData];
        [[self activityIndicator] setHidden:NO];
        [[self activityIndicator] start];
    }
    
    __weak typeof(self) weakSelf = self;
    HEMSensorService* service = [self sensorService];
    [service pollDataForSensorsExcept:nil
                           completion:^(HEMSensorServiceScope scope,
                                        SENSensorStatus* status,
                                        id data,
                                        NSError* error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf setSensorError:error];
        [strongSelf setSensorStatus:status];
                               
        if (!error) {
            SENSensorDataCollection* sensorData = data;
            if (sensorData && ![[strongSelf sensorData] isEqual:sensorData]) {
                [strongSelf setGroupedSensors:[strongSelf groupedSensorsFrom:[status sensors]]];
                [strongSelf setSensorData:data];
                [strongSelf prepareChartDataAndReload];
            } else {
                [strongSelf reloadUI];
            }
            
        } else {
            [strongSelf reloadUI];
        }
        
    }];
}

- (NSArray*)groupedSensorsFrom:(NSArray<SENSensor*>*)allSensors {
    if ([allSensors count] == 0) {
        return nil;
    }
    
    NSMutableArray* groupedSensors = [NSMutableArray arrayWithCapacity:[allSensors count]];
    NSMutableArray* airGroup = nil;
    NSInteger airGroupInitialIndex = -1;
    NSUInteger sensorIndex = 0;
    SENSensor* initialAirSensor = nil;
    
    for (SENSensor* sensor in allSensors) {
        if ([sensor type] == SENSensorTypeDust
            || [sensor type] == SENSensorTypeCO2
            || [sensor type] == SENSensorTypeVOC) {
            if (!airGroup) {
                initialAirSensor = sensor;
                airGroup = [NSMutableArray arrayWithCapacity:3];
                airGroupInitialIndex = sensorIndex;
            }
            [airGroup addObject:sensor];
        } else {
            [groupedSensors addObject:sensor];
        }
        sensorIndex++;
    }
    
    if (airGroupInitialIndex >= 0 && initialAirSensor) {
        if ([airGroup count] < 2) {
            [groupedSensors insertObject:initialAirSensor atIndex:airGroupInitialIndex];
        } else {
            [groupedSensors insertObject:airGroup atIndex:airGroupInitialIndex];
        }
    }
    
    return groupedSensors;
}

#pragma mark - Charts

- (void)prepareChartDataAndReload {
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        NSArray<SENSensor*>* sensors = [[strongSelf sensorStatus] sensors];
        for (SENSensor* sensor in sensors) {
            NSArray<NSNumber*>* values = [[strongSelf sensorData] dataPointsForSensorType:[sensor type]];
            NSArray<SENSensorTime*>* timestamps = [[strongSelf sensorData] timestamps];
            if ([values count] == [timestamps count]) {
                NSMutableArray* chartData = [NSMutableArray arrayWithCapacity:[values count]];
                CGFloat chartMax = 0.0f;
                NSUInteger index = 0;
                for (NSNumber* value in values) {
                    CGFloat entryValue = MAX(0.0f, [value doubleValue]);
                    [chartData addObject:[[ChartDataEntry alloc] initWithX:index++ y:entryValue]];
                    if ([value doubleValue] > chartMax) {
                        chartMax = [value doubleValue];
                    }
                }
                [strongSelf chartDataBySensor][@([sensor type])] = chartData;
                [strongSelf chartMaxBySensor][@([sensor type])] = @(chartMax);
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [strongSelf reloadUI];
        });
    });
}

- (LineChartView*)chartViewForSensor:(SENSensor*)sensor
                              inCell:(HEMSensorCollectionViewCell*)cell
                             animate:(BOOL*)animate {
    LineChartView* lineChartView = (id) [[cell graphContainerView] chartView];
    
    if (!lineChartView) {
        lineChartView = [[LineChartView alloc] initForSensorWithFrame:[[cell graphContainerView] bounds]];
        [lineChartView setViewPortOffsetsWithLeft:0.0f top:6.0f right:0.0f bottom:0.0f];
        *animate = YES;
    } else {
        *animate = NO;
    }
    
    SENCondition condition = [sensor condition];
    UIColor* sensorColor = [UIColor colorForCondition:condition];
    [lineChartView setGridBackgroundColor:sensorColor];
    
    NSArray *gradientColors = [lineChartView gradientColorsWithColor:sensorColor];
    CGGradientRef gradient = CGGradientCreateWithColors(nil, (CFArrayRef)gradientColors, nil);
    
    NSArray* chartData = [self chartDataBySensor][@([sensor type])];
    LineChartDataSet* dataSet = [[LineChartDataSet alloc] initWithValues:[chartData copy]];
    [dataSet setFill:[ChartFill fillWithLinearGradient:gradient angle:90.0f]];
    [dataSet setColor:[lineChartView lineColorForColor:sensorColor]];
    [dataSet setDrawFilledEnabled:YES];
    [dataSet setDrawValuesEnabled:NO];
    [dataSet setDrawCirclesEnabled:NO];
    [dataSet setLabel:nil];
    
    CGGradientRelease(gradient);
    
    [lineChartView setData:[[LineChartData alloc] initWithDataSet:dataSet]];
    [lineChartView setNeedsDisplay];
    
    return lineChartView;
}

#pragma mark - Text

- (NSAttributedString*)attributedIntroTitle {
    if (!_attributedIntroTitle) {
        NSMutableParagraphStyle* style = DefaultBodyParagraphStyle();
        [style setAlignment:NSTextAlignmentCenter];
        
        NSDictionary* attrs = @{NSFontAttributeName : [UIFont h5],
                                NSForegroundColorAttributeName : [UIColor grey6],
                                NSParagraphStyleAttributeName : style};
        
        NSString* title = NSLocalizedString(@"room-conditions.intro.title", nil);
        
        _attributedIntroTitle = [[NSAttributedString alloc] initWithString:title attributes:attrs];
    }
    return _attributedIntroTitle;
}

- (NSAttributedString*)attributedIntroDesc {
    if (!_attributedIntroDesc) {
        NSMutableParagraphStyle* style = DefaultBodyParagraphStyle();
        [style setAlignment:NSTextAlignmentCenter];
        
        NSDictionary* attrs = @{NSFontAttributeName : [UIFont body],
                                NSForegroundColorAttributeName : [UIColor grey5],
                                NSParagraphStyleAttributeName : style};
        
        NSString* desc = NSLocalizedString(@"room-conditions.intro.desc", nil);
        
        _attributedIntroDesc = [[NSAttributedString alloc] initWithString:desc attributes:attrs];
    }
    return _attributedIntroDesc;
}

#pragma mark - UICollectionView

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
  
    HEMCardFlowLayout* cardLayout = (id)collectionViewLayout;
    CGSize itemSize = [cardLayout itemSize];
    
    switch ([[self sensorStatus] state]) {
        case SENSensorStateWaiting:
        case SENSensorStateOk: {
            id sensorObj = [self groupedSensors][[indexPath row]];
            if ([sensorObj isKindOfClass:[NSArray class]]) {
                CGFloat cellWidth = itemSize.width;
                UIFont* textFont = [UIFont body];
                NSString* worstConditionString = nil;
                SENCondition worstCondition = SENConditionIncomplete;
                for (SENSensor* sensor in sensorObj) {
                    if (!worstConditionString || [sensor condition] < worstCondition) {
                        worstConditionString = [sensor localizedMessage];
                        worstCondition = [sensor condition];
                    }
                }
                itemSize.height = [HEMSensorGroupCollectionViewCell heightWithNumberOfMembers:[sensorObj count]
                                                                                conditionText:worstConditionString
                                                                                conditionFont:textFont
                                                                                    cellWidth:cellWidth];
            } else {
                SENSensor* sensor = sensorObj;
                itemSize.height = [HEMSensorCollectionViewCell heightWithDescription:[sensor localizedMessage]
                                                                           cellWidth:itemSize.width];
            }
            return itemSize;
        }
        case SENSensorStateNoSense:
            itemSize.height = kHEMRoomConditionsPairViewHeight;
            return itemSize;
        default: {
            if ([self sensorError]) {
                NSString* text = NSLocalizedString(@"sensor.data-unavailable", nil);
                UIFont* font = [UIFont body];
                CGFloat maxWidth = itemSize.width - (HEMStyleCardErrorTextHorzMargin * 2);
                CGFloat textHeight = [text heightBoundedByWidth:maxWidth usingFont:font];
                itemSize.height = textHeight + (HEMStyleCardErrorTextVertMargin * 2);
            }
            return itemSize;
        }
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    switch ([[self sensorStatus] state]) {
        case SENSensorStateWaiting:
        case SENSensorStateOk:
            return [[self groupedSensors] count];
        case SENSensorStateNoSense:
            return 1;
        default: {
            return [self sensorError] ? 1 : 0;
        }
    }
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView
                 cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString* reuseId = nil;
    
    switch ([[self sensorStatus] state]) {
        case SENSensorStateWaiting:
        case SENSensorStateOk: {
            id sensorObj = [self groupedSensors][[indexPath row]];
            if ([sensorObj isKindOfClass:[NSArray class]]) {
                reuseId = [HEMMainStoryboard groupReuseIdentifier];
            } else {
                reuseId = [HEMMainStoryboard sensorReuseIdentifier];
            }
            break;
        }
        case SENSensorStateNoSense:
            reuseId = [HEMMainStoryboard pairReuseIdentifier];
            break;
        default:
            reuseId = [self sensorError] ? [HEMMainStoryboard errorReuseIdentifier] : nil;
            break;
    }
    
    UICollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseId
                                                                           forIndexPath:indexPath];
    if ([cell isKindOfClass:[HEMSensorCollectionViewCell class]]) {
        SENSensor* sensor = [self groupedSensors][[indexPath row]];
        [self configureSensorCell:(id)cell forSensor:sensor];
    } else if ([cell isKindOfClass:[HEMSenseRequiredCollectionViewCell class]]) {
        [self configurePairSenseCell:(id)cell];
    } else if ([cell isKindOfClass:[HEMTextCollectionViewCell class]]) { // error
        [self configureErrorCell:(id)cell];
    } else if ([cell isKindOfClass:[HEMSensorGroupCollectionViewCell class]]) {
        NSArray<SENSensor*>* sensors = [self groupedSensors][[indexPath row]];
        [self configureGroupSensorCell:(id)cell forSensors:sensors];
    }
    
    return cell;
}

//- (void)collectionView:(UICollectionView *)collectionView
//       willDisplayCell:(UICollectionViewCell *)cell
//    forItemAtIndexPath:(NSIndexPath *)indexPath {
//    
//    if ([cell isKindOfClass:[HEMSensorCollectionViewCell class]]) {
//        SENSensor* sensor = [self groupedSensors][[indexPath row]];
//        [self configureSensorCell:(id)cell forSensor:sensor];
//    } else if ([cell isKindOfClass:[HEMSenseRequiredCollectionViewCell class]]) {
//        [self configurePairSenseCell:(id)cell];
//    } else if ([cell isKindOfClass:[HEMTextCollectionViewCell class]]) { // error
//        [self configureErrorCell:(id)cell];
//    } else if ([cell isKindOfClass:[HEMSensorGroupCollectionViewCell class]]) {
//        NSArray<SENSensor*>* sensors = [self groupedSensors][[indexPath row]];
//        [self configureGroupSensorCell:(id)cell forSensors:sensors];
//    }
//}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
referenceSizeForHeaderInSection:(NSInteger)section {
    CGSize headerSize = CGSizeZero;
    if ([self sensorStatus]
        && [[self sensorStatus] state] != SENSensorStateNoSense
        && ![self sensorError]
        && [[self introService] shouldIntroduceType:HEMIntroTypeRoomConditions]) {
        if ([self headerViewHeight] < 0.0f) {
            HEMCardFlowLayout* flowLayout = (id) collectionViewLayout;
            NSAttributedString* title = [self attributedIntroTitle];
            NSAttributedString* message = [self attributedIntroDesc];
            CGFloat itemWidth = [flowLayout itemSize].width;
            [self setHeaderViewHeight:[HEMDescriptionHeaderView heightWithTitle:title
                                                                     description:message
                                                                widthConstraint:itemWidth]];
            // must additionally increment here b/c reloadData will initially not
            // increment the count
            [[self introService] incrementIntroViewsForType:HEMIntroTypeRoomConditions];
        }
        headerSize.height = [self headerViewHeight];
        [self setIntroShowing:YES];
    } else {
        [self setIntroShowing:NO];
    }
    return headerSize;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath {
    NSString* reuseId = kHEMRoomConditionsIntroReuseId;
    return [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                              withReuseIdentifier:reuseId
                                                     forIndexPath:indexPath];
}

- (void)collectionView:(UICollectionView *)collectionView
willDisplaySupplementaryView:(UICollectionReusableView *)view
        forElementKind:(NSString *)elementKind
           atIndexPath:(NSIndexPath *)indexPath {
    if ([view isKindOfClass:[HEMDescriptionHeaderView class]]) {
        HEMDescriptionHeaderView* header = (id) view;
        [[header titlLabel] setAttributedText:[self attributedIntroTitle]];
        [[header imageView] setImage:[UIImage imageNamed:@"introRoomConditions"]];
        
        UILabel* descriptionLabel = [header descriptionLabel];
        CGFloat containerWidth = CGRectGetWidth([collectionView bounds]);
        CGFloat labelWidth = containerWidth - (2 * kHEMRoomConditionsIntroDescriptionMargin);
        [descriptionLabel setAttributedText:[self attributedIntroDesc]];
        [descriptionLabel setPreferredMaxLayoutWidth:labelWidth];
        [descriptionLabel sizeToFit];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self didScrollContentIn:scrollView];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell* cell = [collectionView cellForItemAtIndexPath:indexPath];
    if ([cell isKindOfClass:[HEMSensorCollectionViewCell class]]) {
        id sensorObj = [self groupedSensors][[indexPath row]];
        if ([sensorObj isKindOfClass:[SENSensor class]]) {
            [[self delegate] showSensor:sensorObj fromPresenter:self];
        }
    }
}

#pragma mark - Cell configurations

- (void)configureGroupSensorCell:(HEMSensorGroupCollectionViewCell*)groupCell
                      forSensors:(NSArray<SENSensor*>*)sensors {
    NSString* groupTitle = NSLocalizedString(@"room-conditions.air-quality", nil);
    [[groupCell groupNameLabel] setText:[groupTitle uppercaseString]];
    
    SENCondition worstCondition = SENConditionIncomplete;
    NSString* worstConditionString = nil;
    NSInteger groupCount = [sensors count];
    NSInteger index = 0;
    for (SENSensor* sensor in sensors) {
        if (!worstConditionString || [sensor condition] < worstCondition) {
            worstConditionString = [sensor localizedMessage];
            worstCondition = [sensor condition];
        }
        
        [[self formatter] setSensorUnit:[sensor unit]];
        [[self formatter] setIncludeUnitSymbol:YES];
        UIColor* conditionColor = [UIColor colorForCondition:[sensor condition]];
        NSString* valueText = nil;
        if ([sensor condition] != SENConditionCalibrating) {
            valueText = [[self formatter] stringFromSensor:sensor];
        } else {
            valueText = NSLocalizedString(@"room-conditions.status.calibrating", nil);
        }
        NSString* name = [sensor localizedName];
        HEMSensorGroupMemberView* memberView = [groupCell addSensorWithName:name
                                                                      value:valueText
                                                                 valueColor:conditionColor];
        [[memberView separatorView] setHidden:index++ == groupCount - 1];
        [memberView setType:[sensor type]];
        [[memberView tap] addTarget:self action:@selector(didTapOnGroupMember:)];
    }
    [[groupCell groupMessageLabel] setText:worstConditionString];
    [[groupCell groupMessageLabel] setFont:[UIFont body]];
}

- (void)configureSensorCell:(HEMSensorCollectionViewCell*)sensorCell forSensor:(SENSensor*)sensor {
    [[self formatter] setSensorUnit:[sensor unit]];
    
    SENCondition condition = [sensor condition];
    UIColor* conditionColor = [UIColor colorForCondition:condition];
    
    if ([sensor type] == SENSensorTypeTemp) {
        [[self formatter] setIncludeUnitSymbol:YES];
        [[sensorCell unitLabel] setText:nil];
        
        NSString* formattedValue = [[self formatter] stringFromSensorValue:[sensor value]];
        [[sensorCell valueLabel] setText:formattedValue];
        [[sensorCell valueLabel] setTextColor:conditionColor];
        
    } else if ([sensor type] == SENSensorTypeHumidity) {
        [[self formatter] setIncludeUnitSymbol:YES];
        
        NSDictionary* valueAttributes = @{NSFontAttributeName : [UIFont h4],
                                          NSForegroundColorAttributeName : conditionColor};
        NSDictionary* unitAttributes = @{NSFontAttributeName : [UIFont h8],
                                         NSForegroundColorAttributeName : conditionColor,
                                         NSBaselineOffsetAttributeName : @(5.0f)};
        
        NSAttributedString* attributedString =
            [[self formatter] attributedValueFromSensor:sensor
                                     unitSymbolLocation:HEMSensorValueUnitLocSuperscript
                                        valueAttributes:valueAttributes
                                         unitAttributes:unitAttributes];

        [[sensorCell valueLabel] setAttributedText:attributedString];
        [[sensorCell unitLabel] setText:nil];
        
    } else {
        [[self formatter] setIncludeUnitSymbol:NO];
        [[sensorCell unitLabel] setText:[[self formatter] unitSymbol]];
        
        NSString* formattedValue = [[self formatter] stringFromSensorValue:[sensor value]];
        [[sensorCell valueLabel] setText:formattedValue];
        [[sensorCell valueLabel] setTextColor:conditionColor];
    }
    
    BOOL animate = NO;
    LineChartView* chartView = [self chartViewForSensor:sensor
                                                 inCell:sensorCell
                                                animate:&animate];
    
    [[sensorCell descriptionLabel] setText:[sensor localizedMessage]];
    [[sensorCell nameLabel] setText:[[sensor localizedName] uppercaseString]];
    
    NSNumber* chartMax = nil;
    NSNumber* calculatedChartMax = [self chartMaxBySensor][@([sensor type])];
    CGFloat minValue = [chartView chartYMin];
    CGFloat maxValue = [chartView chartYMax];
    // a hack until we can properly line up the chart to the limit lines.  This
    // case identifies when values in the chart are all 0s.
    if (!(minValue == -1.0f && maxValue == 1.0f)) {
        minValue = 0.0f;
        chartMax = calculatedChartMax;
    } else {
        chartMax = @(maxValue);
    }
    
    [[self formatter] setIncludeUnitSymbol:YES];
    
    HEMSensorChartContainer* chartContainer = [sensorCell graphContainerView];
    [chartContainer setChartView:chartView];
    [chartContainer setUserInteractionEnabled:NO];
    [chartContainer setScrubberEnable:NO];
    [[chartContainer topLimitLabel] setText:[[self formatter] stringFromSensorValue:chartMax]];
    [[chartContainer botLimitLabel] setText:[[self formatter] stringFromSensorValue:@(minValue)]];
    
    if (animate) {
        [chartView animateIn];
    }
}

- (void)configureErrorCell:(HEMTextCollectionViewCell*)errorCell {
    [[errorCell textLabel] setText:NSLocalizedString(@"sensor.data-unavailable", nil)];
    [[errorCell textLabel] setFont:[UIFont body]];
    [errorCell displayAsACard:YES];
}

- (void)configurePairSenseCell:(HEMSenseRequiredCollectionViewCell*)pairSenseCell {
    NSString* buttonTitle = NSLocalizedString(@"room-conditions.pair-sense.button.title", nil);
    NSString* message = NSLocalizedString(@"room-conditions.pair-sense.message", nil);
    [[pairSenseCell descriptionLabel] setText:message];
    [[pairSenseCell pairSenseButton] addTarget:self
                                        action:@selector(pairSense)
                              forControlEvents:UIControlEventTouchUpInside];
    [[pairSenseCell pairSenseButton] setTitle:[buttonTitle uppercaseString]
                                     forState:UIControlStateNormal];
}

#pragma mark - Actions

- (void)didTapOnGroupMember:(UITapGestureRecognizer*)tap {
    switch ([tap state]) {
        case UIGestureRecognizerStateEnded: {
            if ([[tap view] isKindOfClass:[HEMSensorGroupMemberView class]]) {
                HEMSensorGroupMemberView* member = (id) [tap view];
                for (SENSensor* sensor in [[self sensorStatus] sensors]) {
                    if ([sensor type] == [member type]) {
                        [[self delegate] showSensor:sensor fromPresenter:self];
                        break;
                    }
                }
            }
            break;
        }
        default:
            break;
    }
}

- (void)pairSense {
    [[self pairDelegate] pairSenseFrom:self];
}

#pragma mark - Clean up

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if (_collectionView) {
        [_collectionView setDelegate:nil];
        [_collectionView setDataSource:nil];
    }
}

@end
