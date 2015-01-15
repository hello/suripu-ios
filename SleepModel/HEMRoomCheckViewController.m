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

#import "HEMRoomCheckViewController.h"
#import "HEMScrollableView.h"
#import "HelloStyleKit.h"
#import "HEMOnboardingUtils.h"
#import "HEMActionButton.h"
#import "HEMSensorCheckView.h"
#import "UIColor+HEMStyle.h"
#import "HEMMarkdown.h"

static CGFloat const HEMRoomCheckImageYOffset = 50.0f;
static CGFloat const HEMRoomCheckShowSensorDelay = 1.0f;
static CGFloat const HEMRoomCheckDataDisplayTime = 2.0f;
static CGFloat const HEMRoomCheckMinVerticalPadding = 28.0f;
static CGFloat const HEMRoomCheckAnimationDuration = 0.5f;

static CGFloat const HEMRoomCheckMinimumExpandedHeight = 320.0f;

@interface HEMRoomCheckViewController()

@property (weak, nonatomic) IBOutlet HEMScrollableView *contentView;
@property (weak, nonatomic) IBOutlet UIView *buttonContainer;
@property (weak, nonatomic) IBOutlet HEMActionButton *startButton;

@property (strong, nonatomic) NSMutableArray* sensorViews;
@property (assign, nonatomic) CGFloat currentTopY;
@property (assign, nonatomic) BOOL sensorsOk;

@property (weak, nonatomic) IBOutlet UIView *resultView;
@property (weak, nonatomic) IBOutlet UIView *resultSeparator;
@property (weak, nonatomic) IBOutlet UILabel *resultTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *resultMessageLabel;
@property (weak, nonatomic) IBOutlet HEMActionButton *nextButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *resultHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *resultBottomConstraint;

@end

@implementation HEMRoomCheckViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[self navigationItem] setHidesBackButton:YES];
    [self setSensorsOk:YES];
    [self setCurrentTopY:HEMRoomCheckMinVerticalPadding];
    [self setupContent];
    [self enableBackButton:NO];
    [SENAnalytics track:kHEMAnalyticsEventOnBRoomCheck];
}

- (void)setupContent {
    NSString* desc = NSLocalizedString(@"onboarding.room-check.description", nil);
    NSMutableAttributedString* attrText =
        [[NSMutableAttributedString alloc] initWithString:desc];
    [HEMOnboardingUtils applyCommonDescriptionAttributesTo:attrText];
    
    [[self contentView] addTitle:NSLocalizedString(@"onboarding.room-check.title", nil)];
    [[self contentView] addDescription:attrText];
    [[self contentView] addImage:[HelloStyleKit sensePlacement] withYOffset:HEMRoomCheckImageYOffset];
    
    CGRect resultSeparatorFrame = [[self resultSeparator] frame];
    resultSeparatorFrame.size.height = 0.5f;
    [[self resultSeparator] setFrame:resultSeparatorFrame];
}

#pragma mark - Sensor Messages

- (NSAttributedString*)messageForSensor:(SENSensor*)sensor {
    NSMutableAttributedString* attrMessage = nil;
    if ([sensor condition] == SENSensorConditionIdeal) {
        NSString* format = NSLocalizedString(@"onboarding.room-check.ideal-condition-format", nil);
        NSString* message = [NSString stringWithFormat:format, [sensor localizedName]];
        attrMessage = [self attributedMessage:message];
    } else {
        UIColor* color = [UIColor colorForSensorWithCondition:[sensor condition]];
        NSDictionary* statusAttributes = [HEMMarkdown attributesForRoomCheckWithConditionColor:color];
        
        attrMessage = markdown_to_attr_string([sensor message], 0, statusAttributes);
        NSMutableParagraphStyle* paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        [paragraphStyle setAlignment:NSTextAlignmentCenter];
        [attrMessage addAttribute:NSParagraphStyleAttributeName
                            value:paragraphStyle
                            range:NSMakeRange(0, [attrMessage length])];
    }
    
    return attrMessage;
}

- (NSMutableAttributedString*)attributedMessage:(NSString*)message {
    NSMutableParagraphStyle* paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setAlignment:NSTextAlignmentCenter];
    
    NSDictionary* attributes = @{NSFontAttributeName : [UIFont onboardingRoomCheckSensorFont],
                                 NSForegroundColorAttributeName : [UIColor blackColor],
                                 NSParagraphStyleAttributeName : paragraphStyle};
    
    return [[NSMutableAttributedString alloc] initWithString:message attributes:attributes];
}

#pragma mark - Content Display

