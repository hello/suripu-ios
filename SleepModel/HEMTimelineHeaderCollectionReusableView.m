//
//  HEMTimelineHeaderCollectionReusableView.m
//  Sense
//
//  Created by Delisa Mason on 11/3/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import "HEMTimelineHeaderCollectionReusableView.h"
#import "HelloStyleKit.h"

@interface HEMTimelineHeaderCollectionReusableView ()
@property (nonatomic, strong) CAGradientLayer* gradientLayer;
@end

@implementation HEMTimelineHeaderCollectionReusableView

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self configureGradientLayer];
}

- (void)configureGradientLayer
{
    if (!self.gradientLayer) {
        UIColor* topColor = [HelloStyleKit timelineGradientDarkColor];
        UIColor* bottomColor = [UIColor whiteColor];
        self.gradientLayer = [CAGradientLayer layer];
        self.gradientLayer.colors = @[(id)topColor.CGColor, (id)bottomColor.CGColor];
        self.gradientLayer.locations = @[@0, @1];
        [self.layer insertSublayer:self.gradientLayer atIndex:0];
    }
    self.gradientLayer.frame = self.bounds;
}

@end
