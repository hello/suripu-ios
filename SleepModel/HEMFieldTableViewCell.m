//
//  HEMFieldTableViewCell.m
//  Sense
//
//  Created by Jimmy Lu on 5/29/15.
//  Copyright (c) 2015 Hello. All rights reserved.
//

#import "HEMFieldTableViewCell.h"
#import "UIFont+HEMStyle.h"
#import "HelloStyleKit.h"

@interface HEMFieldTableViewCell()

@property (nonatomic, weak) IBOutlet UITextField* textField;

@end

@implementation HEMFieldTableViewCell

- (void)awakeFromNib {
    [[self textField] setFont:[UIFont textfieldTextFont]];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    [[self textField] setAttributedPlaceholder:nil];
    [[self textField] setText:nil];
}

- (void)setPlaceHolder:(NSString*)text {
    if ([text length] == 0) return;
    
    NSDictionary* attributes = @{NSFontAttributeName : [UIFont textfieldPlaceholderFont],
                                 NSForegroundColorAttributeName : [HelloStyleKit textfieldPlaceholderColor]};
    NSAttributedString* attributedPlaceHolder =
        [[NSAttributedString alloc] initWithString:text attributes:attributes];
    
    [[self textField] setAttributedPlaceholder:attributedPlaceHolder];
}

@end
