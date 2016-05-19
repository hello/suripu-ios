//
//  HEMTitledTextField.h
//  Sense
//
//  Created by Jimmy Lu on 5/12/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HEMSimpleLineTextField;

@interface HEMTitledTextField : UIView

@property (nonatomic, weak) IBOutlet HEMSimpleLineTextField* textField;
@property (nonatomic, copy) NSString* placeholderText;

@end
