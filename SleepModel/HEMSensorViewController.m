
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
@property (weak, nonatomic) IBOutlet UILabel* statusLabel;
@property (weak, nonatomic) IBOutlet UIView* comfortZoneContainer;
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
    [self configureGraphViewBackground];
    [self initializeGraphDataSource];
    [self configureGraphView];
    [self configureSensorValueViews];
    [self configureComfortLevelViews];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self fadeInGraphView];
    [self updateSelectionViewLocation];
    [UIView animateWithDuration:0.25 animations:^{
        self.selectionView.alpha = 1;
        [self.hourlyGraphButton setTitleColor:[HelloStyleKit senseBlueColor] forState:UIControlStateNormal];
    }];
}

#pragma mark - Configuration

- (void)initializeGraphDataSource
{
    self.showHourlyData = YES;
    self.hourlyDataSeries = @[];
    self.dailyDataSeries = @[];
    [self toggleDataSeriesTo:self.hourlyDataSeries animated:NO];
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
    self.view.backgroundColor = [HelloStyleKit currentConditionsBackgroundColor];
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.graphContainerView.bounds;
    gradient.colors = @[
                        (id)[[UIColor whiteColor] CGColor],
                        (id)[[HelloStyleKit backViewBackgroundColor] CGColor]];
    gradient.locations = @[@0, @(0.8)];
    [self.graphContainerView.layer insertSublayer:gradient atIndex:0];
}

- (void)configureGraphView
{
    self.overlayView.alpha = 0;
    self.selectionView.alpha = 0;
    self.graphView.enableBezierCurve = YES;
    self.graphView.enablePopUpReport = YES;
    self.graphView.colorBottom = [UIColor clearColor];
    self.graphView.colorTop = [UIColor clearColor];
    self.graphView.colorPoint = [UIColor clearColor];
    self.graphView.colorLine = [HelloStyleKit backViewTextColor];
    self.graphView.widthLine = 1.f;
    self.graphView.labelFont = [UIFont sensorGraphNumberFont];
}

