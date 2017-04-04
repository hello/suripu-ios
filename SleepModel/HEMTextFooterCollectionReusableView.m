//
//  HEMTextLinkFooterCollectionReusableView.m
//  Sense
//
//  Created by Jimmy Lu on 2/20/15.
//  Copyright (c) 2015 Hello, Inc. All rights reserved.
//

#import "Sense-Swift.h"
#import "HEMTextFooterCollectionReusableView.h"

static CGFloat const HEMTextFooterMargins = 24.0f;
static CGFloat const HEMTextFooterTextTopInset = -8.0f;
static CGFloat const HEMTextFooterTextLeftInset = -4.0f;

@interface HEMTextFooterCollectionReusableView() <UITextViewDelegate>

@end

@implementation HEMTextFooterCollectionReusableView

- (id)init {
    self = [super init];
    if (self) {
        [self configureContentView];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self configureContentView];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self configureContentView];
    }
    return self;
}

- (void)configureContentView {
    if ([self textView] == nil) {
        CGRect frame = [self bounds];
        frame.origin.x = HEMTextFooterMargins;
        frame.size.width -= (HEMTextFooterMargins*2);
        [self setTextView:[[UITextView alloc] initWithFrame:frame]];
    }
    
    [[self textView] setEditable:NO];
    [[self textView] setDelegate:self];
    [[self textView] setScrollEnabled:NO];
    [[self textView] setBackgroundColor:[UIColor clearColor]];
    [[self textView] setDataDetectorTypes:UIDataDetectorTypeLink|UIDataDetectorTypeAddress];
    [[self textView] setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
    [[self textView] setTextContainerInset:UIEdgeInsetsMake(HEMTextFooterTextTopInset, HEMTextFooterTextLeftInset, 0.0f, 0.0f)];
    
    [[self textView] applyClassStyleWithAClass:[self class]];
    [self addSubview:[self textView]];
}

- (void)setText:(NSAttributedString*)attributedText {
    [[self textView] setAttributedText:attributedText];
    [[self textView] applyClassStyleWithAClass:[self class]];
}

#pragma mark - UITextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange {
    [[self delegate] didTapOnLink:URL from:self];
    return NO;
}

@end
