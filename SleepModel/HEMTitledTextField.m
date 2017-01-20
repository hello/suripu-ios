//
//  HEMTitledTextField.m
//  Sense
//
//  Created by Jimmy Lu on 5/12/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "HEMTitledTextField.h"
#import "HEMSimpleLineTextField.h"
#import "HEMStyle.h"

static CGFloat const kHEMTitledTextFieldAnimeDuration = 0.5f;
static CGFloat const kHEMTitledTextFieldPlaceholderExtraOffset = 5.0f;

@interface HEMTitledTextField() <HEMTextFieldFocusDelegate>

@property (nonatomic, weak) IBOutlet UILabel* titleLabel;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint* titleTopConstraint;
@property (nonatomic, assign) CGFloat origTitleTopMargin;

@end

@implementation HEMTitledTextField

- (void)awakeFromNib {
    [super awakeFromNib];
    [self configureDefaults];
}

- (void)configureDefaults {
    [self setOrigTitleTopMargin:[[self titleTopConstraint] constant]];
    
    [[self titleLabel] setTextColor:[UIColor grey4]];
    [[self titleLabel] setFont:[UIFont body]];
    [[self titleLabel] setHidden:NO];
    [[self textField] setPlaceholder:nil];
    [[self textField] setFocusDelegate:self];
}

- (void)setPlaceholderText:(NSString *)placeholderText {
    _placeholderText = [placeholderText copy];
    [[self titleLabel] setText:_placeholderText];
}

#pragma mark - HEMTextFieldFocusDelegate

- (void)textField:(HEMSimpleLineTextField *)textField didGainFocus:(BOOL)focus {
    UIFont* textFont = nil;
    
    if (focus) {
        textFont = [UIFont h7Bold];
        [[self titleTopConstraint] setConstant:0.0f];
    } else if (![[self textField] hasText]) {
        textFont = [UIFont body];
        CGFloat top = CGRectGetMinY([[self textField] frame]);
        [[self titleTopConstraint] setConstant:top + kHEMTitledTextFieldPlaceholderExtraOffset];
    }
    
    if (textFont) {
        [UIView animateWithDuration:kHEMTitledTextFieldAnimeDuration animations:^{
            [[self titleLabel] setFont:textFont];
            [self layoutIfNeeded];
        }];
    }
    
}

@end
