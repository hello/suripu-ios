
#import <SenseKit/SENSensor.h>
#import <SenseKit/SENAPIRoom.h>
#import <SenseKit/SENAuthorizationService.h>
#import <SenseKit/SENSettings.h>
#import <BEMSimpleLineGraph/BEMSimpleLineGraphView.h>
#import <markdown_peg.h>

#import "HEMSensorViewController.h"
#import "HEMLineGraphDataSource.h"
#import "HEMGraphSectionOverlayView.h"
#import "HelloStyleKit.h"
#import "UIColor+HEMStyle.h"
#import "UIFont+HEMStyle.h"
#import "NSAttributedString+HEMUtils.h"
#import "HEMMarkdown.h"

@interface HEMSensorViewController ()<BEMSimpleLineGraphDelegate>

@property (weak, nonatomic) IBOutlet UIButton* dailyGraphButton;
@property (weak, nonatomic) IBOutlet UIButton* hourlyGraphButton;
@property (weak, nonatomic) IBOutlet UILabel* valueLabel;
@property (weak, nonatomic) IBOutlet BEMSimpleLineGraphView* graphView;
@property (weak, nonatomic) IBOutlet UILabel* statusMessageLabel;
@property (weak, nonatomic) IBOutlet UILabel* statusLabel;
@property (weak, nonatomic) IBOutlet UILabel* idealLabel;
@property (weak, nonatomic) IBOutlet UIView *graphContainerView;
@property (weak, nonatomic) IBOutlet UILabel* unitLabel;
@property (weak, nonatomic) IBOutlet UIView* chartContainerView;
@property (weak, nonatomic) IBOutlet UIView* selectionView;
@property (weak, nonatomic) IBOutlet HEMGraphSectionOverlayView* overlayView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint* selectionLeftConstraint;

@property (strong, nonatomic) NSArray* hourlyDataSeries;
@property (strong, nonatomic) NSArray* dailyDataSeries;
@property (strong, nonatomic) HEMLineGraphDataSource* graphDataSource;
@property (nonatomic, getter=isShowingHourlyData) BOOL showHourlyData;
@property (nonatomic, strong) NSDateFormatter* hourlyFormatter;
@property (nonatomic, strong) NSDateFormatter* dailyFormatter;
@property (nonatomic, strong) NSTimer* refreshTimer;
@property (nonatomic) CGFloat maxGraphValue;
@property (nonatomic) CGFloat minGraphValue;
@property (nonatomic, getter=isPanning) BOOL panning;
@end

@implementation HEMSensorViewController

static NSTimeInterval const HEMSensorRefreshInterval = 30.f;

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self configureDateFormatters];
    self.hourlyGraphButton.titleLabel.font = [UIFont sensorRangeSelectionFont];
    self.dailyGraphButton.titleLabel.font = [UIFont sensorRangeSelectionFont];
    [self initializeGraphDataSource];
    [self configureGraphView];
    [self configureSensorValueViews];
    
    NSString* sensorName = [[self sensor] localizedName] ?: @"";
    [SENAnalytics track:kHEMAnalyticsEventSensor
             properties:@{kHEMAnalyticsEventPropSensorName : sensorName}];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.view.backgroundColor = [UIColor whiteColor];
    if ([self isShowingHourlyData])
        [self positionSelectionViewUnderView:self.hourlyGraphButton animated:NO];
    [self reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self fadeInGraphView];
    self.refreshTimer = [NSTimer scheduledTimerWithTimeInterval:HEMSensorRefreshInterval
                                                         target:self
                                                       selector:@selector(refreshData)
                                                       userInfo:nil
                                                        repeats:YES];
    [self registerForNotifications];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.refreshTimer invalidate];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)dealloc
{
    [_refreshTimer invalidate];
}

- (void)registerForNotifications
{
    NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
    [center addObserver:self
               selector:@selector(refreshCurrentSensorValue:)
                   name:SENSensorUpdatedNotification object:nil];
    [center addObserver:self
               selector:@selector(reloadData)
                   name:SENSettingsDidUpdateNotification object:SENSettingsUpdateTypeTemp];
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
    [self refreshData];
}

- (void)configureDateFormatters
{
    self.hourlyFormatter = [NSDateFormatter new];
    self.dailyFormatter = [NSDateFormatter new];
    if ([SENSettings timeFormat] == SENTimeFormat12Hour) {
        self.hourlyFormatter.dateFormat = @"h:mma";
        self.dailyFormatter.dateFormat = @"EEEE — h:mma";
    } else {
        self.hourlyFormatter.dateFormat = @"H:mm";
        self.dailyFormatter.dateFormat = @"EEEE — H:mm";
    }
}

- (void)configureGraphView
{
    self.overlayView.alpha = 0;
    self.graphView.delegate = self;
    self.graphView.enableBezierCurve = NO;
    self.graphView.enableTouchReport = YES;
    self.graphView.colorBottom = [UIColor clearColor];
    self.graphView.colorTop = [UIColor clearColor];
    self.graphView.colorPoint = [UIColor clearColor];
    self.graphView.widthLine = 1.f;
    self.graphView.labelFont = [UIFont sensorGraphNumberFont];
}

