
#import <SenseKit/SENSensor.h>
#import <SenseKit/SENAPIRoom.h>
#import <SORelativeDateTransformer/SORelativeDateTransformer.h>
#import <JBChartView/JBLineChartView.h>
#import <markdown_peg.h>

#import "HEMSensorViewController.h"
#import "HEMSensorGraphDataSource.h"
#import "HEMGraphTooltipView.h"
#import "HEMColorUtils.h"
#import "HelloStyleKit.h"

CGFloat const kJBBaseChartViewControllerAnimationDuration = 0.25f;

@interface HEMSensorViewController () <JBLineChartViewDelegate>

@property (weak, nonatomic) IBOutlet UIButton* dailyGraphButton;
@property (weak, nonatomic) IBOutlet UIButton* hourlyGraphButton;
@property (weak, nonatomic) IBOutlet UILabel* valueLabel;
@property (weak, nonatomic) IBOutlet JBLineChartView* graphView;
@property (weak, nonatomic) IBOutlet UILabel* comfortZoneInfoLabel;
@property (weak, nonatomic) IBOutlet UILabel* comfortZoneLabel;
@property (strong, nonatomic) NSArray* hourlyDataSeries;
@property (strong, nonatomic) NSArray* dailyDataSeries;
@property (strong, nonatomic) HEMSensorGraphDataSource* graphDataSource;
@property (nonatomic, getter=isShowingHourlyData) BOOL showHourlyData;
@property (weak, nonatomic) IBOutlet UILabel* unitLabel;

@property (nonatomic, strong) HEMGraphTooltipView* tooltipView;
@end

@implementation HEMSensorViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [HelloStyleKit currentConditionsBackgroundColor];
    [self initializeGraphDataSource];
    [self configureSensorValueViews];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.graphView reloadData];
    [self fadeInGraphView];
}

- (void)initializeGraphDataSource
{
    self.showHourlyData = YES;
    self.hourlyDataSeries = @[];
    self.dailyDataSeries = @[];
    self.graphDataSource = [[HEMSensorGraphDataSource alloc] initWithDataSeries:@[] forSensor:self.sensor];
    [self configureGraphView];
    [self refreshGraphData];
}

- (void)configureGraphView
{
    self.graphView.delegate = self;
    self.graphView.dataSource = self.graphDataSource;
    [self.graphView reloadData];
    self.graphView.maximumValue = (self.graphView.maximumValue ?: 0) * 1.25;
    self.graphView.minimumValue = 0;

    CAGradientLayer* mask = [CAGradientLayer layer];
    mask.frame = self.graphView.bounds;
    mask.colors = @[ (id)[UIColor whiteColor].CGColor,
                     (id)[UIColor whiteColor].CGColor,
                     (id)[UIColor clearColor].CGColor,
                     (id)[UIColor clearColor].CGColor ];
    mask.startPoint = CGPointMake(0, 0.5);
    mask.endPoint = CGPointMake(1, 0.5);
    mask.locations = @[ @(-1), @(-1), @0, @1 ];
    self.graphView.layer.mask = mask;
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
    self.valueLabel.text = [NSString stringWithFormat:@"%.0f", [[self.sensor valueInPreferredUnit] floatValue]];
    self.unitLabel.text = [self.sensor localizedUnit];
    UIFont* emFont = [UIFont fontWithName:@"HelveticaNeue-Medium" size:21.0];
    NSDictionary* attributes = @{
        @(EMPH) : @{
            NSFontAttributeName : emFont,
        },
        @(PARA) : @{
            NSForegroundColorAttributeName : [UIColor colorWithWhite:0.22f alpha:1.f],
        }
    };

    self.comfortZoneInfoLabel.attributedText = markdown_to_attr_string(self.sensor.message, 0, attributes);
}

- (void)refreshGraphData
{
    [SENAPIRoom hourlyHistoricalDataForSensorWithName:self.sensor.name completion:^(id data, NSError* error) {
        if (!data)
            return;
        NSArray* values = [data valueForKey:@"value"];
        self.hourlyDataSeries = values;
        if ([self isShowingHourlyData]) {
            self.graphDataSource = [[HEMSensorGraphDataSource alloc] initWithDataSeries:values forSensor:self.sensor];
            [self configureGraphView];
        }
    }];
    [SENAPIRoom dailyHistoricalDataForSensorWithName:self.sensor.name completion:^(id data, NSError* error) {
        if (!data)
            return;
        NSArray* values = [data valueForKey:@"value"];
        self.dailyDataSeries = values;
        if (![self isShowingHourlyData]) {
            self.graphDataSource = [[HEMSensorGraphDataSource alloc] initWithDataSeries:values forSensor:self.sensor];
            [self configureGraphView];
        }
    }];
}

