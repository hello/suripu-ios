//
//  HEMPlayButton.m
//  Sense
//
//  Created by Delisa Mason on 7/28/15.
//  Copyright (c) 2015 Hello. All rights reserved.
//

#import "HEMPlayButton.h"
#import "UIColor+HEMStyle.h"

@implementation HEMPlayButton

CGFloat const HEMPlayButtonShadowOpacity = 0.15f;

- (void)awakeFromNib {
    self.layer.cornerRadius = CGRectGetWidth(self.bounds) / 2;
    self.layer.shadowColor = [UIColor blackColor].CGColor;
    self.layer.shadowOpacity = 0.15f;
    self.layer.shadowRadius = 2.f;
    self.layer.shadowOffset = CGSizeMake(1.f, 1.f);
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.layer.cornerRadius = CGRectGetWidth(self.bounds) / 2;
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    if (highlighted) {
        self.backgroundColor = [UIColor timelineSelectedBackgroundColor];
        self.layer.shadowOpacity = 0.0f;
    } else {
        self.backgroundColor = [UIColor whiteColor];
        self.layer.shadowOpacity = HEMPlayButtonShadowOpacity;
    }
}

@end
