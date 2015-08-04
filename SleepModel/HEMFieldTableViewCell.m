//
//  HEMFieldTableViewCell.m
//  Sense
//
//  Created by Jimmy Lu on 5/29/15.
//  Copyright (c) 2015 Hello. All rights reserved.
//

#import "HEMFieldTableViewCell.h"
#import "UIFont+HEMStyle.h"
#import "UIColor+HEMStyle.h"

@interface HEMFieldTableViewCell() <UITextFieldDelegate>

@property (nonatomic, weak) IBOutlet UITextField* textField;

@end

@implementation HEMFieldTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [[self textField] setFont:[UIFont textfieldTextFont]];
    [[self textField] setDelegate:self];
    [[self textField] addTarget:self
                         action:@selector(didChangeTextInField:)
               forControlEvents:UIControlEventEditingChanged];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    [[self textField] setAttributedPlaceholder:nil];
    [[self textField] setText:nil];
    [[self textField] setSecureTextEntry:NO];
}

- (CGFloat)separatorIndentation {
    return CGRectGetMinX([[self textField] frame]);
}

- (void)setPlaceHolder:(NSString*)text {
    if ([text length] == 0) return;
    
    NSDictionary* attributes = @{NSFontAttributeName : [UIFont textfieldPlaceholderFont],
                                 NSForegroundColorAttributeName : [UIColor textfieldPlaceholderColor]};
    NSAttributedString* attributedPlaceHolder =
        [[NSAttributedString alloc] initWithString:text attributes:attributes];
    
    [[self textField] setAttributedPlaceholder:attributedPlaceHolder];
}

- (NSString*)placeHolderText {
    return [[[self textField] attributedPlaceholder] string];
}

- (void)setDefaultText:(NSString*)text {
    [[self textField] setText:text];
}

- (void)setKeyboardType:(UIKeyboardType)keyboardType {
    [[self textField] setKeyboardType:keyboardType];
}

- (void)setKeyboardReturnKeyType:(UIReturnKeyType)returnType {
    [[self textField] setReturnKeyType:returnType];
}

- (void)setSecure:(BOOL)secure {
    [[self textField] setSecureTextEntry:secure];
}

- (void)becomeFirstResponder {
    [[self textField] becomeFirstResponder];
}

- (void)didChangeTextInField:(UITextField*)textField {
    [[self delegate] didChangeTextTo:[textField text] from:self];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ([[self delegate] respondsToSelector:@selector(didTapOnKeyboardReturnKeyFrom:)]) {
        [[self delegate] didTapOnKeyboardReturnKeyFrom:self];
    }
    return YES;
}

@end
