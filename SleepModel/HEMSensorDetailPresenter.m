//
//  HEMSensorDetailPresenter.m
//  Sense
//
//  Created by Jimmy Lu on 9/12/16.
//  Copyright © 2016 Hello. All rights reserved.
//
#import <Charts/Charts-Swift.h>
#import "LineChartView+HEMSensor.h"

#import <SenseKit/SENSensor.h>
#import <SenseKit/SENPreference.h>
#import <SenseKit/SENSensorStatus.h>

#import "HEMSensorDetailPresenter.h"
#import "HEMSensorService.h"
#import "HEMMainStoryboard.h"
#import "HEMStyle.h"
#import "HEMSensorValueFormatter.h"
#import "HEMSensorChartContainer.h"
#import "HEMSensorXAxisValueFormatter.h"
#import "HEMSubNavigationView.h"

#import "HEMSensorValueCollectionViewCell.h"
#import "HEMSensorAboutCollectionViewCell.h"
#import "HEMSensorChartCollectionViewCell.h"
#import "HEMSensorScaleCollectionViewCell.h"

static CGFloat const kHEMSensorDetailCellChartHeightRatio = 0.45f;
static CGFloat const kHEMSensorDetailChartXLabelCount = 7;
static NSUInteger const kHEMSensorDetailXAxisOffset = 10;

typedef NS_ENUM(NSUInteger, HEMSensorDetailContent) {
    HEMSensorDetailContentValue = 0,
    HEMSensorDetailContentChart,
    HEMSensorDetailContentScale,
    HEMSensorDetailContentAbout
};

@interface HEMSensorDetailPresenter() <
    UICollectionViewDelegate,
    UICollectionViewDataSource,
    UICollectionViewDelegateFlowLayout,
    HEMSensorChartScrubberDelegate
>

@property (nonatomic, weak) HEMSensorService* sensorService;
@property (nonatomic, weak) UICollectionView* collectionView;
@property (nonatomic, strong) NSArray* content;
@property (nonatomic, strong) SENSensor* sensor;
@property (nonatomic, strong) NSString* aboutDetail;
@property (nonatomic, strong) HEMSensorValueFormatter* formatter;
@property (nonatomic, strong) SENSensorStatus* status;
@property (nonatomic, strong) SENSensorDataCollection* sensorData;
@property (nonatomic, strong) NSError* pollError;
@property (nonatomic, strong) NSArray<ChartDataEntry*>* chartData;
@property (nonatomic, strong) NSArray<NSString*>* xLabelData;
@property (nonatomic, assign) HEMSensorServiceScope scopeSelected;
@property (nonatomic, strong) NSDateFormatter* xAxisLabelFormatter;
@property (nonatomic, assign) BOOL chartLoaded;
@property (nonatomic, assign, getter=isScrubbing) BOOL scrubbing;
@property (nonatomic, weak) LineChartView* chartView;
@property (nonatomic, strong) NSDateFormatter* exactTimeFormatter;
@property (nonatomic, weak) UILabel* currentValueLabel;
@property (nonatomic, weak) HEMSensorValueCollectionViewCell* valueCell;

@end

@implementation HEMSensorDetailPresenter

- (instancetype)initWithSensorService:(HEMSensorService*)sensorService
                            forSensor:(SENSensor*)sensor {
    if (self = [super init]) {
        _sensorService = sensorService;
        _sensor = sensor;
        _xAxisLabelFormatter = [NSDateFormatter new];
        _exactTimeFormatter = [NSDateFormatter new];
        _formatter = [[HEMSensorValueFormatter alloc] initWithSensorUnit:[sensor unit]];
        [_formatter setIncludeUnitSymbol:YES];
        
        [self updateFormatters];
        [self determineContent];
    }
    return self;
}

- (void)bindWithCollectionView:(UICollectionView*)collectionView {
    [collectionView setBackgroundColor:[UIColor whiteColor]];
    [collectionView setDelegate:self];
    [collectionView setDataSource:self];
    [self setCollectionView:collectionView];
}

- (void)bindWithSubNavigationView:(HEMSubNavigationView*)subNav {
    [self bindWithShadowView:[subNav shadowView]];
}

