
#import "HEMSleepSegmentCollectionViewCell.h"
#import "HelloStyleKit.h"

@interface HEMSleepSegmentCollectionViewCell ()

@property (nonatomic) CGFloat fillRatio;
@property (nonatomic, strong) UIColor* fillColor;
@end

@implementation HEMSleepSegmentCollectionViewCell

- (void)setSegmentRatio:(CGFloat)ratio withColor:(UIColor*)color
{
    self.fillRatio = ratio;
    self.fillColor = color;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGFloat inset = HEMLinedCollectionViewCellLineOffset + HEMLinedCollectionViewCellLineWidth;
    CGRect fillRect = CGRectMake(inset, CGRectGetMinY(rect), (CGRectGetWidth(rect) - inset) * self.fillRatio, CGRectGetHeight(rect));
    CGContextClearRect(ctx, fillRect);
    CGContextSetFillColorWithColor(ctx, self.fillColor.CGColor);
    CGContextFillRect(ctx, fillRect);
}

@end
