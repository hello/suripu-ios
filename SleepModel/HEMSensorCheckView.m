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

@interface HEMSensorCheckView()

@property (nonatomic, weak) UIImageView* iconImageView;
@property (nonatomic, weak) UILabel* titleLabel;
@property (nonatomic, weak) UILabel* messageLabel;

@end

@implementation HEMSensorCheckView

+ (CGFloat)collapsedHeight {
    return HEMSensorCheckCollapsedHeight;
}

- (instancetype)initWithIcon:(UIImage*)icon
             highlightedIcon:(UIImage*)highlighedIcon
                       title:(NSString*)title
                     message:(NSString*)message {
    
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
    }
    return self;
}

- (void)addIconImageViewWithIcon:(UIImage*)icon highlightedIcon:(UIImage*)highlightedIcon {
    UIImageView* imageView = [[UIImageView alloc] initWithImage:icon];
    [imageView setHighlightedImage:highlightedIcon];
    [imageView setContentMode:UIViewContentModeScaleAspectFit];
    
    CGRect imageFrame = [imageView frame];
    imageFrame.size = [icon size];
    imageFrame.origin.x = (CGRectGetWidth([self bounds]) - CGRectGetWidth(imageFrame))/2;
    imageFrame.origin.y = ((CGRectGetHeight([self bounds]) - CGRectGetHeight(imageFrame))/2);
    [imageView setFrame:imageFrame];
    
    [self addSubview:imageView];
    [[self iconImageView] setFrame:imageFrame];
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
    [label setHidden:YES];
    [label setAlpha:0.0f];
    [label setTextAlignment:NSTextAlignmentCenter];
    [label setFont:[UIFont onboardingRoomCheckSensorFont]];
    
    [self addSubview:label];
    [self setTitleLabel:label];
}

- (void)addMessageWithText:(NSString*)message {
    UILabel* label = [[UILabel alloc] init];
    [label setText:message];
    [label setTextColor:[UIColor blackColor]];
    [label setFont:[UIFont onboardingRoomCheckSensorFont]];
    [label setNumberOfLines:3];
    [label setHidden:YES];
    [label setAlpha:0.0f];
    [label setTextAlignment:NSTextAlignmentCenter];
    
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

@end
