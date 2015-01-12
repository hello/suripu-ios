
#import "UIFont+HEMStyle.h"

#import "HEMRoundedTextField.h"
#import "HelloStyleKit.h"

@interface HEMRoundedTextField ()

@property (nonatomic, strong) UIView* lineView;
@end

@implementation HEMRoundedTextField

- (id)initWithCoder:(NSCoder*)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        self.backgroundColor = [UIColor clearColor];
        [self setBorderStyle:UITextBorderStyleNone];
        [self setTintColor:[HelloStyleKit senseBlueColor]];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    if (!self.lineView) {
        self.lineView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.bounds) - 1, CGRectGetWidth(self.bounds), 1.f)];
        self.lineView.backgroundColor = [HelloStyleKit separatorColor];
        [self addSubview:self.lineView];
    } else {
        UIColor* placeholderColor = nil;
        UIColor* separatorColor = nil;

        if ([self isFirstResponder]) {
            separatorColor = [HelloStyleKit senseBlueColor];
            placeholderColor = [HelloStyleKit textfieldPlaceholderFocusedColor];
        } else {
            separatorColor = [HelloStyleKit separatorColor];
            placeholderColor = [HelloStyleKit textfieldPlaceholderColor];
        }
        
        NSDictionary* placeHolderAttrs = @{
            NSFontAttributeName : [UIFont textfieldPlaceholderFont],
            NSForegroundColorAttributeName : placeholderColor
        };
        NSAttributedString* attrText
            = [[NSAttributedString alloc] initWithString:[self placeholder]
                                              attributes:placeHolderAttrs];
        [self setAttributedPlaceholder:attrText];
        [[self lineView] setBackgroundColor:separatorColor];
        
    }
}

@end