- (void)configureSensorValueViews
{
    UIColor* color = [UIColor colorForSensorWithCondition:self.sensor.condition];
    NSDictionary* statusAttributes = [HEMMarkdown attributesForSensorMessageWithConditionColor:color];
    NSDictionary* idealAttributes = [HEMMarkdown attributesForRoomCheckWithConditionColor:[HelloStyleKit idealSensorColor]];

    self.valueLabel.textColor = color;
    self.unitLabel.textColor = color;
    self.title = self.sensor.localizedName;
    [self updateValueLabelWithValue:self.sensor.value];
    self.unitLabel.text = [self.sensor localizedUnit];
    self.statusMessageLabel.textAlignment = NSTextAlignmentLeft;
    self.statusMessageLabel.attributedText = [markdown_to_attr_string(self.sensor.message, 0, statusAttributes) trim];
    self.idealLabel.attributedText = [markdown_to_attr_string(self.sensor.idealConditionsMessage, 0, idealAttributes) trim];
    self.graphView.colorLine = color;
    self.graphView.alphaLine = 0.7;
    self.graphView.colorBottom = [color colorWithAlphaComponent:0.2];
}

- (void)updateValueLabelWithValue:(NSNumber*)value
{
    if (value) {
        CGFloat formattedValue = [[SENSensor value:value inPreferredUnit:self.sensor.unit] floatValue];
        self.valueLabel.text = [NSString stringWithFormat:@"%.0f", formattedValue];
    } else {
        self.valueLabel.text = NSLocalizedString(@"empty-data", nil);
    }
}

#pragma mark - Update Graph

- (void)fadeInGraphView
{
    [CATransaction begin];
    [CATransaction setValue:@1 forKey:kCATransactionAnimationDuration];
    ((CAGradientLayer*)self.graphView.layer.mask).locations = @[ @0, @1, @2, @2 ];
    [CATransaction commit];
}

- (void)reloadData
{
    [self configureSensorValueViews];
    [self.graphView reloadGraph];
}

- (void)refreshData
{
    if (![SENAuthorizationService isAuthorized])
        return;
    self.statusLabel.text = NSLocalizedString(@"activity.loading", nil);
    [SENAPIRoom hourlyHistoricalDataForSensor:self.sensor completion:^(id data, NSError* error) {
        if (!data) {
            self.statusLabel.text = NSLocalizedString(@"graph-data.unavailable", nil);
            self.statusLabel.alpha = 1;
            self.overlayView.alpha = 0;
            return;
        }
        self.hourlyDataSeries = data;
        if ([self isShowingHourlyData])
            [self updateGraphWithHourlyData:data];
    }];
    [SENAPIRoom dailyHistoricalDataForSensor:self.sensor completion:^(id data, NSError* error) {
        if (!data) {
            self.statusLabel.text = NSLocalizedString(@"graph-data.unavailable", nil);
            self.statusLabel.alpha = 1;
            self.overlayView.alpha = 0;
            return;
        }
        self.dailyDataSeries = data;
        if (![self isShowingHourlyData])
            [self updateGraphWithDailyData:data];
    }];
    [SENSensor refreshCachedSensors];
}

- (void)refreshCurrentSensorValue:(NSNotification*)note
{
    SENSensor* sensor = note.object;
    if (![sensor.name isEqualToString:self.sensor.name])
        return;

    self.sensor = sensor;
    [self configureSensorValueViews];

}

- (IBAction)selectedHourlyGraph:(id)sender
{
    if ([self isShowingHourlyData])
        return;
    self.showHourlyData = YES;
    [self toggleDataSeriesTo:self.hourlyDataSeries animated:YES];
}

- (IBAction)selectedDailyGraph:(id)sender
{
    if (![self isShowingHourlyData])
        return;
    self.showHourlyData = NO;
    [self toggleDataSeriesTo:self.dailyDataSeries animated:YES];
}