- (IBAction)selectedHourlyGraph:(id)sender
{
    if ([self isShowingHourlyData])
        return;

    self.hourlyGraphButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:21.0];
    self.dailyGraphButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:21.0];
    [self animateActiveDataSeriesTo:self.hourlyDataSeries];
}

- (IBAction)selectedDailyGraph:(id)sender
{
    if (![self isShowingHourlyData])
        return;

    self.dailyGraphButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:21.0];
    self.hourlyGraphButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:21.0];
    [self animateActiveDataSeriesTo:self.dailyDataSeries];
}

- (void)animateActiveDataSeriesTo:(NSArray*)dataSeries
{
    [UIView animateWithDuration:0.25 animations:^{
        self.graphView.alpha = 0;
    } completion:^(BOOL finished) {
        self.showHourlyData = dataSeries == self.hourlyDataSeries;
        self.graphDataSource = [[HEMSensorGraphDataSource alloc] initWithDataSeries:dataSeries forSensor:self.sensor];
        [self.graphView reloadData];
        [UIView animateWithDuration:0.25 animations:^{
            self.graphView.alpha = 1.f;
        }];
    }];
}

#pragma mark - JBLineChartViewDelegate

- (void)lineChartView:(JBLineChartView*)lineChartView didSelectLineAtIndex:(NSUInteger)lineIndex horizontalIndex:(NSUInteger)horizontalIndex touchPoint:(CGPoint)touchPoint
{
    NSArray* dataSeries = ([self isShowingHourlyData] ? self.hourlyDataSeries : self.dailyDataSeries);
    NSNumber* value = [dataSeries objectAtIndex:horizontalIndex];
    [self setTooltipVisible:YES animated:YES atTouchPoint:touchPoint];
    [self.tooltipView setTitleText:[SENSensor formatValue:value withUnit:self.sensor.unit]];
    [self.tooltipView setDetailText:[[SORelativeDateTransformer registeredTransformer] transformedValue:[NSDate dateWithTimeIntervalSinceNow:60 * 60 * horizontalIndex]]];
}

- (void)didUnselectLineInLineChartView:(JBLineChartView*)lineChartView
{
    [self setTooltipVisible:NO animated:YES];
}

- (void)setTooltipVisible:(BOOL)tooltipVisible animated:(BOOL)animated atTouchPoint:(CGPoint)touchPoint
{

    JBChartView* chartView = [self graphView];

    if (!self.tooltipView) {
        self.tooltipView = [[HEMGraphTooltipView alloc] initWithFrame:CGRectMake(0, 0, 50, 26)];
        self.tooltipView.alpha = 0.0;
        [self.view addSubview:self.tooltipView];
    }

    dispatch_block_t adjustTooltipPosition = ^{
        CGPoint convertedTouchPoint = [self.view convertPoint:touchPoint fromView:chartView];
        CGFloat minChartX = (chartView.frame.origin.x + ceil(CGRectGetWidth(self.tooltipView.frame) * 0.5));
        if (convertedTouchPoint.x < minChartX)
            convertedTouchPoint.x = minChartX;

        CGFloat maxChartX = (chartView.frame.origin.x + chartView.frame.size.width - ceil(self.tooltipView.frame.size.width * 0.5));
        if (convertedTouchPoint.x > maxChartX)
            convertedTouchPoint.x = maxChartX;

        self.tooltipView.frame = CGRectMake(convertedTouchPoint.x - ceil(CGRectGetWidth(self.tooltipView.frame) * 0.5), CGRectGetMinY(chartView.frame) - CGRectGetHeight(self.tooltipView.frame) - 10.f, CGRectGetWidth(self.tooltipView.frame), CGRectGetHeight(self.tooltipView.frame));
    };

    dispatch_block_t adjustTooltipVisibility = ^{
        self.tooltipView.alpha = tooltipVisible ? 1.0 : 0.0;
    };

    if (tooltipVisible) {
        adjustTooltipPosition();
    }

    if (animated) {
        [UIView animateWithDuration:kJBBaseChartViewControllerAnimationDuration animations:^{
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
