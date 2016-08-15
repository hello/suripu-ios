//
//  HEMAlertView.m
//  Sense
//
//  Created by Jimmy Lu on 11/19/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import <CGFloatType/CGFloatType.h>
#import "HEMAlertView.h"
#import "HEMActionButton.h"
#import "HEMSupportUtil.h"
#import "UIFont+HEMStyle.h"
#import "UIColor+HEMStyle.h"
#import "NSString+HEMUtils.h"
#import "HEMAlertTextView.h"
#import "HEMScreenUtils.h"

@interface HEMAlertView () <UITextViewDelegate>

@property (nonatomic, assign) UIEdgeInsets contentInsets;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UITextView *messageTextView;
@property (nonatomic, strong) NSMutableArray *buttons;
@property (nonatomic, strong) NSMutableDictionary *actionsCallbacks; // key = title, value = block
@property (nonatomic) HEMAlertViewType type;
@end

@implementation HEMAlertView

CGFloat const HEMDialogContentSpacing = 8.0f;
CGFloat const HEMDialogContentTopPadding = 40.0f;
CGFloat const HEMDialogContentBotPadding = 8.0f;
CGFloat const HEMDialogVerticalSpaceBetweenMessageAndButtons = 38.0f;
CGFloat const HEMDialogBooleanSpaceBetweenMessageAndButtons = 38.0f;
CGFloat const HEMDialogButtonHeight = 56.0f;
CGFloat const HEMDialogHorzMargins = 8.0f;

- (instancetype)initWithImage:(UIImage *)image
                        title:(NSString *)title
                         type:(HEMAlertViewType)type
            attributedMessage:(NSAttributedString *)message {
    if (self = [super initWithFrame:CGRectZero]) {
        _type = type;
        _actionsCallbacks = [NSMutableDictionary new];
        _buttons = [NSMutableArray new];
        [self layoutElementsWithImage:image title:title message:message];
    }
    return self;
}

- (CGSize)intrinsicContentSize {
    CGFloat width = CGRectGetWidth(HEMKeyWindowBounds()) - (2 * HEMDialogHorzMargins);
    CGFloat height = CGRectGetMaxY(self.messageTextView.frame);
    if (self.type == HEMAlertViewTypeVertical) {
        height += (self.buttons.count * HEMDialogButtonHeight) + HEMDialogVerticalSpaceBetweenMessageAndButtons;
        if (self.buttons.count == 1)
            height += HEMDialogContentBotPadding;
    } else {
        height += HEMDialogButtonHeight + HEMDialogBooleanSpaceBetweenMessageAndButtons;
    }
    return CGSizeMake(width, ceilCGFloat(height));
}

- (void)updateFrame {
    CGRect frame = self.frame;
    frame.size = [self intrinsicContentSize];
    self.frame = frame;
}

- (void)layoutElementsWithImage:(UIImage *)image title:(NSString *)title message:(NSAttributedString *)message {
    CGFloat const HEMDialogCornerRadius = 4.0f;
    CGFloat const HEMDialogContentHorzPadding = 25.0f;
    self.contentInsets = UIEdgeInsetsMake(HEMDialogContentTopPadding, HEMDialogContentHorzPadding,
                                          HEMDialogContentBotPadding, HEMDialogContentHorzPadding);

    self.backgroundColor = [UIColor whiteColor];
    self.layer.cornerRadius = HEMDialogCornerRadius;

    [self addImageViewWithImage:image];
    [self addTitleLabelWithText:title];
    [self addMessageViewWithText:message];

    if (self.type == HEMAlertViewTypeBoolean)
        [self addButtonDivider];
    [self updateFrame];
}

- (void)addButtonDivider {
    CGSize alertSize = [self intrinsicContentSize];
    CGFloat height = HEMDialogButtonHeight;
    CGRect frame = CGRectMake(floorCGFloat(alertSize.width/2), alertSize.height - height, 1, height);
    UIView *divider = [[UIView alloc] initWithFrame:frame];
    divider.backgroundColor = [UIColor colorWithHex:0xE6E6E6 alpha:1.0];
    [self addSubview:divider];
}

- (void)addImageViewWithImage:(UIImage *)image {
    if (!image)
        return;
    CGFloat const HEMDialogContentMaxImageHeight = 150.0f;
    CGFloat horzPadding = [self contentInsets].left + [self contentInsets].right;
    CGRect imageFrame
        = CGRectMake([self contentInsets].left, [self contentInsets].top, CGRectGetWidth([self bounds]) - horzPadding,
                     MIN(HEMDialogContentMaxImageHeight, image.size.height));
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:imageFrame];
    imageView.contentMode = UIViewContentModeCenter;
    imageView.backgroundColor = [UIColor clearColor];
    imageView.image = image;
    self.imageView = imageView;
    [self addSubview:imageView];
}

- (void)addTitleLabelWithText:(NSString *)text {
    CGFloat top = HEMDialogContentTopPadding;
    if (self.imageView)
        top = HEMDialogContentSpacing + CGRectGetMaxY(self.imageView.frame);

    UIFont *font = [UIFont dialogTitleFont];
    CGFloat horzPadding = [self contentInsets].left + [self contentInsets].right;
    CGFloat width = [self intrinsicContentSize].width - horzPadding;
    CGFloat height = [text heightBoundedByWidth:width usingFont:font];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(self.contentInsets.left, top, width, height)];
    label.text = text;
    label.textColor = [UIColor blackColor];
    label.font = font;
    label.numberOfLines = 0;
    self.titleLabel = label;
    [self addSubview:label];
}

