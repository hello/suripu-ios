//
//  HEMRoomCheckView.m
//  Sense
//
//  Created by Jimmy Lu on 4/6/15.
//  Copyright (c) 2015 Hello. All rights reserved.
//
#import <NAPickerView/NAPickerView.h>

#import "UIFont+HEMStyle.h"
#import "NSMutableAttributedString+HEMFormat.h"

#import "HEMRoomCheckView.h"
#import "HEMActivityIndicatorView.h"
#import "HelloStyleKit.h"
#import "HEMAnimationUtils.h"

static CGFloat const HEMRoomCheckViewSensorIconSpacing = 28.0f;
static CGFloat const HEMRoomCheckViewSensorIconSize = 40.0f;
static CGFloat const HEMRoomCheckViewSensorIconActivitySize = 44.0f;
static CGFloat const HEMRoomCheckViewSensorDigitWidth = 41.0f;
static CGFloat const HEMRoomCheckViewSensorDigitHeight = 98.0f;
static CGFloat const HEMRoomCheckViewSensorDigitSpacing = 3.0f;
static CGFloat const HEMRoomCheckViewSensorDigitToUnitSpacing = 7.0f;
static CGFloat const HEMRoomCheckViewSensorUnitHeight = 44.0f;
static CGFloat const HEMRoomCheckViewSensorUnitYOffset = 14.0f;
static CGFloat const HEMRoomCheckViewArtificialActivityDuration = 1.5f;
static CGFloat const HEMRoomCheckViewSensorDisplayDuration = 2.0f;

@interface HEMRoomCheckView()

@property (weak, nonatomic) IBOutlet UIImageView *senseBgImageView;
@property (weak, nonatomic) IBOutlet UIImageView *senseImageView;
@property (weak, nonatomic) IBOutlet UIView *sensorContainerView;
@property (weak, nonatomic) IBOutlet UILabel *sensorMessageLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sensorMessageHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *sensorValueContainer;

@property (assign, nonatomic) NSInteger numberOfSensors;
@property (assign, nonatomic, getter=isLoaded) BOOL loaded;
@property (assign, nonatomic, getter=isAnimating) BOOL animating;
@property (strong, nonatomic) NSMutableArray* sensorValueRotaries;

@end

@implementation HEMRoomCheckView

+ (HEMRoomCheckView*)createRoomCheckViewWithFrame:(CGRect)frame {
    
    NSString* nibName = NSStringFromClass([self class]);
    NSArray* contents = [[NSBundle mainBundle] loadNibNamed:nibName owner:self options:nil];
    
    HEMRoomCheckView* view = [contents firstObject];
    [view setFrame:frame];
    
    return view;
}

- (void)awakeFromNib {
    [[self sensorMessageLabel] setFont:[UIFont onboardingRoomCheckSensorLightFont]];
    [self setSensorValueRotaries:[NSMutableArray array]];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (![self isLoaded]) {
        [self reload];
        [self setLoaded:YES];
    }
}

- (NSAttributedString*)attributedSensorUnitFrom:(NSString*)value color:(UIColor*)color {
    if (value == nil) {
        return nil;
    }
    NSDictionary* attributes = @{NSFontAttributeName : [UIFont onboardingRoomCheckSensorUnitFont],
                                 NSForegroundColorAttributeName : color};
    return [[NSAttributedString alloc] initWithString:value attributes:attributes];
}

- (CGSize)sizeOfAttributedSensorValueUnit:(NSAttributedString*)attributedUnit {
    CGSize constraint = CGSizeMake(MAXFLOAT, HEMRoomCheckViewSensorUnitHeight);
    return [attributedUnit boundingRectWithSize:constraint
                                        options:NSStringDrawingUsesFontLeading
                                                | NSStringDrawingUsesLineFragmentOrigin
                                        context:nil].size;
}

#pragma mark - Presentation of data

- (void)reload {
    [self setNumberOfSensors:[[self delegate] numberOfSensorsInRoomCheckView:self]];
    
    if ([self numberOfSensors] > 0) {
        [self layoutSensorIcons];
        [self configureRotariesForSensorAtIndex:0];
    }
}

