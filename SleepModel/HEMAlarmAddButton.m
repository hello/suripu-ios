
#import "HEMAlarmAddButton.h"
#import "HelloStyleKit.h"

@implementation HEMAlarmAddButton

static NSString* const HEMAlarmAddText = @"+";

- (void)awakeFromNib
{
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self setTitleColor:[UIColor colorWithWhite:0.9 alpha:0.25] forState:UIControlStateDisabled];
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    [[HelloStyleKit lightSleepColor] setFill];
    CGContextFillEllipseInRect(ctx, rect);
    UIColor* color = [self isEnabled] ? [UIColor whiteColor] : [UIColor colorWithWhite:0.9 alpha:0.25];
    UIFont* font = [UIFont systemFontOfSize:24.f];
    NSDictionary* attributes = @{NSForegroundColorAttributeName : color, NSFontAttributeName : font};
    CGSize size = [HEMAlarmAddText sizeWithAttributes:attributes];
    CGPoint point = cgpo
}

@end
