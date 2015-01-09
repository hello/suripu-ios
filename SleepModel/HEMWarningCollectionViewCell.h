//
//  HEMWarningCollectionViewCell.h
//  Sense
//
//  Created by Jimmy Lu on 1/8/15.
//  Copyright (c) 2015 Hello, Inc. All rights reserved.
//

#import "HEMCardCollectionViewCell.h"

extern CGFloat const HEMWarningCellBaseHeight;

@class HEMActionButton;

@interface HEMWarningCollectionViewCell : HEMCardCollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *warningMessageLabel;
@property (weak, nonatomic) IBOutlet HEMActionButton *actionButton;

@end