- (void)determineContent {
    NSString* sensorType = [[[self sensor] typeStringValue] lowercaseString];
    if ([[self sensor] type] == SENSensorTypeTemp) {
        if ([SENPreference useCentigrade]) {
            sensorType = [sensorType stringByAppendingString:@".celsius"];
        } else {
            sensorType = [sensorType stringByAppendingString:@".fahrenheit"];
        }
    }
    NSString* aboutKey = [NSString stringWithFormat:@"sensor.section.about.%@", sensorType];
    NSString* about = NSLocalizedString(aboutKey, nil);
    
    NSMutableArray* content = [NSMutableArray arrayWithCapacity:HEMSensorDetailContentAbout + 1];
    [content addObject:@(HEMSensorDetailContentValue)];
    [content addObject:@(HEMSensorDetailContentChart)];
    
    // check if sensor has scales to show
    if ([[[self sensor] scales] count] > 0) {
        [content addObject:@(HEMSensorDetailContentScale)];
    }
    
    // if string for content exists
    if (![about isEqualToString:aboutKey]) {
        [self setAboutDetail:about];
        [content addObject:@(HEMSensorDetailContentAbout)];
    }
    
    [self setContent:content];
}

#pragma mark - Poll data

- (void)startPolling {
    __weak typeof(self) weakSelf = self;
    HEMSensorService* service = [self sensorService];
    [service pollDataForSensor:[self sensor]
                     withScope:[self scopeSelected]
                    completion:^(HEMSensorServiceScope scope,
                                 SENSensorStatus* status,
                                 SENSensorDataCollection* data,
                                 NSError* error) {
                        
                        __strong typeof(weakSelf) strongSelf = weakSelf;
                        if ([strongSelf scopeSelected] != scope) {
                            return; // ignore
                        }
                        
                        [strongSelf setPollError:error];
                        if (!error) {
                            BOOL needsUIUpdate = ![strongSelf status]
                                || ![status isEqual:[strongSelf status]];
                            [strongSelf setStatus:status];
                            [strongSelf updateSensorFromStatus];
                            
                            SENSensorDataCollection* sensorData = data;
                            if (sensorData && ![[strongSelf sensorData] isEqual:sensorData]) {
                                [strongSelf setSensorData:data];
                                needsUIUpdate = needsUIUpdate || YES;
                            }
                            
                            if (needsUIUpdate) {
                                [strongSelf prepareChartDataAndReload];
                            }
                            
                        } else {
                            [strongSelf reloadUI];
                        }
                    }];
}

- (void)updateSensorFromStatus {
    for (SENSensor* sensor in [[self status] sensors]) {
        if ([sensor type] == [[self sensor] type]) {
            [self setSensor:sensor];
            break;
        }
    }
}

- (void)reloadUI {
    if (![self isScrubbing]) {
        [[self collectionView] reloadData];
    }
}

- (void)prepareChartDataAndReload {
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        NSArray<NSNumber*>* values = [[strongSelf sensorData] dataPointsForSensorType:[[strongSelf sensor] type]];
        NSArray<SENSensorTime*>* timestamps = [[strongSelf sensorData] timestamps];
        NSUInteger valueCount = [values count];
        
        if (valueCount == [timestamps count]) {
            NSMutableArray* chartData = [NSMutableArray arrayWithCapacity:valueCount];
            NSMutableArray* labelData = [NSMutableArray arrayWithCapacity:kHEMSensorDetailChartXLabelCount];
            NSInteger indicesBetweenLabels = (valueCount - 1) / kHEMSensorDetailChartXLabelCount;
            NSUInteger index = 0;
            SENSensorTime* time = nil;
            for (NSNumber* value in values) {
                [chartData addObject:[[ChartDataEntry alloc] initWithValue:absCGFloat([value doubleValue]) xIndex:index]];
                if (index == ([labelData count] + 1) * indicesBetweenLabels) {
                    NSInteger indexWithOffset = index - kHEMSensorDetailXAxisOffset;
                    time = [[strongSelf sensorData] timestamps][indexWithOffset];
                    [labelData addObject:[[strongSelf xAxisLabelFormatter]
                                          stringFromDate:[time date]]];
                }
                index++;
            }
            [strongSelf setChartData:chartData];
            [strongSelf setXLabelData:labelData];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [strongSelf reloadUI];
        });
    });
}

- (void)setPollScope:(HEMSensorServiceScope)scope {
    [[self sensorService] stopPollingForData];
    [self setScopeSelected:scope];
    [self setSensorData:nil];
    [self setStatus:nil];
    [self setPollError:nil];
    [self setChartData:nil];
    [self updateFormatters];
    [self reloadUI];
    [self startPolling];
}

