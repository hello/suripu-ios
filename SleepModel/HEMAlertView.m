//
//  HEMAlertView.m
//  Sense
//
//  Created by Jimmy Lu on 11/19/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import "UIFont+HEMStyle.h"

#import "HEMAlertView.h"
#import "HelloStyleKit.h"
#import "HEMActionButton.h"
#import "HEMSupportUtil.h"

static CGFloat const kHEMDialogHorzMargins = 17.0f;
static CGFloat const kHEMDialogCornerRadius = 4.0f;
static CGFloat const kHEMDialogContentSpacing = 30.0f;
static CGFloat const kHEMDialogContentHorzPadding = 25.0f;
static CGFloat const kHEMDialogContentTopPadding = 34.0f;
static CGFloat const kHEMDialogContentBotPadding = 10.0f;
static CGFloat const kHEMDialogContentMaxImageHeight = 150.0f;
static CGFloat const kHEMDialogButtonBorderWidth = 1.0f;
static CGFloat const kHEMDialogButtonHorzPadding = 20.0f;
static CGFloat const kHEMDialogButtonHeight = 40.0f;
static CGFloat const kHEMDialogButtonSpacing = 10.0f;

@interface HEMAlertView() <UITextViewDelegate>

@property (nonatomic, assign) UIEdgeInsets contentInsets;
@property (nonatomic, copy)   NSString* title;
@property (nonatomic, copy)   NSString* message;
@property (nonatomic, strong) UIImage* image;
@property (nonatomic, weak)   UIButton* okButton; // used as anchor for actions
@property (nonatomic, strong) NSMutableDictionary* actionsCallbacks; // key = title, value = block
@property (nonatomic, copy)   NSAttributedString* attributedMessage;

@end

@implementation HEMAlertView

+ (CGRect)defaultFrame {
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    CGRect frame = CGRectZero;
    frame.size.width = CGRectGetWidth(screenBounds)-(2*kHEMDialogHorzMargins);
    frame.size.height = kHEMDialogContentTopPadding + kHEMDialogContentBotPadding;
    return frame;
}

- (id)initWithImage:(UIImage*)image
              title:(NSString*)title
            message:(NSString*)message {
    
    return [self initWithImage:image title:title message:message frame:[[self class] defaultFrame]];
}

- (id)initWithImage:(UIImage*)image
              title:(NSString*)title
  attributedMessage:(NSAttributedString*)message {
    self = [super initWithFrame:[[self class] defaultFrame]];
    if (self) {
        [self setImage:image];
        [self setTitle:title];
        [self setAttributedMessage:message];
        [self setup];
    }
    return self;
}

- (id)initWithImage:(UIImage*)image
              title:(NSString*)title
            message:(NSString*)message
              frame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setImage:image];
        [self setTitle:title];
        [self setMessage:message];
        [self setup];
    }
    return self;
}

- (void)setup {
    [self setActionsCallbacks:[NSMutableDictionary dictionary]];
    [self setContentInsets:UIEdgeInsetsMake(kHEMDialogContentTopPadding,
                                            kHEMDialogContentHorzPadding,
                                            kHEMDialogContentBotPadding,
                                            kHEMDialogContentHorzPadding)];
    
    [self setBackgroundColor:[UIColor whiteColor]];
    [[self layer] setCornerRadius:kHEMDialogCornerRadius];
    [[self layer] setBorderWidth:kHEMDialogButtonBorderWidth];
    [[self layer] setBorderColor:[[UIColor colorWithWhite:0.0f alpha:0.1f] CGColor]];
    
    CGFloat maxY = [self addDialogImage];
    maxY = [self addTitleLabelAtY:maxY];
    maxY = [self addMessageView:maxY];
    maxY = [self addOkButtonAtY:maxY];
    
    CGRect myFrame = [self frame];
    myFrame.size.height = maxY + kHEMDialogContentBotPadding;
    [self setFrame:myFrame];
}

