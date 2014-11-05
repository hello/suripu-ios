
#import <SenseKit/SENSensor.h>
#import <SenseKit/SENAPIRoom.h>
#import <SenseKit/SENSettings.h>
#import <SORelativeDateTransformer/SORelativeDateTransformer.h>
#import <JBChartView/JBLineChartView.h>
#import <markdown_peg.h>

#import "HEMSensorViewController.h"
#import "HEMSensorGraphDataSource.h"
#import "HEMGraphTooltipView.h"
#import "HEMColorUtils.h"
#import "HelloStyleKit.h"
#import "UIFont+HEMStyle.h"

@interface HEMSensorViewController () <JBLineChartViewDelegate>

@property (weak, nonatomic) IBOutlet UIButton* dailyGraphButton;
@property (weak, nonatomic) IBOutlet UIButton* hourlyGraphButton;
@property (weak, nonatomic) IBOutlet UILabel* valueLabel;
@property (weak, nonatomic) IBOutlet JBLineChartView* graphView;
@property (weak, nonatomic) IBOutlet UILabel* comfortZoneInfoLabel;
@property (weak, nonatomic) IBOutlet UILabel* comfortZoneLabel;
@property (weak, nonatomic) IBOutlet UIView *graphContainerView;
@property (weak, nonatomic) IBOutlet UILabel* unitLabel;
@property (weak, nonatomic) IBOutlet UIView* chartContainerView;
@property (nonatomic, strong) HEMGraphTooltipView* tooltipView;

@property (strong, nonatomic) NSArray* hourlyDataSeries;
@property (strong, nonatomic) NSArray* dailyDataSeries;
@property (strong, nonatomic) HEMSensorGraphDataSource* graphDataSource;
@property (nonatomic, getter=isShowingHourlyData) BOOL showHourlyData;
@property (nonatomic, strong) NSDateFormatter* hourlyFormatter;
@property (nonatomic, strong) NSDateFormatter* dailyFormatter;

@end

@implementation HEMSensorViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.hourlyFormatter = [[NSDateFormatter alloc] init];
    self.hourlyFormatter.dateFormat = [SENSettings timeFormat] == SENTimeFormat12Hour ? @"ha" : @"H";
    self.dailyFormatter = [[NSDateFormatter alloc] init];
    self.dailyFormatter.dateFormat = @"EEEEEE";
    self.hourlyGraphButton.titleLabel.font = [UIFont sensorRangeSelectionFont];
    self.dailyGraphButton.titleLabel.font = [UIFont sensorRangeSelectionFont];
    self.view.backgroundColor = [HelloStyleKit currentConditionsBackgroundColor];
    [self configureGraphViewBackground];
    [self initializeGraphDataSource];
    [self configureSensorValueViews];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self fadeInGraphView];
}

- (void)initializeGraphDataSource
{
    self.showHourlyData = YES;
    self.hourlyDataSeries = @[];
    self.dailyDataSeries = @[];
    self.graphDataSource = [[HEMSensorGraphDataSource alloc] initWithDataSeries:@[]];
    CAGradientLayer* mask = [CAGradientLayer layer];
    mask.frame = self.graphView.bounds;
    mask.colors = @[(id)[UIColor whiteColor].CGColor,
                    (id)[UIColor whiteColor].CGColor,
                    (id)[HelloStyleKit backViewBackgroundColor].CGColor,
                    (id)[HelloStyleKit backViewBackgroundColor].CGColor];
    mask.startPoint = CGPointMake(0, 0.5);
    mask.endPoint = CGPointMake(1, 0.5);
    mask.locations = @[ @(-1), @(-1), @0, @1 ];
    self.graphView.layer.mask = mask;
    [self configureGraphView];
    [self refreshGraphData];
}

- (void)configureGraphViewBackground
{
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.view.bounds;
    gradient.colors = @[
                        (id)[[UIColor whiteColor] CGColor],
                        (id)[[UIColor colorWithWhite:1.f alpha:0] CGColor]];
    gradient.locations = @[@0, @(0.4)];
    [self.graphContainerView.layer insertSublayer:gradient atIndex:0];
}

