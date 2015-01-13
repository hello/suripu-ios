//
//  HEMNoDeviceCollectionViewCell.h
//  Sense
//
//  Created by Jimmy Lu on 1/7/15.
//  Copyright (c) 2015 Hello, Inc. All rights reserved.
//

#import "HEMCardCollectionViewCell.h"

@class HEMActionButton;

@interface HEMNoDeviceCollectionViewCell : HEMCardCollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet HEMActionButton *actionButton;


@end