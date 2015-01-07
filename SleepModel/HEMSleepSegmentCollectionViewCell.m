
#import "HEMSleepSegmentCollectionViewCell.h"
#import "HelloStyleKit.h"

CGFloat const HEMLinedCollectionViewCellLineOffset = 28.f;
CGFloat const HEMLinedCollectionViewCellLineWidth = 2.f;
CGFloat const HEMSleepSegmentMinimumFillWidth = 28.f;
CGFloat const HEMSleepLineWidth = 1.f;

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
        CGFloat x = (CGRectGetWidth(rect) - width)/2;
        CGRect fillRect = CGRectMake(x, CGRectGetMinY(rect), width, CGRectGetHeight(rect));
        CGContextSetFillColorWithColor(ctx, self.fillColor.CGColor);
        CGContextFillRect(ctx, fillRect);
    }
}

@end
