//
//  HEMActionView.m
//  Sense
//
//  Created by Jimmy Lu on 12/1/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import "HEMActionView.h"
#import "HEMStyle.h"
#import "HEMScreenUtils.h"

static CGFloat const HEMActionViewHorzPadding = 30.0f;
static CGFloat const HEMActionViewTopPadding = 24.0f;
static CGFloat const HEMActionViewTopPaddingWithoutTitle = 34.0f;
static CGFloat const HEMActionViewBotPadding = 0.0f;
static CGFloat const HEMActionViewTitleHeight = 40.0f;
static CGFloat const HEMActionButtonDividerWidth = 1.0f;
static CGFloat const HEMActionButtonDividerHeight = 35.0f;
static CGFloat const HEMActionButtonDividerVertPadding = 14.0f;
static CGFloat const HEMActionButtonHeight = 63.0f; // (divider padding * 2) + divider height
static CGFloat const HEMActionButtonTopPadding = 20.0f;
static CGFloat const HEMActionViewExtraSpaceForSpring = 20.0f;
static CGFloat const HEMActionViewAnimationDuration = 0.25f;
static CGFloat const HEMActionViewExtraBottomMargin = 0.0f;

@interface HEMActionView()

@property (nonatomic, assign) UIEdgeInsets insets;
@property (nonatomic, weak)   UIView* titleView;
@property (nonatomic, weak)   UILabel* messageLabel;
@property (nonatomic, weak)   UIView* buttonContainer;

@property (nonatomic, weak, readwrite) UIButton* cancelButton;
@property (nonatomic, weak, readwrite) UIButton* okButton;

@end

@implementation HEMActionView

+ (CGRect)defaultFrame {
    return (CGRect){
        0.0f,
        0.0f,
        CGRectGetWidth(HEMKeyWindowBounds()),
        0.0f // will be updated based on content size
    };
}

- (instancetype)initWithTitle:(NSString*)title message:(NSAttributedString*)attributedMessage {
    self = [super initWithFrame:[[self class] defaultFrame]];
    if (self) {
        [self setupAppearance];
        [self setupWithTitle:title andMessage:attributedMessage];
    }
    return self;
}

- (instancetype)initWithTitleView:(UIView*)titleView message:(NSAttributedString*)attributedMessage {
    self = [super initWithFrame:[[self class] defaultFrame]];
    if (self) {
        [self setupAppearance];
        [self setupWithTitleView:titleView andMessage:attributedMessage];
    }
    return self;
}

- (void)setupAppearance {
    // setting insets from constants just to make it easier to use / understand
    [self setInsets:UIEdgeInsetsMake(HEMActionViewTopPadding,
                                     HEMActionViewHorzPadding,
                                     HEMActionViewBotPadding,
                                     HEMActionViewHorzPadding)];
    
    [self setBackgroundColor:[UIColor colorWithWhite:1.0f alpha:0.97f]];
    
    NSShadow* shadow = [NSShadow shadowForActionView];
    [[self layer] setShadowColor:[[shadow shadowColor] CGColor]];
    [[self layer] setShadowOffset:[shadow shadowOffset]];
    [[self layer] setShadowRadius:[shadow shadowBlurRadius]];
    [[self layer] setShadowOpacity:1.0f];
}

- (void)setupWithTitle:(NSString*)title andMessage:(NSAttributedString*)message {
    if ([title length] > 0) {
        [self addTitleLabelWithText:title];
    }
    
    [self addMessageLabelWithText:message];
    [self addActionButtons];
    [self sizeToFitContent];
}

- (void)setupWithTitleView:(UIView*)titleView andMessage:(NSAttributedString*)message {
    if (titleView != nil) {
        [titleView setFrame:[self titleFrame]];
        [self addSubview:titleView];
    }

    [self addMessageLabelWithText:message];
    [self addActionButtons];
    [self sizeToFitContent];
}

- (void)sizeToFitContent {
    CGRect frame = [self frame];
    frame.size.height = CGRectGetMaxY([[self buttonContainer] frame]) + HEMActionViewExtraSpaceForSpring;
    [self setFrame:frame];
}

- (CGRect)titleFrame {
    CGRect frame = {
        [self insets].left,
        [self insets].top,
        CGRectGetWidth([self bounds])-[self insets].left - [self insets].right,
        HEMActionViewTitleHeight
    };
    return frame;
}

