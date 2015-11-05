//
//  HEMNoAlarmCell.h
//  Sense
//
//  Created by Jimmy Lu on 11/4/15.
//  Copyright © 2015 Hello. All rights reserved.
//

#import "HEMCardCollectionViewCell.h"

@class HEMActionButton;

@interface HEMNoAlarmCell : HEMCardCollectionViewCell

@property (weak, nonatomic) IBOutlet UILabel *detailLabel;
@property (weak, nonatomic) IBOutlet HEMActionButton *alarmButton;

@end
