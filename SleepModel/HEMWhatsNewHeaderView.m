//
//  HEMWhatsNewHeaderView.m
//  Sense
//
//  Created by Jimmy Lu on 6/2/16.
//  Copyright © 2016 Hello. All rights reserved.
//
#import "NSString+HEMUtils.h"

#import "HEMWhatsNewHeaderView.h"
#import "HEMStyle.h"

static CGFloat const HEMWhatsNewHeaderBaseHeight = 135.0f;
static CGFloat const HEMWhatsNewHeaderSideMargin = 24.0f;

@implementation HEMWhatsNewHeaderView

+ (CGFloat)heightWithTitle:(NSString*)title message:(NSString*)message andMaxWidth:(CGFloat)maxWidth {
    CGFloat maxTextWidth = maxWidth - (HEMWhatsNewHeaderSideMargin * 2);
    NSDictionary* titleAttrs = @{NSFontAttributeName : [UIFont h5],
                                 NSForegroundColorAttributeName : [UIColor textColor]};
    NSDictionary* messageAttrs = @{NSFontAttributeName : [UIFont body],
                                   NSForegroundColorAttributeName : [UIColor detailTextColor]};
    CGFloat titleHeight = [title sizeBoundedByWidth:maxTextWidth attriburtes:titleAttrs].height;
    CGFloat messageHeight = [message sizeBoundedByWidth:maxTextWidth attriburtes:messageAttrs].height;
    return HEMWhatsNewHeaderBaseHeight + titleHeight + messageHeight;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [[self titleLabel] setFont:[UIFont h5]];
    [[self titleLabel] setNumberOfLines:0];
    [[self titleLabel] setTextColor:[UIColor grey6]];
    [[self messageLabel] setFont:[UIFont body]];
    [[self messageLabel] setNumberOfLines:0];
    [[self messageLabel] setTextColor:[UIColor grey5]];
    [[[self actionButton] titleLabel] setFont:[UIFont button]];
    [[self actionButton] setTitleColor:[UIColor tintColor]
                              forState:UIControlStateNormal];
}

- (void)setTitle:(NSString*)title andMessage:(NSString*)message {
    [[self titleLabel] setText:title];
    [[self messageLabel] setText:message];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGSize constraint = CGSizeMake(CGRectGetWidth([[self messageLabel] bounds]), MAXFLOAT);
    CGSize messageSize = [[self messageLabel] sizeThatFits:constraint];
    CGRect messageFrame = [[self messageLabel] frame];
    messageFrame.size.height = messageSize.height;
    [[self messageLabel] setFrame:messageFrame];
}

@end
