
#import "HEMSleepSegmentCollectionViewCell.h"
#import "HelloStyleKit.h"

CGFloat HEMLinedCollectionViewCellLineOffset = 20.f;
CGFloat HEMLinedCollectionViewCellLineWidth = 2.f;
CGFloat HEMSleepSegmentMinimumFillWidth = 28.f;

@interface HEMSleepSegmentCollectionViewCell ()

@property (nonatomic, readwrite) CGFloat fillRatio;
@property (nonatomic, strong, readwrite) UIColor* fillColor;
@end

@implementation HEMSleepSegmentCollectionViewCell

- (void)awakeFromNib
{
    self.backgroundColor = [UIColor whiteColor];
}

- (void)setSegmentRatio:(CGFloat)ratio withColor:(UIColor*)color
{
    self.fillRatio = MIN(ratio, 1.0);
    self.fillColor = color;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    if (![self isLastSegment] && ![self isFirstSegment]) {
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        CGFloat inset = HEMLinedCollectionViewCellLineOffset + HEMLinedCollectionViewCellLineWidth;
        CGFloat maximumFillWidth = (CGRectGetWidth(rect) - (inset*2));
        CGFloat width = MAX(maximumFillWidth * self.fillRatio, HEMSleepSegmentMinimumFillWidth);
        CGRect fillRect = CGRectMake(inset, CGRectGetMinY(rect), width, CGRectGetHeight(rect));
        CGContextClearRect(ctx, fillRect);
        CGContextSetFillColorWithColor(ctx, self.fillColor.CGColor);
        CGContextFillRect(ctx, fillRect);

        inset += HEMSleepSegmentMinimumFillWidth;
        width = (CGRectGetWidth(rect) - inset);
        fillRect = CGRectMake(inset, CGRectGetMinY(rect), width, CGRectGetHeight(rect));
        CGContextSetFillColorWithColor(ctx, [UIColor colorWithWhite:1.f alpha:0.8].CGColor);
        CGContextFillRect(ctx, fillRect);
    }
}

@end
