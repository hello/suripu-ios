//
//  HEMSenseRequiredCollectionViewCell.h
//  Sense
//
//  Created by Jimmy Lu on 11/5/15.
//  Copyright © 2015 Hello. All rights reserved.
//

#import "HEMCardCollectionViewCell.h"

@class HEMActionButton;

@interface HEMSenseRequiredCollectionViewCell : HEMCardCollectionViewCell

@property (nonatomic, weak) IBOutlet UIImageView* illustrationView;
@property (nonatomic, weak) IBOutlet UILabel* descriptionLabel;
@property (nonatomic, weak) IBOutlet HEMActionButton* pairSenseButton;

@end