- (void)configureSensorValueViews
{
    self.title = self.sensor.localizedName;
    if (self.sensor.value) {
        NSString* format = nil;
        if (self.sensor.unit == SENSensorUnitMicrogramPerCubicMeter && [self.sensor.value floatValue] > 0.0f) {
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
        @(EMPH)  : @{ NSFontAttributeName : [UIFont settingsInsightMessageFont]},
        @(PLAIN) : @{ NSFontAttributeName : [UIFont settingsInsightMessageFont]}
    };

    self.comfortZoneInfoLabel.attributedText = markdown_to_attr_string(self.sensor.message, 0, attributes);
}

- (void)configureComfortLevelViews
{
    self.comfortZoneLabel.font = [UIFont insightTitleFont];
    self.comfortZoneContainer.layer.cornerRadius = 2.f;
    self.comfortZoneContainer.layer.shadowColor = [UIColor colorWithWhite:0 alpha:0.1f].CGColor;
    self.comfortZoneContainer.layer.shadowOffset = CGSizeMake(0, 1);
    self.comfortZoneContainer.layer.shadowOpacity = 1.f;
    self.comfortZoneContainer.layer.shadowRadius = 2.f;
}

#pragma mark - Update Graph

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

- (void)refreshGraphData
{
    self.statusLabel.text = NSLocalizedString(@"activity.loading", nil);
    [SENAPIRoom hourlyHistoricalDataForSensorWithName:self.sensor.name completion:^(id data, NSError* error) {
        if (!data) {
            self.statusLabel.text = NSLocalizedString(@"sensor.value.none", nil);
            self.statusLabel.alpha = 1;
            return;
        }
        self.hourlyDataSeries = data;
        if ([self isShowingHourlyData])
            [self updateGraphWithHourlyData:data];
    }];
    [SENAPIRoom dailyHistoricalDataForSensorWithName:self.sensor.name completion:^(id data, NSError* error) {
        if (!data) {
            self.statusLabel.text = NSLocalizedString(@"sensor.value.none", nil);
            self.statusLabel.alpha = 1;
            return;
        }
        self.dailyDataSeries = data;
        if (![self isShowingHourlyData])
            [self updateGraphWithDailyData:data];
    }];
}

- (IBAction)selectedHourlyGraph:(id)sender
{
    if ([self isShowingHourlyData])
        return;
    self.showHourlyData = YES;
    [self.dailyGraphButton setTitleColor:[HelloStyleKit backViewTextColor] forState:UIControlStateNormal];
    [self.hourlyGraphButton setTitleColor:[HelloStyleKit senseBlueColor] forState:UIControlStateNormal];
    [self toggleDataSeriesTo:self.hourlyDataSeries animated:YES];
}

- (IBAction)selectedDailyGraph:(id)sender
{
    if (![self isShowingHourlyData])
        return;
    self.showHourlyData = NO;
    [self.dailyGraphButton setTitleColor:[HelloStyleKit senseBlueColor] forState:UIControlStateNormal];
    [self.hourlyGraphButton setTitleColor:[HelloStyleKit backViewTextColor] forState:UIControlStateNormal];
    [self toggleDataSeriesTo:self.dailyDataSeries animated:YES];
}

- (void)toggleDataSeriesTo:(NSArray*)dataSeries animated:(BOOL)animated
{
    void (^animations)() = ^{
        self.graphView.alpha = 0;
        self.overlayView.alpha = 0;
        [self updateSelectionViewLocation];
    };
    void (^completion)(BOOL) = ^(BOOL finished) {
        if ([self isShowingHourlyData]) {
            [self updateGraphWithHourlyData:dataSeries];
        } else {
            [self updateGraphWithDailyData:dataSeries];
        }
        [UIView animateWithDuration:0.25 animations:^{
            self.graphView.alpha = 1.f;
        }];
    };
    if (animated) {
        [UIView animateWithDuration:0.25 animations:animations completion:completion];
    } else {
        animations();
        completion(YES);
    }
}

- (void)updateSelectionViewLocation {
    UIButton* button = [self isShowingHourlyData] ? self.hourlyGraphButton : self.dailyGraphButton;
    self.selectionViewLeadingConstraint.constant = CGRectGetMinX(button.frame);
    self.selectionViewWidthConstraint.constant = CGRectGetWidth(button.frame);
    [self.selectionView layoutIfNeeded];
}

- (void)updateGraphWithHourlyData:(NSArray*)dataSeries {
    [self updateGraphWithData:dataSeries formatter:self.hourlyFormatter];
}

- (void)updateGraphWithDailyData:(NSArray*)dataSeries {
    [self updateGraphWithData:dataSeries formatter:self.dailyFormatter];
}

- (void)updateGraphWithData:(NSArray*)dataSeries formatter:(NSDateFormatter*)formatter
{
    self.graphDataSource = [[HEMLineGraphDataSource alloc] initWithDataSeries:dataSeries
                                                                         unit:self.sensor.unit];
    self.graphDataSource.dateFormatter = formatter;
    [self reloadData];
    if (dataSeries.count == 0) {
        self.statusLabel.text = NSLocalizedString(@"sensor.value.none", nil);
        self.statusLabel.alpha = 1;
    } else {
        self.statusLabel.alpha = 0;
    }
}

#pragma mark - BEMSimpleLineGraphDelegate

- (NSArray*)dataSeries {
    return [self isShowingHourlyData] ? self.hourlyDataSeries : self.dailyDataSeries;
}

- (NSInteger)numberOfGapsBetweenLabelsOnLineGraph:(BEMSimpleLineGraphView *)graph {
    return ceil(self.dataSeries.count/8);
}

- (BOOL)noDataLabelEnableForLineGraph:(BEMSimpleLineGraphView *)graph {
    return NO;
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
