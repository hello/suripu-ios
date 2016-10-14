//
//  HEMAlarmExpansionListCell.h
//  Sense
//
//  Created by Jimmy Lu on 10/12/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "HEMAlarmListCell.h"

@interface HEMAlarmExpansionListCell : HEMAlarmListCell

@property (weak, nonatomic) IBOutlet UIView* expansionSeparator;
@property (weak, nonatomic) IBOutlet UIImageView* expansionIconView;
@property (weak, nonatomic) IBOutlet UILabel* expansionLabel;

@end
