//
//  HEMQuestionCell.m
//  Sense
//
//  Created by Jimmy Lu on 12/15/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import "HEMQuestionCell.h"
#import "UIFont+HEMStyle.h"

CGFloat const HEMQuestionCellTextPadding = 22.0f;
CGFloat const HEMQuestionCellContentPadding = 8.0f;
CGFloat const HEMQuestionCellBaseHeight = 168.0f;

@interface HEMQuestionCell()

@property (weak, nonatomic) IBOutlet UILabel* titleLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *dividerWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *questionLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *questionTrailingConstraint;

@end

@implementation HEMQuestionCell

+ (NSDictionary*)questionTextAttributes {
    static NSDictionary* attributes = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableParagraphStyle* style =
            [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
        [style setAlignment:NSTextAlignmentCenter];
        
        attributes = @{NSFontAttributeName : [UIFont feedQuestionFont],
                       NSParagraphStyleAttributeName : style};
    });
    return attributes;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [[self dividerWidthConstraint] setConstant:0.5f];
    
    CGFloat padding = HEMQuestionCellTextPadding-HEMQuestionCellContentPadding;
    [[self questionLeadingConstraint] setConstant:padding];
    [[self questionTrailingConstraint] setConstant:padding];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    [[self questionLabel] setAttributedText:nil];
}

@end
