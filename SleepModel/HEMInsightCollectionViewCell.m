//
//  HEMInsightSummaryView.m
//  Sense
//
//  Created by Jimmy Lu on 10/28/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//
#import <markdown_peg.h>
#import "UIFont+HEMStyle.h"

#import "HEMInsightCollectionViewCell.h"

CGFloat const HEMInsightCellMessagePadding = 16.0f;
CGFloat const HEMInsightCellBaseHeight = 88.0f;
CGFloat const HEMInsightCellMaxMessageHeight = 100.0f;

static CGFloat const HEMInsightCellNaturalPadding = 8.0f;

@interface HEMInsightCollectionViewCell()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint* messageBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint* messageLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint* messageTrailingConstraint;
@property (weak, nonatomic) IBOutlet UILabel* moreLabel;

@property (assign, nonatomic) CGFloat fullMessageBottomConstraintConstant;

@end

@implementation HEMInsightCollectionViewCell

+ (NSDictionary*)messageTextAttributes {
    static NSDictionary* attributes = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableParagraphStyle* style =
            [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
        [style setAlignment:NSTextAlignmentLeft];
        
        UIColor* color = [UIColor colorWithWhite:0.0f alpha:0.7f];
        attributes = @{@(STRONG)  : @{ NSFontAttributeName : [UIFont feedInsightMessageBoldFont],
                                       NSParagraphStyleAttributeName : style,
                                       NSForegroundColorAttributeName : color},
                       @(PLAIN) : @{ NSFontAttributeName : [UIFont settingsInsightMessageFont],
                                     NSParagraphStyleAttributeName : style,
                                     NSForegroundColorAttributeName : color},
                       NSParagraphStyleAttributeName : style,
                       NSFontAttributeName : [UIFont settingsInsightMessageFont],
                       NSForegroundColorAttributeName : color
                      };
    });
    return attributes;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    CGFloat padding = HEMInsightCellMessagePadding - HEMInsightCellNaturalPadding;
    [[self messageLeadingConstraint] setConstant:padding];
    [[self messageTrailingConstraint] setConstant:padding];
    
    [self setFullMessageBottomConstraintConstant:[[self messageBottomConstraint] constant]];
    
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    [[self messageLabel] setAttributedText:nil];
    [[self moreLabel] setHidden:YES];
    [[self messageBottomConstraint] setConstant:[self fullMessageBottomConstraintConstant]];
}

- (void)setMessage:(NSString*)message {
    NSDictionary* attributes = [[self class] messageTextAttributes];
    CGSize constraint = CGSizeMake(CGRectGetWidth([[self contentView] bounds])-HEMInsightCellMessagePadding, MAXFLOAT);
    CGRect textSize = [message boundingRectWithSize:constraint
                                            options:NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin
                                         attributes:attributes
                                            context:nil];
    
    NSAttributedString* text = markdown_to_attr_string(message, 0, [[self class] messageTextAttributes]);
    [[self messageLabel] setAttributedText:text];
    
    BOOL more = CGRectGetHeight(textSize) > HEMInsightCellMaxMessageHeight;
    if (more) {
        textSize.size.height = HEMInsightCellMaxMessageHeight;
        [[self moreLabel] setHidden:NO];
        CGFloat constant = [self fullMessageBottomConstraintConstant];
        CGFloat moreHeight = CGRectGetHeight([[self moreLabel] bounds]);
        [[self messageBottomConstraint] setConstant:constant+moreHeight];
        [self setNeedsDisplay];
    }
    
}

@end
