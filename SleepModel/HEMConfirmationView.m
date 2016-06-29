//
//  HEMConfirmationView.m
//  Sense
//
//  Created by Jimmy Lu on 6/22/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "HEMConfirmationView.h"
#import "HEMStyle.h"
#import "HEMScreenUtils.h"
#import "NSString+HEMUtils.h"

static CGFloat const HEMConfirmCornerRadius = 3.0f;

static CGFloat const HEMConfirmHorzHeight = 40.0f;
static CGFloat const HEMConfirmHorzMargin = 13.0f;
static CGFloat const HEMConfirmHorzContentSpacing = 5.0f;

static CGFloat const HEMConfirmVertMargin = 22.0f;
static CGFloat const HEMConfirmVertContentSpacing = 12.0f;

static CGFloat const HEMConfirmDisplayYOffset = -100.0f;
static CGFloat const HEMConfirmAnimeYOffset = -10.0f;
static CGFloat const HEMConfirmAnimeDuration = 0.5f;
static CGFloat const HEMConfirmDisplayDuration = 2.0f;

@interface HEMConfirmationView()

@property (nonatomic, copy) NSString* text;
@property (nonatomic, assign) HEMConfirmationLayout layout;
@property (nonatomic, weak) UIImageView* checkImageView;
@property (nonatomic, weak) UILabel* textLabel;

@end

@implementation HEMConfirmationView

- (instancetype)initWithText:(NSString*)text layout:(HEMConfirmationLayout)layout {
    self = [super init];
    if (self) {
        _text = [text copy];
        _layout = layout;
        
        [self setBackgroundColor:[[UIColor grey7] colorWithAlphaComponent:0.8f]];
        [[self layer] setCornerRadius:HEMConfirmCornerRadius];
        
        [self addCheckImage];
        [self addTextLabel];
    }
    return self;
}

- (void)addCheckImage {
    UIImage* checkImage = [UIImage imageNamed:@"checkWhite"];

    UIImageView* checkView = [[UIImageView alloc] initWithImage:checkImage];
    [checkView setContentMode:UIViewContentModeScaleAspectFit];
    
    CGRect checkFrame = CGRectZero;
    if ([self layout] == HEMConfirmationLayoutVertical) {
        checkFrame.size = checkImage.size;
    } else {
        CGFloat imageSizeRatio = checkImage.size.width / checkImage.size.height;
        checkFrame.size.height = HEMConfirmHorzHeight - (HEMConfirmHorzMargin * 2);
        checkFrame.size.width = CGRectGetHeight(checkFrame) * imageSizeRatio;
    }
    
    [checkView setFrame:checkFrame];
    [self addSubview:checkView];
    [self setCheckImageView:checkView];
}

- (void)addTextLabel {
    UILabel* label = [UILabel new];
    [label setTextColor:[UIColor whiteColor]];
    [label setFont:[UIFont bodyBold]];
    [label setText:[self text]];
    [label setContentMode:UIViewContentModeCenter];
    
    CGFloat margin = [self layout] == HEMConfirmationLayoutVertical ? HEMConfirmVertMargin : HEMConfirmHorzMargin;
    CGFloat maxWidth = CGRectGetWidth(HEMKeyWindowBounds()) - (margin * 2);
    CGSize constraint = CGSizeMake(maxWidth, HEMConfirmHorzHeight); // yes, restrict to horiz height regardless of layout
    CGSize textSize = [label sizeThatFits:constraint];
    
    CGRect labelFrame = CGRectZero;
    labelFrame.size = textSize;
    [label setFrame:labelFrame];
    
    [self addSubview:label];
    [self setTextLabel:label];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect imageFrame = [[self checkImageView] frame];
    CGRect labelFrame = [[self textLabel] frame];
    CGRect myFrame = [self frame];
    
    CGFloat textWidth = CGRectGetWidth(labelFrame);
    
    if ([self layout] == HEMConfirmationLayoutVertical) {
        CGFloat margins = (HEMConfirmVertMargin * 2);
        myFrame.size.width = textWidth + margins;
        myFrame.size.height = CGRectGetHeight(labelFrame)
            + HEMConfirmVertContentSpacing
            + CGRectGetHeight(imageFrame)
            + margins;
        
        imageFrame.origin.x = (CGRectGetWidth(myFrame) - CGRectGetWidth(imageFrame)) / 2.0f;
        imageFrame.origin.y = HEMConfirmVertMargin;
        
        labelFrame.origin.y = CGRectGetMaxY(imageFrame) + HEMConfirmVertContentSpacing;
        labelFrame.origin.x = HEMConfirmVertMargin;
    } else {
        CGFloat imageWidth = CGRectGetWidth(imageFrame);
        myFrame.size.width = textWidth + imageWidth + (HEMConfirmHorzMargin * 2) + HEMConfirmHorzContentSpacing;
        myFrame.size.height = HEMConfirmHorzHeight;
        
        imageFrame.origin.x = HEMConfirmHorzMargin;
        imageFrame.origin.y = HEMConfirmHorzMargin;
        
        labelFrame.origin.x = CGRectGetMaxX(imageFrame) + HEMConfirmHorzContentSpacing;
        labelFrame.origin.y = (CGRectGetHeight(myFrame) - CGRectGetHeight(labelFrame)) / 2.0f;
    }

    [self setFrame:myFrame];
    [[self checkImageView] setFrame:imageFrame];
    [[self textLabel] setFrame:labelFrame];
}

- (void)showInView:(UIView*)view {
    [self layoutIfNeeded];
    
    CGRect frame = [self frame];
    frame.origin.x = (CGRectGetWidth([view bounds]) - CGRectGetWidth(frame)) / 2.0f;
    frame.origin.y = ((CGRectGetHeight([view bounds]) - CGRectGetHeight(frame)) / 2.0f) + HEMConfirmDisplayYOffset;
    [self setFrame:frame];
    [self setAlpha:0.0f];
    
    [view addSubview:self];
    
    [UIView animateWithDuration:HEMConfirmAnimeDuration animations:^{
        [self setAlpha:1.0f];
        CGRect frame = [self frame];
        frame.origin.y += HEMConfirmAnimeYOffset;
        [self setFrame:frame];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:HEMConfirmAnimeDuration
                              delay:HEMConfirmDisplayDuration
                            options:UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             [self setAlpha:0.0f];
                             CGRect frame = [self frame];
                             frame.origin.y -= HEMConfirmAnimeYOffset;
                             [self setFrame:frame];
                         } completion:^(BOOL finished) {
                             [self removeFromSuperview];
                         }];
    }];
}

@end
