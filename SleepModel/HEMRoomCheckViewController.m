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
#import "HEMSensorUtils.h"

static CGFloat const HEMRoomCheckShowSensorDelay = 1.0f;
static CGFloat const HEMRoomCheckDataDisplayTime = 2.0f;
static CGFloat const HEMRoomCheckMinVerticalPadding = 28.0f;
static CGFloat const HEMRoomCheckAnimationDuration = 0.5f;

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
    
    [SENAnalytics track:kHEMAnalyticsEventOnBRoomCheck];
}

- (void)setupContent {
    NSString* desc = NSLocalizedString(@"onboarding.room-check.description", nil);
    NSMutableAttributedString* attrText =
        [[NSMutableAttributedString alloc] initWithString:desc];
    [HEMOnboardingUtils applyCommonDescriptionAttributesTo:attrText];
    
    [[self contentView] addTitle:NSLocalizedString(@"onboarding.room-check.title", nil)];
    [[self contentView] addImage:[HelloStyleKit sensePlacement]];
    [[self contentView] addDescription:attrText];
    
    CGRect resultSeparatorFrame = [[self resultSeparator] frame];
    resultSeparatorFrame.size.height = 0.5f;
    [[self resultSeparator] setFrame:resultSeparatorFrame];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    CGFloat shadowOpacity = [[self contentView] scrollRequired]?1.0f:0.0f;
    [[[self buttonContainer] layer] setShadowOpacity:shadowOpacity];
}

#pragma mark - Sensor Messages

- (NSAttributedString*)messageForSensor:(SENSensor*)sensor {
    NSMutableAttributedString* attrMessage = nil;
    if ([sensor condition] == SENSensorConditionIdeal) {
        NSString* format = NSLocalizedString(@"onboarding.room-check.ideal-condition-format", nil);
        NSString* message = [NSString stringWithFormat:format, [sensor localizedName]];
        attrMessage = [self attributedMessage:message];
    } else {
        UIColor* conditionColor = [HEMSensorUtils colorForSensorWithCondition:[sensor condition]];
        NSDictionary* statusAttributes = @{
            @(EMPH)  : @{ NSForegroundColorAttributeName : conditionColor},
            @(PLAIN) : @{ NSFontAttributeName : [UIFont onboardingRoomCheckSensorFont]}
        };
        
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
        [self setSensorsOk:[self sensorsOk] && [sensor condition] != SENSensorConditionUnknown];
        nextY += CGRectGetHeight([[self addSensorViewFor:sensor atY:nextY] bounds]);
    }
    
    // add a couple of placeholder sensors since we don't have them yet, but were
    // asked for by design.  probably will end up throwing this away soon after tho
    NSString* message = NSLocalizedString(@"sensor.sound.placeholder-message", nil);
    nextY += CGRectGetHeight([[self addSensorViewWithIcon:[HelloStyleKit sensorSound]
                                          highlightedIcon:[HelloStyleKit sensorSoundBlue]
                                                     name:NSLocalizedString(@"sensor.light", nil)
                                                  message:[self attributedMessage:message]
                                             introMessage:NSLocalizedString(@"onboarding.room-check.intro.sound", nil)
                                                    value:30
                                            andValueColor:[HEMSensorUtils colorForSensorWithCondition:SENSensorConditionIdeal]
                                                 withUnit:NSLocalizedString(@"measurement.db.unit", nil)
                                                      atY:nextY] bounds]);
    
    message = NSLocalizedString(@"sensor.light.placeholder-message", nil);
    [self addSensorViewWithIcon:[HelloStyleKit sensorLight]
                highlightedIcon:[HelloStyleKit sensorLightBlue]
                           name:NSLocalizedString(@"sensor.light", nil)
                        message:[self attributedMessage:message]
                   introMessage:NSLocalizedString(@"onboarding.room-check.intro.light", nil)
                          value:200
                  andValueColor:[HEMSensorUtils colorForSensorWithCondition:SENSensorConditionIdeal]
                       withUnit:NSLocalizedString(@"measurement.lx.unit", nil)
                            atY:nextY];
    
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
        default:
            break;
    }
    
    return [self addSensorViewWithIcon:icon
                       highlightedIcon:highlightedIcon
                                  name:[sensor localizedName]
                               message:[self messageForSensor:sensor]
                          introMessage:intro
                                 value:[[sensor value] integerValue]
                         andValueColor:[HEMSensorUtils colorForSensorWithCondition:[sensor condition]]
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
    
    [UIView animateWithDuration:HEMRoomCheckAnimationDuration
                     animations:^{
                         [view collapse];
                         
                         CGFloat bHeight = CGRectGetHeight([[self view] bounds]);
                         CGFloat remainingHeight
                            = bHeight
                            - viewY
                            - HEMSensorCheckCollapsedHeight
                            - HEMRoomCheckMinVerticalPadding;
                         
                         [[self resultHeightConstraint] setConstant:remainingHeight];
                         [[self resultBottomConstraint] setConstant:0.0f];
                         [[self view] layoutIfNeeded];
                     }];
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
    
    if (index == sensorCount - 1) { // last
        viewHeight = bHeight - [self currentTopY];
    }
    
    [view moveTo:[self currentTopY] andExpandTo:viewHeight whileAnimating:^{
        for (NSInteger prevIndex = 0; prevIndex < index; prevIndex++) {
            HEMSensorCheckView* prevView = [self sensorViews][prevIndex];
            [prevView collapse];
        }
        
        if (index == 0) {
            CGFloat minY = bHeight - HEMSensorCheckCollapsedHeight - HEMRoomCheckMinVerticalPadding;
            for (NSInteger i = [[self sensorViews] count] - 1; i > index; i--) {
                UIView* otherView = [self sensorViews][i];
                CGRect frame = [otherView frame];
                frame.origin.y = minY;
                [otherView setFrame:frame];
                
                minY -= CGRectGetHeight([otherView bounds]);
            }
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
