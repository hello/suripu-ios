
#import "HEMSleepEventButton.h"

@implementation HEMSleepEventButton

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.layer.cornerRadius = CGRectGetWidth(frame) / 2;
        self.layer.borderWidth = 0.f;
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(ctx, [UIColor whiteColor].CGColor);
    CGContextFillEllipseInRect(ctx, CGRectInset(rect, 1.f, 1.f));
}

@end