- (void)layoutSensorIcons {
    NSArray* sensorIconViews = [[self sensorContainerView] subviews];
    [sensorIconViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    CGFloat requiredWidth =
        ([self numberOfSensors] * HEMRoomCheckViewSensorIconSize)
        + (([self numberOfSensors] - 1) * HEMRoomCheckViewSensorIconSpacing);
    
    CGRect iconFrame = CGRectZero;
    iconFrame.size = CGSizeMake(HEMRoomCheckViewSensorIconSize, HEMRoomCheckViewSensorIconSize);
    iconFrame.origin.x = (CGRectGetWidth([[self sensorContainerView] bounds]) - requiredWidth)/2;
    
    UIImage* icon = nil;
    UIImage* highlightedIcon = nil;
    UIImageView* iconView = nil;
    
    for (NSUInteger index = 0; index < [self numberOfSensors]; index++) {
        icon = [[self delegate] sensorIconImageAtIndex:index forState:HEMRoomCheckStateWaiting inRoomCheckView:self];
        highlightedIcon = [[self delegate] sensorIconImageAtIndex:index forState:HEMRoomCheckStateLoading inRoomCheckView:self];
        iconView = [[UIImageView alloc] initWithImage:icon];
        [iconView setFrame:iconFrame];
        [iconView setHighlightedImage:highlightedIcon];
        
        [[self sensorContainerView] addSubview:iconView];
        
        iconFrame.origin.x += CGRectGetWidth(iconFrame) + HEMRoomCheckViewSensorIconSpacing;
    }
}

- (void)configureRotariesForSensorAtIndex:(NSUInteger)index {
    if (index >= [self numberOfSensors]) return;
    
    if ([[self sensorValueRotaries] count] > 0) {
        [[self sensorValueRotaries] removeAllObjects];
        [[[self sensorValueContainer] subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    }
    
    NSInteger sensorValue = [[self delegate] sensorValueAtIndex:index inRoomCheckView:self];
    NSUInteger digits = [[@(sensorValue) stringValue] length];
    
    NSString* unit = [[self delegate] sensorValueUnitAtIndex:index inRoomCheckView:self];
    UIColor* color = [[self delegate] sensorValueColorAtIndex:index inRoomCheckView:self];
    NSAttributedString* attrUnit = [self attributedSensorUnitFrom:unit color:color];
    CGSize unitSize = [self sizeOfAttributedSensorValueUnit:attrUnit];
    CGFloat requiredWidth
        = (digits * HEMRoomCheckViewSensorDigitWidth)
        + ((digits - 1) * HEMRoomCheckViewSensorDigitSpacing)
        + unitSize.width;
    
    CGRect containerBounds = [[self sensorValueContainer] bounds];
    CGRect valueFrame = CGRectZero;
    valueFrame.origin.x = (CGRectGetWidth(containerBounds) - requiredWidth)/2;
    valueFrame.origin.y = (CGRectGetHeight(containerBounds) - HEMRoomCheckViewSensorDigitHeight)/2;
    valueFrame.size = CGSizeMake(HEMRoomCheckViewSensorDigitWidth, HEMRoomCheckViewSensorDigitHeight);
    
    for (int i = 0; i < digits; i++) {
        [self addDigitRotaryWithFrame:valueFrame];
        valueFrame.origin.x += HEMRoomCheckViewSensorDigitWidth + HEMRoomCheckViewSensorDigitHeight;
    }
    
    [self appendSensorUnit:attrUnit withSize:unitSize];
}

- (void)addDigitRotaryWithFrame:(CGRect)frame {
    NSMutableArray* digits = [NSMutableArray arrayWithCapacity:10];
    for (long i = 0; i < 10; i++) {
        [digits addObject:[NSString stringWithFormat:@"%ld", i]];
    }
    
    NAPickerView* digitRotary = [[NAPickerView alloc] initWithFrame:frame andItems:digits andDelegate:nil];
    [digitRotary setInfiniteScrolling:YES];
    [digitRotary setShowOverlay:NO];
    [digitRotary setUserInteractionEnabled:NO];
    [digitRotary setCellHeight:HEMRoomCheckViewSensorDigitHeight];
    [digitRotary setBackgroundColor:[UIColor clearColor]];
    [digitRotary setConfigureBlock:^(NALabelCell *cell, NSString *item) {
        [[cell textView] setFont:[UIFont onboardingRoomCheckSensorValueFont]];
        [[cell textView] setText:item];
        [[cell textView] setTextAlignment:NSTextAlignmentCenter];
        [[cell textView] setBackgroundColor:[UIColor clearColor]];
        [[cell textView] setAlpha:([self isAnimating] ? 0.2f : 1.0f)];
    }];
    
    [[self sensorValueRotaries] addObject:digitRotary];
    [[self sensorValueContainer] addSubview:digitRotary];
}

- (void)appendSensorUnit:(NSAttributedString*)attributedUnit withSize:(CGSize)size {
    UIView* lastRotary = [[self sensorValueRotaries] lastObject];
    CGRect unitFrame = CGRectZero;
    unitFrame.origin.x = CGRectGetMaxX([lastRotary frame]) + HEMRoomCheckViewSensorDigitToUnitSpacing;
    unitFrame.origin.y = CGRectGetMinY([lastRotary frame]) + HEMRoomCheckViewSensorUnitYOffset;
    unitFrame.size = size;
    
    UILabel* label = [[UILabel alloc] initWithFrame:unitFrame];
    [label setBackgroundColor:[UIColor clearColor]];
    [label setClipsToBounds:YES];
    [label setAttributedText:attributedUnit];
    
    [[self sensorValueContainer] addSubview:label];
}

#pragma mark - Animations

- (void)setDefaultMessageForSensorAtIndex:(NSUInteger)index {
    NSString* sensorName = [[self delegate] sensorNameAtIndex:index inRoomCheckView:self];
    NSString* messageFormat = NSLocalizedString(@"onboarding.room-check.checking-sensor.format", nil);
    NSString* message = [NSString stringWithFormat:messageFormat, sensorName];
    [[self sensorMessageLabel] setText:[message uppercaseString]];
    [[self sensorMessageLabel] setTextColor:[UIColor colorWithWhite:0.0f alpha:0.4f]];
    [self resizeSensorMessageLabel];

}

- (void)showSensorMessageForSensorAtIndex:(NSUInteger)index {
    [[self sensorMessageLabel] setFont:[UIFont onboardingRoomCheckSensorFont]];
    [[self sensorMessageLabel] setTextColor:[UIColor blackColor]];
    [[self sensorMessageLabel] setText:[[self delegate] sensorMessageAtIndex:index inRoomCheckView:self]];
    [self resizeSensorMessageLabel];
}

- (void)resizeSensorMessageLabel {
    CGSize constraint = [[self sensorMessageLabel] bounds].size;
    constraint.height = MAXFLOAT;
    CGFloat textHeight = [[self sensorMessageLabel] sizeThatFits:constraint].height;
    [[self sensorMessageHeightConstraint] setConstant:textHeight];
}

- (void)delay:(CGFloat)duration then:(void(^)(void))thenBlock {
    int64_t delaySecs = (int64_t)(HEMRoomCheckViewArtificialActivityDuration * NSEC_PER_SEC);
    dispatch_time_t delay = dispatch_time(DISPATCH_TIME_NOW, delaySecs);
    dispatch_after(delay, dispatch_get_main_queue(), thenBlock);
}

- (void)animate {
    // TODO jimmy: handle no sensors
    [self animateSensorAtIndex:0];
}

- (void)animateSensorAtIndex:(NSUInteger)index {
    if (index >= [self numberOfSensors]) {
        // show continue button
        return;
    }
    
    [self setDefaultMessageForSensorAtIndex:index];
    
    [self animateSensorValueAtIndex:index infinite:YES];
    [self animateProgressAroundSensorIconAtIndex:index beforeRemoval:^{
        [self animateSensorValueAtIndex:index infinite:NO];
    } afterRemoval:^{
        [HEMAnimationUtils fade:[self sensorMessageLabel] out:^{
            [self showSensorMessageForSensorAtIndex:index];
        } thenIn:^{
            [self delay:HEMRoomCheckViewSensorDisplayDuration then:^{
                NSUInteger nextIndex = index + 1;
                [self configureRotariesForSensorAtIndex:nextIndex];
                [self animateSensorAtIndex:nextIndex];
            }];
        }];
    }];
}

- (void)animateSensorValueAtIndex:(NSUInteger)index infinite:(BOOL)infinite {
    NSInteger value = [[self delegate] sensorValueAtIndex:index inRoomCheckView:self];
    NSString* valueString = [@(value) stringValue];
    for (NSInteger i = [valueString length] - 1; i >= 0; i--) {
        unichar digit = [valueString characterAtIndex:i];
        if (isdigit(digit)) {
            NAPickerView* rotary = [self sensorValueRotaries][i];
            [UIView animateWithDuration:0.5f animations:^{
                [rotary setIndex:digit];
            }];
        }
    }
}

- (void)animateProgressAroundSensorIconAtIndex:(NSUInteger)index
                                 beforeRemoval:(void(^)(void))beforeRemoval
                                  afterRemoval:(void(^)(void))afterRemoval {
    
    UIImageView* iconView = [[self sensorContainerView] subviews][index];
    [iconView setHighlighted:YES];
    
    CGFloat activityOriginDiff = (HEMRoomCheckViewSensorIconActivitySize - HEMRoomCheckViewSensorIconSize)/2;
    CGRect activityFrame = CGRectZero;
    activityFrame.size = CGSizeMake(HEMRoomCheckViewSensorIconActivitySize, HEMRoomCheckViewSensorIconActivitySize);
    activityFrame.origin.x = CGRectGetMinX([iconView frame]) - activityOriginDiff;
    activityFrame.origin.y = CGRectGetMinY([iconView frame]) - activityOriginDiff;
    
    HEMActivityIndicatorView* activity = [[HEMActivityIndicatorView alloc] initWithFrame:activityFrame];
    [[self sensorContainerView] addSubview:activity];
    [activity start];
    
    UIImage* loadedIcon = [[self delegate] sensorIconImageAtIndex:index forState:HEMRoomCheckStateLoaded inRoomCheckView:self];
    
    [self delay:HEMRoomCheckViewArtificialActivityDuration then:^{
        if (beforeRemoval) {
            beforeRemoval();
        }
        [UIView animateWithDuration:0.5f
                         animations:^{
                             [activity setAlpha:0.0f];
                         }
                         completion:^(BOOL finished) {
                             [activity removeFromSuperview];
                             [iconView setImage:loadedIcon];
                             [iconView setHighlighted:NO];
                             if (afterRemoval) {
                                 afterRemoval();
                             }
                         }];
    }];
}

@end
