
#import "HEMSensorDataHeaderView.h"
#import "HelloStyleKit.h"

@interface HEMSensorDataHeaderView ()

@property (weak, nonatomic) IBOutlet UIView* temperatureContainerView;
@property (weak, nonatomic) IBOutlet UIView* humidityContainerView;
@property (weak, nonatomic) IBOutlet UIView* particulateContainerView;
@end

@implementation HEMSensorDataHeaderView

static CGFloat const HEMSensorDataHeaderViewShadowHeight = 5.f;

- (void)drawRect:(CGRect)rect
{
    [self drawShadowGradientInRect:rect];
}

- (void)drawShadowGradientInRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(ctx, [UIColor colorWithWhite:0.97f alpha:1.f].CGColor);
    CGRect contentRect = CGRectMake(CGRectGetMinX(rect), CGRectGetMinY(rect), CGRectGetWidth(rect), CGRectGetHeight(rect) - HEMSensorDataHeaderViewShadowHeight);
    CGRect shadowRect = CGRectMake(CGRectGetMinX(rect), CGRectGetHeight(contentRect), CGRectGetWidth(rect), HEMSensorDataHeaderViewShadowHeight);
    CGContextFillRect(ctx, contentRect);

    CGFloat colors[] = {
        0.51, 0.52, 0.52, 0.1,
        0.302, 0.31, 0.306, 0.0,
    };
    CGColorSpaceRef baseSpace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColorComponents(baseSpace, colors, NULL, 2);
    CGColorSpaceRelease(baseSpace), baseSpace = NULL;

    CGContextSaveGState(ctx);
    CGContextAddRect(ctx, shadowRect);
    CGContextClip(ctx);

    CGPoint startPoint = CGPointMake(CGRectGetMinX(shadowRect), CGRectGetMinY(shadowRect));
    CGPoint endPoint = CGPointMake(CGRectGetMinX(shadowRect), CGRectGetMaxY(shadowRect));

    CGContextDrawLinearGradient(ctx, gradient, startPoint, endPoint, 0);
    CGGradientRelease(gradient), gradient = NULL;

    CGContextRestoreGState(ctx);
}

@end