- (CGFloat)addDialogImage {
    CGFloat maxY = kHEMDialogContentTopPadding;
    if ([self image] != nil) {
        CGFloat horzPadding = [self contentInsets].left + [self contentInsets].right;
        CGRect imageFrame = {
            [self contentInsets].left,
            [self contentInsets].top,
            CGRectGetWidth([self bounds]) - horzPadding,
            MIN(kHEMDialogContentMaxImageHeight, [[self image] size].height)
        };
        
        UIImageView* imageView = [[UIImageView alloc] initWithFrame:imageFrame];
        [imageView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        [imageView setTranslatesAutoresizingMaskIntoConstraints:YES];
        [imageView setContentMode:UIViewContentModeCenter];
        [imageView setBackgroundColor:[UIColor clearColor]];
        [imageView setImage:[self image]];
        
        [self addSubview:imageView];
        
        maxY = CGRectGetMaxY(imageFrame) + kHEMDialogContentSpacing;
    }
    return maxY;
}

- (CGFloat)addTitleLabelAtY:(CGFloat)y {
    CGFloat maxY = y;
    
    if ([[self title] length] > 0) {
        UILabel* label = [[UILabel alloc] init];
        [label setText:[self title]];
        [label setTextColor:[UIColor blackColor]];
        [label setFont:[UIFont dialogTitleFont]];
        [label setNumberOfLines:0];
        
        CGFloat horzPadding = [self contentInsets].left + [self contentInsets].right;
        CGRect labelFrame = {
            [self contentInsets].left,
            y,
            CGRectGetWidth([self bounds]) - horzPadding,
            MAXFLOAT // will get resized later
        };
        CGSize constraint = labelFrame.size;
        CGSize textSize = [label sizeThatFits:constraint];
        labelFrame.size.height = textSize.height;
        [label setFrame:labelFrame];
        
        [self addSubview:label];
        
        maxY = CGRectGetMaxY(labelFrame) + kHEMDialogContentSpacing;
    }
    
    return maxY;
}

- (NSAttributedString*)attributedMessage {
    if (_attributedMessage) {
        return _attributedMessage;
    } else if (_message) {
        NSDictionary* atts = @{NSFontAttributeName : [UIFont dialogMessageFont],
                               NSForegroundColorAttributeName : [UIColor blackColor]};
        return [[NSAttributedString alloc] initWithString:_message attributes:atts];
    } else {
        return nil;
    }
}

- (CGFloat)addMessageView:(CGFloat)y {
    UITextView *textView = [[UITextView alloc] init];
    [textView setAttributedText:[self attributedMessage]];
    [textView setEditable:NO];
    [textView setDelegate:self];
    [textView setScrollEnabled:NO];
    [textView setBackgroundColor:[UIColor clearColor]];
    [textView setDataDetectorTypes:UIDataDetectorTypeLink | UIDataDetectorTypeAddress];
    [textView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [textView setLinkTextAttributes:@{NSForegroundColorAttributeName : [UIColor blackColor],
                                      NSFontAttributeName : [UIFont dialogMessageBoldFont]}];
    
    // remove the magic padding / margins in the text view.
    [textView setTextContainerInset:UIEdgeInsetsZero];
    [[textView textContainer] setLineFragmentPadding:0.0f];
    
    // size the text view based on the attribted text's required height, leaving
    // the width as is
    CGFloat horzPadding = [self contentInsets].left + [self contentInsets].right;
    CGRect messageFrame = CGRectZero;
    messageFrame.origin = CGPointMake([self contentInsets].left, y);
    messageFrame.size   = CGSizeMake(CGRectGetWidth([self bounds]) - horzPadding, MAXFLOAT);
    
    CGSize constraint = messageFrame.size;
    constraint.height = MAXFLOAT;
    CGSize textSize = [textView sizeThatFits:constraint];
    messageFrame.size.height = textSize.height;
    
    [textView setFrame:messageFrame];
    [self addSubview:textView];
    
    return CGRectGetMaxY(messageFrame) + kHEMDialogContentSpacing;
}

- (CGRect)buttonFrameAtY:(CGFloat)y {
    CGRect buttonFrame = {
        kHEMDialogButtonHorzPadding,
        y,
        CGRectGetWidth([self bounds]) - (2*kHEMDialogButtonHorzPadding),
        kHEMDialogButtonHeight
    };
    return buttonFrame;
}

- (CGFloat)addOkButtonAtY:(CGFloat)y {
    NSString* title = NSLocalizedString(@"actions.ok", nil);
    HEMActionButton* ok = [[HEMActionButton alloc] initWithFrame:[self buttonFrameAtY:y]];
    [ok setTitle:title forState:UIControlStateNormal];
    [ok setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [ok setTranslatesAutoresizingMaskIntoConstraints:YES];
    [ok addTarget:self action:@selector(customAction:) forControlEvents:UIControlEventTouchUpInside];

    [self setOkButton:ok];
    [self addSubview:ok];
    
    return CGRectGetMaxY([ok frame]) + kHEMDialogButtonSpacing;
}

#pragma mark - UITextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange {
    HEMDialogLinkActionBlock actionBlock = [[self actionsCallbacks] objectForKey:[URL absoluteString]];
    if (actionBlock) {
        actionBlock (URL);
    }
    return NO;
}

#pragma mark - Actions

- (void)onDone:(HEMDialogActionBlock)doneBlock {
    NSString* doneTitle = [[self okButton] titleForState:UIControlStateNormal];
    [[self actionsCallbacks] setValue:[doneBlock copy] forKey:doneTitle];
}

- (void)onLink:(NSString*)url tap:(HEMDialogLinkActionBlock)actionBlock {
    [[self actionsCallbacks] setValue:[actionBlock copy] forKey:url];
}
- (void)addActionButtonWithTitle:(NSString*)title
                         primary:(BOOL)primary
                          action:(HEMDialogActionBlock)block {
    
    CGRect okFrame = [[self okButton] frame];
    CGRect buttonFrame = [self buttonFrameAtY:CGRectGetMinY(okFrame)];
    UIButton* button = nil;
    
    if (primary) {
        button = [[HEMActionButton alloc] initWithFrame:buttonFrame];
    } else {
        button = [UIButton buttonWithType:UIButtonTypeCustom];
        [[button titleLabel] setFont:[UIFont secondaryButtonFont]];
    }
    
    [button setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [button setTranslatesAutoresizingMaskIntoConstraints:YES];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[HelloStyleKit senseBlueColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(customAction:) forControlEvents:UIControlEventTouchUpInside];
    [button setFrame:buttonFrame];
    
    [[self actionsCallbacks] setValue:[block copy] forKey:title];

    CGFloat increasedHeight = CGRectGetHeight(buttonFrame) + kHEMDialogButtonSpacing;
    [self insertSubview:button belowSubview:[self okButton]];
    
    okFrame.origin.y += increasedHeight;
    [[self okButton] setFrame:okFrame];
 
    CGRect myFrame = [self frame];
    myFrame.size.height += increasedHeight;
    [self setFrame:myFrame];
}

- (void)customAction:(UIButton*)button {
    NSString* buttonTitle = [button titleForState:UIControlStateNormal];
    HEMDialogActionBlock block = [[self actionsCallbacks] valueForKey:buttonTitle];
    if (block) {
        block();
    }
}

@end
