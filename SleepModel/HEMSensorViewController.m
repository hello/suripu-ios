
#import <SenseKit/SENSensor.h>
#import <SenseKit/SENAPIRoom.h>
#import <SenseKit/SENSettings.h>
#import <BEMSimpleLineGraph/BEMSimpleLineGraphView.h>
#import <markdown_peg.h>

#import "HEMSensorViewController.h"
#import "HEMLineGraphDataSource.h"
#import "HEMGraphSectionOverlayView.h"
#import "HEMColorUtils.h"
#import "HelloStyleKit.h"
#import "UIFont+HEMStyle.h"

@interface HEMSensorViewController ()<BEMSimpleLineGraphDelegate>

@property (weak, nonatomic) IBOutlet UIButton* dailyGraphButton;
@property (weak, nonatomic) IBOutlet UIButton* hourlyGraphButton;
@property (weak, nonatomic) IBOutlet UILabel* valueLabel;
@property (weak, nonatomic) IBOutlet BEMSimpleLineGraphView* graphView;
@property (weak, nonatomic) IBOutlet UILabel* comfortZoneInfoLabel;
@property (weak, nonatomic) IBOutlet UILabel* comfortZoneLabel;
@property (weak, nonatomic) IBOutlet UIView *graphContainerView;
@property (weak, nonatomic) IBOutlet UILabel* unitLabel;
@property (weak, nonatomic) IBOutlet UIView* chartContainerView;
@property (weak, nonatomic) IBOutlet HEMGraphSectionOverlayView* overlayView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *selectionViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *selectionViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet UIView *selectionView;

@property (strong, nonatomic) NSArray* hourlyDataSeries;
@property (strong, nonatomic) NSArray* dailyDataSeries;
@property (strong, nonatomic) HEMLineGraphDataSource* graphDataSource;
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
    self.dailyFormatter.dateFormat = @"EEEEE";
    self.hourlyGraphButton.titleLabel.font = [UIFont sensorRangeSelectionFont];
    self.dailyGraphButton.titleLabel.font = [UIFont sensorRangeSelectionFont];
    self.view.backgroundColor = [HelloStyleKit currentConditionsBackgroundColor];
    [self configureGraphViewBackground];
    [self initializeGraphDataSource];
    [self configureGraphView];
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
    self.graphDataSource = [[HEMLineGraphDataSource alloc] initWithDataSeries:@[] unit:self.sensor.unit];
    self.graphDataSource.dateFormatter = self.hourlyFormatter;
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
    [self reloadData];
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
    self.overlayView.alpha = 0;
    self.graphView.enableBezierCurve = YES;
    self.graphView.enablePopUpReport = YES;
    self.graphView.colorBottom = [UIColor clearColor];
    self.graphView.colorTop = [UIColor clearColor];
    self.graphView.colorPoint = [UIColor clearColor];
    self.graphView.colorLine = [HelloStyleKit backViewTextColor];
    self.graphView.widthLine = 1.f;
    self.graphView.labelFont = [UIFont sensorGraphNumberFont];
}

- (void)reloadData
{
    self.graphView.delegate = self;
    self.graphView.dataSource = self.graphDataSource;
    [self.graphView reloadGraph];
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
        if ([self isShowingHourlyData])
            [self updateGraphWithHourlyData:data];
    }];
    [SENAPIRoom dailyHistoricalDataForSensorWithName:self.sensor.name completion:^(id data, NSError* error) {
        if (!data)
            return;
        self.dailyDataSeries = data;
        if (![self isShowingHourlyData])
            [self updateGraphWithDailyData:data];
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
    UIButton* button = [self isShowingHourlyData] ? self.hourlyGraphButton : self.dailyGraphButton;
    [UIView animateWithDuration:0.25 animations:^{
        self.graphView.alpha = 0;
        self.overlayView.alpha = 0;
        self.selectionViewLeadingConstraint.constant = CGRectGetMinX(button.frame);
        self.selectionViewWidthConstraint.constant = CGRectGetWidth(button.frame);
        [self.selectionView layoutIfNeeded];
    } completion:^(BOOL finished) {
        if ([self isShowingHourlyData]) {
            [self updateGraphWithHourlyData:dataSeries];
        } else {
            [self updateGraphWithDailyData:dataSeries];
        }
        [UIView animateWithDuration:0.25 animations:^{
            self.graphView.alpha = 1.f;
        }];
    }];
}

- (void)updateGraphWithHourlyData:(NSArray*)dataSeries {
    self.graphDataSource = [[HEMLineGraphDataSource alloc] initWithDataSeries:dataSeries
                                                                         unit:self.sensor.unit];
    self.graphDataSource.dateFormatter = self.hourlyFormatter;
    [self reloadData];
}

- (void)updateGraphWithDailyData:(NSArray*)dataSeries {
    self.graphDataSource = [[HEMLineGraphDataSource alloc] initWithDataSeries:dataSeries
                                                                         unit:self.sensor.unit];
    self.graphDataSource.dateFormatter = self.dailyFormatter;
    [self reloadData];
}

#pragma mark - BEMSimpleLineGraphDelegate

- (NSArray*)dataSeries {
    return [self isShowingHourlyData] ? self.hourlyDataSeries : self.dailyDataSeries;
}

- (NSInteger)numberOfGapsBetweenLabelsOnLineGraph:(BEMSimpleLineGraphView *)graph {
    return ceil(self.dataSeries.count/8);
}

- (void)lineGraphDidFinishLoading:(BEMSimpleLineGraphView *)graph {
    NSArray* labels = self.graphDataSource.valuesForSectionIndexes;
    if ([self isShowingHourlyData]) {
        NSMutableArray* modifiedLabels = [[NSMutableArray alloc] initWithCapacity:labels.count];
        for (NSDictionary* label in labels) {
            NSString* dateLabelText = [[label allKeys] firstObject];
            NSString* sensorValue = [[label allValues] firstObject];
            [modifiedLabels addObject:@{[dateLabelText lowercaseString]:sensorValue}];
        }
        labels = modifiedLabels;
    }
    [self.overlayView setSectionValues:labels];
    [UIView animateWithDuration:0.5f animations:^{
        self.overlayView.alpha = 1;
    }];
}

@end
