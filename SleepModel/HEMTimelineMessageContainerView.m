//
//  HEMTimelineMessageContainerView.m
//  Sense
//
//  Created by Delisa Mason on 6/12/15.
//  Copyright (c) 2015 Hello. All rights reserved.
//

#import "HEMTimelineMessageContainerView.h"
#import "UIColor+HEMStyle.h"

static CGFloat const HEMTimelineMessageShadowOpacity = 0.08f;

@interface HEMTimelineMessageContainerView()

@property (nonatomic, strong) UITapGestureRecognizer* tapGesture;

@end

@implementation HEMTimelineMessageContainerView

- (void)awakeFromNib {
    self.layer.cornerRadius = 2.f;
    self.layer.shadowRadius = 3.f;
    self.layer.shadowOpacity = HEMTimelineMessageShadowOpacity;
    self.layer.shadowOffset = CGSizeMake(0, 0);
    self.backgroundColor = [UIColor whiteColor];
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    if (highlighted) {
        self.layer.shadowOpacity = 0.0f;
        self.backgroundColor = [UIColor timelineBackgroundColor];
    } else {
        self.layer.shadowOpacity = HEMTimelineMessageShadowOpacity;
        self.backgroundColor = [UIColor whiteColor];
    }
}

@end
