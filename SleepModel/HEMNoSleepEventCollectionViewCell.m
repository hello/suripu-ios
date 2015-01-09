
#import "HEMNoSleepEventCollectionViewCell.h"
#import "HelloStyleKit.h"

@interface HEMNoSleepEventCollectionViewCell ()

@end

@implementation HEMNoSleepEventCollectionViewCell

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGFloat width = HEMSleepLineWidth;
    CGFloat height = CGRectGetHeight(rect);
    CGFloat x = CGRectGetMidX(rect)  - width;
    CGContextSetFillColorWithColor(ctx, [HelloStyleKit timelineLineColor].CGColor);
    CGRect contentRect = CGRectMake(x, CGRectGetMinY(rect), width, height);
    CGContextFillRect(ctx, contentRect);
}
@end
