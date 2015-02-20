
#import <SenseKit/SENSensor.h>
#import <SenseKit/SENAPIRoom.h>
#import <SenseKit/SENAuthorizationService.h>
#import <SenseKit/SENLocalPreferences.h>
#import <SenseKit/SENPreference.h>
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
#import "HEMTutorial.h"

@interface HEMSensorViewController ()<BEMSimpleLineGraphDelegate>

@property (weak, nonatomic) IBOutlet UIButton* dailyGraphButton;
@property (weak, nonatomic) IBOutlet UIButton* hourlyGraphButton;
@property (weak, nonatomic) IBOutlet UILabel* valueLabel;
@property (weak, nonatomic) IBOutlet BEMSimpleLineGraphView* graphView;
@property (weak, nonatomic) IBOutlet UILabel* statusMessageLabel;
@property (weak, nonatomic) IBOutlet UILabel* statusLabel;
@property (weak, nonatomic) IBOutlet UIView *graphContainerView;
@property (weak, nonatomic) IBOutlet UILabel* unitLabel;
@property (weak, nonatomic) IBOutlet UIView* chartContainerView;
@property (weak, nonatomic) IBOutlet UIView* selectionView;
@property (weak, nonatomic) IBOutlet HEMGraphSectionOverlayView* overlayView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint* selectionLeftConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint* tinySeparatorConstraint;

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

static NSTimeInterval const HEMSensorRefreshInterval = 10.f;
static CGFloat const HEMSensorValueMinLabelHeight = 68.f;

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
    [self configureBarButtonItems];
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
    [HEMTutorial showTutorialIfNeededForSensorNamed:self.sensor.name];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.refreshTimer invalidate];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self adjustValueViewHeights];
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
               selector:@selector(refreshData)
                   name:SENAPIReachableNotification object:nil];
    [center addObserver:self
               selector:@selector(reloadData)
                   name:SENLocalPrefDidChangeNotification
                 object:[SENPreference nameFromType:SENPreferenceTypeTempCelcius]];
}

- (void)showTutorial
{
    if ([self isViewLoaded] && self.view.window)
        [HEMTutorial showTutorialForSensorNamed:self.sensor.name];
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

- (void)configureBarButtonItems
{
    static CGFloat const HEMSensorBarButtonSpace = 8.f;
    if (self.navigationItem.rightBarButtonItems.count > 1)
        return;
    self.tinySeparatorConstraint.constant = 0.5f;
    UIImage* image = [HelloStyleKit infoButtonIcon];
    UIButton* buttonView = [UIButton buttonWithType:UIButtonTypeCustom];
    buttonView.bounds = CGRectMake(0, 0, image.size.width, image.size.height);
    [buttonView setImage:image forState:UIControlStateNormal];
    [buttonView addTarget:self action:@selector(showTutorial) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem* rightItem = [[UIBarButtonItem alloc] initWithCustomView:buttonView];

    UIBarButtonItem *rightFixedSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                                                                     target:nil
                                                                                     action:nil];
    rightFixedSpace.width = HEMSensorBarButtonSpace;
    UIBarButtonItem* leftItem = self.navigationItem.leftBarButtonItem;
    if (leftItem) {
        UIBarButtonItem *leftFixedSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                                                                        target:nil
                                                                                        action:nil];
        leftFixedSpace.width = HEMSensorBarButtonSpace;
        self.navigationItem.leftBarButtonItems = @[leftFixedSpace, leftItem];
    }
    self.navigationItem.rightBarButtonItems = @[rightFixedSpace, rightItem];
}

- (void)configureDateFormatters
{
    self.hourlyFormatter = [NSDateFormatter new];
    self.dailyFormatter = [NSDateFormatter new];
    if ([SENPreference timeFormat] == SENTimeFormat12Hour) {
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
    self.graphView.userInteractionEnabled = NO;
    self.graphView.labelFont = [UIFont sensorGraphNumberFont];
}

- (void)configureSensorValueViews
{
    UIColor* color = [UIColor colorForSensorWithCondition:self.sensor.condition];
    NSDictionary* statusAttributes = [HEMMarkdown attributesForSensorMessage];

    self.valueLabel.textColor = color;
    self.unitLabel.textColor = color;
    self.title = self.sensor.localizedName;
    [self updateValueLabelWithValue:self.sensor.value];
    self.unitLabel.text = [self.sensor localizedUnit];
    self.statusMessageLabel.textAlignment = NSTextAlignmentLeft;
    NSMutableAttributedString* statusMessage = [[markdown_to_attr_string(self.sensor.message, 0, statusAttributes) trim] mutableCopy];
    if (self.sensor.idealConditionsMessage.length > 0) {
        static NSString* const HEMSensorContentDivider = @"\n\n";
        NSDictionary* idealAttributes = [HEMMarkdown attributesForSensorMessage];
        NSAttributedString* divider = [[NSAttributedString alloc] initWithString:HEMSensorContentDivider attributes:statusAttributes];
        NSAttributedString* idealMessage = [markdown_to_attr_string(self.sensor.idealConditionsMessage, 0, idealAttributes) trim];
        [statusMessage appendAttributedString:divider];
        [statusMessage appendAttributedString:idealMessage];
    }
    self.statusMessageLabel.attributedText = statusMessage;
    [self adjustValueViewHeights];
    self.graphView.colorLine = color;
    self.graphView.alphaLine = 0.7;
    self.graphView.colorBottom = [color colorWithAlphaComponent:0.2];
}

- (void)adjustValueViewHeights
{
    [self.view layoutIfNeeded];
    BOOL shouldHideValue = CGRectGetHeight(self.valueLabel.bounds) < HEMSensorValueMinLabelHeight;
    self.valueLabel.hidden = shouldHideValue;
    self.unitLabel.hidden = shouldHideValue;
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
        if (error) {
            self.statusLabel.text = NSLocalizedString(@"graph-data.unavailable", nil);
            self.statusLabel.alpha = 1;
            self.overlayView.alpha = 0;
            self.graphView.alpha = 0;
            return;
        }
        if (![self.hourlyDataSeries isEqualToArray:data]) {
            self.hourlyDataSeries = data;
            if ([self isShowingHourlyData])
                [self updateGraphWithHourlyData:data];
        }
    }];
    [SENAPIRoom dailyHistoricalDataForSensor:self.sensor completion:^(id data, NSError* error) {
        if (error) {
            self.statusLabel.text = NSLocalizedString(@"graph-data.unavailable", nil);
            self.statusLabel.alpha = 1;
            self.overlayView.alpha = 0;
            self.graphView.alpha = 0;
            return;
        }
        if (![self.dailyDataSeries isEqualToArray:data]) {
            self.dailyDataSeries = data;
            if (![self isShowingHourlyData])
                [self updateGraphWithDailyData:data];
        }
    }];
    [SENSensor refreshCachedSensors];
}

