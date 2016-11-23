//
//  HEMSwitchControl.m
//  Sense
//
//  Originally created by Delisa Mason for alarms.  Still needed
//
//  Created by Jimmy Lu on 1/22/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "HEMSwitchControl.h"
#import "HEMStyle.h"

@implementation HEMSwitchControl

- (void)awakeFromNib {
    [super awakeFromNib];
    self.onTintColor = [UIColor tintColor];
    self.backgroundColor = [UIColor grey1];
    self.layer.cornerRadius = ceilf(CGRectGetHeight(self.bounds) / 2);
}

@end
