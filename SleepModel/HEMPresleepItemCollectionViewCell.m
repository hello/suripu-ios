//
//  HEMPresleepItemCollectionViewCell.m
//  Sense
//
//  Created by Delisa Mason on 10/13/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import <SenseKit/SENSleepResult.h>
#import "HEMPresleepItemCollectionViewCell.h"
#import "HelloStyleKit.h"

@interface HEMPresleepItemCollectionViewCell ()
@property (nonatomic, strong) CAGradientLayer* gradientLayer;
@property (nonatomic, weak) IBOutlet UIView* buttonContainerView;
@property (nonatomic, strong) NSArray* sensorInsights;
@property (nonatomic) NSInteger selectedIndex;
@end

@implementation HEMPresleepItemCollectionViewCell

static CGFloat const HEMPresleepItemBorderWidth = 1.f;
static CGFloat const HEMBorderDashLength[] = {4,4};
static CGFloat const HEMInsightButtonWidth = 40.f;
static CGFloat const HEMInsightButtonMaximumSpacing = 90.f;
static CGFloat const HEMInsightAnimationDuration = 0.2f;
static int const HEMInsightButtonTagOffset = 90032;
static int const HEMBorderDashLengthCount = 2;

- (void)addButtonsForInsights:(NSArray *)insights
{
    self.sensorInsights = insights;
    [self layoutInsightButtons];
}

- (void)didTapInsightButton:(UIButton*)sender
{
    long index = sender.tag - HEMInsightButtonTagOffset;
    if (index < self.sensorInsights.count) {
        SENSleepResultSensorInsight* insight = self.sensorInsights[index];
        if ([self.messageLabel.text isEqualToString:insight.message]) {
            if ([self.presleepActionDelegate respondsToSelector:@selector(willHideInsightDetails)])
                [self.presleepActionDelegate willHideInsightDetails];
            self.selectedIndex = NSNotFound;
            [UIView animateWithDuration:HEMInsightAnimationDuration animations:^{
                self.messageLabel.alpha = 0;
            } completion:^(BOOL finished) {
                self.messageLabel.text = nil;
                self.messageLabel.alpha = 1;
            }];
            [self unhighlightAllButtons];
        } else {
            if ([self.presleepActionDelegate respondsToSelector:@selector(willShowDetailsForInsight:)])
                [self.presleepActionDelegate willShowDetailsForInsight:insight];
            self.selectedIndex = index;
            [UIView animateWithDuration:0.1f animations:^{
                self.messageLabel.alpha = 0;
            } completion:^(BOOL finished) {
                [self highlightButton:sender];
                self.messageLabel.text = insight.message;
                [UIView animateWithDuration:HEMInsightAnimationDuration animations:^{
                    self.messageLabel.alpha = 1;
                }];
            }];
        }
    }
}

- (void)highlightButton:(UIButton*)highlightedButton
{
    [UIView animateWithDuration:HEMInsightAnimationDuration animations:^{
        for (UIView* view in self.buttonContainerView.subviews) {
            if ([view isKindOfClass:[UIButton class]]) {
                UIButton* button = (id)view;
                if ([button isEqual:highlightedButton]) {
                    long index = button.tag - HEMInsightButtonTagOffset;
                    if (index < self.sensorInsights.count) {
                        SENSleepResultSensorInsight* insight = self.sensorInsights[index];
                        UIColor* tintColor = [self tintColorForInsight:insight];
                        button.backgroundColor = [tintColor colorWithAlphaComponent:0.2];
                        button.tintColor = tintColor;
                    }
                } else {
                    button.backgroundColor = [UIColor clearColor];
                    button.tintColor = [HelloStyleKit timelineInsightTintColor];
                }
            }
        }
    }];
}

- (void)unhighlightAllButtons
{
    [UIView animateWithDuration:HEMInsightAnimationDuration animations:^{
        for (UIView* view in self.buttonContainerView.subviews) {
            if ([view isKindOfClass:[UIButton class]]) {
                UIButton* button = (id)view;
                long index = button.tag - HEMInsightButtonTagOffset;
                if (index < self.sensorInsights.count) {
                    SENSleepResultSensorInsight* insight = self.sensorInsights[index];
                    button.tintColor = [self tintColorForInsight:insight];
                    button.backgroundColor = [UIColor clearColor];
                }
            }
        }
    }];
}

#pragma mark Layout

- (void)awakeFromNib
{
    self.messageLabel.text = nil;
    self.selectedIndex = NSNotFound;
}

