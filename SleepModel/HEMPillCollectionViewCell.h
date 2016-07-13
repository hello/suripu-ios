//
//  HEMPillCollectionViewCell.h
//  Sense
//
//  Created by Jimmy Lu on 7/13/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "HEMDeviceCollectionViewCell.h"

@class HEMActionButton;

@interface HEMPillCollectionViewCell : HEMDeviceCollectionViewCell

@property (weak, nonatomic) IBOutlet UILabel *firmwareLabel;
@property (weak, nonatomic) IBOutlet UILabel *firmwareValueLabel;
@property (weak, nonatomic) IBOutlet HEMActionButton *updateButton;

+ (CGFloat)heightWithFirmwareUpdate:(BOOL)firmwareUpdate;

@end
