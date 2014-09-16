
#import "HEMAlarmAddButton.h"
#import "HelloStyleKit.h"

@implementation HEMAlarmAddButton

- (void)awakeFromNib
{
    [self setTitleColor:[HelloStyleKit lightBlueColor] forState:UIControlStateNormal];
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    [[UIColor whiteColor] setFill];
    CGContextFillEllipseInRect(ctx, rect);
}

@end
