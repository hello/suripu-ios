//
//  HEMTextFieldCollectionViewCell.m
//  Sense
//
//  Created by Jimmy Lu on 5/13/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "HEMTextFieldCollectionViewCell.h"
#import "HEMTitledTextField.h"

@interface HEMTextFieldCollectionViewCell()

@property (nonatomic, weak) IBOutlet HEMTitledTextField* titledTextField;
@property (weak, nonatomic) IBOutlet UIButton *revealSecretButton;

@end

@implementation HEMTextFieldCollectionViewCell

- (void)setPlaceholderText:(NSString*)placeholderText {
    [[[self titledTextField] textField] setPlaceholder:placeholderText];
}

- (UITextField*)textField {
    return [[self titledTextField] textField];
}

- (void)setSecure:(BOOL)secure {
    [[self textField] setSecureTextEntry:secure];
    [[self revealSecretButton] setHidden:!secure];
    
    if (secure) {
        [[self revealSecretButton] addTarget:self
                                      action:@selector(reveal)
                            forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void)reveal {
    BOOL reveal = ![[self revealSecretButton] isSelected];
    [[self revealSecretButton] setSelected:reveal];
    
    UITextField* textField = [self textField];
    UITextPosition* cursorPosition = [textField beginningOfDocument];
    
    // must move the cursor back and forth, otherwise cursor is at a position that
    // appears to have added whitespace, but there really isn't due to size of dots
    // and actual character size
    [textField setSelectedTextRange:[textField textRangeFromPosition:cursorPosition
                                                          toPosition:cursorPosition]];
    [textField setSecureTextEntry:!reveal];
    
    cursorPosition = [textField endOfDocument];
    [textField setSelectedTextRange:[textField textRangeFromPosition:cursorPosition
                                                          toPosition:cursorPosition]];
}

@end
