//
//  HEMSleepGraphView.m
//  Sense
//
//  Created by Delisa Mason on 12/4/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import "HEMSleepGraphView.h"
#import "HelloStyleKit.h"

@interface HEMSleepGraphView ()

@property (weak, nonatomic) IBOutlet UIView *shadowView;
@property (nonatomic, getter=isAnimatingShadow) BOOL animatingShadow;
@end

@implementation HEMSleepGraphView

- (void)awakeFromNib {
    self.shadowView.layer.shadowOpacity = 0;
    self.shadowView.layer.shadowColor = [UIColor colorWithWhite:0 alpha:0.9f].CGColor;
    self.shadowView.layer.shadowOffset = CGSizeZero;
    self.shadowView.layer.masksToBounds = NO;
}

- (void)showShadow:(BOOL)isVisible animated:(BOOL)animated {
    if (isVisible == [self isShadowVisible] || [self isAnimatingShadow])
        return;
    self.animatingShadow = YES;
    void (^animations)() = ^{
        if (isVisible) {
            self.shadowView.layer.shadowRadius = 3.f;
            self.shadowView.layer.shadowOffset = CGSizeMake(0, 3.f);
            self.shadowView.layer.shadowOpacity = 0.4f;
        } else {
            self.shadowView.layer.shadowRadius = 0;
            self.shadowView.layer.shadowOffset = CGSizeZero;
            self.shadowView.layer.shadowOpacity = 0;
        }
        self.animatingShadow = NO;
    };
    if (animated) {
        [UIView animateWithDuration:0.25f animations:animations];
    } else {
        animations();
    }
}

- (BOOL)isShadowVisible {
    return self.shadowView.layer.shadowOpacity > 0;
}

@end
