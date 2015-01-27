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

static CGFloat const HEMInsightCellBaseHeight = 106.0f;

@interface HEMInsightCollectionViewCell()

@property (weak, nonatomic) IBOutlet UILabel* moreLabel;

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

- (void)setMessage:(NSString*)message {
    if ([message length] == 0) return;
    
    NSAttributedString* text = [[self class] attributedTextForMessage:message];
    [[self messageLabel] setAttributedText:text];
}

@end
