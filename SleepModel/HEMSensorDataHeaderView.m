
#import "HEMSensorDataHeaderView.h"
#import "HEMSensorDataHeaderClockContainerView.h"
#import "HelloStyleKit.h"

@interface HEMSensorDataHeaderView ()

@property (weak, nonatomic) IBOutlet HEMSensorDataHeaderClockContainerView* clockContainerView;
@end

@implementation HEMSensorDataHeaderView

static CGFloat const HEMSensorDataHeaderViewShadowHeight = 5.f;

- (void)awakeFromNib
{
    // Initialization code
}

- (void)drawRect:(CGRect)rect
{
    [self drawShadowGradientInRect:rect];
}

- (void)drawShadowGradientInRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(ctx, [UIColor colorWithWhite:0.97f alpha:1.f].CGColor);
    CGContextFillRect(ctx, CGRectMake(0, 0, CGRectGetWidth(rect), CGRectGetHeight(rect) - HEMSensorDataHeaderViewShadowHeight));
    CGContextSetFillColorWithColor(ctx, [HelloStyleKit intermediateSleepColor].CGColor);
    CGContextFillRect(ctx, CGRectMake(0, CGRectGetHeight(rect) - HEMSensorDataHeaderViewShadowHeight, CGRectGetWidth(rect), 1));

    CGFloat colors[] = {
        0.51, 0.52, 0.52, 0.25,
        0.302, 0.31, 0.306, 0.0,
    };
    CGRect shadowRect = CGRectMake(0, CGRectGetHeight(rect) - HEMSensorDataHeaderViewShadowHeight, CGRectGetWidth(rect), HEMSensorDataHeaderViewShadowHeight);
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
