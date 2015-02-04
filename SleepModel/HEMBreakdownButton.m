//
//  HEMBreakdownButton.m
//  Sense
//
//  Created by Delisa Mason on 2/3/15.
//  Copyright (c) 2015 Hello, Inc. All rights reserved.
//

#import "HEMBreakdownButton.h"
#import "HelloStyleKit.h"

@interface HEMBreakdownButton ()
@property (nonatomic) CGFloat targetGraphHeight;
@end

@implementation HEMBreakdownButton

- (void)awakeFromNib
{
    self.targetGraphHeight = CGRectGetHeight(self.bounds);
}

- (void)animateDiameterTo:(CGFloat)targetHeight
{
    CGFloat height = self.targetGraphHeight;
    if (height == targetHeight)
        return;
    CGFloat diff = ABS(targetHeight - height);
    if (targetHeight > height) {
        for (int i = 0; i < diff; i++) {
            CGFloat nextHeight = height + i;
            [self animateTargetGraphHeightTo:nextHeight timeOffset:i];
        }
    } else {
        for (int i = 0; i < diff; i++) {
            CGFloat nextHeight = height - i;
            [self animateTargetGraphHeightTo:nextHeight timeOffset:i];
        }
    }
}

- (void)animateTargetGraphHeightTo:(CGFloat)targetHeight timeOffset:(CGFloat)offset
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(offset * 0.0035 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        _targetGraphHeight = targetHeight;
        [self setNeedsDisplay];
    });
}

- (void)setSleepScore:(NSInteger)sleepScore
{
    if (sleepScore == _sleepScore)
        return;
    _sleepScore = sleepScore;
    [self setNeedsDisplay];
}

- (void)setVisible:(BOOL)visible
{
    if (visible == _visible)
        return;
    _visible = visible;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    if (self.sleepScore == 0 || ![self isVisible])
        return;
    [HelloStyleKit drawBreakdownWithSleepScore:self.sleepScore
                                   controlSize:self.targetGraphHeight];
}

@end
