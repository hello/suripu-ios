
#import "HEMSleepSummaryCollectionViewCell.h"
#import "HEMSleepScoreGraphView.h"
#import "HEMTimelineDrawingUtils.h"

@interface HEMSleepSummaryCollectionViewCell ()

@end

@implementation HEMSleepSummaryCollectionViewCell

static CGFloat const HEMSleepSummaryShadowHeight = 1.f;

- (void)awakeFromNib
{
    UIColor* topColor = [UIColor whiteColor];
    UIColor* bottomColor = [UIColor colorWithRed:0.96 green:0.96 blue:0.97 alpha:1];
    CAGradientLayer *gradient = [CAGradientLayer layer];
    CGRect gradientRect = self.bounds;
    gradientRect.size.height -= HEMSleepSummaryShadowHeight;
    gradient.frame = gradientRect;
    gradient.colors = @[(id)topColor.CGColor, (id)bottomColor.CGColor];
    [self.layer insertSublayer:gradient atIndex:0];
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
    CGRect shadowRect = CGRectMake(CGRectGetMinX(rect), CGRectGetHeight(rect) - HEMSleepSummaryShadowHeight, CGRectGetWidth(rect), HEMSleepSummaryShadowHeight);
    CGContextSetFillColorWithColor(ctx, [UIColor colorWithRed:0.9 green:0.91 blue:0.91 alpha:1].CGColor);
    CGContextFillRect(ctx, shadowRect);
}

@end
