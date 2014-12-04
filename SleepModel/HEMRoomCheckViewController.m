//
//  HEMRoomCheckViewController.m
//  Sense
//
//  Created by Jimmy Lu on 12/3/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import <SenseKit/SENSensor.h>

#import "UIFont+HEMStyle.h"

#import "HEMRoomCheckViewController.h"
#import "HEMScrollableView.h"
#import "HelloStyleKit.h"
#import "HEMOnboardingUtils.h"
#import "HEMActionButton.h"
#import "HEMSensorCheckView.h"
#import "HEMSensorUtils.h"

static CGFloat const HEMRoomCheckMinVerticalPadding = 28.0f;
static CGFloat const HEMRoomCheckAnimationDuration = 0.5f;

@interface HEMRoomCheckViewController()

@property (weak, nonatomic) IBOutlet HEMScrollableView *contentView;
@property (weak, nonatomic) IBOutlet UIView *buttonContainer;
@property (weak, nonatomic) IBOutlet HEMActionButton *continueButton;

@property (strong, nonatomic) NSMutableArray* sensorViews;
@property (assign, nonatomic) CGFloat currentTopY;

@end

@implementation HEMRoomCheckViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setCurrentTopY:HEMRoomCheckMinVerticalPadding];
    [self setupContent];
}

- (void)setupContent {
    NSString* desc = NSLocalizedString(@"onboarding.room-check.description", nil);
    NSMutableAttributedString* attrText =
        [[NSMutableAttributedString alloc] initWithString:desc];
    [HEMOnboardingUtils applyCommonDescriptionAttributesTo:attrText];
    
    [[self contentView] addTitle:NSLocalizedString(@"onboarding.room-check.title", nil)];
    [[self contentView] addImage:[HelloStyleKit sensePlacement]];
    [[self contentView] addDescription:attrText];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    CGFloat shadowOpacity = [[self contentView] scrollRequired]?1.0f:0.0f;
    [[[self buttonContainer] layer] setShadowOpacity:shadowOpacity];
}

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
        nextY += CGRectGetHeight([[self addSensorViewFor:sensor atY:nextY] bounds]);
    }
    
    // add a couple of placeholder sensors since we don't have them yet
    nextY += CGRectGetHeight([[self addSensorViewWithIcon:[HelloStyleKit sensorSound]
                                          highlightedIcon:[HelloStyleKit sensorSoundBlue]
                                                     name:NSLocalizedString(@"sensor.sound", nil)
                                                  message:NSLocalizedString(@"sensor.sound.placeholder-message", nil)
                                                      atY:nextY] bounds]);
    
    [self addSensorViewWithIcon:[HelloStyleKit sensorLight]
                highlightedIcon:[HelloStyleKit sensorLightBlue]
                           name:NSLocalizedString(@"sensor.light", nil)
                        message:NSLocalizedString(@"sensor.light.placeholder-message", nil)
                            atY:nextY];
    
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

    switch ([sensor unit]) {
        case SENSensorUnitAQI: {
            icon = [HelloStyleKit sensorParticulates];
            highlightedIcon = [HelloStyleKit sensorParticulatesBlue];
            break;
        }
        case SENSensorUnitDegreeCentigrade: {
            icon = [HelloStyleKit sensorTemperature];
            highlightedIcon = [HelloStyleKit sensorTemperatureBlue];
            break;
        }
        case SENSensorUnitPercent: {
            icon = [HelloStyleKit sensorHumidity];
            highlightedIcon = [HelloStyleKit sensorHumidityBlue];
            break;
        }
        default:
            break;
    }
    
    return [self addSensorViewWithIcon:icon
                       highlightedIcon:highlightedIcon
                                  name:[sensor localizedName]
                               message:[sensor message]
                                   atY:yOrigin];
}

- (HEMSensorCheckView*)addSensorViewWithIcon:(UIImage*)icon
                             highlightedIcon:(UIImage*)highlightedIcon
                                        name:(NSString*)name
                                     message:(NSString*)message
                                         atY:(CGFloat)yOrigin {
    
    NSString* titleFormat = NSLocalizedString(@"onboarding.room-check.checking-sensor.format", nil);
    NSString* title = [NSString stringWithFormat:titleFormat, name];
    
    HEMSensorCheckView* view = [[HEMSensorCheckView alloc] initWithIcon:icon
                                                        highlightedIcon:highlightedIcon
                                                                  title:title
                                                                message:message];
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

- (void)displaySensorDataAtIndex:(NSInteger)index {
    UIView* view = [self sensorViews][index];
    [UIView animateWithDuration:HEMRoomCheckAnimationDuration
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         CGRect frame = [view frame];
                         frame.origin.y = [self currentTopY];
                         [view setFrame:frame];
                         
                         if (index == 0) {
                             // move all other views down, starting from the last
                             CGFloat bHeight = CGRectGetHeight([[self view] bounds]);
                             NSInteger minY = bHeight - CGRectGetHeight([view bounds]) - HEMRoomCheckMinVerticalPadding;
                             
                             for (NSInteger i = [[self sensorViews] count] - 1; i > index; i--) {
                                 UIView* otherView = [self sensorViews][i];
                                 CGRect frame = [otherView frame];
                                 frame.origin.y = minY;
                                 [otherView setFrame:frame];
                                 
                                 minY -= CGRectGetHeight([otherView bounds]);
                             }
                             
                         }
                     }
                     completion:^(BOOL finished) {
                         [self setCurrentTopY:CGRectGetMaxY([view frame])];
                     }];
}

#pragma mark - Actions

- (IBAction)next:(id)sender {
    [self hideContent:^(BOOL finished) {
        [self showSensors:^(BOOL finished) {
            dispatch_time_t delay = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC));
            dispatch_after(delay, dispatch_get_main_queue(), ^{
                [self displaySensorDataAtIndex:0];
            });
        }];
    }];
}

@end
