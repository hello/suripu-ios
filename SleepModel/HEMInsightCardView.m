//
//  HEMInsightCardView.m
//  Sense
//
//  Created by Jimmy Lu on 11/11/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import "UIFont+HEMStyle.h"

#import "HEMInsightCardView.h"
#import "HEMActionButton.h"
#import "HelloStyleKit.h"

static CGFloat const kHEMInsightCardCornerRadius = 5.0f;
static CGFloat const kHEMInsightCardBorderWidth = 0.5f;
static CGFloat const kHEMInsightCardHMargin = 20.0f;
static CGFloat const kHEMInsightCardHPadding = 15.0f;
static CGFloat const kHEMInsightCardVPadding = 20.0f;
static CGFloat const kHEMInsightCardLabelSpacing = 15.0f;
static CGFloat const kHEMInsightCardButtonSpacing = 30.0f;
static CGFloat const kHEMInsightCardDefaultLabelHeight = 30.0f;
static CGFloat const kHEMInsightCardButtonHeight = 40.0f;
static CGFloat const kHEMInsightCardAnimDuration = 0.3f;

@interface HEMInsightCardView()

@property (nonatomic, weak) UILabel* titleLabel;
@property (nonatomic, weak) UILabel* messageLabel;
@property (nonatomic, weak) HEMActionButton* okButton;
@property (nonatomic, copy) HEMInsightDismissBBlock dismissblock;

@end

@implementation HEMInsightCardView

+ (CGRect)defaultFrame {
    UIScreen* screen = [UIScreen mainScreen];
    CGRect frame = CGRectZero;
    frame.size.width = CGRectGetWidth([screen bounds]) - kHEMInsightCardHMargin;
    frame.size.height =
        (kHEMInsightCardHPadding * 2)
        + kHEMInsightCardDefaultLabelHeight
        + kHEMInsightCardLabelSpacing
        + kHEMInsightCardDefaultLabelHeight
        + kHEMInsightCardButtonSpacing
        + kHEMInsightCardButtonHeight;
    return frame;
}

- (id)init {
    return [self initWithFrame:[[self class] defaultFrame]];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    [self setBackgroundColor:[UIColor whiteColor]];
    [[self layer] setCornerRadius:kHEMInsightCardCornerRadius];
    [[self layer] setBorderWidth:kHEMInsightCardBorderWidth];
    [[self layer] setBorderColor:[[UIColor colorWithWhite:0.0f alpha:0.3f] CGColor]];
    
    [self addTitleLabel];
    [self addMessageLabelRelativeTo:[self titleLabel]];
    [self addOkButtonRelativeTo:[self messageLabel]];
}

- (CGFloat)subviewWidth {
    return CGRectGetWidth([self bounds]) - (2*kHEMInsightCardHPadding);
}

- (void)addTitleLabel {
    CGRect titleFrame = {
        kHEMInsightCardHPadding,
        kHEMInsightCardVPadding,
        [self subviewWidth],
        kHEMInsightCardDefaultLabelHeight
    };
    
    UILabel* title = [[UILabel alloc] initWithFrame:titleFrame];
    [title setTextColor:[HelloStyleKit senseBlueColor]];
    [title setFont:[UIFont insightCardTitleFont]];
    [title setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin];
    [title setTranslatesAutoresizingMaskIntoConstraints:YES];
    
    [self setTitleLabel:title];
    [self addSubview:title];
}

- (void)addMessageLabelRelativeTo:(UIView*)topView {
    CGRect messageFrame = {
        kHEMInsightCardHPadding,
        CGRectGetMaxY([topView frame]) + kHEMInsightCardLabelSpacing,
        [self subviewWidth],
        kHEMInsightCardDefaultLabelHeight
    };
    
    UILabel* message = [[UILabel alloc] initWithFrame:messageFrame];
    [message setTextColor:[UIColor blackColor]];
    [message setFont:[UIFont insightCardMessageFont]];
    [message setNumberOfLines:0];
    [message setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [message setTranslatesAutoresizingMaskIntoConstraints:YES];
    
    [self setMessageLabel:message];
    [self addSubview:message];
}

- (void)addOkButtonRelativeTo:(UIView*)topView {
    CGRect buttonFrame = {
        kHEMInsightCardHPadding,
        CGRectGetMaxY([topView frame]) + kHEMInsightCardButtonSpacing,
        [self subviewWidth],
        kHEMInsightCardButtonHeight
    };
    
    HEMActionButton* ok = [HEMActionButton buttonWithType:UIButtonTypeCustom];
    [ok setFrame:buttonFrame];
    [ok setTitle:NSLocalizedString(@"actions.ok", nil) forState:UIControlStateNormal];
    [ok setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin];
    [ok setTranslatesAutoresizingMaskIntoConstraints:YES];
    [ok addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    
    [self setOkButton:ok];
    [self addSubview:ok];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGSize constraint = [[self messageLabel] bounds].size;
    constraint.height = MAXFLOAT;
    CGSize messageSize = [[self messageLabel] sizeThatFits:constraint];
    
    CGRect messageFrame = [[self messageLabel] frame];
    messageFrame.size.height = messageSize.height;
    [[self messageLabel] setFrame:messageFrame];
    
    CGRect okFrame = [[self okButton] frame];
    okFrame.origin.y = CGRectGetMaxY(messageFrame) + kHEMInsightCardButtonSpacing;
    [[self okButton] setFrame:okFrame];
    
    CGRect myFrame = [self frame];
    myFrame.size.height = CGRectGetMaxY([[self okButton] frame]) + kHEMInsightCardVPadding;
    [self setFrame:myFrame];
}

- (void)setTitle:(NSString*)title andMessage:(NSString*)message {
    [[self titleLabel] setText:title];
    [[self messageLabel] setText:message];
    [self setNeedsLayout];
}

- (void)showInsightTitle:(NSString*)title
             withMessage:(NSString*)message
                  inView:(UIView*)view
              completion:(void(^)(BOOL finished))completion
            dismissBlock:(HEMInsightDismissBBlock)dismissBlock {
    
    [self setTitle:title andMessage:message];
    [self setAlpha:0.0f];
    [self setDismissblock:dismissBlock];
    
    CGRect myFrame = [self frame];
    myFrame.size.width = CGRectGetWidth([view bounds]) - (2*kHEMInsightCardHMargin);
    myFrame.origin.x = kHEMInsightCardHMargin;
    myFrame.origin.y = (CGRectGetHeight([view bounds]) - CGRectGetHeight(myFrame))/2;
    [self setFrame:myFrame];
    
    [view addSubview:self];
    
    [UIView animateWithDuration:kHEMInsightCardAnimDuration
                     animations:^{
                         [self setAlpha:1.0f];
                     }
                     completion:completion];
}

- (void)dismiss {
    [UIView animateWithDuration:kHEMInsightCardAnimDuration
                     animations:^{
                         [self setAlpha:0.0f];
                     } completion:^(BOOL finished) {
                         [self removeFromSuperview];
                         if ([self dismissblock]) [self dismissblock]();
                     }];
}

@end
