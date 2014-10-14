
#import "HEMSleepSummaryCollectionViewCell.h"
#import "HEMSleepScoreGraphView.h"
#import "HEMTimelineDrawingUtils.h"

@interface HEMSleepSummaryCollectionViewCell ()

@property (weak, nonatomic) IBOutlet HEMSleepScoreGraphView* sleepScoreGraphView;
@end

@implementation HEMSleepSummaryCollectionViewCell

static CGFloat const HEMSleepSummaryShadowHeight = 5.f;
static CGFloat const HEMSleepSummaryInsetHeight = 8.f;

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
    CGRect contentRect = CGRectMake(CGRectGetMinX(rect), CGRectGetMinY(rect), CGRectGetWidth(rect), CGRectGetHeight(rect) - HEMSleepSummaryShadowHeight - HEMSleepSummaryInsetHeight);
    CGContextFillRect(ctx, contentRect);

    CGFloat colors[] = {
        0.51, 0.52, 0.52, 0.1,
        0.302, 0.31, 0.306, 0.0,
    };
    CGRect shadowRect = CGRectMake(CGRectGetMinX(rect), CGRectGetMaxY(rect) - HEMSleepSummaryInsetHeight - HEMSleepSummaryShadowHeight, CGRectGetWidth(rect), HEMSleepSummaryShadowHeight);
    [HEMTimelineDrawingUtils drawVerticalGradientInRect:shadowRect withColors:colors];
}

@end
