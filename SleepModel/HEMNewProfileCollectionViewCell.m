//
//  HEMNewProfileCollectionViewCell.m
//  Sense
//
//  Created by Jimmy Lu on 5/13/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "HEMNewProfileCollectionViewCell.h"
#import "HEMStyle.h"

static CGFloat const HEMNewProfileButtonCornerRadius = 3.0f;
static CGFloat const HEMNewProfileButtonBorderWidth = 1.0f;

@implementation HEMNewProfileCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self configureAppearances];
}

- (void)configureAppearances {
    CALayer* buttonLayer = [[self fbAutofillButton] layer];
    [buttonLayer setCornerRadius:HEMNewProfileButtonCornerRadius];
    [buttonLayer setBorderColor:[[UIColor borderColor] CGColor]];
    [buttonLayer setBorderWidth:HEMNewProfileButtonBorderWidth];
    
    [[self fbAutofillButton] setTitleColor:[UIColor grey3] forState:UIControlStateHighlighted];
    [[self fbAutofillButton] setTitleColor:[UIColor grey3] forState:UIControlStateSelected];
}

@end
