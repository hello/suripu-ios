
#import "HEMAlarmAddButton.h"
#import "HelloStyleKit.h"

@implementation HEMAlarmAddButton

- (void)awakeFromNib
{
    [self setTitleColor:[UIColor colorWithRed:0.24 green:0.25 blue:0.27 alpha:1] forState:UIControlStateNormal];
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    [[UIColor whiteColor] setFill];
    CGContextFillEllipseInRect(ctx, rect);
}

@end