- (void)updateFormatters {
    if ([self scopeSelected] == HEMSensorServiceScopeWeek) {
        [[self xAxisLabelFormatter] setDateFormat:@"EEE"];
        if ([SENPreference timeFormat] == SENTimeFormat24Hour) {
            [[self exactTimeFormatter] setDateFormat:@"EEEE - HH:mm"];
        } else {
            [[self exactTimeFormatter] setDateFormat:@"EEEE - hh:mm a"];
        }
    } else {
        if ([SENPreference timeFormat] == SENTimeFormat24Hour) {
            [[self xAxisLabelFormatter] setDateFormat:@"HH:mm"];
            [[self exactTimeFormatter] setDateFormat:@"HH:mm"];
        } else {
            [[self xAxisLabelFormatter] setDateFormat:@"ha"];
            [[self exactTimeFormatter] setDateFormat:@"hh:mm a"];
        }
    }
}

#pragma mark - UICollectionViewDelegate / DataSource

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewFlowLayout* flowLayout = (id)collectionViewLayout;
    CGFloat widthBounds = CGRectGetWidth([[collectionView superview] bounds]);
    CGFloat heightBounds = CGRectGetHeight([[collectionView superview] bounds]);
    CGFloat cellSpacing = [flowLayout minimumInteritemSpacing];
    CGFloat topSpacing = [flowLayout sectionInset].top;
    CGFloat chartHeight = heightBounds * kHEMSensorDetailCellChartHeightRatio;
    CGFloat height = 0.0f;
    
    NSNumber* contentType = [self content][[indexPath row]];
    switch ([contentType unsignedIntegerValue]) {
        default:
        case HEMSensorDetailContentValue:
            height = CGRectGetHeight([collectionView bounds])
                        - cellSpacing
                        - topSpacing
                        - chartHeight;
            break;
        case HEMSensorDetailContentChart:
            height = chartHeight;
            break;
        case HEMSensorDetailContentScale: {
            NSUInteger count = [[[self sensor] scales] count];
            height = [HEMSensorScaleCollectionViewCell heightWithNumberOfScales:count];
            break;
        }
        case HEMSensorDetailContentAbout: {
            NSString* about = [self aboutDetail];
            NSString* title = NSLocalizedString(@"sensor.section.about.title", nil);
            height = [HEMSensorAboutCollectionViewCell heightWithTitle:title about:about maxWidth:widthBounds];
            break;
        }
    }

    return CGSizeMake(widthBounds, height);
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [[self content] count];
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString* reuseId = nil;
    NSNumber* contentType = [self content][[indexPath row]];
    switch ([contentType unsignedIntegerValue]) {
        case HEMSensorDetailContentValue:
            reuseId = [HEMMainStoryboard currentValueReuseIdentifier];
            break;
        case HEMSensorDetailContentChart:
            reuseId = [HEMMainStoryboard chartReuseIdentifier];
            break;
        case HEMSensorDetailContentScale:
            reuseId = [HEMMainStoryboard scaleReuseIdentifier];
            break;
        case HEMSensorDetailContentAbout:
            reuseId = [HEMMainStoryboard aboutReuseIdentifier];
            break;
        default:
            break;
    }
    return [collectionView dequeueReusableCellWithReuseIdentifier:reuseId forIndexPath:indexPath];
}

- (void)collectionView:(UICollectionView *)collectionView
       willDisplayCell:(UICollectionViewCell *)cell
    forItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell isKindOfClass:[HEMSensorValueCollectionViewCell class]]) {
        [self configureValueCell:(id) cell];
    } else if ([cell isKindOfClass:[HEMSensorChartCollectionViewCell class]]) {
        [self configureChartCell:(id) cell];
    } else if ([cell isKindOfClass:[HEMSensorScaleCollectionViewCell class]]) {
        [self configureScaleCell:(id) cell];
    } else if ([cell isKindOfClass:[HEMSensorAboutCollectionViewCell class]]) {
        [self configureAboutCell:(id) cell];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self didScrollContentIn:scrollView];
}

#pragma mark - Cell appearance