- (void)hideContent:(void(^)(BOOL finished))completion {
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

- (void)showSensors:(void(^)(BOOL finished))completion {
    CGFloat totalCollapsedHeight = HEMSensorCheckCollapsedHeight * 5;
    CGFloat nextY = (CGRectGetHeight([[self view] bounds]) - totalCollapsedHeight)/2;
    NSArray* sensors = [SENSensor sensors];
    for (SENSensor* sensor in sensors) {
        if ([sensor unit] != SENSensorUnitUnknown) {
            [self setSensorsOk:[self sensorsOk] && [sensor condition] != SENSensorConditionUnknown];
            nextY += CGRectGetHeight([[self addSensorViewFor:sensor atY:nextY] bounds]);
        }
    }
    
    // show each sensor view in collapsed state
    [UIView animateWithDuration:HEMRoomCheckAnimationDuration
                     animations:^{
                         for (UIView* view in [self sensorViews]) {
                             [view setAlpha:1.0f];
                         }
                     }
                     completion:completion];
    
}

- (HEMSensorCheckView*)addSensorViewFor:(SENSensor*)sensor atY:(CGFloat)yOrigin {
    UIImage* icon = nil;
    UIImage* highlightedIcon = nil;
    NSString* intro = nil;

    switch ([sensor unit]) {
        case SENSensorUnitAQI: {
            icon = [HelloStyleKit sensorParticulates];
            intro = NSLocalizedString(@"onboarding.room-check.intro.air", nil);
            highlightedIcon = [HelloStyleKit sensorParticulatesBlue];
            break;
        }
        case SENSensorUnitDegreeCentigrade: {
            icon = [HelloStyleKit sensorTemperature];
            intro = NSLocalizedString(@"onboarding.room-check.intro.temperature", nil);
            highlightedIcon = [HelloStyleKit sensorTemperatureBlue];
            break;
        }
        case SENSensorUnitPercent: {
            icon = [HelloStyleKit sensorHumidity];
            intro = NSLocalizedString(@"onboarding.room-check.intro.humidity", nil);
            highlightedIcon = [HelloStyleKit sensorHumidityBlue];
            break;
        }
        case SENSensorUnitLux: {
            icon = [HelloStyleKit sensorLight];
            intro = NSLocalizedString(@"onboarding.room-check.intro.light", nil);
            highlightedIcon = [HelloStyleKit sensorLightBlue];
            break;
        }
        case SENSensorUnitDecibel: {
            icon = [HelloStyleKit sensorSound];
            intro = NSLocalizedString(@"onboarding.room-check.intro.sound", nil);
            highlightedIcon = [HelloStyleKit sensorSoundBlue];
        }
        default:
            break;
    }
    
    return [self addSensorViewWithIcon:icon
                       highlightedIcon:highlightedIcon
                                  name:[sensor localizedName]
                               message:[self messageForSensor:sensor]
                          introMessage:intro
                                 value:[[sensor valueInPreferredUnit] integerValue]
                         andValueColor:[UIColor colorForSensorWithCondition:[sensor condition]]
                              withUnit:[sensor localizedUnit]
                                   atY:yOrigin];
}

- (HEMSensorCheckView*)addSensorViewWithIcon:(UIImage*)icon
                             highlightedIcon:(UIImage*)highlightedIcon
                                        name:(NSString*)name
                                     message:(NSAttributedString*)message
                                introMessage:(NSString*)introMessage
                                       value:(NSInteger)value
                               andValueColor:(UIColor*)color
                                    withUnit:(NSString*)unit
                                         atY:(CGFloat)yOrigin {
    
    NSString* titleFormat = NSLocalizedString(@"onboarding.room-check.checking-sensor.format", nil);
    NSString* title = [NSString stringWithFormat:titleFormat, name];
    
    HEMSensorCheckView* view = [[HEMSensorCheckView alloc] initWithIcon:icon
                                                        highlightedIcon:highlightedIcon
                                                                  title:title
                                                                message:message
                                                           introMessage:introMessage
                                                                  value:value
                                                     withConditionColor:color
                                                                   unit:unit];
    
    CGRect frame = [view frame];
    frame.origin.y = yOrigin;
    [view setFrame:frame];
    [view setAlpha:0.0f];
    
    if ([self sensorViews] == nil) {
        [self setSensorViews:[NSMutableArray array]];
    }
    [[self sensorViews] addObject:view];
    
    [[self view] addSubview:view];
    
    return view;
}

- (void)showResult {
    if (![self sensorsOk]) {
        [[self resultTitleLabel] setText:NSLocalizedString(@"onboarding.room-check.failed", nil)];
        [[self resultMessageLabel] setText:NSLocalizedString(@"onboarding.room-check.failed-message", nil)];
    }
    
    HEMSensorCheckView* view = [[self sensorViews] lastObject];
    CGFloat viewY = CGRectGetMinY([view frame]);
    CGFloat configuredHeight = [[self resultHeightConstraint] constant];
    CGFloat statusHeight = CGRectGetHeight([[UIApplication sharedApplication] statusBarFrame]);
    
    [UIView animateWithDuration:HEMRoomCheckAnimationDuration
                     animations:^{
                         [view collapse];
                         
                         CGFloat bHeight = CGRectGetHeight([[self view] bounds]);
                         CGFloat remainingHeight
                            = bHeight
                            - viewY
                            - HEMSensorCheckCollapsedHeight
                            - HEMRoomCheckMinVerticalPadding;
                         CGFloat resultHeight = remainingHeight;
                         
                         if (remainingHeight < configuredHeight) {
                             resultHeight = configuredHeight;
                             CGFloat diff = configuredHeight - remainingHeight;
                             for (HEMSensorCheckView* sensorView in [self sensorViews]) {
                                 CGRect frame = [sensorView frame];
                                 frame.origin.y -= diff;
                                 [sensorView setFrame:frame];
                                 
                                 CGFloat y = CGRectGetMinY(frame);
                                 if (y < statusHeight) {
                                     CGFloat percentageOff = (fabsf(y)/CGRectGetHeight(frame)) * 2; // 2 to make it fade sooner
                                     [sensorView setAlpha:1-percentageOff];
                                 }
                             }
                         }
                         
                         [[self resultHeightConstraint] setConstant:resultHeight];
                         [[self resultBottomConstraint] setConstant:0.0f];
                         [[self view] layoutIfNeeded];
                     }];
}

- (CGFloat)minimumYForLastSensorInCollapsedState {
    CGFloat totalSensors = [[self sensorViews] count];
    CGFloat collapsedSensors = totalSensors - 1; // first 1 will be expanded
    CGFloat lastCollapsedY = (collapsedSensors - 1) * HEMSensorCheckCollapsedHeight;
    return [self currentTopY]
            + HEMRoomCheckMinimumExpandedHeight
            + lastCollapsedY;
}

- (void)moveOtherSensorsDownToMakeRoom {
    CGFloat bHeight = CGRectGetHeight([[self view] bounds]);
    CGFloat lastSensorYOffset = HEMSensorCheckCollapsedHeight - HEMRoomCheckMinVerticalPadding;
    CGFloat suggestedMinY = bHeight - lastSensorYOffset;
    CGFloat requiredMinY = [self minimumYForLastSensorInCollapsedState];
    CGFloat y = MAX(suggestedMinY, requiredMinY);
    
    for (NSInteger i = [[self sensorViews] count] - 1; i > 0; i--) {
        UIView* otherView = [self sensorViews][i];
        
        CGRect frame = [otherView frame];
        frame.origin.y = y;
        [otherView setFrame:frame];
        
        y -= CGRectGetHeight([otherView bounds]);
    }
}

- (void)displaySensorDataAtIndex:(NSInteger)index {
    NSInteger sensorCount = [[self sensorViews] count];
    if (index == sensorCount) {
        [self showResult];
        return;
    }
    
    HEMSensorCheckView* view = [self sensorViews][index];
    
    NSInteger collapsedCount = sensorCount - index + 1;
    CGFloat bHeight = CGRectGetHeight([[self view] bounds]);
    CGFloat viewHeight
        = bHeight
        - [self currentTopY]
        - HEMRoomCheckMinVerticalPadding
        - ((collapsedCount-1)*HEMSensorCheckCollapsedHeight);
    viewHeight = MAX(viewHeight, HEMRoomCheckMinimumExpandedHeight);
    
    if (index == sensorCount - 1) { // last
        viewHeight = bHeight - [self currentTopY];
    }
    
    [view moveTo:[self currentTopY] andExpandTo:viewHeight whileAnimating:^{
        for (NSInteger prevIndex = 0; prevIndex < index; prevIndex++) {
            HEMSensorCheckView* prevView = [self sensorViews][prevIndex];
            [prevView collapse];
        }
        
        if (index == 0) {
            [self moveOtherSensorsDownToMakeRoom];
        }
    } onCompletion:^(BOOL finished) {
        [self setCurrentTopY:[self currentTopY] + HEMSensorCheckCollapsedHeight];
        [view showSensorValue:^{
            int64_t delaySecs = (int64_t)(HEMRoomCheckDataDisplayTime * NSEC_PER_SEC);
            dispatch_time_t delay = dispatch_time(DISPATCH_TIME_NOW, delaySecs);
            dispatch_after(delay, dispatch_get_main_queue(), ^{
                [self displaySensorDataAtIndex:index + 1];
            });
        }];
        
    }];
}

#pragma mark - Actions

- (IBAction)start:(id)sender {
    [self hideContent:^(BOOL finished) {
        [self showSensors:^(BOOL finished) {
            int64_t delaySecs = (int64_t)(HEMRoomCheckShowSensorDelay * NSEC_PER_SEC);
            dispatch_time_t delay = dispatch_time(DISPATCH_TIME_NOW, delaySecs);
            dispatch_after(delay, dispatch_get_main_queue(), ^{
                [self displaySensorDataAtIndex:0];
            });
        }];
    }];
}

@end
