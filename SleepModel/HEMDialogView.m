//
//  HEMDialogView.m
//  Sense
//
//  Created by Jimmy Lu on 11/19/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import "UIFont+HEMStyle.h"

#import "HEMDialogView.h"
#import "HelloStyleKit.h"
#import "HEMActionButton.h"
#import "HEMSupportUtil.h"

static CGFloat const kHEMDialogHorzMargins = 17.0f;
static CGFloat const kHEMDialogCornerRadius = 4.0f;
static CGFloat const kHEMDialogContentSpacing = 30.0f;
static CGFloat const kHEMDialogContentHorzPadding = 25.0f;
static CGFloat const kHEMDialogContentTopPadding = 34.0f;
static CGFloat const kHEMDialogContentBotPadding = 10.0f;
static CGFloat const kHEMDialogContentMaxImageHeight = 150.0f;
static CGFloat const kHEMDialogButtonBorderWidth = 1.0f;
static CGFloat const kHEMDialogButtonHorzPadding = 35.0f;
static CGFloat const kHEMDialogButtonHeight = 40.0f;
static CGFloat const kHEMDialogButtonSpacing = 10.0f;

@interface HEMDialogView()

@property (nonatomic, assign) UIEdgeInsets contentInsets;
@property (nonatomic, copy)   NSString* title;
@property (nonatomic, copy)   NSString* message;
@property (nonatomic, strong) UIImage* image;
@property (nonatomic, weak)   UIButton* okButton; // used as anchor for actions
@property (nonatomic, strong) NSMutableDictionary* actionsCallbacks; // key = title, value = block

@end

@implementation HEMDialogView

+ (CGRect)defaultFrame {
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    CGRect frame = CGRectZero;
    frame.size.width = CGRectGetWidth(screenBounds)-(2*kHEMDialogHorzMargins);
    frame.size.height = kHEMDialogContentTopPadding + kHEMDialogContentBotPadding;
    return frame;
}

- (id)initWithImage:(UIImage*)image
              title:(NSString*)title
            message:(NSString*)message {
    
    return [self initWithImage:image title:title message:message frame:[[self class] defaultFrame]];
}

- (id)initWithImage:(UIImage*)image
              title:(NSString*)title
            message:(NSString*)message
              frame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setImage:image];
        [self setTitle:title];
        [self setMessage:message];
        [self setup];
    }
    return self;
}

- (void)setup {
    [self setActionsCallbacks:[NSMutableDictionary dictionary]];
    [self setContentInsets:UIEdgeInsetsMake(kHEMDialogContentTopPadding,
                                            kHEMDialogContentHorzPadding,
                                            kHEMDialogContentBotPadding,
                                            kHEMDialogContentHorzPadding)];
    
    [self setBackgroundColor:[UIColor whiteColor]];
    [[self layer] setCornerRadius:kHEMDialogCornerRadius];
    [[self layer] setBorderWidth:kHEMDialogButtonBorderWidth];
    [[self layer] setBorderColor:[[UIColor colorWithWhite:0.0f alpha:0.1f] CGColor]];
    
    CGFloat maxY = [self addDialogImage];
    maxY = [self addTitleLabelAtY:maxY];
    maxY = [self addMessageLabel:maxY];
    maxY = [self addOkButtonAtY:maxY];
    
    CGRect myFrame = [self frame];
    myFrame.size.height = maxY + kHEMDialogContentBotPadding;
    [self setFrame:myFrame];
}