- (void)refreshCurrentSensorValue:(NSNotification*)note
{
    SENSensor* sensor = note.object;
    if (![sensor.name isEqualToString:self.sensor.name])
        return;

    if (![self.sensor isEqual:sensor]) {
        self.sensor = sensor;
        [self configureSensorValueViews];
    }
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
    [self setGraphButtonSelected:self.hourlyGraphButton];
    [self positionSelectionViewUnderView:self.hourlyGraphButton];
    [self updateGraphWithData:dataSeries];
}

- (void)updateGraphWithDailyData:(NSArray*)dataSeries {
    [self setGraphButtonSelected:self.dailyGraphButton];
    [self positionSelectionViewUnderView:self.dailyGraphButton];
    [self updateGraphWithData:dataSeries];
}

- (void)setGraphButtonSelected:(UIButton*)button {
    BOOL hourlyIsOn = [button isEqual:self.hourlyGraphButton];
    NSString* dailyText = [NSLocalizedString(@"sensor.graph-button.past-week.title", nil) uppercaseString];
    NSDictionary* dailyAttributes = [HEMMarkdown attributesForSensorGraphButtonWithSelectedState:!hourlyIsOn][@(PARA)];
    NSAttributedString* dailyButtonText = [[NSAttributedString alloc] initWithString:dailyText
                                                                          attributes:dailyAttributes];
    NSString* hourlyText = [NSLocalizedString(@"sensor.graph-button.last-day.title", nil) uppercaseString];
    NSDictionary* hourlyAttributes = [HEMMarkdown attributesForSensorGraphButtonWithSelectedState:hourlyIsOn][@(PARA)];
    NSAttributedString* hourlyButtonText = [[NSAttributedString alloc] initWithString:hourlyText
                                                                          attributes:hourlyAttributes];
    [self.dailyGraphButton setAttributedTitle:dailyButtonText forState:UIControlStateNormal];
    [self.hourlyGraphButton setAttributedTitle:hourlyButtonText forState:UIControlStateNormal];
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
    self.graphView.userInteractionEnabled = NO;
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
    NSMutableArray* values = [[dataSeries valueForKey:NSStringFromSelector(@selector(value))] mutableCopy];
    [values sortUsingComparator:^NSComparisonResult(NSNumber* obj1, NSNumber* obj2) {
        if ([obj1 isKindOfClass:[NSNumber class]] && [obj2 isKindOfClass:[NSNumber class]])
            return [obj1 compare:obj2];
        else if ([obj1 isKindOfClass:[NSNull class]] && [obj2 isKindOfClass:[NSNull class]])
            return NSOrderedSame;
        else if ([obj1 isKindOfClass:[NSNull class]])
            return NSOrderedAscending;
        else
            return NSOrderedDescending;
    }];
    NSNumber* maxValue = [values lastObject];
    NSNumber* minValue = @1;
    if ([maxValue isEqual:[NSNull null]])
        self.maxGraphValue = 0;
    else
        self.maxGraphValue = [[SENSensor value:maxValue inPreferredUnit:self.sensor.unit] floatValue];
    for (NSNumber* value in values) {
        if (![value isEqual:[NSNull null]]) {
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
    [self updateValueLabelWithValue:dataPoint.value];
    [UIView animateWithDuration:0.2f animations:^{
        self.overlayView.alpha = 0;
    }];
}

- (void)lineGraph:(BEMSimpleLineGraphView *)graph didReleaseTouchFromGraphWithClosestIndex:(CGFloat)index {
    [self.view setNeedsUpdateConstraints];
    [self configureSensorValueViews];
    self.panning = NO;
    [UIView animateWithDuration:0.2f animations:^{
        self.overlayView.alpha = 1;
    }];
}

- (void)lineGraphDidFinishLoading:(BEMSimpleLineGraphView *)graph {
    [self.overlayView setSectionFooters:self.graphDataSource.valuesForSectionIndexes headers:nil];
    [self.graphView setUserInteractionEnabled:self.graphDataSource.dataSeries.count > 0];
    [UIView animateWithDuration:0.5f animations:^{
        self.graphView.alpha = 1;
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