- (LineChartView*)chartViewForSensor:(SENSensor*)sensor
                              inCell:(HEMSensorChartCollectionViewCell*)cell {
    SENCondition condition = [sensor condition];
    UIColor* sensorColor = [UIColor colorForCondition:condition];
    
    LineChartView* lineChartView = (id) [[cell chartContentView] chartView];
    if (!lineChartView) {
        lineChartView = [[LineChartView alloc] initForSensorWithFrame:[[cell chartContentView] bounds]];
        [lineChartView setHighlightPerDragEnabled:NO];
    }
    
    NSArray *gradientColors = [lineChartView gradientColorsWithColor:sensorColor];
    CGGradientRef gradient = CGGradientCreateWithColors(nil, (CFArrayRef)gradientColors, nil);
    
    LineChartDataSet* dataSet = [[LineChartDataSet alloc] initWithYVals:[self chartData]];
    [dataSet setFill:[ChartFill fillWithLinearGradient:gradient angle:90.0f]];
    [dataSet setColor:[lineChartView lineColorForColor:sensorColor]];
    [dataSet setDrawFilledEnabled:YES];
    [dataSet setDrawCirclesEnabled:NO];
    [dataSet setHighlightColor:sensorColor];
    [dataSet setDrawHorizontalHighlightIndicatorEnabled:NO];
    [dataSet setLabel:nil];
    
    CGGradientRelease(gradient);
    
    NSArray<SENSensorTime*>* xVals = [[self sensorData] timestamps];
    [lineChartView setData:[[LineChartData alloc] initWithXVals:xVals dataSet:dataSet]];
    [lineChartView setGridBackgroundColor:sensorColor];
    [lineChartView setNeedsDisplay];
    
    return lineChartView;
}

- (void)updateValueCell:(HEMSensorValueCollectionViewCell*)valueCell
              withValue:(NSNumber*)value
              condition:(SENCondition)condition
                message:(NSString*)message {
    UIColor* conditionColor = [UIColor colorForCondition:condition];
    
    if ([[self sensor] type] == SENSensorTypeTemp) {
        NSString* valueString = [[self formatter] stringFromSensorValue:value];
        [[valueCell valueLabel] setTextColor:conditionColor];
        [[valueCell valueLabel] setText:valueString];
        [[valueCell valueLabel] setFont:[UIFont h1]];
    } else {
        NSDictionary* valueAttributes = @{NSFontAttributeName : [UIFont h1],
                                          NSForegroundColorAttributeName : conditionColor};
        NSDictionary* unitAttributes = @{NSFontAttributeName : [UIFont h4],
                                         NSForegroundColorAttributeName : conditionColor,
                                         NSBaselineOffsetAttributeName : @(12.0f)};
        
        NSAttributedString* attrValue = [[self formatter] attributedValue:value
                                                       unitSymbolLocation:HEMSensorValueUnitLocSubscript valueAttributes:valueAttributes unitAttributes:unitAttributes];
        [[valueCell valueLabel] setAttributedText:attrValue];
    }
    
    [[valueCell messageLabel] setText:message];
    [[valueCell messageLabel] setTextColor:[UIColor grey5]];
    [[valueCell messageLabel] setFont:[UIFont body]];
}

- (void)configureValueCell:(HEMSensorValueCollectionViewCell*)valueCell {
    NSNumber* value = [[self sensor] value];
    NSString* message = [[self sensor] localizedMessage];
    SENCondition condition = [[self sensor] condition];
    [self updateValueCell:valueCell withValue:value condition:condition message:message];
    [self setValueCell:valueCell];
}

- (void)configureChartCell:(HEMSensorChartCollectionViewCell*)chartCell {
    LineChartView* chartView = [self chartViewForSensor:[self sensor] inCell:chartCell];
    [[chartCell chartContentView] setChartView:chartView];
    [[[chartCell chartContentView] topLimitLabel] setText:nil];
    [[[chartCell chartContentView] botLimitLabel] setText:nil];
    [chartCell setXAxisLabels:[self xLabelData]];
    
    if (![self chartLoaded] && [[self chartData] count] > 0) {
        [chartView animateIn];
        [self setChartLoaded:YES];
    } else {
        [chartView fadeIn];
    }
    
    CGFloat minValue = MAX(0.0f, [chartView chartYMin]);
    CGFloat maxValue = [chartView chartYMax];
    HEMSensorChartContainer* chartContainer = [chartCell chartContentView];
    [chartContainer setChartView:chartView];
    [[chartContainer topLimitLabel] setText:[[self formatter] stringFromSensorValue:@(maxValue)]];
    [[chartContainer botLimitLabel] setText:[[self formatter] stringFromSensorValue:@(minValue)]];
    [chartContainer setScrubberColor:[UIColor colorForCondition:[[self sensor] condition]]];
    [chartContainer setDelegate:self];
    
    [self setChartView:chartView];
}

