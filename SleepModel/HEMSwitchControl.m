//
//  HEMSwitchControl.m
//  Sense
//
//  Created by Delisa Mason on 3/30/15.
//  Copyright (c) 2015 Hello. All rights reserved.
//

#import "HEMSwitchControl.h"
#import "UIColor+HEMStyle.h"

@implementation HEMSwitchControl

- (void)awakeFromNib {
    self.onTintColor = [UIColor tintColor];
    self.backgroundColor = [UIColor switchOffBackgroundColor];
    self.layer.cornerRadius = ceilf(CGRectGetHeight(self.bounds) / 2);
}

@end
