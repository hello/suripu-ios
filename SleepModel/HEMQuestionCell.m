//
//  HEMQuestionCell.m
//  Sense
//
//  Created by Jimmy Lu on 12/15/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import "HEMQuestionCell.h"

#import "UIFont+HEMStyle.h"
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

- (void)awakeFromNib {
    [super awakeFromNib];
    [[self dividerWidthConstraint] setConstant:0.5f];
    
    CGFloat padding = HEMQuestionCellTextPadding-HEMQuestionCellContentPadding;
    [[self questionLeadingConstraint] setConstant:padding];
    [[self questionTrailingConstraint] setConstant:padding];
    [[self titleLabel] setFont:[UIFont h7Bold]];
    
    [[self skipButton] setExclusiveTouch:YES];
    [[self answerButton] setExclusiveTouch:YES];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    [[self questionLabel] setAttributedText:nil];
}

@end
