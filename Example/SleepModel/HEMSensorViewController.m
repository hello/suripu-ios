
#import <SenseKit/SENSensor.h>
#import <SORelativeDateTransformer/SORelativeDateTransformer.h>
#import <JBChartView/JBLineChartView.h>
#import <markdown_peg.h>

#import "HEMSensorViewController.h"
#import "HEMGraphTooltipView.h"
#import "HEMColorUtils.h"

CGFloat const kJBBaseChartViewControllerAnimationDuration = 0.25f;

@interface HEMSensorViewController () <JBLineChartViewDataSource, JBLineChartViewDelegate>

@property (weak, nonatomic) IBOutlet UIButton* dailyGraphButton;
@property (weak, nonatomic) IBOutlet UIButton* hourlyGraphButton;
@property (weak, nonatomic) IBOutlet UILabel* valueLabel;
@property (weak, nonatomic) IBOutlet JBLineChartView* graphView;
@property (weak, nonatomic) IBOutlet UILabel* comfortZoneInfoLabel;
@property (weak, nonatomic) IBOutlet UILabel* comfortZoneLabel;
@property (strong, nonatomic) NSArray* hourlyDataSeries;
@property (strong, nonatomic) NSArray* dailyDataSeries;
@property (strong, nonatomic) NSArray* activeDataSeries;
@property (weak, nonatomic) IBOutlet UILabel* unitLabel;

@property (nonatomic, strong) HEMGraphTooltipView* tooltipView;
@end

@implementation HEMSensorViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self configureViewBackground];
    [self configureGraphView];
    [self configureSensorValueViews];
}

- (void)configureViewBackground
{
    [self.view.layer insertSublayer:[HEMColorUtils layerWithBlueBackgroundGradientInFrame:self.view.bounds]
                            atIndex:0];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.graphView reloadData];
    [UIView animateWithDuration:0.5 animations:^{
        self.graphView.alpha = 1.f;
    }];
}

- (void)configureGraphView
{
    self.graphView.delegate = self;
    self.graphView.dataSource = self;
    self.graphView.alpha = 0;
    self.dailyDataSeries = @[
        @[ @22, @24, @24, @25, @38, @23, @24, @27, @30, @29 ]
    ];
    self.hourlyDataSeries = @[
        @[ @250, @284, @280, @268, @300, @362, @580, @610, @586, @601 ]
    ];
    self.activeDataSeries = self.hourlyDataSeries;
    [self.graphView reloadData];
    self.graphView.maximumValue = self.graphView.maximumValue * 1.25;
    self.graphView.minimumValue = 0;
}

- (void)configureSensorValueViews
{
    self.title = self.sensor.localizedName;
    self.valueLabel.text = [NSString stringWithFormat:@"%.0f", [[self.sensor value] floatValue]];
    self.unitLabel.text = [self.sensor localizedUnit];
    UIFont* emFont = [UIFont fontWithName:@"HelveticaNeue-Bold" size:14.0];
    NSDictionary* attributes = @{
        @(EMPH) : @{
            NSFontAttributeName : emFont,
        },
        @(PARA) : @{
            NSForegroundColorAttributeName : [UIColor whiteColor],
        }
    };

    self.comfortZoneInfoLabel.attributedText = markdown_to_attr_string(self.sensor.message, 0, attributes);
}

- (IBAction)selectedHourlyGraph:(id)sender
{
    if ([self.activeDataSeries isEqual:self.hourlyDataSeries])
        return;

    self.hourlyGraphButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:15.0];
    self.dailyGraphButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:15.0];
    [self animateActiveDataSeriesTo:self.hourlyDataSeries];
}

- (IBAction)selectedDailyGraph:(id)sender
{
    if ([self.activeDataSeries isEqual:self.dailyDataSeries])
        return;

    self.dailyGraphButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:15.0];
    self.hourlyGraphButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:15.0];
    [self animateActiveDataSeriesTo:self.dailyDataSeries];
}

- (void)animateActiveDataSeriesTo:(NSArray*)dataSeries
{
    [UIView animateWithDuration:0.25 animations:^{
        self.graphView.alpha = 0;
    } completion:^(BOOL finished) {
        self.activeDataSeries = dataSeries;
        [self.graphView reloadData];
        [UIView animateWithDuration:0.25 animations:^{
            self.graphView.alpha = 1.f;
        }];
    }];
}

#pragma mark - JBLineChartViewDelegate

- (void)lineChartView:(JBLineChartView*)lineChartView didSelectLineAtIndex:(NSUInteger)lineIndex horizontalIndex:(NSUInteger)horizontalIndex touchPoint:(CGPoint)touchPoint
{
    NSNumber* value = [[self.activeDataSeries objectAtIndex:0] objectAtIndex:horizontalIndex];
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

#pragma mark - JBLineChartViewDataSource

- (NSUInteger)numberOfLinesInLineChartView:(JBLineChartView*)lineChartView
{
    return self.activeDataSeries.count + 1;
}

- (NSUInteger)lineChartView:(JBLineChartView*)lineChartView numberOfVerticalValuesAtLineIndex:(NSUInteger)lineIndex
{
    NSArray* values = self.activeDataSeries[0];
    return values.count;
}

- (CGFloat)lineChartView:(JBLineChartView*)lineChartView verticalValueForHorizontalIndex:(NSUInteger)horizontalIndex atLineIndex:(NSUInteger)lineIndex
{
    if (lineIndex == 0)
        return [self.activeDataSeries[lineIndex][horizontalIndex] floatValue];

    return [self.sensor.value floatValue];
}

#pragma mark appearance

- (JBLineChartViewLineStyle)lineChartView:(JBLineChartView*)lineChartView lineStyleForLineAtLineIndex:(NSUInteger)lineIndex
{
    return lineIndex == 0 ? JBLineChartViewLineStyleSolid : JBLineChartViewLineStyleDashed;
}

- (BOOL)lineChartView:(JBLineChartView*)lineChartView showsDotsForLineAtLineIndex:(NSUInteger)lineIndex
{
    return lineIndex == 0;
}

- (BOOL)lineChartView:(JBLineChartView*)lineChartView smoothLineAtLineIndex:(NSUInteger)lineIndex
{
    return lineIndex == 0;
}

- (CGFloat)lineChartView:(JBLineChartView*)lineChartView widthForLineAtLineIndex:(NSUInteger)lineIndex
{
    if (lineIndex == 0)
        return 2.f;
    return 1.f;
}

- (UIColor*)lineChartView:(JBLineChartView*)lineChartView colorForLineAtLineIndex:(NSUInteger)lineIndex
{
    return [UIColor whiteColor];
}

- (UIColor*)lineChartView:(JBLineChartView*)lineChartView colorForDotAtHorizontalIndex:(NSUInteger)horizontalIndex atLineIndex:(NSUInteger)lineIndex
{
    return [UIColor whiteColor];
}

#pragma mark selection appearance

- (CGFloat)verticalSelectionWidthForLineChartView:(JBLineChartView*)lineChartView
{
    return 2.f;
}

@end