- (CGFloat)addDialogImage {
    CGFloat maxY = kHEMDialogContentTopPadding;
    if ([self image] != nil) {
        CGRect imageFrame = {
            [self contentInsets].left,
            [self contentInsets].top,
            CGRectGetWidth([self bounds]) - (2*kHEMDialogContentHorzPadding),
            MIN(kHEMDialogContentMaxImageHeight, [[self image] size].height)
        };
        
        UIImageView* imageView = [[UIImageView alloc] initWithFrame:imageFrame];
        [imageView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        [imageView setTranslatesAutoresizingMaskIntoConstraints:YES];
        [imageView setContentMode:UIViewContentModeCenter];
        [imageView setBackgroundColor:[UIColor clearColor]];
        [imageView setImage:[self image]];
        
        [self addSubview:imageView];
        
        maxY = CGRectGetMaxY(imageFrame) + kHEMDialogContentSpacing;
    }
    return maxY;
}

- (CGFloat)addLabelWithText:(NSString*)text
                   withFont:(UIFont*)font
              numberOfLines:(NSInteger)lines
                        atY:(CGFloat)y {
    
    CGFloat maxY = y;
    
    if ([text length] > 0) {
        UILabel* label = [[UILabel alloc] init];
        [label setText:text];
        [label setTextColor:[UIColor blackColor]];
        [label setFont:font];
        [label setNumberOfLines:lines];
        
        CGRect labelFrame = {
            [self contentInsets].left,
            y,
            CGRectGetWidth([self bounds]) - (2*kHEMDialogContentHorzPadding),
            MAXFLOAT // will get resized later
        };
        CGSize constraint = labelFrame.size;
        CGSize textSize = [label sizeThatFits:constraint];
        labelFrame.size.height = textSize.height;
        [label setFrame:labelFrame];
        
        [self addSubview:label];
        
        maxY = CGRectGetMaxY(labelFrame) + kHEMDialogContentSpacing;
    }
    
    return maxY;
}

- (CGFloat)addTitleLabelAtY:(CGFloat)y {
    return [self addLabelWithText:[self title] withFont:[UIFont dialogTitleFont] numberOfLines:1 atY:y];
}

- (CGFloat)addMessageLabel:(CGFloat)y {
    return [self addLabelWithText:[self message] withFont:[UIFont dialogMessageFont] numberOfLines:0 atY:y];
}

- (CGRect)buttonFrameAtY:(CGFloat)y {
    CGRect buttonFrame = {
        kHEMDialogButtonHorzPadding,
        y,
        CGRectGetWidth([self bounds]) - (2*kHEMDialogButtonHorzPadding),
        kHEMDialogButtonHeight
    };
    return buttonFrame;
}

- (CGFloat)addOkButtonAtY:(CGFloat)y {
    NSString* title = NSLocalizedString(@"actions.ok", nil);
    HEMActionButton* ok = [HEMActionButton buttonWithType:UIButtonTypeCustom];
    [ok setTitle:title forState:UIControlStateNormal];
    [ok setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [ok setTranslatesAutoresizingMaskIntoConstraints:YES];
    [ok addTarget:self action:@selector(customAction:) forControlEvents:UIControlEventTouchUpInside];
    [ok setFrame:[self buttonFrameAtY:y]];

    [self setOkButton:ok];
    [self addSubview:ok];
    
    return CGRectGetMaxY([ok frame]) + kHEMDialogButtonSpacing;
}

#pragma mark - Actions

- (void)onDone:(HEMDialogActionBlock)doneBlock {
    NSString* doneTitle = [[self okButton] titleForState:UIControlStateNormal];
    [[self actionsCallbacks] setValue:[doneBlock copy] forKey:doneTitle];
}

- (void)addActionButtonWithTitle:(NSString*)title
                         primary:(BOOL)primary
                          action:(HEMDialogActionBlock)block {
    
    CGRect okFrame = [[self okButton] frame];
    CGRect buttonFrame = CGRectZero;
    UIButton* button = nil;
    
    if (primary) {
        buttonFrame = [self buttonFrameAtY:CGRectGetMinY(okFrame)];
        button = [HEMActionButton buttonWithType:UIButtonTypeCustom];
    } else {
        buttonFrame = [self buttonFrameAtY:CGRectGetMaxY(okFrame) + kHEMDialogButtonSpacing];
        button = [UIButton buttonWithType:UIButtonTypeCustom];
        [[button titleLabel] setFont:[UIFont secondaryButtonFont]];
    }
    
    [button setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [button setTranslatesAutoresizingMaskIntoConstraints:YES];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[HelloStyleKit senseBlueColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(customAction:) forControlEvents:UIControlEventTouchUpInside];
    [button setFrame:buttonFrame];
    
    [[self actionsCallbacks] setValue:[block copy] forKey:title];

    CGFloat increasedHeight = CGRectGetHeight(buttonFrame) + kHEMDialogButtonSpacing;
    
    if (primary) {
        [self insertSubview:button belowSubview:[self okButton]];
        
        okFrame.origin.y += increasedHeight;
        [[self okButton] setFrame:okFrame];
    } else {
        [self insertSubview:button aboveSubview:[self okButton]];
    }
 
    CGRect myFrame = [self frame];
    myFrame.size.height += increasedHeight;
    [self setFrame:myFrame];
}

- (void)customAction:(UIButton*)button {
    NSString* buttonTitle = [button titleForState:UIControlStateNormal];
    HEMDialogActionBlock block = [[self actionsCallbacks] valueForKey:buttonTitle];
    if (block) {
        block();
    }
}

@end
