//
//  HEMTextLinkFooterCollectionReusableView.m
//  Sense
//
//  Created by Jimmy Lu on 2/20/15.
//  Copyright (c) 2015 Hello, Inc. All rights reserved.
//

#import "HEMTextFooterCollectionReusableView.h"

static CGFloat const HEMTextFooterMargins = 16.0f;

@interface HEMTextFooterCollectionReusableView() <UITextViewDelegate>

@property (nonatomic, strong) IBOutlet UITextView* textView;

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
    
    [self addSubview:[self textView]];
}

- (void)setText:(NSAttributedString*)attributedText {
    [[self textView] setAttributedText:attributedText];
}

#pragma mark - UITextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange {
    [[self delegate] didTapOnLink:URL from:self];
    return NO;
}

@end
