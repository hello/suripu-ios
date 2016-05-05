//
//  HEMRoomCheckView.m
//  Sense
//
//  Created by Jimmy Lu on 4/6/15.
//  Copyright (c) 2015 Hello. All rights reserved.
//
#import <markdown_peg.h>

#import "UIFont+HEMStyle.h"
#import "NSMutableAttributedString+HEMFormat.h"

#import "HEMRoomCheckView.h"
#import "HEMActivityIndicatorView.h"
#import "UIColor+HEMStyle.h"
#import "HEMAnimationUtils.h"
#import "HEMSpinnerView.h"
#import "HEMMarkdown.h"

static CGFloat const HEMRoomCheckViewSensorIconSpacing = 28.0f;
static CGFloat const HEMRoomCheckViewSensorIconSize = 40.0f;
static CGFloat const HEMRoomCheckViewSensorIconActivitySize = 40.0f;
static CGFloat const HEMRoomCheckViewSensorDigitWidth = 41.0f;
static CGFloat const HEMRoomCheckViewSensorDigitHeight = 98.0f;
static CGFloat const HEMRoomCheckViewSensorDigitSpacing = 3.0f;
static CGFloat const HEMRoomCheckViewSensorDigitToUnitSpacing = 7.0f;
static CGFloat const HEMRoomCheckViewSensorUnitHeight = 44.0f;
static CGFloat const HEMRoomCheckViewSensorUnitYOffset = 14.0f;
static CGFloat const HEMRoomCheckViewSensorDisplayDuration = 3.0f;

@interface HEMRoomCheckView()

@property (weak, nonatomic) IBOutlet UIImageView *senseBgImageView;
@property (weak, nonatomic) IBOutlet UIImageView *senseImageView;
@property (weak, nonatomic) IBOutlet UIView *sensorContainerView;
@property (weak, nonatomic) IBOutlet UIView *sensorValueContainer;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sensorTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sensorContainerTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sensorMessageHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sensorValueContainerBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sensorMessageTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bgImageTopConstraint;

@property (assign, nonatomic) NSInteger numberOfSensors;
@property (assign, nonatomic, getter=isLoaded) BOOL loaded;
@property (assign, nonatomic, getter=isAnimating) BOOL animating;
@property (strong, nonatomic) NSMutableArray* sensorValueRotaries;
@property (weak,   nonatomic) HEMActivityIndicatorView* currentSensorActivity;
@property (assign, nonatomic) NSUInteger currentSensorIndex;
@property (weak,   nonatomic) CAGradientLayer* topGradientLayer;
@property (weak,   nonatomic) CAGradientLayer* botGradientLayer;
@property (assign, nonatomic) CGFloat gradientHeight;
@property (strong, nonatomic) NSArray* gradientColorRefs;

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

- (CAGradientLayer*)gradientLayerWithWidth:(CGFloat)width
                           containerHeight:(CGFloat)containerHeight
                                    colors:(NSArray*)colors
                                 locations:(NSArray*)locations {
    
    CAGradientLayer* gradientLayer = [CAGradientLayer layer];
    CGRect gradientFrame = CGRectZero;
    gradientFrame.size.width = width;
    gradientFrame.size.height = ((containerHeight - HEMRoomCheckViewSensorDigitHeight) / 2.0f);
    [gradientLayer setFrame:gradientFrame];
    [gradientLayer setColors:colors];
    [gradientLayer setLocations:locations];
    return gradientLayer;
}

- (NSArray*)gradientColorRefs {
    if (!_gradientColorRefs) {
        _gradientColorRefs = @[(id)[UIColor whiteColor].CGColor,
                               (id)[UIColor colorWithWhite:1.0f alpha:0.3f].CGColor];
    }
    return _gradientColorRefs;
}

- (void)addTopGradientTo:(UIView*)view {
    NSArray* colors = [self gradientColorRefs];
    CGFloat topWidth = CGRectGetWidth([[self sensorValueContainer] bounds]);
    CGFloat containerHeight = CGRectGetHeight([[self sensorValueContainer] bounds]);
    CAGradientLayer* layer = [self gradientLayerWithWidth:topWidth
                                          containerHeight:containerHeight
                                                   colors:colors
                                                locations:@[@(0.75f), @1]];
    [[view layer] addSublayer:layer];
    [self setTopGradientLayer:layer];
}

