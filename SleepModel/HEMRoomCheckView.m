//
//  HEMRoomCheckView.m
//  Sense
//
//  Created by Jimmy Lu on 4/6/15.
//  Copyright (c) 2015 Hello. All rights reserved.
//
#import <UICountingLabel/UICountingLabel.h>

#import "UIFont+HEMStyle.h"
#import "NSMutableAttributedString+HEMFormat.h"

#import "HEMRoomCheckView.h"
#import "HEMActivityIndicatorView.h"
#import "UIColor+HEMStyle.h"
#import "HEMAnimationUtils.h"
#import "HEMMarkdown.h"

static CGFloat const HEMRoomCheckViewSensorIconSpacing = 28.0f;
static CGFloat const HEMRoomCheckViewSensorIconSize = 40.0f;
static CGFloat const HEMRoomCheckViewSensorIconActivitySize = 40.0f;

static CGFloat const kHEMRoomCheckViewSensorValueDuration = 0.5f;
static CGFloat const kHEMRoomCheckViewSensorDisplayDuration = 2.0f;

@interface HEMRoomCheckView()

@property (weak, nonatomic) IBOutlet UIImageView *senseBgImageView;
@property (weak, nonatomic) IBOutlet UIImageView *senseImageView;
@property (weak, nonatomic) IBOutlet UIView *sensorContainerView;
@property (weak, nonatomic) IBOutlet UIView *sensorValueContainer;
@property (weak, nonatomic) IBOutlet UICountingLabel *valueLabel;
@property (weak, nonatomic) IBOutlet UILabel *unitLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sensorTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sensorContainerTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sensorMessageHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sensorValueContainerBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sensorMessageTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bgImageTopConstraint;

@property (assign, nonatomic) NSInteger numberOfSensors;
@property (assign, nonatomic, getter=isLoaded) BOOL loaded;
@property (assign, nonatomic, getter=isAnimating) BOOL animating;
@property (weak,   nonatomic) HEMActivityIndicatorView* currentSensorActivity;
@property (assign, nonatomic) NSUInteger currentSensorIndex;
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

- (void)configureSensorValueLabelAtIndx:(NSUInteger)index {
    if (index >= [self numberOfSensors]) {
        return;
    }

    NSString* unit = [[self delegate] sensorValueUnitAtIndex:index inRoomCheckView:self];
    UIColor* color = [[self delegate] sensorValueColorAtIndex:index inRoomCheckView:self];
    
    [[self valueLabel] setFormat:@"%.0f"];
    [[self valueLabel] setFont:[UIFont h1]];
    [[self valueLabel] setTextColor:color];
    [[self unitLabel] setFont:[UIFont h4]];
    [[self unitLabel] setText:unit];
    [[self unitLabel] setTextColor:[UIColor grey3]];
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
    NSAttributedString* attrMessage = [[NSAttributedString alloc] initWithString:message
                                                                      attributes:statusAttributes];
    
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
    
    NSInteger value = [[self delegate] sensorValueAtIndex:index inRoomCheckView:self];
    
    __weak typeof(self) weakSelf = self;
    [[self valueLabel] setCompletionBlock:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf animateSenseImageToLoadedStateForSensorAtIndex:index];
        [strongSelf animateSensorIconToLoadedStateAtIndex:index];
        [strongSelf hideActivityAroundSensorIcon];
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
    
    [[self valueLabel] countFromCurrentValueTo:value withDuration:kHEMRoomCheckViewSensorValueDuration];
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
