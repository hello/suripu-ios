
#import "HEMDateButton.h"
#import "HelloStyleKit.h"

@implementation HEMDateButton

static CGFloat const HEMDateButtonWidthOffset = 18.f;
static CGFloat const HEMDateButtonHeightOffset = 8.f;
static CGFloat const HEMDateButtonTextOffset = 3.f;

- (void)awakeFromNib
{
    self.backgroundColor = [UIColor clearColor];
    [self setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
}


- (CGSize)intrinsicContentSize
{
    NSString* text = [self titleForState:self.state];
    CGSize textSize = [text sizeWithAttributes:@{NSFontAttributeName: self.titleLabel.font}];
    CGSize size = CGSizeMake(textSize.width + HEMDateButtonWidthOffset, textSize.height + HEMDateButtonHeightOffset);
    self.layer.cornerRadius = size.height/2;
    return size;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGFloat edgeDiameter = CGRectGetHeight(rect);
    CGContextSetFillColorWithColor(ctx, [HelloStyleKit tintColor].CGColor);
    CGContextFillEllipseInRect(ctx, CGRectMake(0, 0, edgeDiameter, edgeDiameter));
    CGContextFillEllipseInRect(ctx, CGRectMake(CGRectGetWidth(rect) - edgeDiameter, 0, edgeDiameter, edgeDiameter));
    CGContextFillRect(ctx, CGRectMake(CGRectGetMinX(rect) + (edgeDiameter/2), 0, CGRectGetWidth(rect) - edgeDiameter, CGRectGetHeight(rect)));
    NSString* text = [self titleForState:self.state];
    NSMutableDictionary* textAttributes = @{ NSFontAttributeName: self.titleLabel.font }.mutableCopy;
    if ([self isHighlighted])
        textAttributes[NSForegroundColorAttributeName] = [UIColor colorWithWhite:1.f alpha:0.5f];
    else
        textAttributes[NSForegroundColorAttributeName] = [UIColor whiteColor];
    CGSize textSize = [text sizeWithAttributes:textAttributes];
    CGPoint point = CGPointMake((CGRectGetWidth(rect) - textSize.width)/2,
                                (CGRectGetHeight(rect) - textSize.height)/2 + HEMDateButtonTextOffset);
    [text drawAtPoint:point withAttributes:textAttributes];
}

- (void)setTitle:(NSString *)title forState:(UIControlState)state
{
    [super setTitle:title forState:state];
    [self setNeedsDisplay];
}

- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    [self setNeedsDisplay];
}

@end
