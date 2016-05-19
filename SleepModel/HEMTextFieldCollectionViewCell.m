//
//  HEMTextFieldCollectionViewCell.m
//  Sense
//
//  Created by Jimmy Lu on 5/13/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "HEMTextFieldCollectionViewCell.h"
#import "HEMTitledTextField.h"
#import "HEMSimpleLineTextField.h"
#import "HEMStyle.h"

@class HEMSimpleLineTextField;

@interface HEMTextFieldCollectionViewCell()

@property (nonatomic, weak) IBOutlet HEMTitledTextField* titledTextField;

@end

@implementation HEMTextFieldCollectionViewCell

- (void)setPlaceholderText:(NSString*)placeholderText {
    [[self titledTextField] setPlaceholderText:placeholderText];
}

- (HEMSimpleLineTextField*)textField {
    return [[self titledTextField] textField];
}

@end