- (void)addBotGradientTo:(UIView*)view {
    NSArray* colors = [[[self gradientColorRefs] reverseObjectEnumerator] allObjects];
    CGFloat topWidth = CGRectGetWidth([[self sensorValueContainer] bounds]);
    CGFloat containerHeight = CGRectGetHeight([[self sensorValueContainer] bounds]);
    
    CAGradientLayer* layer = [self gradientLayerWithWidth:topWidth
                                          containerHeight:containerHeight
                                                   colors:colors
                                                locations:@[@0, @(0.25f)]];
    CGRect layerFrame = [layer frame];
    layerFrame.origin.y = containerHeight - CGRectGetHeight(layerFrame);
    [layer setFrame:layerFrame];
    
    [[view layer] addSublayer:layer];
    [self setBotGradientLayer:layer];
}

- (void)adjustForiPhone4 {
    [[self bgImageTopConstraint] setConstant:0];
    
    CGFloat sensorTopConstant = [[self sensorTopConstraint] constant] * 0.4f;
    [[self sensorTopConstraint] setConstant:sensorTopConstant];
    
    CGFloat sensorContainerTopConstrant = [[self sensorContainerTopConstraint] constant] * 0.075f;
    [[self sensorContainerTopConstraint] setConstant:sensorContainerTopConstrant];
    
    CGFloat sensorMessageTopConstant = [[self sensorMessageTopConstraint] constant] * 0.5f;
    [[self sensorMessageTopConstraint] setConstant:sensorMessageTopConstant];
    
    CGFloat sensorValueBottomConstraint = [[self sensorValueContainerBottomConstraint] constant] * 0.7f;
    [[self sensorValueContainerBottomConstraint] setConstant:sensorValueBottomConstraint];
}

- (void)adjustForiPhone5 {
    CGFloat sensorContainerTopConstrant = [[self sensorContainerTopConstraint] constant] * 0.5f;
    [[self sensorContainerTopConstraint] setConstant:sensorContainerTopConstrant];
    
    CGFloat sensorValueBottomConstraint = [[self sensorValueContainerBottomConstraint] constant] * 0.63f;
    [[self sensorValueContainerBottomConstraint] setConstant:sensorValueBottomConstraint];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (![self isLoaded]) {
        [self reload];
        
        [self addTopGradientTo:[self sensorValueContainer]];
        [self addBotGradientTo:[self sensorValueContainer]];
        
        [self setLoaded:YES];
    }
}

- (NSAttributedString*)attributedSensorUnitFrom:(NSString*)value
                                          color:(UIColor*)color
                                           font:(UIFont*)font {
    if (value == nil) {
        return nil;
    }
    NSDictionary* attributes = @{NSFontAttributeName : font,
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
        [self setCurrentSensorIndex:0];
    }
}