- (void)configureGraphView
{
    self.graphView.delegate = self;
    self.graphView.dataSource = self.graphDataSource;
    NSInteger sectionSize = self.graphDataSource.dataSeries.count / 8;
    NSInteger midPoint = sectionSize / 2;
    NSMutableArray* sections = [[NSMutableArray alloc] initWithCapacity:7];

    for (int i = 0; i < 7 && i < self.graphDataSource.dataSeries.count; i++) {
        NSInteger index = i == 6 ? (sectionSize * (i + 1)) : midPoint + (sectionSize * i);
        NSDictionary* dataPoint = self.graphDataSource.dataSeries[index];
        CGFloat value = [dataPoint[@"value"] floatValue];
        NSString* sectionLabel;
        NSString* sectionValue;
        NSDate* lastUpdated = [NSDate dateWithTimeIntervalSince1970:([dataPoint[@"datetime"] doubleValue]) / 1000];
        if ([self isShowingHourlyData]) {
            sectionLabel = [self.hourlyFormatter stringFromDate:lastUpdated];
        } else {
            sectionLabel = [self.dailyFormatter stringFromDate:lastUpdated];
        }
        if (value == 0) {
            sectionValue = @"-";
        } else if (i == 6) {
            sectionValue = [SENSensor formatValue:@(value) withUnit:self.sensor.unit];
        }
        else {
            sectionValue = [NSString stringWithFormat:@"%ld", [[SENSensor value:@(value) inPreferredUnit:self.sensor.unit] longValue]];
        }
        if (!sectionValue) {
            sectionValue = NSLocalizedString(@"sensor.value.none", nil);
        }
        sections[i] = @{
            @"value" : sectionValue,
            @"label" : sectionLabel
        };
    }
    self.graphView.sections = sections;
    [self.graphView reloadData];
}

- (void)fadeInGraphView
{
    [CATransaction begin];
    [CATransaction setValue:@1 forKey:kCATransactionAnimationDuration];
    ((CAGradientLayer*)self.graphView.layer.mask).locations = @[ @0, @1, @2, @2 ];
    [CATransaction commit];
}

- (void)configureSensorValueViews
{
    self.title = self.sensor.localizedName;
    if (self.sensor.value) {
        NSString* format = nil;
        if (self.sensor.unit == SENSensorUnitMicrogramPerCubicMeter
            && [self.sensor.value floatValue] > 0.0f) {
            format = @"%.02f";
        } else {
            format = @"%.0f";
        }
        self.valueLabel.text = [NSString stringWithFormat:format, [[self.sensor valueInPreferredUnit] floatValue]];
    } else {
        self.valueLabel.text = NSLocalizedString(@"empty-data", nil);
    }

    self.unitLabel.text = [self.sensor localizedUnit];
    NSDictionary* attributes = @{
        @(EMPH) : @{
            NSFontAttributeName : [UIFont settingsInsightMessageFont],
        },
        @(PLAIN) : @{
            NSFontAttributeName : [UIFont settingsInsightMessageFont],
        },
        @(PARA) : @{
            NSForegroundColorAttributeName : [HelloStyleKit backViewTextColor],
        }
    };

    self.comfortZoneInfoLabel.attributedText = markdown_to_attr_string(self.sensor.message, 0, attributes);
}

- (void)refreshGraphData
{
    [SENAPIRoom hourlyHistoricalDataForSensorWithName:self.sensor.name completion:^(id data, NSError* error) {
        if (!data)
            return;
        self.hourlyDataSeries = data;
        if ([self isShowingHourlyData]) {
            self.graphDataSource = [[HEMSensorGraphDataSource alloc] initWithDataSeries:data];
            [self configureGraphView];
        }
    }];
    [SENAPIRoom dailyHistoricalDataForSensorWithName:self.sensor.name completion:^(id data, NSError* error) {
        if (!data)
            return;
        self.dailyDataSeries = data;
        if (![self isShowingHourlyData]) {
            self.graphDataSource = [[HEMSensorGraphDataSource alloc] initWithDataSeries:data];
            [self configureGraphView];
        }
    }];
}

- (IBAction)selectedHourlyGraph:(id)sender
{
    if ([self isShowingHourlyData])
        return;
    [self.dailyGraphButton setTitleColor:[HelloStyleKit backViewTextColor] forState:UIControlStateNormal];
    [self.hourlyGraphButton setTitleColor:[HelloStyleKit senseBlueColor] forState:UIControlStateNormal];

    [self animateActiveDataSeriesTo:self.hourlyDataSeries];
}

