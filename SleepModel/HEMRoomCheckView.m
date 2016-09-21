//
//  HEMRoomCheckView.m
//  Sense
//
//  Created by Jimmy Lu on 4/6/15.
//  Copyright (c) 2015 Hello. All rights reserved.
//
#import <UICountingLabel/UICountingLabel.h>

#import "NSString+HEMUtils.h"

#import "HEMRoomCheckView.h"
#import "HEMActivityIndicatorView.h"
#import "HEMAnimationUtils.h"
#import "HEMStyle.h"

static CGFloat const kHEMRoomCheckViewSensorIconMoveDuration = 0.25f;
static CGFloat const kHEMRoomCheckViewSensorIconSpacing = 28.0f;
static CGFloat const kHEMRoomCheckViewSensorIconSize = 40.0f;
static CGFloat const HEMRoomCheckViewSensorIconActivitySize = 40.0f;

static CGFloat const kHEMRoomCheckViewSensorValueDuration = 2.0f;
static CGFloat const kHEMRoomCheckViewSensorDisplayDuration = 1.0f;

@interface HEMRoomCheckView()

@property (weak, nonatomic) IBOutlet UIImageView *senseBgImageView;
@property (weak, nonatomic) IBOutlet UIImageView *senseImageView;
@property (weak, nonatomic) IBOutlet UIView *sensorValueContainer;
@property (weak, nonatomic) IBOutlet UICountingLabel *valueLabel;
@property (weak, nonatomic) IBOutlet UILabel *unitLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sensorTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sensorContainerTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sensorMessageHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sensorValueContainerBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sensorMessageTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bgImageTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sensorContainerLeftConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sensorValueCenterConstraint;

@property (assign, nonatomic) NSInteger numberOfSensors;
@property (assign, nonatomic, getter=isLoaded) BOOL loaded;
@property (assign, nonatomic, getter=isAnimating) BOOL animating;
@property (weak,   nonatomic) HEMActivityIndicatorView* currentSensorActivity;
@property (assign, nonatomic) NSUInteger currentSensorIndex;

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
    [[self unitLabel] setFont:[UIFont h4]];
    [[self valueLabel] setFont:[UIFont h1]];
}

