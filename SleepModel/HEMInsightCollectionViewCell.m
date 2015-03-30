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

static CGFloat const HEMInsightCellBaseHeight = 115.0f;
static CGFloat const HEMInsightCellPreviewHeight = 51.0f;

@interface HEMInsightCollectionViewCell()

@property (weak, nonatomic) IBOutlet UIView *separator;
@property (weak, nonatomic) IBOutlet UIImageView *accessory;

@end

@implementation HEMInsightCollectionViewCell

+ (NSAttributedString*)attributedTextForMessage:(NSString*)message {
    return [markdown_to_attr_string(message, 0, [HEMMarkdown attributesForBackViewText]) trim];
}

+ (CGFloat)contentHeightWithMessage:(NSString*)message
                        infoPreview:(NSString*)infoPreview
                            inWidth:(CGFloat)contentWidth {
    
    NSAttributedString* text = [self attributedTextForMessage:message];
    
    CGSize constraint = CGSizeMake(contentWidth, MAXFLOAT);
    NSStringDrawingOptions options =
        NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin;
    CGSize contentSize = [text boundingRectWithSize:constraint options:options context:nil].size;
    
    CGFloat baseHeight = HEMInsightCellBaseHeight;
    if ([infoPreview length] == 0) {
        baseHeight -= HEMInsightCellPreviewHeight;
    }

    return contentSize.height + baseHeight;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    [[self messageLabel] setAttributedText:nil];
    [[self previewLabel] setAttributedText:nil];
    [self showPreview:YES];
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
    if ([message length] == 0) {
        return;
    }
    
    NSAttributedString* text = [[self class] attributedTextForMessage:message];
    [[self messageLabel] setAttributedText:text];
}

- (void)showPreview:(BOOL)show {
    [[self separator] setHidden:!show];
    [[self accessory] setHidden:!show];
    [[self previewLabel] setHidden:!show];
}

- (void)setInfoPreview:(NSString*)infoPreview {
    if ([infoPreview length] == 0) {
        [self showPreview:NO];
        return;
    }
    NSDictionary* attributes = [HEMMarkdown attributesForBackViewTitle];
    NSAttributedString* text = [markdown_to_attr_string(infoPreview, 0, attributes) trim];
    self.previewLabel.attributedText = text;
}

@end
