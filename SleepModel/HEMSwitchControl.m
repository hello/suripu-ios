//
//  HEMSwitchControl.m
//  Sense
//
//  Created by Delisa Mason on 3/30/15.
//  Copyright (c) 2015 Hello. All rights reserved.
//

#import "HEMSwitchControl.h"
#import "HelloStyleKit.h"

@implementation HEMSwitchControl

- (void)awakeFromNib {
    self.onTintColor = [HelloStyleKit tintColor];
    self.backgroundColor = [HelloStyleKit switchOffBackgroundColor];
    self.layer.cornerRadius = ceilf(CGRectGetHeight(self.bounds) / 2);
}

@end
