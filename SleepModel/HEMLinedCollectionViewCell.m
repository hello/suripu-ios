
#import "HEMLinedCollectionViewCell.h"
#import "HelloStyleKit.h"

CGFloat HEMLinedCollectionViewCellLineOffset = 33.5f;
CGFloat HEMLinedCollectionViewCellLineWidth = 2.f;

@implementation HEMLinedCollectionViewCell

- (void)drawRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(ctx, [HelloStyleKit deepSleepColor].CGColor);
    CGRect lineRect = CGRectMake(HEMLinedCollectionViewCellLineOffset, 0, HEMLinedCollectionViewCellLineWidth, CGRectGetHeight(rect));
    CGContextFillRect(ctx, lineRect);
}

@end
