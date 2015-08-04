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
    }
    return self;
}

- (void)configureViewWithWidth:(CGFloat)width {
    [self setAutoresizingMask:UIViewAutoresizingFlexibleWidth];

    UIImage* closeImage = [UIImage imageNamed:@"closeX.png"];
    NSDictionary* textAttributes = @{NSFontAttributeName : [UIFont handholdingMessageFont]};
    CGFloat buttonWidth = (2*HEMHintMessagePadding) + closeImage.size.width;
    CGFloat labelWidth = width - buttonWidth - (2 * HEMHintMessagePadding);
    
    CGSize constraint = CGSizeMake(labelWidth, MAXFLOAT);
    CGSize textSize = [[self message] boundingRectWithSize:constraint
                                                   options:NSStringDrawingUsesFontLeading |
                                                           NSStringDrawingUsesLineFragmentOrigin
                                                attributes:textAttributes context:nil].size;
    
    CGFloat viewHeight = textSize.height + (2 * HEMHintMessagePadding);
    
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