- (void)addTitleLabelWithText:(NSString*)title {
    UILabel* label = [[UILabel alloc] initWithFrame:[self titleFrame]];
    [label setBackgroundColor:[UIColor clearColor]];
    [label setTextColor:[UIColor grey6]];
    [label setFont:[UIFont h5]];
    [label setTextAlignment:NSTextAlignmentCenter];
    [label setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [label setTranslatesAutoresizingMaskIntoConstraints:YES];
    [label setNumberOfLines:1];
    [label setText:title];
    
    [self addSubview:label];
    [self setTitleView:label];
}

- (void)addMessageLabelWithText:(NSAttributedString*)message {
    CGFloat titleHeight = CGRectGetHeight([[self titleView] bounds]);
    CGRect frame = {
        [self insets].left,
        MAX(titleHeight + HEMActionViewTopPadding, HEMActionViewTopPaddingWithoutTitle),
        CGRectGetWidth([self bounds])-[self insets].left-[self insets].right,
        0.0f // will update based on message
    };
    
    UILabel* label = [[UILabel alloc] init];
    [label setBackgroundColor:[UIColor clearColor]];
    [label setNumberOfLines:0];
    [label setAttributedText:message];
    [label setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [label setTranslatesAutoresizingMaskIntoConstraints:YES];
    
    CGSize constraint = frame.size;
    constraint.height = MAXFLOAT;
    frame.size.height = [label sizeThatFits:constraint].height;
    [label setFrame:frame];
    
    [self addSubview:label];
    [self setMessageLabel:label];
}

- (void)addActionButtons {
    CGRect containerFrame = {
        0.0f,
        CGRectGetMaxY([[self messageLabel] frame]) + HEMActionButtonTopPadding,
        CGRectGetWidth([self bounds]),
        HEMActionButtonHeight
    };
    UIView* container = [[UIView alloc] initWithFrame:containerFrame];
    [container setBackgroundColor:[UIColor clearColor]];
    [container setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [container setTranslatesAutoresizingMaskIntoConstraints:YES];
    
    NSString* cancelText = [NSLocalizedString(@"actions.skip", nil) uppercaseString];
    UIColor * cancelColor = [UIColor grey4];
    UIButton* cancelButton = [self actionButtonWithText:cancelText color:cancelColor andXOrigin:0.0f];
    [container addSubview:cancelButton];
    
    NSString* okText = [NSLocalizedString(@"actions.ok", nil) uppercaseString];
    UIColor* okColor = [UIColor tintColor];
    CGFloat x = CGRectGetMaxX([cancelButton frame])+HEMActionButtonDividerWidth;
    UIButton* okButton = [self actionButtonWithText:okText color:okColor andXOrigin:x];
    [container addSubview:okButton];
    
    [self addSubview:container];
    [self setCancelButton:cancelButton];
    [self setOkButton:okButton];
    [self setButtonContainer:container];
    
}

- (UIButton*)actionButtonWithText:(NSString*)text
                            color:(UIColor*)color
                       andXOrigin:(CGFloat)x {
    CGRect frame = {
        x,
        0.0f,
        (CGRectGetWidth([self bounds])-HEMActionButtonDividerWidth)/2,
        HEMActionButtonHeight
    };
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    [[button titleLabel] setFont:[UIFont button]];
    [button setTitle:text forState:UIControlStateNormal];
    [button setTitleColor:color forState:UIControlStateNormal];
    [button setBackgroundColor:[UIColor clearColor]];
    [button setFrame:frame];
    return button;
}

- (void)drawRect:(CGRect)rect {
    if (![[self okButton] isHidden]) {
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSaveGState(context);
        CGContextSetStrokeColorWithColor(context, [[UIColor separatorColor] CGColor]);
        CGContextSetLineWidth(context, HEMActionButtonDividerWidth);
        
        // add a line at the middle of the view, at the bottom where the button container is
        CGFloat x = ((CGRectGetWidth([self bounds]) - HEMActionButtonDividerWidth))/2;
        CGFloat y = (CGRectGetMinY([[self buttonContainer] frame])) + HEMActionButtonDividerVertPadding;
        CGContextMoveToPoint(context, x, y);
        CGContextAddLineToPoint(context, x, y + HEMActionButtonDividerHeight);
        
        CGContextStrokePath(context);
        CGContextRestoreGState(context);
    }
}

- (void)hideOkButton {
    CGFloat okWidth = CGRectGetWidth([[self okButton] frame]);
    
    CGRect cancelFrame = [[self cancelButton] frame];
    cancelFrame.size.width += okWidth;
    [[self cancelButton] setFrame:cancelFrame];
    
    [[self cancelButton] setTitleColor:[UIColor tintColor] forState:UIControlStateNormal];
    
    [[self okButton] setHidden:YES];
    
    [self setNeedsDisplay];
}

#pragma mark - Show / Hide

- (void)showInView:(UIView*)view
             below:(UIView*)topView
          animated:(BOOL)animated
        completion:(void(^)(void))completion {
    
    CGFloat topViewHeight = CGRectGetHeight([topView bounds]);
    CGFloat bHeight = CGRectGetHeight([view bounds]);
    CGFloat bWidth = CGRectGetWidth([view bounds]);
    
    CGRect myFrame = [self frame];
    myFrame.origin.y = bHeight;
    myFrame.size.width = bWidth;
    [self setFrame:myFrame];
    
    [self setNeedsDisplay];
    
    if (topView) {
        [view insertSubview:self belowSubview:topView];
    } else {
        [view addSubview:self];
    }
    
    CGFloat damping = 0.6f;
    CGFloat duration = HEMActionViewAnimationDuration * (1 + damping);
    [UIView animateWithDuration:animated?duration:0.0f
                          delay:0.0f
         usingSpringWithDamping:0.6f
          initialSpringVelocity:0.0f
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         CGRect myFrame = [self frame];
                         myFrame.origin.y = bHeight - CGRectGetHeight(myFrame) + HEMActionViewExtraSpaceForSpring - topViewHeight - HEMActionViewExtraBottomMargin;
                         [self setFrame:myFrame];
                     }
                     completion:^(BOOL finished) {
                         if (completion) completion ();
                     }];
}

- (void)dismiss:(BOOL)animated completion:(void(^)(void))completion {
    CGFloat bHeight = CGRectGetHeight([[self superview] bounds]);
    
    [UIView animateWithDuration:animated?HEMActionViewAnimationDuration:0.0f
                     animations:^{
                         CGRect myFrame = [self frame];
                         myFrame.origin.y = bHeight;
                         [self setFrame:myFrame];
                     }
                     completion:^(BOOL finished) {
                         [self removeFromSuperview];
                         if (completion) completion ();
                     }];
}

@end
