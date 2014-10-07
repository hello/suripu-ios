
#import "HEMSleepSummaryCollectionViewCell.h"
#import "HEMSleepScoreGraphView.h"

@interface HEMSleepSummaryCollectionViewCell ()

@property (weak, nonatomic) IBOutlet HEMSleepScoreGraphView* sleepScoreGraphView;
@end

@implementation HEMSleepSummaryCollectionViewCell

static CGFloat const HEMSleepSummaryShadowHeight = 5.f;

- (void)awakeFromNib
{
    self.backgroundColor = [UIColor clearColor];
}

- (void)setSleepScore:(NSUInteger)sleepScore animated:(BOOL)animated
{
    [self.sleepScoreGraphView setSleepScore:sleepScore animated:animated];
}

- (void)drawRect:(CGRect)rect
{
    [self drawShadowGradientInRect:rect];
}

- (void)drawShadowGradientInRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(ctx, [UIColor colorWithWhite:0.97f alpha:1.f].CGColor);
    CGRect contentRect = CGRectMake(CGRectGetMinX(rect), CGRectGetMinY(rect), CGRectGetWidth(rect), CGRectGetHeight(rect) - HEMSleepSummaryShadowHeight);
    CGRect shadowRect = CGRectMake(CGRectGetMinX(rect), CGRectGetHeight(contentRect), CGRectGetWidth(rect), HEMSleepSummaryShadowHeight);
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
