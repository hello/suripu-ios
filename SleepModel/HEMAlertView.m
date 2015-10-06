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
#import "NSAttributedString+HEMUtils.h"
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
CGFloat const HEMDialogSpaceBetweenMessageAndButtons = 38.0f;
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

- (void)layoutElementsWithImage:(UIImage *)image title:(NSString *)title message:(NSAttributedString *)message {
    CGFloat const HEMDialogButtonBorderWidth = 1.0f;
    CGFloat const HEMDialogCornerRadius = 4.0f;
    CGFloat const HEMDialogContentHorzPadding = 25.0f;
    self.contentInsets = UIEdgeInsetsMake(HEMDialogContentTopPadding, HEMDialogContentHorzPadding,
                                          HEMDialogContentBotPadding, HEMDialogContentHorzPadding);

    self.backgroundColor = [UIColor whiteColor];
    self.layer.cornerRadius = HEMDialogCornerRadius;
    self.layer.borderWidth = HEMDialogButtonBorderWidth;
    self.layer.borderColor = [UIColor colorWithWhite:0.0f alpha:0.1f].CGColor;

    [self addImageViewWithImage:image];
    [self addTitleLabelWithText:title];
    [self addMessageViewWithText:message];

    if (self.type == HEMAlertViewTypeVertical)
        [self setDefaultButtonText:NSLocalizedString(@"actions.ok", nil)];
    [self invalidateIntrinsicContentSize];
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
    CGSize textSize = [text sizeWithWidth:[self intrinsicContentSize].width - horzPadding];
    UITextView *textView = [[HEMAlertTextView alloc]
        initWithFrame:(CGRect){.origin = CGPointMake(self.contentInsets.left, top), .size = textSize }];
    textView.attributedText = text;
    textView.delegate = self;
    self.messageTextView = textView;
    [self addSubview:textView];
}

- (UIButton *)defaultButton {
    return [self.buttons firstObject];
}

- (void)setDefaultButtonText:(NSString *)text {
    UIButton *button;
    if (!self.defaultButton) {
        button = [[HEMActionButton alloc] initWithFrame:[self nextButtonFrame]];
        [button addTarget:self action:@selector(customAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.buttons addObject:button];
        [self addSubview:button];
    } else {
        button = [self.buttons firstObject];
    }
    [button setTitle:[text uppercaseString] forState:UIControlStateNormal];
}

- (CGSize)intrinsicContentSize {
    CGFloat width = CGRectGetWidth(HEMKeyWindowBounds()) - (2 * HEMDialogHorzMargins);
    CGFloat height = CGRectGetMaxY(self.messageTextView.frame);
    if (self.buttons.count > 0) {
        height += HEMDialogSpaceBetweenMessageAndButtons;
        height += (self.buttons.count * HEMDialogButtonHeight);
        if (self.buttons.count == 1)
            height += HEMDialogContentBotPadding;
    }

    return CGSizeMake(width, ceilCGFloat(height));
}

- (void)invalidateIntrinsicContentSize {
    [super invalidateIntrinsicContentSize];
    CGRect frame = self.frame;
    frame.size = [self intrinsicContentSize];
    self.frame = frame;
}

- (CGRect)nextButtonFrame {
    CGFloat const HEMDialogButtonHorzPadding = 8.0f;
    CGFloat top = 0;
    UIButton *lastButton = [self.buttons lastObject];
    if (lastButton)
        top = CGRectGetMaxY(lastButton.frame);
    else
        top = HEMDialogSpaceBetweenMessageAndButtons + CGRectGetMaxY(self.messageTextView.frame);

    CGFloat width = [self intrinsicContentSize].width - (2 * HEMDialogButtonHorzPadding);
    return CGRectMake(HEMDialogButtonHorzPadding, top, width, HEMDialogButtonHeight);
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

- (void)addActionButtonWithTitle:(NSString *)title primary:(BOOL)primary action:(HEMDialogActionBlock)block {
    CGRect buttonFrame = [self nextButtonFrame];
    UIButton *button = nil;

    if (primary) {
        button = [[HEMActionButton alloc] initWithFrame:buttonFrame];
    } else {
        button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.titleLabel.font = [UIFont secondaryButtonFont];
        button.frame = buttonFrame;
    }

    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor tintColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(customAction:) forControlEvents:UIControlEventTouchUpInside];

    [[self actionsCallbacks] setValue:[block copy] forKey:title];
    [self insertSubview:button belowSubview:self.defaultButton];
    [self.buttons addObject:button];
    [self invalidateIntrinsicContentSize];
}

- (void)customAction:(UIButton *)button {
    NSString *buttonTitle = [button titleForState:UIControlStateNormal];
    HEMDialogActionBlock block = [[self actionsCallbacks] valueForKey:buttonTitle];
    if (block) {
        block();
    }
}

@end
