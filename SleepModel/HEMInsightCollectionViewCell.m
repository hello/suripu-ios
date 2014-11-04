//
//  HEMInsightSummaryView.m
//  Sense
//
//  Created by Jimmy Lu on 10/28/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import "UIFont+HEMStyle.h"

#import "HEMInsightCollectionViewCell.h"
#import "HelloStyleKit.h"

static CGFloat const kHEMInsightSummaryHorizontalMargin = 12.0f;
static CGFloat const kHEMInsightSummaryDefaultHeight = 112.0f;
static CGFloat const kHEMInsightSummaryLabelHorizPadding = 12.0f;
static CGFloat const kHEMInsightSummaryLabelVertPadding = 15.0f;
static CGFloat const kHEMInsightSummaryTitleHeight = 15.0f;
static CGFloat const kHEMInsightSummaryCornerRadius = 3.0f;

@interface HEMInsightCollectionViewCell()

@property (nonatomic, weak) IBOutlet UILabel* titleLabel;
@property (nonatomic, weak) IBOutlet UILabel* messageLabel;

@end

@implementation HEMInsightCollectionViewCell

+ (CGRect)defaultFrame {
    UIScreen* mainScreen = [UIScreen mainScreen];
    CGFloat screenWidth = CGRectGetWidth([mainScreen bounds]);
    return CGRectMake(0.0f,
                      0.0f,
                      screenWidth,
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
    [self setBackgroundColor:[UIColor whiteColor]];
    [[self layer] setCornerRadius:kHEMInsightSummaryCornerRadius];
    
    [self setTitleLabel:[self addTitleLabelWithText:title]];
    [self setMessageLabel:[self addMessageLabelWithText:message
                                      relativeToTopView:[self titleLabel]]];
}

- (UILabel*)addTitleLabelWithText:(NSString*)text {
    CGFloat containerWidth = CGRectGetWidth([[self contentView] bounds]);
    CGFloat width = containerWidth - (2*kHEMInsightSummaryHorizontalMargin);
    CGRect titleFrame = CGRectMake(kHEMInsightSummaryLabelHorizPadding,
                                   kHEMInsightSummaryLabelVertPadding,
                                   width,
                                   kHEMInsightSummaryTitleHeight);
    
    UILabel* label = [[UILabel alloc] initWithFrame:titleFrame];
    [label setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [label setTranslatesAutoresizingMaskIntoConstraints:YES];
    [label setBackgroundColor:[self backgroundColor]];
    [label setFont:[UIFont insightTitleFont]];
    [label setTextColor:[HelloStyleKit senseBlueColor]];
    [label setText:text];
    
    [[self contentView] addSubview:label];
    
    return label;
}

- (UILabel*)addMessageLabelWithText:(NSString*)text relativeToTopView:(UIView*)topView {
    CGFloat containerWidth = CGRectGetWidth([[self contentView] bounds]);
    CGFloat containerHeight = CGRectGetHeight([[self contentView] bounds]);
    CGFloat y = CGRectGetMaxY([topView frame]) + kHEMInsightSummaryLabelVertPadding;
    // height is calculated as height of container - minus the max y of the top view, which should
    // account for the top padding + padding between the topview and the padding at the bottom of
    // the container
    CGFloat height = containerHeight - y - kHEMInsightSummaryLabelVertPadding;
    CGFloat width = containerWidth - (2*kHEMInsightSummaryHorizontalMargin);
    CGRect messageFrame = CGRectMake(kHEMInsightSummaryLabelHorizPadding,
                                     y,
                                     width,
                                     height);
    
    UILabel* label = [[UILabel alloc] initWithFrame:messageFrame];
    [label setBackgroundColor:[self backgroundColor]];
    [label setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [label setFont:[UIFont settingsInsightMessageFont]];
    [label setTextColor:[HelloStyleKit onboardingGrayColor]];
    [label setText:text];
    [label setNumberOfLines:3];

    [[self contentView] addSubview:label];
 
    return label;
}

- (void)fitToText:(UILabel*)label {
    CGSize constraint = [label bounds].size;
    CGSize size = [label sizeThatFits:constraint];
    CGRect frame = [label frame];
    frame.size.height = size.height;
    [label setFrame:frame];
}

- (void)setTitle:(NSString*)title message:(NSString*)message {
    
    [[self titleLabel] setText:title];
    [self fitToText:[self titleLabel]];
    
    [[self messageLabel] setText:message];
    [self fitToText:[self messageLabel]];
    
}

@end
