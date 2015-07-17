
#import "UIFont+HEMStyle.h"

#import "HEMSimpleLineTextField.h"
#import "UIColor+HEMStyle.h"

static CGFloat const HEMSimpleLineHeight = 1.0f;

@interface HEMSimpleLineTextField ()

@end

@implementation HEMSimpleLineTextField

- (id)initWithCoder:(NSCoder*)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        self.backgroundColor = [UIColor clearColor];
        [self setBorderStyle:UITextBorderStyleNone];
        [self setTintColor:[UIColor senseBlueColor]];
        [self setFont:[UIFont textfieldTextFont]];
        [self setTextColor:[UIColor textfieldTextColor]];
        [self setFocus:NO];
    }
    return self;
}

- (BOOL)becomeFirstResponder {
    BOOL become = [super becomeFirstResponder];
    if (become) [self setFocus:YES];
    return become;
}

- (BOOL)resignFirstResponder {
    BOOL resign = [super resignFirstResponder];
    if (resign) [self setFocus:NO];
    return resign;
}

- (void)drawRect:(CGRect)rect {
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    
    UIColor* lineColor
        = [self isFirstResponder]
        ? [UIColor senseBlueColor]
        : [UIColor separatorColor];

    CGContextSetStrokeColorWithColor(context, [lineColor CGColor]);
    CGContextSetLineWidth(context, HEMSimpleLineHeight);
    
    CGFloat y = CGRectGetHeight(self.bounds) - HEMSimpleLineHeight;
    CGContextMoveToPoint(context, 0.0f, y);
    CGContextAddLineToPoint(context, CGRectGetWidth([self bounds]), y);
    CGContextStrokePath(context);
    
    CGContextRestoreGState(context);
    
}

- (void)setFocus:(BOOL)focus {
    UIColor* placeholderColor
        = [self isFirstResponder]
        ? [UIColor textfieldPlaceholderFocusedColor]
        : [UIColor textfieldPlaceholderColor];
    
    NSDictionary* placeHolderAttrs = @{
        NSFontAttributeName : [UIFont textfieldPlaceholderFont],
        NSForegroundColorAttributeName : placeholderColor
    };
    NSAttributedString* attrText
    = [[NSAttributedString alloc] initWithString:[self placeholder]
                                      attributes:placeHolderAttrs];
    
    [self setAttributedPlaceholder:attrText];
    [self setNeedsDisplay];
}

@end
