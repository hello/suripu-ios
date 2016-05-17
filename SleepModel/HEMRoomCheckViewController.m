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
#import "HEMActionButton.h"
#import "HEMRoomCheckView.h"
#import "HEMMarkdown.h"

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
    
    [[self resultsDescriptionLabel] setAlpha:0.0f];
    [[self resultsTitleLabel] setAlpha:0.0f];
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
    NSString* iconImageName = [[[sensor name] lowercaseString] stringByAppendingString:@"Icon"];
    NSString* defaultColor = @"Gray";
    switch (state) {
        case HEMRoomCheckStateLoaded: {
            SENCondition condition = [sensor condition];
            iconImageName = [self imageName:iconImageName withColorFromCondition:condition defaultColor:defaultColor];
            break;
        }
        case HEMRoomCheckStateLoading: {
            SENCondition condition = [sensor condition];
            NSString* baseName = [iconImageName stringByAppendingString:@"NoBorder"];
            iconImageName = [self imageName:baseName withColorFromCondition:condition defaultColor:defaultColor];
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
        if ([sensor condition] < condition) {
            condition = [sensor condition];
        }
     }
    
    return condition;
}

- (void)updateViewConstraints {
    [super updateViewConstraints];
    
    UILabel* messageLabel = [[self roomCheckView] sensorMessageLabel];
    CGRect messageFrame = [messageLabel convertRect:[messageLabel bounds] toView:[self view]];
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

- (UIFont*)sensorValueUnitFontAtIndex:(NSUInteger)sensorIndex inRoomCheckView:(HEMRoomCheckView*)roomCheckView {
    SENSensor* sensor = [self sensors][sensorIndex];
    return [UIFont sensorUnitFontForUnit:[sensor unit]];
}

- (UIColor*)sensorValueColorAtIndex:(NSUInteger)sensorIndex inRoomCheckView:(HEMRoomCheckView*)roomCheckView {
    SENSensor* sensor = [self sensors][sensorIndex];
    return [UIColor colorForCondition:[sensor condition]];
}

- (UIImage*)sensorActivityImageForSensorAtIndex:(NSUInteger)sensorIndex inRoomCheckView:(HEMRoomCheckView *)roomCheckView {
    SENSensor* sensor = [self sensors][sensorIndex];
    return [self sensorActivityImageForSensorCondition:[sensor condition]];
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
