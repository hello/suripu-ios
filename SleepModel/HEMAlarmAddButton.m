
#import "HEMAlarmAddButton.h"
#import "HelloStyleKit.h"
#import "UIView+HEMMotionEffects.h"
#import "UIColor+HEMStyle.h"

@implementation HEMAlarmAddButton

static NSString* const HEMAlarmAddText = @"+";
static CGFloat const HEMAlarmAddTextVerticalOffset = 2.f;
static CGFloat const HEMAlarmAddParallaxDepth = 3.f;

- (void)awakeFromNib
{
    [self setTitle:nil forState:UIControlStateNormal];
    self.backgroundColor = [UIColor clearColor];
    self.layer.shadowRadius = 2.f;
    self.layer.shadowOffset = CGSizeMake(0, 1.f);
    self.layer.shadowOpacity = 0.85f;
    self.layer.shadowColor = [UIColor colorWithWhite:0 alpha:0.2f].CGColor;
    self.layer.masksToBounds = NO;
    [self add3DEffectWithBorder:HEMAlarmAddParallaxDepth];
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    [[UIColor tintColor] setFill];
    CGContextFillEllipseInRect(ctx, rect);
    UIColor* color = [self colorForState];
    UIFont* font = [UIFont systemFontOfSize:24.f];
    NSDictionary* attributes = @{NSForegroundColorAttributeName : color, NSFontAttributeName : font};
    CGSize size = [HEMAlarmAddText sizeWithAttributes:attributes];
    CGPoint point = CGPointMake(ceilf(CGRectGetWidth(rect)/2 - size.width/2),
                                ceilf(CGRectGetHeight(rect)/2 - size.height/2) - HEMAlarmAddTextVerticalOffset);
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
