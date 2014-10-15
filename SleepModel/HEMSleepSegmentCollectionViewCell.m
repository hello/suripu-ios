
#import "HEMSleepSegmentCollectionViewCell.h"
#import "HelloStyleKit.h"

CGFloat HEMLinedCollectionViewCellLineOffset = 14.f;
CGFloat HEMLinedCollectionViewCellLineWidth = 2.f;

@interface HEMSleepSegmentCollectionViewCell ()

@property (nonatomic, readwrite) CGFloat fillRatio;
@property (nonatomic, strong, readwrite) UIColor* fillColor;
@end

@implementation HEMSleepSegmentCollectionViewCell

static CGFloat HEMSleepSegmentMaximumFillRatio = 0.95f;
static CGFloat HEMSleepSegmentMinimumFillWidth = 24.f;

- (void)awakeFromNib
{
    self.backgroundColor = [HelloStyleKit lightestBlueColor];
}

- (void)setSegmentRatio:(CGFloat)ratio withColor:(UIColor*)color
{
    self.fillRatio = ratio;
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
        CGContextSetFillColorWithColor(ctx, [[HelloStyleKit lightestBlueColor] colorWithAlphaComponent:0.8].CGColor);
        CGContextFillRect(ctx, fillRect);
    }
}

@end
