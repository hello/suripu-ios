//
//  HEMAlarmListCell.h
//  Sense
//
//  Created by Delisa Mason on 12/17/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import "HEMCardCollectionViewCell.h"

@interface HEMAlarmListCell : HEMCardCollectionViewCell

@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *meridiemLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;
@property (weak, nonatomic) IBOutlet UISwitch *enabledSwitch;
@end
