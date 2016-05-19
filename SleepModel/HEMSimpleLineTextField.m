
#import "UIFont+HEMStyle.h"

#import "HEMSimpleLineTextField.h"
#import "UIColor+HEMStyle.h"

static CGFloat const HEMSimpleLineHeight = 1.0f;
static CGFloat const HEMSimpleLineRevealPadding = 10.0f;

@interface HEMSimpleLineTextField()

@property (nonatomic, strong) UIButton* revealSecretButton;

@end

@implementation HEMSimpleLineTextField

- (id)initWithCoder:(NSCoder*)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        self.backgroundColor = [UIColor clearColor];
        [self setBorderStyle:UITextBorderStyleNone];
        [self setTintColor:[UIColor tintColor]];
        [self setFont:[UIFont textfieldTextFont]];
        [self setTextColor:[UIColor grey6]];
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
        ? [UIColor tintColor]
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
    UIColor* placeholderColor = [self isFirstResponder] ? [UIColor grey3] : [UIColor grey4];
    
    NSDictionary* placeHolderAttrs = @{
        NSFontAttributeName : [UIFont textfieldPlaceholderFont],
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
    [[self textFieldDelegate] textField:self didGainFocus:focus];
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
    
    UITextPosition* cursorPosition = [self beginningOfDocument];
    
    // must move the cursor back and forth, otherwise cursor is at a position that
    // appears to have added whitespace, but there really isn't due to size of dots
    // and actual character size
    [self setSelectedTextRange:[self textRangeFromPosition:cursorPosition
                                                toPosition:cursorPosition]];
    [self setSecureTextEntry:NO];
    
    // http://stackoverflow.com/questions/35293379/uitextfield-securetextentry-toggle-set-incorrect-font
    [self setFont:nil];
    [self setFont:[UIFont textfieldTextFont]];
    
    cursorPosition = [self endOfDocument];
    [self setSelectedTextRange:[self textRangeFromPosition:cursorPosition
                                                toPosition:cursorPosition]];
}

- (void)hideText {
    [[self revealSecretButton] setSelected:NO];
    [self setSecureTextEntry:YES];
}

@end