- (void)configureScaleCell:(HEMSensorScaleCollectionViewCell*)scaleCell {
    NSUInteger count = [[[self sensor] scales] count];
    NSString* measureFormat = NSLocalizedString(@"sensor.section.scale.measure.format", nil);
    NSString* unitString = [[self formatter] unitSymbol];
    
    if ([[self sensor] type] == SENSensorTypeTemp) {
        if ([SENPreference useCentigrade]) {
            unitString = [NSString stringWithFormat:@"C%@", unitString];
        } else {
            unitString = [NSString stringWithFormat:@"F%@", unitString];
        }
    }

    NSString* measureString = [NSString stringWithFormat:measureFormat, unitString];
    
    [scaleCell setNumberOfScales:count];
    [[scaleCell titleLabel] setText:NSLocalizedString(@"sensor.section.scale.title", nil)];
    [[scaleCell measurementLabel] setText:measureString];
    
    NSString* rangeFormat = nil;
    NSString* rangeString = nil;
    
    for (SENSensorScale* scale in [[self sensor] scales]) {
        if ([scale min] && [scale max]) {
            rangeFormat = NSLocalizedString(@"sensor.section.scale.range.format", nil);
            rangeString = [NSString stringWithFormat:rangeFormat,
                           [[[self formatter] convertValue:[scale min]] doubleValue],
                           [[[self formatter] convertValue:[scale max]] doubleValue]];
        } else if (![scale min] && [scale max]) {
            rangeFormat = NSLocalizedString(@"sensor.section.scale.range.no-min.format", nil);
            rangeString = [NSString stringWithFormat:rangeFormat,
                           [[[self formatter] convertValue:[scale max]] doubleValue]];
        } else if (![scale max] && [scale min]) {
            rangeFormat = NSLocalizedString(@"sensor.section.scale.range.no-max.format", nil);
            rangeString = [NSString stringWithFormat:rangeFormat,
                           [[[self formatter] convertValue:[scale min]] doubleValue]];
        } else {
            rangeString = NSLocalizedString(@"empty-data", nil);
        }

        [scaleCell addScaleWithName:[scale localizedName]
                              range:rangeString
                     conditionColor:[UIColor colorForCondition:[scale condition]]];
    }
}

- (void)configureAboutCell:(HEMSensorAboutCollectionViewCell*)aboutCell {
    NSString* title = NSLocalizedString(@"sensor.section.about.title", nil);
    [[aboutCell titleLabel] setText:title];
    [[aboutCell titleLabel] setFont:[UIFont h6]];
    [[aboutCell titleLabel] setTextColor:[UIColor grey6]];
    [[aboutCell aboutLabel] setText:[self aboutDetail]];
    [[aboutCell aboutLabel] setFont:[UIFont body]];
    [[aboutCell aboutLabel] setTextColor:[UIColor grey5]];
}

#pragma mark - HEMSensorChartScrubberDelegate

- (void)willBeginScrubbingIn:(HEMSensorChartContainer *)chartContainer {
    [[self collectionView] setScrollEnabled:NO];
    [self setScrubbing:YES];
}

- (void)didEndScrubbingIn:(HEMSensorChartContainer *)chartContainer {
    NSString* message = [[self sensor] localizedMessage];
    NSNumber* value = [[self sensor] value];
    SENCondition condition = [[self sensor] condition];
    [self updateValueCell:[self valueCell]
                withValue:value
                condition:condition
                  message:message];
    
    [[self collectionView] setScrollEnabled:YES];
    [self setScrubbing:NO];
}

- (void)didMoveScrubberTo:(CGPoint)pointInChartView within:(HEMSensorChartContainer *)chartContainer {
    ChartDataEntry* entry = [[self chartView] getEntryByTouchPoint:pointInChartView];
    SENSensorTime* time = [[self sensorData] timestamps][[entry xIndex]];
    NSString* timeString = [[self exactTimeFormatter] stringFromDate:[time date]];
    
    DDLogVerbose(@"moved scrubber to value %f, time %@", [entry value], timeString);
    
    [self updateValueCell:[self valueCell]
                withValue:@([entry value])
                condition:[[self sensor] condition]
                  message:timeString];
}

#pragma mark - Clean up

- (void)dealloc {
    if (_sensorService) {
        [_sensorService stopPollingForData];
    }
}

@end
