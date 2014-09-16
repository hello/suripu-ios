
#import "HEMSensorDataHeaderClockContainerView.h"
#import "HelloStyleKit.h"

@implementation HEMSensorDataHeaderClockContainerView

static CGFloat const HEMSensorDataHeaderClockContainerViewBorderWidth = 1.f;

- (void)awakeFromNib
{
    self.backgroundColor = [UIColor clearColor];
}

- (void)drawRect:(CGRect)rect
{
    [self fillRoundedRectInRect:rect withColor:[UIColor colorWithWhite:0.9 alpha:1.f]];
    CGRect inset = CGRectInset(rect, HEMSensorDataHeaderClockContainerViewBorderWidth, HEMSensorDataHeaderClockContainerViewBorderWidth);
    [self fillRoundedRectInRect:inset withColor:[UIColor whiteColor]];

}

- (void)fillRoundedRectInRect:(CGRect)rect withColor:(UIColor*)color
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGFloat segmentWidth = CGRectGetHeight(rect) / 2;
    CGContextSetFillColorWithColor(ctx, color.CGColor);
    CGContextFillEllipseInRect(ctx, CGRectMake(CGRectGetMinX(rect), CGRectGetMinY(rect), CGRectGetHeight(rect), CGRectGetHeight(rect)));
    CGContextFillEllipseInRect(ctx, CGRectMake(CGRectGetMinX(rect) + CGRectGetWidth(rect) - CGRectGetHeight(rect), CGRectGetMinY(rect), CGRectGetHeight(rect), CGRectGetHeight(rect)));
    CGContextFillRect(ctx, CGRectInset(rect, segmentWidth, 0));
}

@end
