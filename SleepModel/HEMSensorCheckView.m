//
//  HEMSensorCheckView.m
//  Sense
//
//  Created by Jimmy Lu on 12/3/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import "HEMSensorCheckView.h"
#import "HelloStyleKit.h"
#import "UIFont+HEMStyle.h"

CGFloat const HEMSensorCheckCollapsedHeight = 45.0f;

static CGFloat const HEMSensorCheckHorzPadding = 45.0f;
static CGFloat const HEMSensorCheckLabelTopMargin = 20.0f;
static CGFloat const HEMSensorCheckTitleHeight = 20.0f;
static CGFloat const HEMSensorCheckMessageMaxHeight = 58.0f;
static CGFloat const HEMSensorCheckSeparatorHeight = 0.5f;
static CGFloat const HEMSensorCheckContentAnimationDuration = 0.7f;

@interface HEMSensorCheckView()

@property (nonatomic, weak)   UIImageView* iconImageView;
@property (nonatomic, weak)   UILabel* titleLabel;
@property (nonatomic, weak)   UILabel* messageLabel;
@property (nonatomic, weak)   UILabel* valueLabel;
@property (nonatomic, weak)   UIView* separator;
@property (nonatomic, copy)   NSString* value;
@property (nonatomic, strong) UIColor* conditionColor;

@end

@implementation HEMSensorCheckView

+ (CGFloat)collapsedHeight {
    return HEMSensorCheckCollapsedHeight;
}

- (instancetype)initWithIcon:(UIImage*)icon
             highlightedIcon:(UIImage*)highlighedIcon
                       title:(NSString*)title
                     message:(NSAttributedString*)message
                       value:(NSString*)value
          withConditionColor:(UIColor*)color {
    
    CGRect bounds = [[UIScreen mainScreen] bounds];
    CGRect frame = CGRectZero;
    frame.size.height = HEMSensorCheckCollapsedHeight;
    frame.size.width = CGRectGetWidth(bounds);
    
    self = [super initWithFrame:frame];
    if (self) {
        [self setClipsToBounds:YES];
        [self addIconImageViewWithIcon:icon highlightedIcon:highlighedIcon];
        [self addTitleWithText:title];
        [self addMessageWithText:message];
        [self addSeparator];
        
        [self setValue:value];
        [self setConditionColor:color];
    }
    return self;
}

- (void)addIconImageViewWithIcon:(UIImage*)icon highlightedIcon:(UIImage*)highlightedIcon {
    UIImageView* imageView = [[UIImageView alloc] initWithImage:icon];
    [imageView setHighlightedImage:highlightedIcon];
    [imageView setContentMode:UIViewContentModeScaleAspectFit];
    [imageView setAutoresizingMask:UIViewAutoresizingFlexibleBottomMargin];
    
    CGRect imageFrame = [imageView frame];
    imageFrame.size = [icon size];
    imageFrame.origin.x = (CGRectGetWidth([self bounds]) - CGRectGetWidth(imageFrame))/2;
    imageFrame.origin.y = ((CGRectGetHeight([self bounds]) - CGRectGetHeight(imageFrame))/2);
    [imageView setFrame:imageFrame];
    
    [self addSubview:imageView];
    [self setIconImageView:imageView];
}

- (void)addTitleWithText:(NSString*)title {
    CGRect frame = {
        HEMSensorCheckHorzPadding,
        CGRectGetMaxY([[self iconImageView] frame]) + HEMSensorCheckLabelTopMargin,
        CGRectGetWidth([self bounds]) - (2*HEMSensorCheckHorzPadding),
        HEMSensorCheckTitleHeight
    };
    
    UILabel* label = [[UILabel alloc] initWithFrame:frame];
    [label setTextColor:[HelloStyleKit senseBlueColor]];
    [label setText:[title uppercaseString]];
    [label setNumberOfLines:1];
    [label setAlpha:0.0f];
    [label setTextAlignment:NSTextAlignmentCenter];
    [label setFont:[UIFont onboardingRoomCheckSensorFont]];
    
    [self addSubview:label];
    [self setTitleLabel:label];
}

