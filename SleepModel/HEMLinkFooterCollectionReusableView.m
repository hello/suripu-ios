//
//  HEMTextLinkFooterCollectionReusableView.m
//  Sense
//
//  Created by Jimmy Lu on 2/20/15.
//  Copyright (c) 2015 Hello, Inc. All rights reserved.
//

#import "HEMLinkFooterCollectionReusableView.h"

@interface HEMLinkFooterCollectionReusableView() <UITextViewDelegate>

@property (nonatomic, strong) IBOutlet UITextView* textView;

@end

@implementation HEMLinkFooterCollectionReusableView

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self configureContentView];
    }
    return self;
}

- (void)configureContentView {
    if ([self textView] == nil) {
        [self setTextView:[[UITextView alloc] initWithFrame:[self bounds]]];
    }
    
    [[self textView] setEditable:NO];
    [[self textView] setDelegate:self];
    [[self textView] setScrollEnabled:NO];
    [[self textView] setBackgroundColor:[UIColor clearColor]];
    [[self textView] setDataDetectorTypes:UIDataDetectorTypeLink|UIDataDetectorTypeAddress];
    [[self textView] setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
    
    [self addSubview:[self textView]];
}

@end