- (void)adjustForiPhone4 {
    [[self bgImageTopConstraint] setConstant:0];
    
    CGFloat sensorTopConstant = [[self sensorTopConstraint] constant] * 0.4f;
    [[self sensorTopConstraint] setConstant:sensorTopConstant];
    
    CGFloat sensorContainerTopConstrant = [[self sensorContainerTopConstraint] constant] * 0.5f;
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

#pragma mark - Presentation of data

- (void)reload {
    [self setNumberOfSensors:[[self delegate] numberOfSensorsInRoomCheckView:self]];
    
    if ([self numberOfSensors] > 0) {
        [self layoutSensorIcons];
        [self configureSensorValueLabelAtIndx:0];
        [self setCurrentSensorIndex:0];
    }
}

- (void)layoutSensorIcons {
    NSArray* sensorIconViews = [[self sensorContainerView] subviews];
    [sensorIconViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    CGFloat cornerRadius = kHEMRoomCheckViewSensorIconSize / 2.0f;
    CGFloat spacing = kHEMRoomCheckViewSensorIconSpacing;
    CGRect iconFrame = CGRectZero;
    iconFrame.size = CGSizeMake(kHEMRoomCheckViewSensorIconSize, kHEMRoomCheckViewSensorIconSize);
    
    UIImage* icon = nil;
    UIImage* highlightedIcon = nil;
    UIImageView* iconView = nil;
    
    for (NSUInteger index = 0; index < [self numberOfSensors]; index++) {
        icon = [[self delegate] sensorIconImageAtIndex:index forState:HEMRoomCheckStateWaiting inRoomCheckView:self];
        highlightedIcon = [[self delegate] sensorIconImageAtIndex:index forState:HEMRoomCheckStateLoading inRoomCheckView:self];
        iconView = [[UIImageView alloc] initWithImage:icon];
        [iconView setFrame:iconFrame];
        [iconView setHighlightedImage:highlightedIcon];
        [iconView setBackgroundColor:[UIColor clearColor]];
        [[iconView layer] setCornerRadius:cornerRadius];
        
        [[self sensorContainerView] addSubview:iconView];
        
        iconFrame.origin.x += CGRectGetWidth(iconFrame) + spacing;
    }
}

- (void)configureSensorValueLabelAtIndx:(NSUInteger)index {
    if (index >= [self numberOfSensors]) {
        return;
    }

    UIColor* color = [[self delegate] sensorValueColorAtIndex:index inRoomCheckView:self];
    NSString* unit = [[self delegate] sensorValueUnitAtIndex:index inRoomCheckView:self];
    
    NSDictionary* unitAttrs = @{NSFontAttributeName : [[self unitLabel] font]};
    CGFloat unitWidth = [unit sizeBoundedByHeight:MAXFLOAT attributes:unitAttrs].width;
    
    [[self sensorValueCenterConstraint] setConstant:-(unitWidth / 2)];
    [[self valueLabel] layoutIfNeeded];
    
    [[self valueLabel] setFormat:@"%.0f"];
    [[self valueLabel] setText:@"0"];
    [[self valueLabel] setTextColor:color];
    [[self unitLabel] setTextColor:color];
    [[self unitLabel] setText:unit];
}

#pragma mark - Animations

- (void)setDefaultMessageForSensorAtIndex:(NSUInteger)index {
    NSString* sensorName = [[self delegate] sensorNameAtIndex:index inRoomCheckView:self];
    NSString* messageFormat = NSLocalizedString(@"onboarding.room-check.checking-sensor.format", nil);
    NSString* message = [NSString stringWithFormat:messageFormat, sensorName];
    [[self sensorMessageLabel] setText:message];
    [[self sensorMessageLabel] setTextColor:[UIColor grey4]];
    [[self sensorMessageLabel] setFont:[UIFont body]];
    [self resizeSensorMessageLabel];
}

- (void)showSensorMessageForSensorAtIndex:(NSUInteger)index {
    NSDictionary* statusAttributes = @{NSFontAttributeName : [UIFont body],
                                       NSForegroundColorAttributeName : [UIColor grey4]};
    NSString* message = [[self delegate] sensorMessageAtIndex:index inRoomCheckView:self];
    NSAttributedString* attrMessage = [[NSAttributedString alloc] initWithString:message
                                                                      attributes:statusAttributes];
    
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

- (void)moveSensorContainerToCenterSensorAtIndex:(NSUInteger)index
                                      completion:(void(^)(BOOL finished))completion {

    CGFloat halfIconSize = (kHEMRoomCheckViewSensorIconSize / 2);
    CGFloat distance = kHEMRoomCheckViewSensorIconSpacing + kHEMRoomCheckViewSensorIconSize;
    CGFloat adjustedConstant = -(index * distance) - halfIconSize;
    
    [[self sensorContainerLeftConstraint] setConstant:adjustedConstant];
    [UIView animateWithDuration:kHEMRoomCheckViewSensorIconMoveDuration animations:^{
        [[self sensorContainerView] layoutIfNeeded];
    } completion:completion];
}

- (void)animate:(void(^)(void))completion {
    [self animateSensorAtIndex:0 completion:completion];
}

- (void)animateSensorAtIndex:(NSUInteger)index completion:(void(^)(void))completion {
    if (index >= [self numberOfSensors]) {
        if (completion) completion ();
        return;
    }
    
    [self moveSensorContainerToCenterSensorAtIndex:index completion:^(BOOL finished) {
        NSInteger value = [[self delegate] sensorValueAtIndex:index inRoomCheckView:self];
        
        [self setCurrentSensorIndex:index];
        [self setSenseImageToDefaultForSensorIndex:index];
        [self setDefaultMessageForSensorAtIndex:index];
        [self showActivityAroundSensorIconAtIndex:index];
        
        __weak typeof(self) weakSelf = self;
        [[self valueLabel] setCompletionBlock:^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf animateSenseImageToLoadedStateForSensorAtIndex:index];
            [strongSelf hideActivityAroundSensorIconAtIndex:index];
            [HEMAnimationUtils fade:[strongSelf sensorMessageLabel] out:^{
                [strongSelf showSensorMessageForSensorAtIndex:index];
            } thenIn:^{
                int64_t delayInSeconds = (int64_t)(kHEMRoomCheckViewSensorDisplayDuration * NSEC_PER_SEC);
                dispatch_time_t delay = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds);
                dispatch_after(delay, dispatch_get_main_queue(), ^(void) {
                    NSUInteger nextIndex = index + 1;
                    [strongSelf configureSensorValueLabelAtIndx:nextIndex];
                    [strongSelf animateSensorAtIndex:nextIndex completion:completion];
                });
            }];
        }];
        
        [[self valueLabel] countFromZeroTo:value withDuration:kHEMRoomCheckViewSensorValueDuration];
    }];
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
    
    CGFloat activityOriginDiff = (HEMRoomCheckViewSensorIconActivitySize - kHEMRoomCheckViewSensorIconSize)/2;
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

- (void)hideActivityAroundSensorIconAtIndex:(NSUInteger)index {
    UIImageView* iconView = [[self sensorContainerView] subviews][index];
    UIColor* color = [[self delegate] sensorValueColorAtIndex:index inRoomCheckView:self];
    [UIView animateWithDuration:kHEMAnimationDefaultDuration+kHEMAnimationActivityDuration animations:^{
        [[self currentSensorActivity] setAlpha:0.0f];
        [iconView setBackgroundColor:[color colorWithAlphaComponent:0.2f]];
    } completion:^(BOOL finished) {
        [[self currentSensorActivity] removeFromSuperview];
        [self setCurrentSensorActivity:nil];
    }];
}

@end