- (void)layoutSensorIcons {
    NSArray* sensorIconViews = [[self sensorContainerView] subviews];
    [sensorIconViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    NSInteger spacesRequired = [self numberOfSensors] - 1;
    
    CGFloat spacing = HEMRoomCheckViewSensorIconSpacing;
    CGFloat totalSpacing = spacesRequired * spacing;
    CGFloat requiredWidth =
        ([self numberOfSensors] * HEMRoomCheckViewSensorIconSize) + totalSpacing;
    
    if (requiredWidth > CGRectGetWidth([self bounds]) - (2*HEMRoomCheckViewSensorIconSpacing)) {
        spacing = (totalSpacing - (HEMRoomCheckViewSensorIconSpacing * 2))/spacesRequired;
        requiredWidth =
            ([self numberOfSensors] * HEMRoomCheckViewSensorIconSize) + (spacesRequired * spacing);
    }
    
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
        
        iconFrame.origin.x += CGRectGetWidth(iconFrame) + spacing;
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
    UIFont* unitFont = [[self delegate] sensorValueUnitFontAtIndex:index inRoomCheckView:self];
    NSAttributedString* attrUnit = [self attributedSensorUnitFrom:unit color:color font:unitFont];
    CGSize unitSize = [self sizeOfAttributedSensorValueUnit:attrUnit];
    CGFloat requiredWidth
        = (digits * HEMRoomCheckViewSensorDigitWidth)
        + ((digits - 1) * HEMRoomCheckViewSensorDigitSpacing);
    
    CGRect containerBounds = [[self sensorValueContainer] bounds];
    CGRect valueFrame = CGRectZero;
    valueFrame.origin.x = (CGRectGetWidth(containerBounds) - requiredWidth)/2;
    valueFrame.origin.y = (CGRectGetHeight(containerBounds) - HEMRoomCheckViewSensorDigitHeight)/2;
    valueFrame.size = CGSizeMake(HEMRoomCheckViewSensorDigitWidth, HEMRoomCheckViewSensorDigitHeight);
    
    for (int i = 0; i < digits; i++) {
        [self addDigitRotaryWithFrame:valueFrame color:color atIndex:i];
        valueFrame.origin.x += HEMRoomCheckViewSensorDigitWidth + HEMRoomCheckViewSensorDigitSpacing;
    }
    
    [self appendSensorUnit:attrUnit withSize:unitSize];
    
    // make sure it always sits above the digits
    [[[self sensorValueContainer] layer] addSublayer:[self topGradientLayer]];
    [[[self sensorValueContainer] layer] addSublayer:[self botGradientLayer]];
}

- (void)addDigitRotaryWithFrame:(CGRect)frame color:(UIColor*)color atIndex:(NSInteger)index {
    NSMutableArray* digits = [NSMutableArray arrayWithCapacity:10];
    for (long i = 0; i < 10; i++) {
        [digits addObject:[NSString stringWithFormat:@"%ld", i]];
    }
    
    UIFont* font = [UIFont onboardingRoomCheckSensorValueFont];
    HEMSpinnerView* rotary = [[HEMSpinnerView alloc] initWithItems:digits
                                                              font:font
                                                             color:color];
    [rotary setTag:index];
    [rotary setFrame:frame];
    
    [[self sensorValueRotaries] addObject:rotary];
    [[self sensorValueContainer] addSubview:rotary];
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
    [[self sensorMessageLabel] setFont:[UIFont onboardingRoomCheckSensorFont]];
    [self resizeSensorMessageLabel];
}

- (void)showSensorMessageForSensorAtIndex:(NSUInteger)index {
    NSDictionary* statusAttributes = [HEMMarkdown attributesForRoomCheckSensorMessage];
    NSString* message = [[self delegate] sensorMessageAtIndex:index inRoomCheckView:self];
    NSAttributedString* attrMessage = markdown_to_attr_string(message, 0, statusAttributes);
    
    [[self sensorMessageLabel] setTextColor:[UIColor blackColor]];
    [[self sensorMessageLabel] setAttributedText:attrMessage];
    [self resizeSensorMessageLabel];
}

- (void)setSenseImageToDefaultForSensorIndex:(NSUInteger)sensorIndex {
    UIImage* image = [[self delegate] senseImageForSensorAtIndex:sensorIndex
                                                        forState:HEMRoomCheckStateWaiting
                                                 inRoomCheckView:self];
    [[self senseImageView] setImage:image];
}

- (void)resizeSensorMessageLabel {
    CGSize constraint = [[self sensorMessageLabel] bounds].size;
    constraint.height = MAXFLOAT;
    CGFloat textHeight = [[self sensorMessageLabel] sizeThatFits:constraint].height;
    [[self sensorMessageHeightConstraint] setConstant:textHeight];
}

- (void)animateSenseImageToLoadedStateForSensorAtIndex:(NSUInteger)index {
    UIImage* image = [[self delegate] senseImageForSensorAtIndex:index
                                                        forState:HEMRoomCheckStateLoaded
                                                 inRoomCheckView:self];
    UIImageView* toSenseImageView = [[UIImageView alloc] initWithImage:image];
    [toSenseImageView setContentMode:[[self senseImageView] contentMode]];
    [HEMAnimationUtils crossFadeFrom:[self senseImageView] toView:toSenseImageView then:^(BOOL finished) {
        [self setSenseImageView:toSenseImageView];
    }];
}

- (void)animateSensorIconToLoadedStateAtIndex:(NSUInteger)index {
    UIImageView* iconView = [[self sensorContainerView] subviews][index];
    UIImage* loadedIcon = [[self delegate] sensorIconImageAtIndex:index
                                                         forState:HEMRoomCheckStateLoaded
                                                  inRoomCheckView:self];
    UIImageView* toLoadedIconView = [[UIImageView alloc] initWithImage:loadedIcon];
    [toLoadedIconView setContentMode:[iconView contentMode]];
    [HEMAnimationUtils crossFadeFrom:iconView toView:toLoadedIconView then:^(BOOL finished) {
        [iconView removeFromSuperview];
    }];
}

- (void)animate:(void(^)(void))completion {
    [self animateSensorAtIndex:0 completion:completion];
}

- (void)animateSensorAtIndex:(NSUInteger)index completion:(void(^)(void))completion {
    if (index >= [self numberOfSensors]) {
        if (completion) completion ();
        return;
    }
    
    [self setCurrentSensorIndex:index];
    [self setSenseImageToDefaultForSensorIndex:index];
    [self setDefaultMessageForSensorAtIndex:index];
    [self showActivityAroundSensorIconAtIndex:index];
    [self animateSensorValueAtIndex:index willComplete:^{
        [self animateSenseImageToLoadedStateForSensorAtIndex:index];
        [self animateSensorIconToLoadedStateAtIndex:index];
        [self hideActivityAroundSensorIcon];
        [HEMAnimationUtils fade:[self sensorMessageLabel] out:^{
            [self showSensorMessageForSensorAtIndex:index];
        } thenIn:^{
            int64_t delayInSeconds = (int64_t)(HEMRoomCheckViewSensorDisplayDuration * NSEC_PER_SEC);
            dispatch_time_t delay = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds);
            dispatch_after(delay, dispatch_get_main_queue(), ^(void) {
                NSUInteger nextIndex = index + 1;
                [self configureRotariesForSensorAtIndex:nextIndex];
                [self animateSensorAtIndex:nextIndex completion:completion];
            });
        }];
    } completion:nil];
}