- (void)addMessageViewWithText:(NSAttributedString *)text {
    CGFloat top = HEMDialogContentSpacing + CGRectGetMaxY(self.titleLabel.frame);
    CGFloat horzPadding = [self contentInsets].left + [self contentInsets].right;
    CGFloat maxTextWidth = [self intrinsicContentSize].width - horzPadding;

    UITextView *textView = [HEMAlertTextView new];
    textView.attributedText = text;
    textView.delegate = self;
    CGSize textSize = [textView sizeThatFits:CGSizeMake(maxTextWidth, MAXFLOAT)];
    
    CGRect textFrame = CGRectZero;
    textFrame.size = textSize;
    textFrame.origin = CGPointMake(self.contentInsets.left, top);
    textView.frame = textFrame;

    self.messageTextView = textView;
    [self addSubview:textView];
}

- (UIButton *)defaultButton {
    return [self.buttons firstObject];
}

- (CGRect)nextButtonFrame {
    CGFloat const HEMDialogButtonHorzPadding = 8.0f;
    CGFloat top = 0, width = 0, left = 0;
    CGFloat messageFrameBottom = CGRectGetMaxY(self.messageTextView.frame);
    UIButton *lastButton = [self.buttons lastObject];
    if (lastButton) {
        if (self.type == HEMAlertViewTypeVertical) {
            top = CGRectGetMaxY(lastButton.frame);
            left = HEMDialogButtonHorzPadding;
        } else {
            top = messageFrameBottom + HEMDialogBooleanSpaceBetweenMessageAndButtons;
            left = CGRectGetMaxX(lastButton.frame);
        }
    } else if (self.type == HEMAlertViewTypeVertical) {
        top = messageFrameBottom + HEMDialogVerticalSpaceBetweenMessageAndButtons;
        left = HEMDialogButtonHorzPadding;
    } else {
        top = messageFrameBottom + HEMDialogBooleanSpaceBetweenMessageAndButtons;
        left = HEMDialogButtonHorzPadding;
    }
    width = [self intrinsicContentSize].width - (2 * HEMDialogButtonHorzPadding);
    if (self.type == HEMAlertViewTypeBoolean)
        width = floorCGFloat(width/2);
    return CGRectMake(left, top, width, HEMDialogButtonHeight);
}

#pragma mark - UITextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange {
    HEMDialogLinkActionBlock actionBlock = [[self actionsCallbacks] objectForKey:[URL absoluteString]];
    if (actionBlock) {
        actionBlock(URL);
    }
    return NO;
}

#pragma mark - Actions

- (void)setCompletionBlock:(HEMDialogActionBlock)doneBlock {
    NSString *doneTitle = [self.defaultButton titleForState:UIControlStateNormal];
    if (doneTitle.length > 0)
        [[self actionsCallbacks] setValue:[doneBlock copy] forKey:doneTitle];
}

- (void)onLink:(NSString *)url tap:(HEMDialogLinkActionBlock)actionBlock {
    [[self actionsCallbacks] setValue:[actionBlock copy] forKey:url];
}

- (void)addActionButtonWithTitle:(NSString *)title style:(HEMAlertViewButtonStyle)style action:(HEMDialogActionBlock)block {
    UIButton *button = [self buttonWithTitle:title style:style];
    [[self actionsCallbacks] setValue:[block copy] forKey:title];
    [self addSubview:button];
    [self.buttons addObject:button];
    [self updateFrame];
}

- (UIButton *)buttonWithTitle:(NSString *)title style:(HEMAlertViewButtonStyle)style {
    CGRect buttonFrame = [self nextButtonFrame];
    UIButton *button = nil;
    if (style == HEMAlertViewButtonStyleRoundRect) {
        button = [[HEMActionButton alloc] initWithFrame:buttonFrame];
    } else {
        button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = buttonFrame;
        switch (style) {
            case HEMAlertViewButtonStyleBlueBoldText:
                [button setTitleColor:[UIColor tintColor] forState:UIControlStateNormal];
                button.titleLabel.font = [UIFont alertBoldButtonFont];
                break;
            case HEMAlertViewButtonStyleGrayText:
                [button setTitleColor:[UIColor grey4] forState:UIControlStateNormal];
                button.titleLabel.font = [UIFont alertLightButtonFont];
                break;
            case HEMAlertViewButtonStyleBlueText:
                [button setTitleColor:[UIColor tintColor] forState:UIControlStateNormal];
                button.titleLabel.font = [UIFont button];
                break;
            default:
                break;
        }
    }

    [button setTitle:title forState:UIControlStateNormal];
    [button addTarget:self action:@selector(customAction:) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (void)customAction:(UIButton *)button {
    NSString *buttonTitle = [button titleForState:UIControlStateNormal];
    HEMDialogActionBlock block = self.actionsCallbacks[buttonTitle];
    if (block) {
        block();
    }
}

@end
