
#import "Sense-Swift.h"
#import "HEMSimpleLineTextField.h"

static CGFloat const HEMSimpleLineHeight = 1.0f;
static CGFloat const HEMSimpleLineRevealPadding = 10.0f;

@interface HEMSimpleLineTextField()
    
    @property (nonatomic, strong) UIButton* revealSecretButton;
    @property (nonatomic, strong) UIColor* lineColor;
    
    @end

@implementation HEMSimpleLineTextField
    
- (id)initWithCoder:(NSCoder*)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self applyStyle];
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
    
    if (![self lineColor]) {
        [self setLineColor:[SenseStyle colorWithAClass:[self class]
                                              property:ThemePropertyTintColor]];
    }
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    
    UIColor* lineColor
    = [self isFirstResponder]
    ? [self tintColor]
    : [self lineColor];
    
    CGContextSetStrokeColorWithColor(context, [lineColor CGColor]);
    CGContextSetLineWidth(context, HEMSimpleLineHeight);
    
    CGFloat y = CGRectGetHeight(self.bounds) - HEMSimpleLineHeight;
    CGContextMoveToPoint(context, 0.0f, y);
    CGContextAddLineToPoint(context, CGRectGetWidth([self bounds]), y);
    CGContextStrokePath(context);
    
    CGContextRestoreGState(context);
    
}
    
- (void)setText:(NSString *)text {
    NSInteger currentLength = [[self text] length];
    if ((currentLength == 0 && [text length] > 0)
        || (currentLength > 0 && [text length] == 0)) {
        [[self focusDelegate] textField:self didChange:text];
    }
    [super setText:text];
}
    
- (void)setFocus:(BOOL)focus {
    UIColor* placeholderColor = [self isFirstResponder] ? [self focusedPlaceholderColor] : [self placeholderColor];
    
    NSDictionary* placeHolderAttrs = @{
                                       NSFontAttributeName : [self font],
                                       NSForegroundColorAttributeName : placeholderColor
                                       };
    
    if ([self placeholder]) {
        NSAttributedString* attrText
        = [[NSAttributedString alloc] initWithString:[self placeholder]
                                          attributes:placeHolderAttrs];
        
        [self setAttributedPlaceholder:attrText];
    }
    
    if ([self isSecurityEnabled]) {
        if (focus) {
            [self revealText];
        } else {
            [self hideText];
        }
    }
    
    [self setNeedsDisplay];
    [[self focusDelegate] textField:self didGainFocus:focus];
}
    
- (void)setSecurityEnabled:(BOOL)securityEnabled {
    _securityEnabled = securityEnabled;
    [self setSecureTextEntry:securityEnabled];
    if (securityEnabled && ![self revealSecretButton]) {
        UIImage* revealImage = [UIImage imageNamed:@"secretEye"];
        UIImage* revealImageHighlighted = [UIImage imageNamed:@"secretEyeHighlighted"];
        UIButton* revealButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [revealButton setImage:revealImage forState:UIControlStateNormal];
        [revealButton setImage:revealImageHighlighted forState:UIControlStateHighlighted];
        [revealButton setImage:revealImageHighlighted forState:UIControlStateSelected];
        [revealButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
        [revealButton addTarget:self action:@selector(toggleTextVisibility) forControlEvents:UIControlEventTouchUpInside];
        
        CGRect buttonFrame = [revealButton frame];
        buttonFrame.size.height = CGRectGetHeight([self bounds]);
        buttonFrame.size.width = revealImage.size.width + (HEMSimpleLineRevealPadding * 2);
        [revealButton setFrame:buttonFrame];
        
        [self setRightView:revealButton];
        [self setRevealSecretButton:revealButton];
    }
    
    if (securityEnabled) {
        [self setRightViewMode:UITextFieldViewModeAlways];
    } else {
        [self setRightViewMode:UITextFieldViewModeNever];
    }
}
    
- (void)toggleTextVisibility {
    BOOL reveal = ![[self revealSecretButton] isSelected];
    if (reveal) {
        [self revealText];
    } else {
        [self hideText];
    }
}
    
- (void)revealText {
    [[self revealSecretButton] setSelected:YES];
    
    UIFont* font = [SenseStyle fontWithAClass:[self class] property:ThemePropertyTextFont];
    UITextPosition* cursorPosition = [self beginningOfDocument];
    
    // must move the cursor back and forth, otherwise cursor is at a position that
    // appears to have added whitespace, but there really isn't due to size of dots
    // and actual character size
    [self setSelectedTextRange:[self textRangeFromPosition:cursorPosition
                                                toPosition:cursorPosition]];
    [self setSecureTextEntry:NO];
    
    // http://stackoverflow.com/questions/35293379/uitextfield-securetextentry-toggle-set-incorrect-font
    [self setFont:nil];
    [self setFont:font];
    [self layoutIfNeeded];
    
    cursorPosition = [self endOfDocument];
    [self setSelectedTextRange:[self textRangeFromPosition:cursorPosition
                                                toPosition:cursorPosition]];
}
    
- (void)hideText {
    [[self revealSecretButton] setSelected:NO];
    [self setSecureTextEntry:YES];
    [self layoutIfNeeded];
}
    
- (void)applyStyle {
    UIColor* tintColor = [SenseStyle colorWithAClass:[self class]
                                            property:ThemePropertyTintHighlightedColor];
    UIColor* lineColor = [SenseStyle colorWithAClass:[self class]
                                            property:ThemePropertyTintColor];
    UIColor* placeHolderColor = [SenseStyle colorWithAClass:[self class]
                                                   property:ThemePropertyHintColor];
    UIColor* textColor = [SenseStyle colorWithAClass:[self class]
                                            property:ThemePropertyTextColor];
    UIFont* font = [SenseStyle fontWithAClass:[self class] property:ThemePropertyTextFont];
    
    NSString* keyboardStyle = [[SenseStyle theme] valueWithAClass:[self class]
                                                         property:ThemePropertyKeyboardAppearance];
    
    UIKeyboardAppearance keyboard = UIKeyboardAppearanceDefault;
    if ([keyboardStyle isEqualToString:@"sense.DARK"]) {
        keyboard = UIKeyboardAppearanceDark;
    }
    
    [self setFont:font];
    [self setKeyboardAppearance:keyboard];
    [self setTextColor:textColor];
    [self setTintColor:tintColor];
    [self setBorderStyle:UITextBorderStyleNone];
    [self setBackgroundColor:[UIColor clearColor]];
    [self setPlaceholderColor:placeHolderColor];
    [self setFocusedPlaceholderColor:placeHolderColor];
    [self setLineColor:lineColor];
}
    
@end