- (void)animateSensorValueAtIndex:(NSUInteger)index
                     willComplete:(void(^)(void))willComplete
                       completion:(void(^)(void))completion {
    NSInteger value = [[self delegate] sensorValueAtIndex:index inRoomCheckView:self];
    NSString* valueString = [@(value) stringValue];
    NSUInteger digitsCount = [valueString length];
    
    if (digitsCount == 0) {
        if (completion) {
            completion ();
        }
        return;
    }
    
    NSInteger digitIndex = digitsCount - 1;
    NSString* digitString = [valueString substringWithRange:NSMakeRange(digitIndex, 1)];
    NSInteger rotations = 0;
    if (digitsCount > 1) {
        // negative numbers should never happen, but if it does we still want to
        // rotate the digits based on the values from 0, taking the absolute value
        // to determine the rotations
        rotations = absCGFloat([[valueString substringToIndex:digitIndex] integerValue]);
    }
    
    HEMSpinnerView* rotary = [self sensorValueRotaries][digitIndex];
    [rotary spinTo:digitString rotations:rotations onRotation:^(HEMSpinnerView* view, NSUInteger rotation) {
        [self incrementAdjacentRotaryAtIndex:[view tag] - 1];
    } willComplete:willComplete completion:^(BOOL finished) {
        if (completion) {
            completion ();
        }
    }];
}

- (void)incrementAdjacentRotaryAtIndex:(NSInteger)index {
    if (index >= 0) {
        HEMSpinnerView* rotary = [self sensorValueRotaries][index];
        [rotary next:^(NSString *itemShowing) {
            if ([itemShowing isEqualToString:@"0"]) {
                [self incrementAdjacentRotaryAtIndex:[rotary tag] - 1];
            }
        }];
    }
}

- (void)showSensorImageForSensorAtIndex:(NSUInteger)index {
    UIImage* image = [[self delegate] senseImageForSensorAtIndex:index
                                                        forState:HEMRoomCheckStateLoaded
                                                 inRoomCheckView:self];
    [[self senseImageView] setImage:image];
}

- (void)showActivityAroundSensorIconAtIndex:(NSUInteger)index {
    UIImageView* iconView = [[self sensorContainerView] subviews][index];
    [iconView setHighlighted:YES];
    
    CGFloat activityOriginDiff = (HEMRoomCheckViewSensorIconActivitySize - HEMRoomCheckViewSensorIconSize)/2;
    CGRect activityFrame = CGRectZero;
    activityFrame.size = CGSizeMake(HEMRoomCheckViewSensorIconActivitySize, HEMRoomCheckViewSensorIconActivitySize);
    activityFrame.origin.x = CGRectGetMinX([iconView frame]) - activityOriginDiff;
    activityFrame.origin.y = CGRectGetMinY([iconView frame]) - activityOriginDiff;
    
    UIImage* activityImage = [[self delegate] sensorActivityImageForSensorAtIndex:index
                                                                  inRoomCheckView:self];
    
    HEMActivityIndicatorView* activity =
        [[HEMActivityIndicatorView alloc] initWithImage:activityImage andFrame:activityFrame];
    
    [self setCurrentSensorActivity:activity];
    [[self sensorContainerView] addSubview:activity];
    [[self currentSensorActivity] start];
}

- (void)hideActivityAroundSensorIcon {
    [UIView animateWithDuration:kHEMAnimationDefaultDuration+kHEMAnimationActivityDuration animations:^{
        [[self currentSensorActivity] setAlpha:0.0f];
    } completion:^(BOOL finished) {
        [[self currentSensorActivity] removeFromSuperview];
        [self setCurrentSensorActivity:nil];
    }];
}

@end
