//
//  HEMActionView.m
//  Sense
//
//  Created by Jimmy Lu on 12/1/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//
#import "Sense-Swift.h"
#import "HEMActionView.h"
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
static CGFloat const HEMActionViewAnimationDuration = 0.25f;

@interface HEMActionView()

@property (nonatomic, assign) UIEdgeInsets insets;
@property (nonatomic, weak)   UIView* titleView;
@property (nonatomic, weak)   UILabel* messageLabel;
@property (nonatomic, weak)   UIView* buttonContainer;
@property (nonatomic, weak)   UIView* topView;

@property (nonatomic, weak, readwrite) UIButton* cancelButton;
@property (nonatomic, weak, readwrite) UIButton* okButton;

@end

@implementation HEMActionView
    
+ (NSDictionary*)messageAttributes {
    NSMutableParagraphStyle* para = [NSMutableParagraphStyle senseStyle];
    [para setAlignment:NSTextAlignmentCenter];
    return @{NSParagraphStyleAttributeName : para,
             NSFontAttributeName : [SenseStyle fontWithAClass:self property:ThemePropertyTextFont],
             NSForegroundColorAttributeName : [SenseStyle colorWithAClass:self property:ThemePropertyTextColor]};
}

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
    
    NSShadow* shadow = [NSShadow shadowForActionView];
    [[self layer] setShadowColor:[[shadow shadowColor] CGColor]];
    [[self layer] setShadowOffset:[shadow shadowOffset]];
    [[self layer] setShadowRadius:[shadow shadowBlurRadius]];
    [[self layer] setShadowOpacity:1.0f];
    
    [self applyStyle];
}

- (void)setupWithTitle:(NSString*)title andMessage:(NSAttributedString*)message {
    if ([title length] > 0) {
        _title = [title copy];
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
    frame.size.height = CGRectGetMaxY([[self buttonContainer] frame]);
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
    [label setTextColor:[SenseStyle colorWithAClass:[self class] property:ThemePropertyTitleColor]];
    [label setFont:[SenseStyle fontWithAClass:[self class] property:ThemePropertyTitleFont]];
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
    UIButton* cancelButton = [self actionButtonWithText:cancelText andXOrigin:0.0f];
    [cancelButton applySecondaryStyle];
    [container addSubview:cancelButton];
    
    NSString* okText = [NSLocalizedString(@"actions.ok", nil) uppercaseString];
    CGFloat x = CGRectGetMaxX([cancelButton frame])+HEMActionButtonDividerWidth;
    UIButton* okButton = [self actionButtonWithText:okText andXOrigin:x];
    [okButton applyStyle];
    [container addSubview:okButton];
    
    [self addSubview:container];
    [self setCancelButton:cancelButton];
    [self setOkButton:okButton];
    [self setButtonContainer:container];
}

- (UIButton*)actionButtonWithText:(NSString*)text andXOrigin:(CGFloat)x {
    CGRect frame = {
        x,
        0.0f,
        (CGRectGetWidth([self bounds])-HEMActionButtonDividerWidth)/2,
        HEMActionButtonHeight
    };
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:text forState:UIControlStateNormal];
    [button setBackgroundColor:[UIColor clearColor]];
    [button setFrame:frame];
    return button;
}

- (void)drawRect:(CGRect)rect {
    if (![[self okButton] isHidden]) {
        UIColor* color = [SenseStyle colorWithAClass:[self class] property:ThemePropertySeparatorColor];
        
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSaveGState(context);
        CGContextSetStrokeColorWithColor(context, [color CGColor]);
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

- (void)layoutSubviews {
    [super layoutSubviews];
    [self updateOrigin];
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

- (void)updateOrigin {
    CGFloat containerHeight = CGRectGetHeight([[self superview] bounds]);
    CGRect myFrame = [self frame];
    if ([[self topView] isHidden]) {
        myFrame.origin.y = containerHeight - CGRectGetHeight(myFrame);
    } else {
        CGFloat topViewHeight = CGRectGetHeight([[self topView] bounds]);
        myFrame.origin.y = containerHeight - CGRectGetHeight(myFrame) - topViewHeight;
    }
    [self setFrame:myFrame];
}

#pragma mark - Show / Hide

- (void)showInView:(UIView*)view
             below:(UIView*)topView
          animated:(BOOL)animated
        completion:(void(^)(void))completion {
    
    CGFloat bHeight = CGRectGetHeight([view bounds]);
    CGFloat bWidth = CGRectGetWidth([view bounds]);
    
    CGRect myFrame = [self frame];
    myFrame.origin.y = bHeight;
    myFrame.size.width = bWidth;
    [self setFrame:myFrame];
    
    [self setTopView:topView];
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
                         [self updateOrigin];
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
                         [self setTopView:nil];
                         if (completion) completion ();
                     }];
}
    
- (void)applyStyle {
    [self applyFillStyle];
}

@end
