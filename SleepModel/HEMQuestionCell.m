//
//  HEMQuestionCell.m
//  Sense
//
//  Created by Jimmy Lu on 12/15/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import "Sense-Swift.h"

#import "HEMQuestionCell.h"
#import "NSAttributedString+HEMUtils.h"

CGFloat const HEMQuestionCellTextPadding = 22.0f;
CGFloat const HEMQuestionCellContentPadding = 8.0f;
CGFloat const HEMQuestionCellBaseHeight = 141.0f;

@interface HEMQuestionCell()

@property (weak, nonatomic) IBOutlet UILabel* titleLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *dividerWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *questionLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *questionTrailingConstraint;

@end

@implementation HEMQuestionCell

+ (CGFloat)heightForCellWithQuestion:(NSAttributedString*)question
                           cellWidth:(CGFloat)width {
    CGFloat maxWidth = width - (HEMQuestionCellTextPadding * 2);
    CGFloat textHeight = [question sizeWithWidth:maxWidth].height;
    return textHeight + HEMQuestionCellBaseHeight;
}

+ (NSDictionary*)questionTextAttributes {
    UIColor* bodyColor = [SenseStyle colorWithAClass:[self class] property:ThemePropertyTextColor];
    UIFont* bodyFont = [SenseStyle fontWithAClass:[self class] property:ThemePropertyTextFont];
    NSMutableParagraphStyle* para = DefaultBodyParagraphStyle();
    [para setAlignment:NSTextAlignmentCenter];
    return @{NSFontAttributeName : bodyFont,
             NSForegroundColorAttributeName : bodyColor,
             NSParagraphStyleAttributeName : para};
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [[self dividerWidthConstraint] setConstant:0.5f];
    
    CGFloat padding = HEMQuestionCellTextPadding-HEMQuestionCellContentPadding;
    [[self questionLeadingConstraint] setConstant:padding];
    [[self questionTrailingConstraint] setConstant:padding];
    
    [[self skipButton] setExclusiveTouch:YES];
    [[self answerButton] setExclusiveTouch:YES];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    [[self questionLabel] setAttributedText:nil];
}

- (void)applyStyle {
    [super applyStyle];
    
    UIColor* titleColor = [SenseStyle colorWithAClass:[self class] property:ThemePropertyTitleColor];
    UIFont* titleFont = [SenseStyle fontWithAClass:[self class] property:ThemePropertyTitleFont];
    UIColor* bodyColor = [SenseStyle colorWithAClass:[self class] property:ThemePropertyTextColor];
    UIFont* bodyFont = [SenseStyle fontWithAClass:[self class] property:ThemePropertyTextFont];
    UIColor* buttonColor = [SenseStyle colorWithAClass:[self class] property:ThemePropertyPrimaryButtonTextColor];
    UIFont* buttonFont = [SenseStyle fontWithAClass:[self class] property:ThemePropertyPrimaryButtonTextColor];
    UIColor* skipButtonColor = [SenseStyle colorWithAClass:[self class] property:ThemePropertySecondaryButtonTextColor];
    UIFont* skipButtonFont = [SenseStyle fontWithAClass:[self class] property:ThemePropertySecondaryButtonTextColor];
    
    [[self titleLabel] setFont:titleFont];
    [[self titleLabel] setTextColor:titleColor];
    [[self questionLabel] setFont:bodyFont];
    [[self questionLabel] setTextColor:bodyColor];
    
    [[[self skipButton] titleLabel] setFont:skipButtonFont];
    [[self skipButton] setTitleColor:skipButtonColor forState:UIControlStateNormal];
    [[[self answerButton] titleLabel] setFont:buttonFont];
    [[self answerButton] setTitleColor:buttonColor forState:UIControlStateNormal];
}

@end