- (IBAction)selectedDailyGraph:(id)sender
{
    if (![self isShowingHourlyData])
        return;

    [self.dailyGraphButton setTitleColor:[HelloStyleKit senseBlueColor] forState:UIControlStateNormal];
    [self.hourlyGraphButton setTitleColor:[HelloStyleKit backViewTextColor] forState:UIControlStateNormal];
    [self animateActiveDataSeriesTo:self.dailyDataSeries];
}

- (void)animateActiveDataSeriesTo:(NSArray*)dataSeries
{
    self.showHourlyData = ![self isShowingHourlyData];
    [UIView animateWithDuration:0.25 animations:^{
        self.graphView.alpha = 0;
    } completion:^(BOOL finished) {
        self.graphDataSource = [[HEMSensorGraphDataSource alloc] initWithDataSeries:dataSeries];
        [self configureGraphView];
        [UIView animateWithDuration:0.25 animations:^{
            self.graphView.alpha = 1.f;
        }];
    }];
}

#pragma mark - JBLineChartViewDelegate

- (void)lineChartView:(JBLineChartView*)lineChartView didSelectLineAtIndex:(NSUInteger)lineIndex horizontalIndex:(NSUInteger)horizontalIndex touchPoint:(CGPoint)touchPoint
{
    NSDictionary* dataPoint = self.graphDataSource.dataSeries[horizontalIndex];
    CGFloat value = [dataPoint[@"value"] floatValue];
    NSString* toolTipText = value == 0
                                ? NSLocalizedString(@"graph-data.unavailable.short", nil)
                                : [SENSensor formatValue:@(value) withUnit:self.sensor.unit];
    NSTimeInterval timeInterval = ([dataPoint[@"datetime"] doubleValue] / 1000);
    [self setTooltipVisible:YES animated:YES atTouchPoint:touchPoint];
    [self.tooltipView setTitleText:toolTipText];
    [self.tooltipView setDetailText:[[SORelativeDateTransformer registeredTransformer] transformedValue:[NSDate dateWithTimeIntervalSince1970:timeInterval]]];
}

- (void)didUnselectLineInLineChartView:(JBLineChartView*)lineChartView
{
    [self setTooltipVisible:NO animated:YES];
}

- (void)setTooltipVisible:(BOOL)tooltipVisible animated:(BOOL)animated atTouchPoint:(CGPoint)touchPoint
{

    JBChartView* chartView = [self graphView];

    if (!self.tooltipView) {
        self.tooltipView = [[HEMGraphTooltipView alloc] initWithFrame:CGRectMake(0, 0, 70, 34)];
        self.tooltipView.alpha = 0.0;
        [self.chartContainerView addSubview:self.tooltipView];
    }

    dispatch_block_t adjustTooltipPosition = ^{
        CGPoint convertedTouchPoint = [self.chartContainerView convertPoint:touchPoint fromView:chartView];
        CGFloat minChartX = (chartView.frame.origin.x + ceil(CGRectGetWidth(self.tooltipView.frame) * 0.5));
        if (convertedTouchPoint.x < minChartX)
            convertedTouchPoint.x = minChartX;

        CGFloat maxChartX = (chartView.frame.origin.x + chartView.frame.size.width - ceil(self.tooltipView.frame.size.width * 0.5));
        if (convertedTouchPoint.x > maxChartX)
            convertedTouchPoint.x = maxChartX;

        self.tooltipView.frame = CGRectMake(convertedTouchPoint.x - ceil(CGRectGetWidth(self.tooltipView.frame) * 0.5),
                                            CGRectGetMinY(chartView.frame) + 30,
                                            CGRectGetWidth(self.tooltipView.frame),
                                            CGRectGetHeight(self.tooltipView.frame));
    };

    dispatch_block_t adjustTooltipVisibility = ^{
        self.tooltipView.alpha = tooltipVisible ? 1.0 : 0.0;
    };

    if (tooltipVisible) {
        adjustTooltipPosition();
    }

    if (animated) {
        [UIView animateWithDuration:0.25f animations:^{
            adjustTooltipVisibility();
        } completion:^(BOOL finished) {
            if (!tooltipVisible)
                adjustTooltipPosition();
        }];
    } else {
        adjustTooltipVisibility();
    }
}

- (void)setTooltipVisible:(BOOL)tooltipVisible animated:(BOOL)animated
{
    [self setTooltipVisible:tooltipVisible animated:animated atTouchPoint:CGPointZero];
}

- (void)setTooltipVisible:(BOOL)tooltipVisible
{
    [self setTooltipVisible:tooltipVisible animated:NO];
}

@end
