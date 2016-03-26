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

@interface HEMSleepSoundConfigurationCell()

@property (nonatomic, weak) UIView* overlay;

@end

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

- (void)deactivate:(BOOL)deactivate {
    [self setUserInteractionEnabled:!deactivate];
    if (deactivate) {
        UIView* overlay = [[UIView alloc] initWithFrame:[self bounds]];
        [overlay setBackgroundColor:[UIColor colorWithWhite:1.0f alpha:0.5f]];
        [[self contentView] addSubview:overlay];
        [self setOverlay:overlay];
    } else {
        [[self overlay] removeFromSuperview];
    }
}

@end