- (void)setNeedsLayout
{
    [super setNeedsLayout];
    [self setNeedsDisplay];
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    [self unhighlightAllButtons];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    if (!self.gradientLayer) {
        UIColor* borderColor = [HelloStyleKit timelineInsightTintColor];
        UIColor* topColor = [HelloStyleKit timelineGradientDarkColor];
        UIColor* bottomColor = [UIColor whiteColor];
        self.gradientLayer = [CAGradientLayer layer];
        self.gradientLayer.colors = @[(id)borderColor.CGColor,(id)topColor.CGColor, (id)bottomColor.CGColor];
        self.gradientLayer.locations = @[@0, @(1/CGRectGetHeight(self.bounds)), @1];
        [self.layer insertSublayer:self.gradientLayer atIndex:0];
    }
    CGRect gradientRect = self.bounds;
    gradientRect.size.height -= HEMPresleepItemBorderWidth * 2;
    gradientRect.origin.y += HEMPresleepItemBorderWidth;
    self.gradientLayer.frame = gradientRect;
}

- (void)layoutInsightButtons
{
    if (self.buttonContainerView.subviews.count > 0)
        [self.buttonContainerView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    CGFloat count = self.sensorInsights.count;
    CGFloat buttonsWidth = count * HEMInsightButtonWidth;
    CGFloat availableWidth = CGRectGetWidth([UIScreen mainScreen].bounds);
    CGFloat separatorWidth = MAX(0, MIN(HEMInsightButtonMaximumSpacing, (availableWidth - buttonsWidth)/count));
    CGFloat totalWidth = buttonsWidth;
    if (count > 1)
        totalWidth += separatorWidth * (count - 1);
    CGFloat xOffset = (availableWidth - totalWidth)/2;
    CGFloat halfButton = floorf(HEMInsightButtonWidth/2);

    for (int i = 0; i < count; i++) {
        CGFloat x = ((HEMInsightButtonWidth + separatorWidth) * i) + xOffset;
        CGRect buttonFrame = CGRectMake(x, 0, HEMInsightButtonWidth, HEMInsightButtonWidth);
        UIButton* button = [[UIButton alloc] initWithFrame:buttonFrame];
        SENSleepResultSensorInsight* insight = self.sensorInsights[i];
        [button setImage:[self imageForInsight:insight] forState:UIControlStateNormal];
        button.tintColor = [self tintColorForInsight:insight];
        button.tag = i + HEMInsightButtonTagOffset;
        button.layer.cornerRadius = halfButton;
        [button addTarget:self action:@selector(didTapInsightButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.buttonContainerView addSubview:button];
        if (i == self.selectedIndex) {
            [self highlightButton:button];
        }
        if (i < count - 1) {
            CGRect lineFrame = CGRectMake(x + HEMInsightButtonWidth, halfButton, separatorWidth, 1.f);
            UIView* lineView = [[UIView alloc] initWithFrame:lineFrame];
            lineView.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.f];
            [self.buttonContainerView addSubview:lineView];
        }
    }
}

- (UIImage*)imageForInsight:(SENSleepResultSensorInsight*)insight
{
    UIImage* image = nil;
    if ([insight.name isEqualToString:@"temperature"]) {
        image = [HelloStyleKit grayTemperatureIcon];
    } else if ([insight.name isEqualToString:@"humidity"]) {
        image = [HelloStyleKit grayHumidityIcon];
    } else if ([insight.name isEqualToString:@"light"]) {
        image = [HelloStyleKit grayLightIcon];
    } else if ([insight.name isEqualToString:@"particulates"]) {
        image = [HelloStyleKit grayParticulatesIcon];
    } else if ([insight.name isEqualToString:@"sound"]) {
        image = [HelloStyleKit graySoundIcon];
    }
    image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    return image;
}

- (UIColor*)tintColorForInsight:(SENSleepResultSensorInsight*)insight
{
    switch (insight.condition) {
        case SENSensorConditionAlert:
            return [HelloStyleKit alertSensorColor];
        case SENSensorConditionIdeal:
            return [HelloStyleKit idealSensorColor];
        case SENSensorConditionWarning:
            return [HelloStyleKit warningSensorColor];
        case SENSensorConditionUnknown:
        default:
            return [HelloStyleKit timelineInsightTintColor];
    }
}

- (void)drawRect:(CGRect)rect
{
    [self drawBordersInRect:rect];
}

- (void)drawBordersInRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGColorRef color = [HelloStyleKit timelineSectionBorderColor].CGColor;
    CGContextSetStrokeColorWithColor(ctx, color);
    CGContextSetLineWidth(ctx, HEMPresleepItemBorderWidth);
    CGContextSetLineDash(ctx, 0, HEMBorderDashLength, HEMBorderDashLengthCount);
    CGFloat y = CGRectGetHeight(rect) - HEMPresleepItemBorderWidth;
    CGContextMoveToPoint(ctx, CGRectGetMinX(rect), y);
    CGContextAddLineToPoint(ctx, CGRectGetMaxX(rect), y);
    CGContextStrokePath(ctx);
}

@end
