//
//  HEMInsightSummaryView.m
//  Sense
//
//  Created by Jimmy Lu on 10/28/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import "HEMInsightSummaryView.h"
#import "HelloStyleKit.h"

static CGFloat const kHEMInsightSummaryHorizontalMargin = 12.0f;
static CGFloat const kHEMInsightSummaryDefaultHeight = 112.0f;
static CGFloat const kHEMInsightSummaryLabelHorizPadding = 12.0f;
static CGFloat const kHEMInsightSummaryLabelVertPadding = 15.0f;
static CGFloat const kHEMInsightSummaryTitleHeight = 15.0f;

@interface HEMInsightSummaryView()

@property (nonatomic, weak) IBOutlet UILabel* titleLabel;
@property (nonatomic, weak) IBOutlet UILabel* messageLabel;

@end

@implementation HEMInsightSummaryView

+ (CGRect)defaultFrame {
    UIScreen* mainScreen = [UIScreen mainScreen];
    CGFloat screenWidth = CGRectGetWidth([mainScreen bounds]);
    return CGRectMake(0.0f,
                      0.0f,
                      screenWidth-(2*kHEMInsightSummaryHorizontalMargin),
                      kHEMInsightSummaryDefaultHeight);
}

- (id)initWithTitle:(NSString*)title message:(NSString*)message {
    self = [super initWithFrame:[[self class] defaultFrame]];
    if (self) {
        [self setupTitle:title andMessage:message];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupTitle:nil andMessage:nil];
    }
    return self;
}

- (id)init {
    return [self initWithTitle:nil message:nil];
}

- (void)setupTitle:(NSString*)title andMessage:(NSString*)message {
    [self setTitleLabel:[self addTitleLabelWithText:title]];
    [self setMessageLabel:[self addMessageLabelWithText:message
                                      relativeToTopView:[self titleLabel]]];
}

- (void)addHorizontalconstraintsWithItem:(UILabel*)label {
    NSLayoutConstraint* leadingConstraint =
        [NSLayoutConstraint constraintWithItem:label
                                     attribute:NSLayoutAttributeLeading
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:self
                                     attribute:NSLayoutAttributeLeft
                                    multiplier:1.0f
                                      constant:kHEMInsightSummaryHorizontalMargin];
    
    NSLayoutConstraint* trailingConstraint =
        [NSLayoutConstraint constraintWithItem:label
                                     attribute:NSLayoutAttributeTrailing
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:self
                                     attribute:NSLayoutAttributeRight
                                    multiplier:1.0f
                                      constant:kHEMInsightSummaryHorizontalMargin];
    
    [self addConstraints:@[leadingConstraint, trailingConstraint]];
}

- (UILabel*)addTitleLabelWithText:(NSString*)text {
    CGFloat width = CGRectGetWidth([self bounds]) - (2*kHEMInsightSummaryHorizontalMargin);
    CGRect titleFrame = CGRectMake(kHEMInsightSummaryLabelHorizPadding,
                                   kHEMInsightSummaryLabelVertPadding,
                                   width,
                                   kHEMInsightSummaryTitleHeight);
    
    UILabel* label = [[UILabel alloc] initWithFrame:titleFrame];
    [label setBackgroundColor:[self backgroundColor]];
    [label setFont:[UIFont fontWithName:@"Calibre-Regular" size:10.0f]];
    [label setTextColor:[HelloStyleKit onboardingBlueColor]];
    [label setText:text];
    
    NSLayoutConstraint* topConstraint =
        [NSLayoutConstraint constraintWithItem:label
                                     attribute:NSLayoutAttributeTop
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:self
                                     attribute:NSLayoutAttributeTop
                                    multiplier:1.0f
                                      constant:kHEMInsightSummaryLabelVertPadding];
    
    NSLayoutConstraint* heightConstraint =
        [NSLayoutConstraint constraintWithItem:label
                                     attribute:NSLayoutAttributeHeight
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:nil
                                     attribute:NSLayoutAttributeNotAnAttribute
                                    multiplier:1.0f
                                      constant:kHEMInsightSummaryTitleHeight];
    
    [label addConstraint:heightConstraint];
    [self addSubview:label];
    [self addHorizontalconstraintsWithItem:label];
    [self addConstraint:topConstraint];
    
    return label;
}

- (UILabel*)addMessageLabelWithText:(NSString*)text relativeToTopView:(UIView*)topView {
    CGFloat y = CGRectGetMaxY([topView frame]) + kHEMInsightSummaryLabelVertPadding;
    // height is calculated as height of container - minus the max y of the top view, which should
    // account for the top padding + padding between the topview and the padding at the bottom of
    // the container
    CGFloat height = CGRectGetHeight([self bounds]) - y - kHEMInsightSummaryLabelVertPadding;
    CGFloat width = CGRectGetWidth([self bounds]) - (2*kHEMInsightSummaryHorizontalMargin);
    CGRect messageFrame = CGRectMake(kHEMInsightSummaryLabelHorizPadding,
                                     y,
                                     width,
                                     height);
    
    UILabel* label = [[UILabel alloc] initWithFrame:messageFrame];
    [label setBackgroundColor:[self backgroundColor]];
    [label setFont:[UIFont fontWithName:@"Calibre-Thin" size:16.0f]];
    [label setTextColor:[HelloStyleKit onboardingGrayColor]];
    [label setText:text];
    [label setNumberOfLines:0];
    
    NSLayoutConstraint* topConstraint =
        [NSLayoutConstraint constraintWithItem:label
                                     attribute:NSLayoutAttributeTop
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:topView
                                     attribute:NSLayoutAttributeTop
                                    multiplier:1.0f
                                      constant:kHEMInsightSummaryLabelVertPadding];
    
    NSLayoutConstraint* heightConstraint =
        [NSLayoutConstraint constraintWithItem:label
                                     attribute:NSLayoutAttributeHeight
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:nil
                                     attribute:NSLayoutAttributeNotAnAttribute
                                    multiplier:1.0f
                                      constant:height];
    
    [label addConstraint:heightConstraint];
    [self addSubview:label];
    [self addHorizontalconstraintsWithItem:label];
    [self addConstraint:topConstraint];
 
    return label;
}

@end
