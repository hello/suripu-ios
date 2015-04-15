//
//  HEMRoomCheckViewController.m
//  Sense
//
//  Created by Jimmy Lu on 12/3/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//
#import <markdown_peg.h>

#import <SenseKit/SENSensor.h>

#import "UIFont+HEMStyle.h"
#import "UIColor+HEMStyle.h"

#import "HEMRoomCheckViewController.h"
#import "HelloStyleKit.h"
#import "HEMOnboardingUtils.h"
#import "HEMActionButton.h"
#import "HEMSensorCheckView.h"
#import "HEMRoomCheckView.h"
#import "HEMMarkdown.h"
#import "HEMBaseController+Protected.h"

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
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleTopConstraint;

@property (strong, nonatomic) NSArray* sensors;
@property (assign, nonatomic) BOOL sensorsOk;
@property (strong, nonatomic) HEMRoomCheckView* roomCheckView;

@end

@implementation HEMRoomCheckViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureRoomCheckView];
    [self enableBackButton:NO];
    [self trackAnalyticsEvent:HEMAnalyticsEventRoomCheck];
}

- (void)configureRoomCheckView {
    [self setSensorsOk:YES];
    [self setSensors:[SENSensor sensors]];
    
    [self setRoomCheckView:[HEMRoomCheckView createRoomCheckViewWithFrame:[[self view] bounds]]];
    [[self roomCheckView] setAlpha:0.0f];
    [[self roomCheckView] setDelegate:self];
    [[self view] insertSubview:[self roomCheckView] atIndex:0];
}

- (UIImage*)iconForSensor:(SENSensor*)sensor forState:(HEMRoomCheckState)state {
    NSString* iconImageName = [[[sensor name] lowercaseString] stringByAppendingString:@"Icon"];

    if (state != HEMRoomCheckStateLoaded) {
        iconImageName = [iconImageName stringByAppendingString:@"Gray"];
    } else {
        SENSensorCondition condition = [sensor condition];
        switch (condition) {
            case SENSensorConditionAlert:
                iconImageName = [iconImageName stringByAppendingString:@"Red"];
                break;
            case SENSensorConditionWarning:
                iconImageName = [iconImageName stringByAppendingString:@"Yellow"];
                break;
            case SENSensorConditionIdeal:
                iconImageName = [iconImageName stringByAppendingString:@"Green"];
                break;
            default:
                iconImageName = [iconImageName stringByAppendingString:@"Gray"];
                break;
        }
    }
    
    return [UIImage imageNamed:iconImageName];
}

- (UIImage*)senseImageForSensorCondition:(SENSensorCondition)condition  {
    NSString* imageName = @"roomcheckSense";
    switch (condition) {
        case SENSensorConditionAlert:
            imageName = [imageName stringByAppendingString:@"Red"];
            break;
        case SENSensorConditionIdeal:
            imageName = [imageName stringByAppendingString:@"Green"];
            break;
        case SENSensorConditionWarning:
            imageName = [imageName stringByAppendingString:@"Yellow"];
            break;
        default:
            imageName = [imageName stringByAppendingString:@"Gray"];
            break;
    }
    return [UIImage imageNamed:imageName];
}

- (SENSensorCondition)averageConditionForAllSensors {
    if ([[self sensors] count] == 0) {
        return SENSensorConditionUnknown;
    }
    
    NSUInteger averageConditionValue = 0;
    for (SENSensor* sensor in [self sensors]) {
        averageConditionValue += [sensor condition];
    }
    long roundedAverage = lroundf((averageConditionValue / [[self sensors] count]) + 0.5f);
    return [SENSensor conditionFromValue:@(roundedAverage)];
}

- (void)adjustConstraintsForIphone5 {
    [self updateConstraint:[self resultsHeightConstraint] withDiff:-40.0f];
    [[self roomCheckView] adjustForiPhone5];
}

- (void)adjustConstraintsForIPhone4 {
    [self updateConstraint:[self resultsHeightConstraint] withDiff:-60.0f];
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
    SENSensorCondition condition = SENSensorConditionUnknown;
    
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
    return [sensor name];
}

- (NSString*)sensorMessageAtIndex:(NSUInteger)sensorIndex inRoomCheckView:(HEMRoomCheckView*)roomCheckView {
    SENSensor* sensor = [self sensors][sensorIndex];
    return [sensor message];
}

- (NSInteger)sensorValueAtIndex:(NSUInteger)sensorIndex inRoomCheckView:(HEMRoomCheckView*)roomCheckView {
    SENSensor* sensor = [self sensors][sensorIndex];
    return [[sensor valueInPreferredUnit] integerValue];
}

- (NSString*)sensorValueUnitAtIndex:(NSUInteger)sensorIndex inRoomCheckView:(HEMRoomCheckView*)roomCheckView {
    SENSensor* sensor = [self sensors][sensorIndex];
    return [sensor localizedUnit];
}

- (UIColor*)sensorValueColorAtIndex:(NSUInteger)sensorIndex inRoomCheckView:(HEMRoomCheckView*)roomCheckView {
    SENSensor* sensor = [self sensors][sensorIndex];
    return [UIColor colorForSensorWithCondition:[sensor condition]];
}

#pragma mark - Sensor Messages

- (NSAttributedString*)messageForSensor:(SENSensor*)sensor {
    NSDictionary* statusAttributes = [HEMMarkdown attributesForRoomCheckSensorMessage];
    return markdown_to_attr_string([sensor message], 0, statusAttributes);
}

#pragma mark - Content Display

- (void)hideContent:(void(^)(BOOL finished))completion {
    [self setTitle:nil]; // make sure title is also not shown, if showing in navbar
    
    [UIView animateWithDuration:HEMRoomCheckAnimationDuration
                     animations:^{
                         [[self roomCheckView] setAlpha:1.0f];
                         
                         [[self contentView] setAlpha:0.0f];
                         CGRect contentFrame = [[self contentView] frame];
                         contentFrame.origin.y -= CGRectGetHeight(contentFrame)/2;
                         [[self contentView] setFrame:contentFrame];

                         [[self buttonContainer] setAlpha:0.0f];
                         CGRect containerFrame = [[self buttonContainer] frame];
                         containerFrame.origin.y += CGRectGetHeight(containerFrame)/2;
                         [[self buttonContainer] setFrame:containerFrame];
                     }
                     completion:completion];
}

- (void)showResults {
    [[self resultsDescriptionLabel] setAlpha:0.0f];
    [[self resultsTitleLabel] setAlpha:0.0f];
    [[self titleTopConstraint] setConstant:30.0f];
    [UIView animateWithDuration:HEMRoomCheckAnimationDuration animations:^{
        [[self resultsDescriptionLabel] setAlpha:1.0f];
        [[self resultsTitleLabel] setAlpha:1.0f];
        [[self resultsBottomConstraint] setConstant:0.0f];
        [[self titleTopConstraint] setConstant:0.0f];
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
