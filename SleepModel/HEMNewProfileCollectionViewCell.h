//
//  HEMNewProfileCollectionViewCell.h
//  Sense
//
//  Created by Jimmy Lu on 5/13/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HEMProfileImageView;

@interface HEMNewProfileCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet HEMProfileImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UIButton *fbAutofillButton;
@property (weak, nonatomic) IBOutlet UIButton *fbInfoButton;

@end
