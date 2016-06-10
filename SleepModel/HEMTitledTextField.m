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

@interface HEMTitledTextField()

@property (nonatomic, weak) IBOutlet UILabel* titleLabel;

@end

@implementation HEMTitledTextField

- (void)awakeFromNib {
    [self configureDefaults];
}

- (void)configureDefaults {
    [[self titleLabel] setTextColor:[UIColor lowImportanceTextColor]];
    [[self titleLabel] setFont:[UIFont h7]];
    [[self titleLabel] setHidden:YES];
}

- (void)setPlaceholderText:(NSString *)placeholderText {
    _placeholderText = [placeholderText copy];
    [[self titleLabel] setText:_placeholderText];
    [[self titleLabel] setHidden:NO];
    [[self textField] setPlaceholder:nil];
}

@end
