//
//  HEMSleepSoundConfigurationCell.m
//  Sense
//
//  Created by Jimmy Lu on 3/9/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "HEMSleepSoundConfigurationCell.h"
#import "HEMStyle.h"

static CGFloat const HEMSleepSoundConfCellSeparatorHeight = 0.5f;

@implementation HEMSleepSoundConfigurationCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [[self titleSeparator] setBackgroundColor:[UIColor separatorColor]];
    [[self soundSeparator] setBackgroundColor:[UIColor separatorColor]];
    [[self durationSeparator] setBackgroundColor:[UIColor separatorColor]];
    
    [[self titleSeparatorHeight] setConstant:HEMSleepSoundConfCellSeparatorHeight];
    [[self soundSeparatorHeight] setConstant:HEMSleepSoundConfCellSeparatorHeight];
    [[self durationSeparatorHeight] setConstant:HEMSleepSoundConfCellSeparatorHeight];
}

@end
