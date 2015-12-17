//
//  HEMInsightSummaryView.m
//  Sense
//
//  Created by Jimmy Lu on 10/28/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import "HEMInsightCollectionViewCell.h"
#import "HEMURLImageView.h"
#import "NSAttributedString+HEMUtils.h"
#import "NSString+HEMUtils.h"
#import "HEMMarkdown.h"
#import "UIColor+HEMStyle.h"

CGFloat const HEMInsightCellMessagePadding = 20.0f;

static CGFloat const HEMInsightCellBaseHeight = 206.0f;

@interface HEMInsightCollectionViewCell()

@property (weak, nonatomic) IBOutlet UIView *separator;

@end

@implementation HEMInsightCollectionViewCell

+ (CGFloat)contentHeightWithMessage:(NSAttributedString*)message
                            inWidth:(CGFloat)contentWidth {
    CGFloat maxWidth = contentWidth - (HEMInsightCellMessagePadding * 2);
    CGFloat textHeight = [message sizeWithWidth:maxWidth].height;
    CGFloat baseHeight = HEMInsightCellBaseHeight;
    return textHeight + baseHeight;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [[self dateLabel] setTextColor:[UIColor insightSummaryDateColor]];
    [[self categoryLabel] setTextColor:[UIColor insightSummaryCategoryColor]];
    [[self messageLabel] setTextColor:[UIColor insightSummaryMessageColor]];
    [[self separator] setBackgroundColor:[UIColor separatorColor]];
    [[self imageContainer] setBackgroundColor:[UIColor backgroundColorForRemoteImageView]];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    [[self messageLabel] setAttributedText:nil];
    [[self messageLabel] setText:nil];
    [[self dateLabel] setAttributedText:nil];
    [[self dateLabel] setText:nil];
    [[self categoryLabel] setAttributedText:nil];
    [[self dateLabel] setText:nil];
}

@end
