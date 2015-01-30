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
#import "NSAttributedString+HEMUtils.h"

CGFloat const HEMInsightCellMessagePadding = 16.0f;

static CGFloat const HEMInsightCellBaseHeight = 106.0f;

@interface HEMInsightCollectionViewCell()

@property (weak, nonatomic) IBOutlet UILabel* moreLabel;

@end

@implementation HEMInsightCollectionViewCell

+ (NSAttributedString*)attributedTextForMessage:(NSString*)message {
    return [markdown_to_attr_string(message, 0, [HEMMarkdown attributesForBackViewText]) trim];
}

+ (CGFloat)contentHeightWithMessage:(NSString*)message inWidth:(CGFloat)contentWidth {
    NSAttributedString* text = [self attributedTextForMessage:message];
    
    CGSize constraint = CGSizeMake(contentWidth, MAXFLOAT);
    NSStringDrawingOptions options =
        NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin;
    CGSize contentSize = [text boundingRectWithSize:constraint options:options context:nil].size;

    return contentSize.height + HEMInsightCellBaseHeight;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    [[self messageLabel] setAttributedText:nil];
}

- (void)setTitle:(NSString*)title {
    if (title.length == 0) {
        self.titleLabel.text = nil;
        return;
    }
    NSDictionary* attributes = [HEMMarkdown attributesForBackViewTitle];
    NSAttributedString* text = [markdown_to_attr_string(title, 0, attributes) trim];
    self.titleLabel.attributedText = text;
}

- (void)setMessage:(NSString*)message {
    if ([message length] == 0) return;
    
    NSAttributedString* text = [[self class] attributedTextForMessage:message];
    [[self messageLabel] setAttributedText:text];
}

@end
