//
//  HEMInsightSummaryView.m
//  Sense
//
//  Created by Jimmy Lu on 10/28/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//
#import <AttributedMarkdown/markdown_peg.h>
#import "UIFont+HEMStyle.h"
#import "HEMMarkdown.h"
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
        attributes = @{
            NSParagraphStyleAttributeName : style,
            NSForegroundColorAttributeName : color
        };
    });
    return attributes;
}

+ (NSAttributedString*)attributedTextForMessage:(NSString*)message {
    NSMutableDictionary* markdownAttributes = [[HEMMarkdown attributesForBackViewText] mutableCopy];
    markdownAttributes[@(PARA)] = [[self class] messageTextAttributes];
    return markdown_to_attr_string(message, 0, markdownAttributes);
}

+ (CGSize)textSizeForMessage:(NSString*)message inWidth:(CGFloat)contentWidth {
    NSAttributedString* text = [self attributedTextForMessage:message];
    CGSize constraint = CGSizeMake(contentWidth, MAXFLOAT);
    NSStringDrawingOptions options = NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin;
    return [text boundingRectWithSize:constraint options:options context:nil].size;
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
    if ([message length] == 0) return;

    NSAttributedString* text = [[self class] attributedTextForMessage:message];
    CGFloat contentWidth = CGRectGetWidth([[self contentView] bounds])-HEMInsightCellMessagePadding;
    CGSize textSize = [[self class] textSizeForMessage:message inWidth:contentWidth];

    [[self messageLabel] setAttributedText:text];
    
    BOOL more = textSize.height > HEMInsightCellMaxMessageHeight;
    if (more) {
        [[self moreLabel] setHidden:NO];
        CGFloat constant = [self fullMessageBottomConstraintConstant];
        CGFloat moreHeight = CGRectGetHeight([[self moreLabel] bounds]);
        [[self messageBottomConstraint] setConstant:constant+moreHeight];
        [self setNeedsDisplay];
    }
    
}

@end
