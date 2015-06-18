//
//  HEMTimelineToBarView.m
//  Sense
//
//  Created by Delisa Mason on 6/11/15.
//  Copyright (c) 2015 Hello. All rights reserved.
//

#import "HEMTimelineTopBarView.h"
#import "HelloStyleKit.h"

@implementation HEMTimelineTopBarView

- (void)awakeFromNib {
    self.layer.shadowOpacity = 0;
    self.layer.shadowColor = [UIColor colorWithWhite:0 alpha:0.2f].CGColor;
    self.layer.shadowOffset = CGSizeZero;
    self.layer.masksToBounds = NO;
}

- (void)showShadow:(BOOL)isVisible animated:(BOOL)animated {
    void (^animations)() = ^{
      if (isVisible) {
          self.layer.shadowRadius = 3.f;
          self.layer.shadowOffset = CGSizeMake(0, 3.f);
          self.layer.shadowOpacity = 0.3f;
      } else {
          self.layer.shadowRadius = 0;
          self.layer.shadowOffset = CGSizeZero;
          self.layer.shadowOpacity = 0;
      }
    };
    if (animated) {
        [UIView animateWithDuration:0.25f animations:animations];
    } else {
        animations();
    }
}

@end
