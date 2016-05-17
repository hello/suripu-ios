//
//  HEMNewProfileCollectionViewCell.m
//  Sense
//
//  Created by Jimmy Lu on 5/13/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "HEMNewProfileCollectionViewCell.h"
#import "HEMProfileImageView.h"
#import "HEMStyle.h"

static CGFloat const HEMNewProfileButtonCornerRadius = 3.0f;
static CGFloat const HEMNewProfileButtonBorderWidth = 1.0f;

@interface HEMNewProfileCollectionViewCell()

@property (weak, nonatomic) IBOutlet HEMProfileImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UIButton *fbAutofillButton;
@property (weak, nonatomic) IBOutlet UIButton *fbInfoButton;

@end

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
}

@end
