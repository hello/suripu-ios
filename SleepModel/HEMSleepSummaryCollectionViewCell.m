
#import "HEMSleepSummaryCollectionViewCell.h"
#import "HEMSleepScoreGraphView.h"
#import "HEMTimelineDrawingUtils.h"

@interface HEMSleepSummaryCollectionViewCell ()

@property (nonatomic, strong) CAGradientLayer* gradientLayer;
@end

@implementation HEMSleepSummaryCollectionViewCell

static CGFloat const HEMSleepSummaryShadowHeight = 1.f;

- (void)setSleepScore:(NSUInteger)sleepScore animated:(BOOL)animated
{
    [self.sleepScoreGraphView setSleepScore:sleepScore animated:animated];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    if (!self.gradientLayer) {
        UIColor* topColor = [UIColor whiteColor];
        UIColor* bottomColor = [UIColor colorWithRed:0.96 green:0.96 blue:0.97 alpha:1];
        self.gradientLayer = [CAGradientLayer layer];
        CGRect gradientRect = self.bounds;
        gradientRect.size.height -= HEMSleepSummaryShadowHeight;
        self.gradientLayer.frame = gradientRect;
        self.gradientLayer.colors = @[(id)topColor.CGColor, (id)bottomColor.CGColor];
        [self.layer insertSublayer:self.gradientLayer atIndex:0];
    }
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
