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

@interface HEMTitledTextField() <HEMSimpleLineTextFieldDelegate>

@property (nonatomic, weak) IBOutlet UILabel* titleLabel;
@property (nonatomic, copy) NSString* placeholderText;

@end

@implementation HEMTitledTextField

- (void)awakeFromNib {
    [self configureDefaults];
}

- (void)configureDefaults {
    [[self titleLabel] setTextColor:[UIColor lowImportanceTextColor]];
    [[self titleLabel] setFont:[UIFont textfieldTitleFont]];
    [[self titleLabel] setHidden:YES];
    
    if ([[self textField] isKindOfClass:[HEMSimpleLineTextField class]]) {
        HEMSimpleLineTextField* simpleField = (id) [self textField];
        [simpleField setTextFieldDelegate:self];
    }
    
}

- (void)update {
    [self updatePlaceholderText:[[self textField] isFocused]];
}

- (void)updatePlaceholderText:(BOOL)focus {
    NSString* placeholderText = [[self textField] placeholder];
    if ([[self textField] placeholder] && ![[self placeholderText] isEqualToString:placeholderText]) {
        [self setPlaceholderText:[[self textField] placeholder]];
    }
    BOOL showTitle = focus || [[[self textField] text] length] > 0;
    if (showTitle) {
        [[self titleLabel] setHidden:NO];
        [[self titleLabel] setText:[self placeholderText]];
        [[self textField] setPlaceholder:nil];
    } else {
        [[self titleLabel] setHidden:YES];
        [[self textField] setPlaceholder:[self placeholderText]];
    }
}

#pragma mark - Text field delegate

- (void)textField:(HEMSimpleLineTextField *)textField didGainFocus:(BOOL)focus {
    [self updatePlaceholderText:focus];
}

@end
