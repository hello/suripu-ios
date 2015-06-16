//
//  HEMTimelineMessageContainerView.m
//  Sense
//
//  Created by Delisa Mason on 6/12/15.
//  Copyright (c) 2015 Hello. All rights reserved.
//

#import "HEMTimelineMessageContainerView.h"

@implementation HEMTimelineMessageContainerView

- (void)awakeFromNib {
    self.layer.cornerRadius = 2.f;
    self.layer.shadowRadius = 3.f;
    self.layer.shadowOpacity = 0.08f;
    self.layer.shadowOffset = CGSizeMake(0, 0);
}

@end
