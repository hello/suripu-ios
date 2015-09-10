//
//  HEMHintMessageView.m
//  Sense
//
//  Created by Jimmy Lu on 6/18/15.
//  Copyright (c) 2015 Hello. All rights reserved.
//

#import "UIFont+HEMStyle.h"

#import "HEMHintMessageView.h"
#import "UIColor+HEMStyle.h"
#import "NSShadow+HEMStyle.h"
#import "NSString+HEMUtils.h"

static CGFloat const HEMHintMessagePadding = 18.0f;

@interface HEMHintMessageView()

@property (nonatomic, copy) NSString* message;
@property (nonatomic, strong) UIButton* dismissButton;

@end

@implementation HEMHintMessageView

- (instancetype)initWithMessage:(NSString*)message constrainedToWidth:(CGFloat)width {
    self = [super init];
    if (self) {
        _message = [message copy];
        [self configureViewWithWidth:width];
        [self configureShadow];
    }
    return self;
}

- (void)configureShadow {
    NSShadow* shadow = [NSShadow shadowForHandholdingMessage];
    CALayer* layer = [self layer];
    [layer setShadowOpacity:1.0f];
    [layer setShadowOffset:[shadow shadowOffset]];
    [layer setShadowRadius:[shadow shadowBlurRadius]];
    [layer setShadowColor:[[shadow shadowColor] CGColor]];
}

- (void)configureViewWithWidth:(CGFloat)width {
    [self setAutoresizingMask:UIViewAutoresizingFlexibleWidth];

    UIImage* closeImage = [UIImage imageNamed:@"closeX"];
    CGFloat buttonWidth = (2*HEMHintMessagePadding) + closeImage.size.width;
    CGFloat labelWidth = width - buttonWidth - (2 * HEMHintMessagePadding);
    CGFloat textHeight = [self.message heightBoundedByWidth:labelWidth usingFont:[UIFont handholdingMessageFont]];
    CGFloat viewHeight = textHeight + (2 * HEMHintMessagePadding);

    CGSize labelSize = CGSizeMake(labelWidth, viewHeight);
    UILabel* messageLabel = [self messageLabelWithText:[self message] size:labelSize];
    
    CGFloat buttonLeftMargin = labelWidth + ( 2 * HEMHintMessagePadding);
    CGRect buttonFrame = CGRectMake(buttonLeftMargin, 0.0f, buttonWidth, viewHeight);
    UIButton* dismissButton = [self dismissButtonWithImage:closeImage withFrame:buttonFrame];
    
    CGRect frame = CGRectZero;
    frame.size.width = width;
    frame.size.height = viewHeight;
    
    [self setFrame:frame];
    [self setBackgroundColor:[UIColor handholdingMessageBackgroundColor]];
    [self addSubview:messageLabel];
    [self addSubview:dismissButton];
    [self setDismissButton:dismissButton];
}

- (UIButton*)dismissButtonWithImage:(UIImage*)image withFrame:(CGRect)frame {
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:image forState:UIControlStateNormal];
    [button setFrame:frame];
    [button setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin];
    [button setBackgroundColor:[UIColor handholdingMessageBackgroundColor]];
    
    return button;
}

- (UILabel*)messageLabelWithText:(NSString*)text size:(CGSize)size {
    CGRect frame = CGRectZero;
    frame.origin.x = HEMHintMessagePadding;
    frame.size = size;
    
    UILabel* label = [[UILabel alloc] initWithFrame:frame];
    [label setText:text];
    [label setNumberOfLines:0];
    [label setFont:[UIFont handholdingMessageFont]];
    [label setTextColor:[UIColor whiteColor]];
    [label setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
    [label setBackgroundColor:[UIColor handholdingMessageBackgroundColor]];
    
    return label;
}

@end
