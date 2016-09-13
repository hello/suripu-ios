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

#import "HEMSensorValueCollectionViewCell.h"
#import "HEMSensorAboutCollectionViewCell.h"
#import "HEMSensorChartCollectionViewCell.h"

static CGFloat const kHEMSensorDetailCellHeightChart = 265.0f;
static CGFloat const kHEMSensorDetailChartAnimeDuration = 1.0f;

typedef NS_ENUM(NSUInteger, HEMSensorDetailContent) {
    HEMSensorDetailContentValue = 0,
    HEMSensorDetailContentChart,
    HEMSensorDetailContentScale,
    HEMSensorDetailContentAbout
};

@interface HEMSensorDetailPresenter() <
    UICollectionViewDelegate,
    UICollectionViewDataSource,
    UICollectionViewDelegateFlowLayout
>

@property (nonatomic, weak) HEMSensorService* sensorService;
@property (nonatomic, weak) UICollectionView* collectionView;
@property (nonatomic, strong) NSArray* content;
@property (nonatomic, weak) SENSensor* sensor;
@property (nonatomic, strong) NSString* aboutDetail;
@property (nonatomic, strong) HEMSensorValueFormatter* formatter;
@property (nonatomic, strong) SENSensorStatus* status;
@property (nonatomic, strong) SENSensorDataCollection* sensorData;
@property (nonatomic, strong) NSError* pollError;
@property (nonatomic, strong) NSArray<ChartDataEntry*>* chartData;
@property (nonatomic, assign) HEMSensorServiceScope scopeSelected;

@end

@implementation HEMSensorDetailPresenter

- (instancetype)initWithSensorService:(HEMSensorService*)sensorService
                            forSensor:(SENSensor*)sensor {
    if (self = [super init]) {
        _sensorService = sensorService;
        _sensor = sensor;
        _formatter = [[HEMSensorValueFormatter alloc] initWithSensorUnit:[sensor unit]];
        if ([sensor unit] == SENSensorUnitCelsius || [sensor unit] == SENSensorUnitFahrenheit) {
            [_formatter setIncludeUnitSymbol:YES];
        }
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
                    completion:^(SENSensorStatus* status, SENSensorDataCollection* data, NSError* error) {
                        __strong typeof(weakSelf) strongSelf = weakSelf;
                        [strongSelf setPollError:error];
                        if (!error) {
                            [strongSelf setStatus:status];
                            
                            SENSensorDataCollection* sensorData = data;
                            if (sensorData && ![[strongSelf sensorData] isEqual:sensorData]) {
                                [strongSelf setSensorData:data];
                                [strongSelf prepareChartDataAndReload];
                            }
                            
                        } else {
                            [[strongSelf collectionView] reloadData];
                        }
                    }];
}

- (void)prepareChartDataAndReload {
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        NSArray<NSNumber*>* values = [[strongSelf sensorData] dataPointsForSensorType:[[strongSelf sensor] type]];
        NSArray<SENSensorTime*>* timestamps = [[strongSelf sensorData] timestamps];
        
        if ([values count] == [timestamps count]) {
            NSMutableArray* chartData = [NSMutableArray arrayWithCapacity:[values count]];
            NSUInteger index = 0;
            for (NSNumber* value in values) {
                [chartData addObject:[[ChartDataEntry alloc] initWithValue:absCGFloat([value doubleValue]) xIndex:index++]];
            }
            [strongSelf setChartData:chartData];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[strongSelf collectionView] reloadData];
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
    [[self collectionView] reloadData];
    [self startPolling];
}