- (void)addMessageWithText:(NSAttributedString*)message {
    UILabel* label = [[UILabel alloc] init];
    [label setAttributedText:message];
    [label setNumberOfLines:3];
    [label setAlpha:0.0f];
    
    CGFloat width = CGRectGetWidth([self bounds]) - (2*HEMSensorCheckHorzPadding);
    CGSize constraint = CGSizeZero;
    constraint.width = width;
    constraint.height = HEMSensorCheckMessageMaxHeight;

    CGRect frame = {
        HEMSensorCheckHorzPadding,
        CGRectGetMaxY([[self titleLabel] frame]) + HEMSensorCheckLabelTopMargin,
        CGRectGetWidth([self bounds]) - (2*HEMSensorCheckHorzPadding),
        [label sizeThatFits:constraint].height
    };
    [label setFrame:frame];
    
    [self addSubview:label];
    [self setMessageLabel:label];
}

- (void)showSensorValue {
    UILabel* label = [[UILabel alloc] init];
    [label setText:[self value]];
    [label setTextColor:[self conditionColor]];
    [label setFont:[UIFont onboardingRoomCheckSensorValueFont]];
    [label setNumberOfLines:1];
    [label sizeToFit];
    [label setAlpha:0.0f];
    
    CGFloat lastY = CGRectGetMaxY([[self messageLabel] frame]);
    CGFloat spaceLeft = CGRectGetHeight([self bounds]) - lastY;
    
    CGRect frame = [label frame];
    frame.origin.x = (CGRectGetWidth([self bounds]) - CGRectGetWidth(frame))/2;
    frame.origin.y = lastY + (spaceLeft - CGRectGetHeight(frame))/2;
    [label setFrame:frame];
    
    [self addSubview:label];
    [self setValueLabel:label];
    
    [UIView animateWithDuration:0.7f
                     animations:^{
                         [label setAlpha:1.0f];
                     }];
}

- (void)addSeparator {
    CGRect frame = {
        0.0f,
        CGRectGetHeight([self bounds]) - HEMSensorCheckSeparatorHeight,
        CGRectGetWidth([self bounds]),
        HEMSensorCheckSeparatorHeight
    };
    
    // NOTE: with half pixel on the separator, autolayout
    // causes the separator to flicker and disppear on iphone 5/5s
    // so we need to not use constraints and be forced to animate
    // it ourselves
    UIView* separator = [[UIView alloc] initWithFrame:frame];
    [separator setBackgroundColor:[UIColor colorWithWhite:0.0f alpha:0.3f]];
    [separator setAlpha:0.0f];
    
    [self addSubview:separator];
    [self setSeparator:separator];
}

- (void)collapse {
    CGRect frame = [self frame];
    frame.size.height = HEMSensorCheckCollapsedHeight;
    [self setFrame:frame];
    
    // reset
    CGRect sepFrame = [[self separator] frame];
    sepFrame.origin.y = HEMSensorCheckCollapsedHeight - CGRectGetHeight(sepFrame);
    [[self separator] setFrame:sepFrame];
    
    [[self separator] setAlpha:0.0f];
    [[self titleLabel] setAlpha:0.0f];
    [[self messageLabel] setAlpha:0.0f];
}

- (void)moveTo:(CGFloat)y
   andExpandTo:(CGFloat)height
whileAnimating:(void(^)(void))animations
  onCompletion:(void(^)(BOOL finished))completion {
    
    [UIView animateWithDuration:HEMSensorCheckContentAnimationDuration
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         CGRect frame = [self frame];
                         frame.origin.y = y;
                         frame.size.height = height;
                         [self setFrame:frame];
                         
                         CGRect sepFrame = [[self separator] frame];
                         sepFrame.origin.y = height - CGRectGetHeight(sepFrame);
                         [[self separator] setFrame:sepFrame];
                         [[self separator] setAlpha:1.0f];
                         
                         if (animations) animations();
                     }
                     completion:^(BOOL finished) {
                         [self displayContents:completion];
                     }];
    
}

- (void)displayContents:(void(^)(BOOL finished))completion {
    [UIView animateWithDuration:HEMSensorCheckContentAnimationDuration
                     animations:^{
                         [[self iconImageView] setHighlighted:YES];
                         [[self titleLabel] setAlpha:1.0f];
                         [[self messageLabel] setAlpha:1.0f];
                     }
                     completion:completion];
}

@end
