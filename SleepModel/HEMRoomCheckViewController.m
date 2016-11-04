//
//  HEMRoomCheckViewController.m
//  Sense
//
//  Created by Jimmy Lu on 12/3/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//
#import "markdown_peg.h"

#import <SenseKit/SENSensor.h>
#import <SenseKit/SENSensorStatus.h>

#import "UIFont+HEMStyle.h"
#import "UIColor+HEMStyle.h"


#import "HEMRoomCheckViewController.h"
#import "HEMActionButton.h"
#import "HEMRoomCheckView.h"
#import "HEMMarkdown.h"
#import "HEMSensorService.h"
#import "HEMSensorValueFormatter.h"

static CGFloat const HEMRoomCheckAnimationDuration = 0.5f;

@interface HEMRoomCheckViewController() <HEMRoomCheckDelegate>

@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIView *buttonContainer;
@property (weak, nonatomic) IBOutlet HEMActionButton *startButton;
@property (weak, nonatomic) IBOutlet UIImageView *illustrationView;
@property (weak, nonatomic) IBOutlet UIView *resultsContainer;
@property (weak, nonatomic) IBOutlet UILabel *resultsTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *resultsDescriptionLabel;
@property (weak, nonatomic) IBOutlet HEMActionButton *nextButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *resultsHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *resultsBottomConstraint;

@property (assign, nonatomic) BOOL sensorsOk;
@property (strong, nonatomic) HEMRoomCheckView* roomCheckView;
@property (strong, nonatomic) HEMSensorService* sensorService;
@property (strong, nonatomic) HEMSensorValueFormatter* valueFormatter;

@end

@implementation HEMRoomCheckViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureRoomCheckView];
    [self enableBackButton:NO];
    [self trackAnalyticsEvent:HEMAnalyticsEventRoomCheck];
    
    // use the time during room check to see if DFU is required for later
    [[HEMOnboardingService sharedService] checkIfSenseDFUIsRequired];
}

- (void)configureRoomCheckView {
    [self setValueFormatter:[HEMSensorValueFormatter new]];
    [self setSensorsOk:YES];
    
    if (![self sensors]) {
        HEMOnboardingService* onbService = [HEMOnboardingService sharedService];
        [self setSensors:[onbService sensors]];
    }
    
    [self setRoomCheckView:[HEMRoomCheckView createRoomCheckViewWithFrame:[[self view] bounds]]];
    [[self roomCheckView] setAlpha:0.0f];
    [[self roomCheckView] setDelegate:self];
    [[self view] insertSubview:[self roomCheckView] atIndex:0];
    
    [[self resultsDescriptionLabel] setAlpha:0.0f];
    [[self resultsDescriptionLabel] setFont:[UIFont body]];
    [[self resultsDescriptionLabel] setTextColor:[UIColor grey4]];
    [[self resultsTitleLabel] setAlpha:0.0f];
    [[self resultsTitleLabel] setFont:[UIFont h4]];
    [[self resultsTitleLabel] setTextColor:[UIColor grey6]];
}

- (NSString*)imageName:(NSString*)imageName
withColorFromCondition:(SENCondition)condition
          defaultColor:(nullable NSString*)defaultColor {
    NSString* name = [imageName copy];
    switch (condition) {
        case SENConditionAlert:
            name = [name stringByAppendingString:@"Red"];
            break;
        case SENConditionWarning:
            name = [name stringByAppendingString:@"Yellow"];
            break;
        case SENConditionIdeal:
            name = [name stringByAppendingString:@"Green"];
            break;
        default:
            if (defaultColor) {
                name = [name stringByAppendingString:defaultColor];
            }
            break;
    }
    return name;
}

- (UIImage*)iconForSensor:(SENSensor*)sensor forState:(HEMRoomCheckState)state {
    SENCondition condition = [sensor condition];
    NSString* iconImageName = [[[sensor typeStringValue] lowercaseString] stringByAppendingString:@"Icon"];
    NSString* defaultColor = @"Gray";
    switch (state) {
        case HEMRoomCheckStateLoading:
        case HEMRoomCheckStateLoaded: {
            iconImageName = [self imageName:iconImageName withColorFromCondition:condition defaultColor:defaultColor];
            break;
        }
        case HEMRoomCheckStateWaiting:
        default:
            iconImageName = [iconImageName stringByAppendingString:@"Gray"];
            break;
    }
    
    return [UIImage imageNamed:iconImageName];
}

- (UIImage*)senseImageForSensorCondition:(SENCondition)condition  {
    return [UIImage imageNamed:[self imageName:@"sense"
                        withColorFromCondition:condition
                                  defaultColor:nil]];
}

- (UIImage*)sensorActivityImageForSensorCondition:(SENCondition)condition {
    return [UIImage imageNamed:[self imageName:@"sensorLoader"
                        withColorFromCondition:condition
                                  defaultColor:@"Gray"]];
}

- (SENCondition)averageConditionForAllSensors {
    if ([[self sensors] count] == 0) {
        return SENConditionUnknown;
    }
    
    SENCondition condition = SENConditionIdeal;
    for (SENSensor* sensor in [self sensors]) {
        SENCondition sensorCondition = [sensor condition];
        if (sensorCondition < condition) {
            condition = sensorCondition;
        }
     }
    
    return condition;
}

