
#import "HEMAlarmAddButton.h"
#import "HelloStyleKit.h"

@implementation HEMAlarmAddButton

static NSString* const HEMAlarmAddText = @"+";

- (void)awakeFromNib
{
    [self setTitle:nil forState:UIControlStateNormal];
    self.backgroundColor = [UIColor clearColor];
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    [[HelloStyleKit lightSleepColor] setFill];
    CGContextFillEllipseInRect(ctx, rect);
    UIColor* color = [self colorForState];
    UIFont* font = [UIFont systemFontOfSize:24.f];
    NSDictionary* attributes = @{NSForegroundColorAttributeName : color, NSFontAttributeName : font};
    CGSize size = [HEMAlarmAddText sizeWithAttributes:attributes];
    CGPoint point = CGPointMake(floorf(CGRectGetWidth(rect)/2 - size.width/2),
                                floorf(CGRectGetHeight(rect)/2 - size.height/2));
    [HEMAlarmAddText drawAtPoint:point withAttributes:attributes];
}

- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    [self setNeedsDisplay];
}

- (UIColor *)colorForState
{
    if ([self isEnabled] && ![self isHighlighted])
        return [UIColor whiteColor];

    return [UIColor colorWithWhite:0.9 alpha:0.25];
}

@end
