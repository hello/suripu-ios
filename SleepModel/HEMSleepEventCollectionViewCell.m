
#import "HEMSleepEventCollectionViewCell.h"
#import "HelloStyleKit.h"

@implementation HEMSleepEventCollectionViewCell

- (void)awakeFromNib
{
    self.backgroundColor = [HelloStyleKit lightestBlueColor];
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGFloat inset = HEMLinedCollectionViewCellLineOffset + HEMLinedCollectionViewCellLineWidth;
    CGFloat width = CGRectGetWidth(self.eventTypeButton.bounds);
    CGContextSetFillColorWithColor(ctx, self.fillColor.CGColor);
    if ([self isLastSegment] && ![self isFirstSegment]) {
        CGRect contentRect = CGRectMake(CGRectGetMinX(rect) + inset, CGRectGetMinY(rect), width, CGRectGetMidY(rect));
        CGContextFillRect(ctx, contentRect);
    } else if ([self isFirstSegment] && ![self isLastSegment]) {
        CGRect contentRect = CGRectMake(CGRectGetMinX(rect) + inset, CGRectGetMidY(rect), width, CGRectGetMidY(rect));
        CGContextFillRect(ctx, contentRect);
    }
}

@end
