//
//  HEMPopupMaskView.m
//  Sense
//
//  Created by Delisa Mason on 7/24/15.
//  Copyright (c) 2015 Hello. All rights reserved.
//

#import "HEMPopupMaskView.h"

@implementation HEMPopupMaskView

- (void)awakeFromNib {
    [super awakeFromNib];
    self.userInteractionEnabled = NO;
}

- (void)showUnderlyingViewRect:(CGRect)rect {
    CAShapeLayer *mask = [CAShapeLayer new];
    mask.fillRule = kCAFillRuleEvenOdd;
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, nil, self.bounds);
    CGPathAddRect(path, nil, rect);
    mask.path = path;
    CGPathRelease(path);
    self.layer.mask = mask;
}

@end
