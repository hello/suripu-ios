
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
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    if (!self.lineView) {
        self.lineView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.bounds) - 1, CGRectGetWidth(self.bounds), 1.f)];
        self.lineView.backgroundColor = [HelloStyleKit onboardingBlueColor];
        [self addSubview:self.lineView];
    }
}

@end