- (void)toggleDataSeriesTo:(NSArray*)dataSeries animated:(BOOL)animated
{
    void (^animations)() = ^{
        self.graphView.alpha = 0;
        self.overlayView.alpha = 0;
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

- (void)updateGraphWithHourlyData:(NSArray*)dataSeries {
    [self.dailyGraphButton setTitleColor:[HelloStyleKit backViewTextColor] forState:UIControlStateNormal];
    [self.hourlyGraphButton setTitleColor:[HelloStyleKit tintColor] forState:UIControlStateNormal];
    [self positionSelectionViewUnderView:self.hourlyGraphButton];
    [self updateGraphWithData:dataSeries];
}

- (void)updateGraphWithDailyData:(NSArray*)dataSeries {
    [self.hourlyGraphButton setTitleColor:[HelloStyleKit backViewTextColor] forState:UIControlStateNormal];
    [self.dailyGraphButton setTitleColor:[HelloStyleKit tintColor] forState:UIControlStateNormal];
    [self positionSelectionViewUnderView:self.dailyGraphButton];
    [self updateGraphWithData:dataSeries];
}

- (void)positionSelectionViewUnderView:(UIView*)view {
    [self positionSelectionViewUnderView:view animated:YES];
}

- (void)positionSelectionViewUnderView:(UIView*)view animated:(BOOL)animated {
    [view layoutIfNeeded];
    CGFloat buttonWidthDiff = (CGRectGetWidth(self.selectionView.bounds) - CGRectGetWidth(view.bounds))/2;
    self.selectionLeftConstraint.constant = CGRectGetMinX(view.frame) - buttonWidthDiff;
    [self.selectionView setNeedsUpdateConstraints];
    void(^animations)() = ^{
        [self.selectionView layoutIfNeeded];
    };
    if (animated) {
        [UIView animateWithDuration:0.25f animations:animations];
    } else {
        animations();
    }
}

- (void)updateGraphWithData:(NSArray*)dataSeries
{
    self.graphDataSource = [[HEMLineGraphDataSource alloc] initWithDataSeries:dataSeries
                                                                         unit:self.sensor.unit];
    self.graphView.dataSource = self.graphDataSource;
    [self setGraphValueBoundsWithData:dataSeries];
    if (![self isPanning])
        [self.graphView reloadGraph];
    if (dataSeries.count == 0) {
        self.statusLabel.text = NSLocalizedString(@"sensor.value.none", nil);
        self.statusLabel.alpha = 1;
    } else {
        self.statusLabel.alpha = 0;
    }
    [self ensureSelectionViewVisible];
}

- (void)ensureSelectionViewVisible
{
    if (self.selectionView.alpha < 1) {
        __weak typeof(self) weakSelf = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.45 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            [UIView animateWithDuration:0.15f animations:^{
                strongSelf.selectionView.alpha = 1;
            }];
        });
    }
}

- (void)setGraphValueBoundsWithData:(NSArray*)dataSeries {
    NSArray* values = [[dataSeries valueForKey:NSStringFromSelector(@selector(value))]
                       sortedArrayUsingSelector:@selector(compare:)];
    NSNumber* maxValue = [values lastObject];
    NSNumber* minValue = @1;
    if ([maxValue floatValue] == 0)
        self.maxGraphValue = 0;
    else
        self.maxGraphValue = [[SENSensor value:maxValue inPreferredUnit:self.sensor.unit] floatValue];
    for (NSNumber* value in values) {
        CGFloat number = [value floatValue];
        if (number  > 0) {
            minValue = value;
            break;
        }
    }
    self.minGraphValue = [[SENSensor value:minValue inPreferredUnit:self.sensor.unit] floatValue] * 0.75;
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

- (void)lineGraph:(BEMSimpleLineGraphView *)graph didTouchGraphWithClosestIndex:(NSInteger)index {
    self.panning = YES;
    SENSensorDataPoint* dataPoint = [self.graphDataSource dataPointAtIndex:index];
    self.statusMessageLabel.textAlignment = NSTextAlignmentCenter;
    NSDateFormatter* formatter = [self isShowingHourlyData] ? self.hourlyFormatter : self.dailyFormatter;
    self.statusMessageLabel.text = [formatter stringFromDate:dataPoint.date];
    CGFloat value = [[SENSensor value:dataPoint.value inPreferredUnit:self.sensor.unit] floatValue];
    if ([dataPoint.value floatValue] > 0)
        self.valueLabel.text = [NSString stringWithFormat:@"%.0f", value];
    else if ([self.graphDataSource canHaveZeroValue])
        self.valueLabel.text = @"0";
    else
        self.valueLabel.text = NSLocalizedString(@"empty-data", nil);
    [UIView animateWithDuration:0.2f animations:^{
        self.overlayView.alpha = 0;
    }];
}

- (void)lineGraph:(BEMSimpleLineGraphView *)graph didReleaseTouchFromGraphWithClosestIndex:(CGFloat)index {
    [self configureSensorValueViews];
    self.panning = NO;
    [UIView animateWithDuration:0.2f animations:^{
        self.overlayView.alpha = 1;
    }];
}

- (void)lineGraphDidFinishLoading:(BEMSimpleLineGraphView *)graph {
    [self.overlayView setSectionFooters:self.graphDataSource.valuesForSectionIndexes headers:nil];
    [UIView animateWithDuration:0.5f animations:^{
        self.overlayView.alpha = 1;
    }];
}

- (CGFloat)maxValueForLineGraph:(BEMSimpleLineGraphView *)graph {
    return self.maxGraphValue;
}

- (CGFloat)minValueForLineGraph:(BEMSimpleLineGraphView *)graph {
    return self.minGraphValue;
}

@end