- (void)adjustResultsHeight {
    UIView* sensorContainer = [[self roomCheckView] sensorContainerView];
    CGRect messageFrame = [sensorContainer convertRect:[sensorContainer bounds] toView:[self view]];
    CGFloat viewHeight = CGRectGetHeight([[self view] bounds]);
    CGFloat resultsHeight = viewHeight - CGRectGetMinY(messageFrame);
    [[self resultsHeightConstraint] setConstant:resultsHeight];
    [[self resultsBottomConstraint] setConstant:-resultsHeight];
}

- (void)adjustConstraintsForIphone5 {
    [[self roomCheckView] adjustForiPhone5];
}

- (void)adjustConstraintsForIPhone4 {
    [[self roomCheckView] adjustForiPhone4];
}

#pragma mark - HEMRoomCheckDelegate

- (NSUInteger)numberOfSensorsInRoomCheckView:(HEMRoomCheckView*)roomCheckView {
    return [[self sensors] count];
}

- (UIImage*)sensorIconImageAtIndex:(NSUInteger)sensorIndex
                          forState:(HEMRoomCheckState)state
                   inRoomCheckView:(HEMRoomCheckView*)roomCheckView {
    return [self iconForSensor:[self sensors][sensorIndex] forState:state];
}

- (UIImage*)senseImageForSensorAtIndex:(NSUInteger)sensorIndex
                              forState:(HEMRoomCheckState)state
                       inRoomCheckView:(HEMRoomCheckView *)roomCheckView {
    SENCondition condition = SENConditionUnknown;
    
    if (state != HEMRoomCheckStateWaiting) {
        if (sensorIndex == [[self sensors] count] - 1) {
            condition = [self averageConditionForAllSensors];
        } else {
            SENSensor* sensor = [self sensors][sensorIndex];
            condition = [sensor condition];
        }
    }

    return [self senseImageForSensorCondition:condition];
}

- (NSString*)sensorNameAtIndex:(NSUInteger)sensorIndex inRoomCheckView:(HEMRoomCheckView *)roomCheckView {
    SENSensor* sensor = [self sensors][sensorIndex];
    return [sensor localizedName];
}

- (NSString*)sensorMessageAtIndex:(NSUInteger)sensorIndex inRoomCheckView:(HEMRoomCheckView*)roomCheckView {
    SENSensor* sensor = [self sensors][sensorIndex];
    return [sensor localizedMessage];
}

- (NSInteger)sensorValueAtIndex:(NSUInteger)sensorIndex inRoomCheckView:(HEMRoomCheckView*)roomCheckView {
    SENSensor* sensor = [self sensors][sensorIndex];
    return [[sensor value] integerValue];
}

- (NSString*)sensorValueUnitAtIndex:(NSUInteger)sensorIndex inRoomCheckView:(HEMRoomCheckView*)roomCheckView {
    SENSensor* sensor = [self sensors][sensorIndex];
    [[self valueFormatter] setUnicodeUnitSymbol:NO];
    [[self valueFormatter] setSensorUnit:[sensor unit]];
    return [[self valueFormatter] unitSymbol];
}

- (BOOL)sensorValueUnitAsSubscriptAtIndex:(NSUInteger)sensorIndex
                              inRoomCheck:(HEMRoomCheckView*)roomCheckView {
    SENSensor* sensor = [self sensors][sensorIndex];
    return [sensor type] != SENSensorTypeTemp;
}

- (UIFont*)sensorValueUnitFontAtIndex:(NSUInteger)sensorIndex inRoomCheckView:(HEMRoomCheckView*)roomCheckView {
    SENSensor* sensor = [self sensors][sensorIndex];
    return [UIFont sensorUnitFontForUnit:[sensor unit]];
}

- (UIColor*)sensorValueColorAtIndex:(NSUInteger)sensorIndex inRoomCheckView:(HEMRoomCheckView*)roomCheckView {
    SENSensor* sensor = [self sensors][sensorIndex];
    SENCondition condition = [sensor condition];
    return [UIColor colorForCondition:condition];
}

- (UIImage*)sensorActivityImageForSensorAtIndex:(NSUInteger)sensorIndex inRoomCheckView:(HEMRoomCheckView *)roomCheckView {
    SENSensor* sensor = [self sensors][sensorIndex];
    SENCondition condition =[sensor condition];
    return [self sensorActivityImageForSensorCondition:condition];
}

#pragma mark - Content Display

- (void)hideContent:(void(^)(BOOL finished))completion {
    [self setTitle:nil]; // make sure title is also not shown, if showing in navbar
    
    [UIView animateWithDuration:HEMRoomCheckAnimationDuration
                     animations:^{
                         [[self roomCheckView] setAlpha:1.0f];
                         [[self contentView] setAlpha:0.0f];
                         [[self buttonContainer] setAlpha:0.0f];
                     }
                     completion:completion];
}

- (void)showResults {
    [self adjustResultsHeight];
    [[self resultsDescriptionLabel] setAlpha:0.0f];
    [[self resultsTitleLabel] setAlpha:0.0f];
    [UIView animateWithDuration:HEMRoomCheckAnimationDuration animations:^{
        [[self resultsDescriptionLabel] setAlpha:1.0f];
        [[self resultsTitleLabel] setAlpha:1.0f];
        [[self resultsBottomConstraint] setConstant:0.0f];
        [[self view] layoutIfNeeded];
    }];
}

#pragma mark - Actions

- (IBAction)start:(id)sender {
    [self hideContent:^(BOOL finished) {
        [[self roomCheckView] animate:^{
            [self showResults];
        }];
    }];
}

@end
