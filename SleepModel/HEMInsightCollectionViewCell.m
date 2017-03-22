//
//  HEMInsightSummaryView.m
//  Sense
//
//  Created by Jimmy Lu on 10/28/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import <AttributedMarkdown/markdown_peg.h>

#import "Sense-Swift.h"
#import "HEMInsightCollectionViewCell.h"
#import "HEMURLImageView.h"
#import "NSAttributedString+HEMUtils.h"
#import "NSString+HEMUtils.h"
#import "HEMMarkdown.h"

CGFloat const HEMInsightCellMessagePadding = 20.0f;

static CGFloat const HEMInsightCellBaseHeight = 235.0f;
static CGFloat const HEMInsightCellShareButtonHeight = 46.0f;

@interface HEMInsightCollectionViewCell()

@property (weak, nonatomic) IBOutlet UIView *separator;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *shareButtonHeightConstraint;

@end

@implementation HEMInsightCollectionViewCell

+ (NSDictionary*)messageAttributes {
    UIColor* color = [SenseStyle colorWithAClass:self property:ThemePropertyTextColor];
    UIColor* boldColor = [SenseStyle colorWithAClass:self property:ThemePropertyTextHighlightedColor];
    UIFont* font = [SenseStyle fontWithAClass:self property:ThemePropertyTextFont];
    NSMutableParagraphStyle *style = DefaultBodyParagraphStyle();
    [style setLineBreakMode:NSLineBreakByWordWrapping];
    return @{@(EMPH) : @{NSFontAttributeName : font,
                         NSParagraphStyleAttributeName : style,
                         NSForegroundColorAttributeName : boldColor},
             @(STRONG) : @{NSFontAttributeName : font,
                           NSParagraphStyleAttributeName : style,
                           NSForegroundColorAttributeName : boldColor},
             @(PARA) : @{NSFontAttributeName : font,
                         NSParagraphStyleAttributeName : style,
                         NSForegroundColorAttributeName : color},
             @(BULLETLIST) : @{NSFontAttributeName : font,
                               NSParagraphStyleAttributeName : style,
                               NSForegroundColorAttributeName : color}};
}

+ (CGFloat)contentHeightWithMessage:(NSAttributedString*)message
                            inWidth:(CGFloat)contentWidth
                          shareable:(BOOL)shareable {
    CGFloat maxWidth = contentWidth - (HEMInsightCellMessagePadding * 2);
    CGFloat textHeight = [message sizeWithWidth:maxWidth].height;
    CGFloat totalHeight = textHeight + HEMInsightCellBaseHeight;
    if (!shareable) {
        totalHeight -= HEMInsightCellShareButtonHeight;
    }
    return totalHeight;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    UIImage* shareIcon = [[UIImage imageNamed:@"shareIcon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [[self shareButton] setImage:shareIcon forState:UIControlStateNormal];
    
    [self applyStyle];
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

- (void)enableShare:(BOOL)enable {
    [[self shareButton] setHidden:!enable];
    [[self separator] setHidden:!enable];
    
    CGFloat height = enable ? HEMInsightCellShareButtonHeight : 0.0f;
    [[self shareButtonHeightConstraint] setConstant:height];
    [self layoutIfNeeded];
}

- (void)applyStyle {
    [super applyStyle];
    
    UIColor* categoryColor = [SenseStyle colorWithAClass:[self class] property:ThemePropertyTitleColor];
    UIFont* categoryFont = [SenseStyle fontWithAClass:[self class] property:ThemePropertyTitleFont];
    UIColor* dateColor = [SenseStyle colorWithAClass:[self class] property:ThemePropertyDetailColor];
    UIFont* dateFont = [SenseStyle fontWithAClass:[self class] property:ThemePropertyDetailFont];
    UIColor* buttonColor = [SenseStyle colorWithAClass:[self class] property:ThemePropertyPrimaryButtonTextColor];
    UIFont* buttonFont = [SenseStyle fontWithAClass:[self class] property:ThemePropertyPrimaryButtonTextFont];
    UIColor* separatorColor = [SenseStyle colorWithAClass:[self class] property:ThemePropertySeparatorColor];
    
    [[self categoryLabel] setFont:categoryFont];
    [[self categoryLabel] setTextColor:categoryColor];
    [[self dateLabel] setFont:dateFont];
    [[self dateLabel] setTextColor:dateColor];
    [[[self shareButton] titleLabel] setFont:buttonFont];
    [[self shareButton] setTitleColor:buttonColor forState:UIControlStateNormal];
    [[self shareButton] setTintColor:buttonColor];
    [[self shareButton] setAdjustsImageWhenHighlighted:NO];
    [[self separator] setBackgroundColor:separatorColor];
}

@end