#pragma mark - UICollectionViewDelegate / DataSource

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewFlowLayout* flowLayout = (id)collectionViewLayout;
    CGFloat width = CGRectGetWidth([[collectionView superview] bounds]);
    CGFloat cellSpacing = [flowLayout minimumInteritemSpacing];
    CGFloat topSpacing = [flowLayout sectionInset].top;
    CGFloat height = 0.0f;
    
    NSNumber* contentType = [self content][[indexPath row]];
    switch ([contentType unsignedIntegerValue]) {
        default:
        case HEMSensorDetailContentValue:
            height = CGRectGetHeight([collectionView bounds])
                        - cellSpacing
                        - topSpacing
                        - kHEMSensorDetailCellHeightChart;
            break;
        case HEMSensorDetailContentChart:
            height = kHEMSensorDetailCellHeightChart;
            break;
        case HEMSensorDetailContentAbout: {
            NSString* about = [self aboutDetail];
            NSString* title = NSLocalizedString(@"sensor.section.about.title", nil);
            height = [HEMSensorAboutCollectionViewCell heightWithTitle:title about:about maxWidth:width];
            break;
        }
    }

    return CGSizeMake(width, height);
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
    } else if ([cell isKindOfClass:[HEMSensorAboutCollectionViewCell class]]) {
        [self configureAboutCell:(id) cell];
    }
}

#pragma mark - Cell appearance

- (ChartViewBase*)chartViewForSensor:(SENSensor*)sensor
                              inCell:(HEMSensorChartCollectionViewCell*)cell {
    SENCondition condition = [sensor condition];
    UIColor* sensorColor = [UIColor colorForCondition:condition];
    
    LineChartView* lineChartView = (id) [[cell chartContentView] chartView];
    if (!lineChartView) {
        lineChartView = [[LineChartView alloc] initForSensorWithFrame:[[cell chartContentView] bounds]];
        [lineChartView setViewPortOffsetsWithLeft:0.0f top:0.0f right:0.0f bottom:-20.0f];
        [lineChartView setHighlighter:nil];
        
    }
    
    LineChartDataSet* dataSet = [[LineChartDataSet alloc] initWithYVals:[self chartData]];
    [dataSet setFill:[ChartFill fillWithColor:sensorColor]];
    [dataSet setColor:sensorColor];
    [dataSet setDrawFilledEnabled:YES];
    [dataSet setDrawCirclesEnabled:NO];
    [dataSet setFillColor:sensorColor];
    [dataSet setLabel:nil];
    
    NSArray<SENSensorTime*>* xVals = [[self sensorData] timestamps];
    [lineChartView setData:[[LineChartData alloc] initWithXVals:xVals dataSet:dataSet]];
    [lineChartView setGridBackgroundColor:sensorColor];
    [lineChartView setNeedsDisplay];
    
    return lineChartView;
}

- (void)configureValueCell:(HEMSensorValueCollectionViewCell*)valueCell {
    UIColor* conditionColor = [UIColor colorForCondition:[[self sensor] condition]];
    NSString* valueString = [[self formatter] stringFromSensor:[self sensor]];
    [[valueCell valueLabel] setTextColor:conditionColor];
    [[valueCell valueLabel] setText:valueString];
    [[valueCell valueLabel] setFont:[UIFont h1]];
    [[valueCell messageLabel] setText:[[self sensor] localizedMessage]];
    [[valueCell messageLabel] setTextColor:[UIColor grey5]];
    [[valueCell messageLabel] setFont:[UIFont body]];
}

- (void)configureChartCell:(HEMSensorChartCollectionViewCell*)chartCell {
    ChartViewBase* chartView = [self chartViewForSensor:[self sensor] inCell:chartCell];
    [[chartCell chartContentView] setChartView:chartView];
    [[[chartCell chartContentView] topLimitLabel] setText:nil];
    [[[chartCell chartContentView] botLimitLabel] setText:nil];
    [chartView animateWithXAxisDuration:kHEMSensorDetailChartAnimeDuration];
}

- (void)configureAboutCell:(HEMSensorAboutCollectionViewCell*)aboutCell {
    NSString* title = NSLocalizedString(@"sensor.section.about.title", nil);
    [[aboutCell titleLabel] setText:[title uppercaseString]];
    [[aboutCell titleLabel] setFont:[UIFont h6]];
    [[aboutCell titleLabel] setTextColor:[UIColor grey6]];
    [[aboutCell aboutLabel] setText:[self aboutDetail]];
    [[aboutCell aboutLabel] setFont:[UIFont body]];
    [[aboutCell aboutLabel] setTextColor:[UIColor grey5]];
}

@end
