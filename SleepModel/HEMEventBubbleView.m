//
//  HEMEventBubbleView.m
//  Sense
//
//  Created by Delisa Mason on 5/21/15.
//  Copyright (c) 2015 Hello. All rights reserved.
//

#import "HEMEventBubbleView.h"

@implementation HEMEventBubbleView

- (void)awakeFromNib {
    self.layer.shadowOffset = CGSizeZero;
    self.layer.shadowRadius = 1.5f;
    self.layer.shadowColor = [UIColor blackColor].CGColor;
    self.layer.shadowOpacity = 0.2f;
    self.layer.cornerRadius = 3.f;
    self.backgroundColor = [UIColor whiteColor];
}

@end
