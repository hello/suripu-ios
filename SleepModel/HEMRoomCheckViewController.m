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

static CGFloat const HEMRoomCheckAnimationDuration = 0.5f;

@interface HEMRoomCheckViewController() <HEMRoomCheckDelegate>

@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIView *buttonContainer;
@property (weak, nonatomic) IBOutlet HEMActionButton *startButton;
@property (weak, nonatomic) IBOutlet UIImageView *illustrationView;

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
    [[self roomCheckView] setDelegate:self];
    [[self view] insertSubview:[self roomCheckView] atIndex:0];
}

- (UIImage*)iconForSensor:(SENSensor*)sensor forState:(HEMRoomCheckState)state {
    NSString* iconImageName = [[[sensor name] lowercaseString] stringByAppendingString:@"Icon"];

    if (state == HEMRoomCheckStateWaiting) {
        iconImageName = [iconImageName stringByAppendingString:@"Gray"];
    } else if (state == HEMRoomCheckStateLoading) {
        iconImageName = [iconImageName stringByAppendingString:@"Blue"];
    } else if (state == HEMRoomCheckStateLoaded) {
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

#pragma mark - HEMRoomCheckDelegate

- (NSUInteger)numberOfSensorsInRoomCheckView:(HEMRoomCheckView*)roomCheckView {
    return [[self sensors] count];
}

- (UIImage*)sensorIconImageAtIndex:(NSUInteger)sensorIndex
                          forState:(HEMRoomCheckState)state
                   inRoomCheckView:(HEMRoomCheckView*)roomCheckView {
    return [self iconForSensor:[self sensors][sensorIndex] forState:state];
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
    return [[sensor value] integerValue];
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
//
//- (void)showSensors:(void(^)(BOOL finished))completion {
//    CGFloat totalCollapsedHeight = HEMSensorCheckCollapsedHeight * 5;
//    CGFloat nextY = (CGRectGetHeight([[self view] bounds]) - totalCollapsedHeight)/2;
//    NSArray* sensors = [SENSensor sensors];
//    for (SENSensor* sensor in sensors) {
//        if ([sensor unit] != SENSensorUnitUnknown) {
//            [self setSensorsOk:[self sensorsOk] && [sensor condition] != SENSensorConditionUnknown];
//            nextY += CGRectGetHeight([[self addSensorViewFor:sensor atY:nextY] bounds]);
//        }
//    }
//    
//    // show each sensor view in collapsed state
//    [UIView animateWithDuration:HEMRoomCheckAnimationDuration
//                     animations:^{
//                         for (UIView* view in [self sensorViews]) {
//                             [view setAlpha:1.0f];
//                         }
//                     }
//                     completion:completion];
//    
//}
//
//- (HEMSensorCheckView*)addSensorViewFor:(SENSensor*)sensor atY:(CGFloat)yOrigin {
//    UIImage* icon = nil;
//    UIImage* highlightedIcon = nil;
//    NSString* intro = nil;
//
//    switch ([sensor unit]) {
//        case SENSensorUnitAQI: {
//            icon = [HelloStyleKit sensorParticulates];
//            intro = NSLocalizedString(@"onboarding.room-check.intro.air", nil);
//            highlightedIcon = [HelloStyleKit sensorParticulatesBlue];
//            break;
//        }
//        case SENSensorUnitDegreeCentigrade: {
//            icon = [HelloStyleKit sensorTemperature];
//            intro = NSLocalizedString(@"onboarding.room-check.intro.temperature", nil);
//            highlightedIcon = [HelloStyleKit sensorTemperatureBlue];
//            break;
//        }
//        case SENSensorUnitPercent: {
//            icon = [HelloStyleKit sensorHumidity];
//            intro = NSLocalizedString(@"onboarding.room-check.intro.humidity", nil);
//            highlightedIcon = [HelloStyleKit sensorHumidityBlue];
//            break;
//        }
//        case SENSensorUnitLux: {
//            icon = [HelloStyleKit sensorLight];
//            intro = NSLocalizedString(@"onboarding.room-check.intro.light", nil);
//            highlightedIcon = [HelloStyleKit sensorLightBlue];
//            break;
//        }
//        case SENSensorUnitDecibel: {
//            icon = [HelloStyleKit sensorSound];
//            intro = NSLocalizedString(@"onboarding.room-check.intro.sound", nil);
//            highlightedIcon = [HelloStyleKit sensorSoundBlue];
//            break;
//        }
//        default:
//            break;
//    }
//    
//    return [self addSensorViewWithIcon:icon
//                       highlightedIcon:highlightedIcon
//                                  name:[sensor localizedName]
//                               message:[self messageForSensor:sensor]
//                          introMessage:intro
//                                 value:[[sensor valueInPreferredUnit] integerValue]
//                         andValueColor:[UIColor colorForSensorWithCondition:[sensor condition]]
//                              withUnit:[sensor localizedUnit]
//                                   atY:yOrigin];
//}
//
//- (HEMSensorCheckView*)addSensorViewWithIcon:(UIImage*)icon
//                             highlightedIcon:(UIImage*)highlightedIcon
//                                        name:(NSString*)name
//                                     message:(NSAttributedString*)message
//                                introMessage:(NSString*)introMessage
//                                       value:(NSInteger)value
//                               andValueColor:(UIColor*)color
//                                    withUnit:(NSString*)unit
//                                         atY:(CGFloat)yOrigin {
//    
//    NSString* titleFormat = NSLocalizedString(@"onboarding.room-check.checking-sensor.format", nil);
//    NSString* title = [NSString stringWithFormat:titleFormat, name];
//    
//    HEMSensorCheckView* view = [[HEMSensorCheckView alloc] initWithIcon:icon
//                                                        highlightedIcon:highlightedIcon
//                                                                  title:title
//                                                                message:message
//                                                           introMessage:introMessage
//                                                                  value:value
//                                                     withConditionColor:color
//                                                                   unit:unit];
//    
//    CGRect frame = [view frame];
//    frame.origin.y = yOrigin;
//    [view setFrame:frame];
//    [view setAlpha:0.0f];
//    
//    if ([self sensorViews] == nil) {
//        [self setSensorViews:[NSMutableArray array]];
//    }
//    [[self sensorViews] addObject:view];
//    
//    [[self view] addSubview:view];
//    
//    return view;
//}
//
//- (void)showResult {
//    if (![self sensorsOk]) {
//        [[self resultTitleLabel] setText:NSLocalizedString(@"onboarding.room-check.failed", nil)];
//        [[self resultMessageLabel] setText:NSLocalizedString(@"onboarding.room-check.failed-message", nil)];
//    }
//    
//    HEMSensorCheckView* view = [[self sensorViews] lastObject];
//    CGFloat viewY = CGRectGetMinY([view frame]);
//    CGFloat configuredHeight = [[self resultHeightConstraint] constant];
//    CGFloat statusHeight = CGRectGetHeight([[UIApplication sharedApplication] statusBarFrame]);
//    
//    [UIView animateWithDuration:HEMRoomCheckAnimationDuration
//                     animations:^{
//                         [view collapse];
//                         
//                         CGFloat bHeight = CGRectGetHeight([[self view] bounds]);
//                         CGFloat remainingHeight
//                            = bHeight
//                            - viewY
//                            - HEMSensorCheckCollapsedHeight
//                            - HEMRoomCheckMinVerticalPadding;
//                         CGFloat resultHeight = remainingHeight;
//                         
//                         if (remainingHeight < configuredHeight) {
//                             resultHeight = configuredHeight;
//                             CGFloat diff = configuredHeight - remainingHeight;
//                             for (HEMSensorCheckView* sensorView in [self sensorViews]) {
//                                 CGRect frame = [sensorView frame];
//                                 frame.origin.y -= diff;
//                                 [sensorView setFrame:frame];
//                                 
//                                 CGFloat y = CGRectGetMinY(frame);
//                                 if (y < statusHeight) {
//                                     CGFloat percentageOff = (fabsf(y)/CGRectGetHeight(frame)) * 2; // 2 to make it fade sooner
//                                     [sensorView setAlpha:1-percentageOff];
//                                 }
//                             }
//                         }
//                         
//                         [[self resultHeightConstraint] setConstant:resultHeight];
//                         [[self resultBottomConstraint] setConstant:0.0f];
//                         [[self view] layoutIfNeeded];
//                     }];
//}
//
//- (CGFloat)minimumYForLastSensorInCollapsedState {
//    CGFloat totalSensors = [[self sensorViews] count];
//    CGFloat collapsedSensors = totalSensors - 1; // first 1 will be expanded
//    CGFloat lastCollapsedY = (collapsedSensors - 1) * HEMSensorCheckCollapsedHeight;
//    return [self currentTopY]
//            + HEMRoomCheckMinimumExpandedHeight
//            + lastCollapsedY;
//}
//
//- (void)moveOtherSensorsDownToMakeRoom {
//    CGFloat bHeight = CGRectGetHeight([[self view] bounds]);
//    CGFloat lastSensorYOffset = HEMSensorCheckCollapsedHeight - HEMRoomCheckMinVerticalPadding;
//    CGFloat suggestedMinY = bHeight - lastSensorYOffset;
//    CGFloat requiredMinY = [self minimumYForLastSensorInCollapsedState];
//    CGFloat y = MAX(suggestedMinY, requiredMinY);
//    
//    for (NSInteger i = [[self sensorViews] count] - 1; i > 0; i--) {
//        UIView* otherView = [self sensorViews][i];
//        
//        CGRect frame = [otherView frame];
//        frame.origin.y = y;
//        [otherView setFrame:frame];
//        
//        y -= CGRectGetHeight([otherView bounds]);
//    }
//}
//
//- (void)displaySensorDataAtIndex:(NSInteger)index {
//    NSInteger sensorCount = [[self sensorViews] count];
//    if (index == sensorCount) {
//        [self showResult];
//        return;
//    }
//    
//    HEMSensorCheckView* view = [self sensorViews][index];
//    
//    NSInteger collapsedCount = sensorCount - index + 1;
//    CGFloat bHeight = CGRectGetHeight([[self view] bounds]);
//    CGFloat viewHeight
//        = bHeight
//        - [self currentTopY]
//        - HEMRoomCheckMinVerticalPadding
//        - ((collapsedCount-1)*HEMSensorCheckCollapsedHeight);
//    viewHeight = MAX(viewHeight, HEMRoomCheckMinimumExpandedHeight);
//    
//    if (index == sensorCount - 1) { // last
//        viewHeight = bHeight - [self currentTopY];
//    }
//    
//    [view moveTo:[self currentTopY] andExpandTo:viewHeight whileAnimating:^{
//        for (NSInteger prevIndex = 0; prevIndex < index; prevIndex++) {
//            HEMSensorCheckView* prevView = [self sensorViews][prevIndex];
//            [prevView collapse];
//        }
//        
//        if (index == 0) {
//            [self moveOtherSensorsDownToMakeRoom];
//        }
//    } onCompletion:^(BOOL finished) {
//        [self setCurrentTopY:[self currentTopY] + HEMSensorCheckCollapsedHeight];
//        [view showSensorValue:^{
//            int64_t delaySecs = (int64_t)(HEMRoomCheckDataDisplayTime * NSEC_PER_SEC);
//            dispatch_time_t delay = dispatch_time(DISPATCH_TIME_NOW, delaySecs);
//            dispatch_after(delay, dispatch_get_main_queue(), ^{
//                [self displaySensorDataAtIndex:index + 1];
//            });
//        }];
//        
//    }];
//}

#pragma mark - Actions

- (IBAction)start:(id)sender {
    [self hideContent:^(BOOL finished) {
        [[self roomCheckView] animate];
    }];
}

@end
