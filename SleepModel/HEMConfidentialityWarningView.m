
#import <SenseKit/SENAuthorizationService.h>
#import "HEMConfidentialityWarningView.h"
#import "UIFont+HEMStyle.h"
#import "HelloStyleKit.h"

@interface HEMConfidentialityWarningView ()

@property (nonatomic, strong) UILabel* textLabel;
@property (nonatomic, strong) NSString* text;
@end

@implementation HEMConfidentialityWarningView

static CGFloat HEMConfidentialityWarningViewHeight = 14.f;

+ (UIWindow*)viewInNewWindow
{
    CGRect frame = CGRectMake(0, 0,
                              CGRectGetWidth([UIScreen mainScreen].bounds),
                              HEMConfidentialityWarningViewHeight);
    UIWindow* window = [[UIWindow alloc] initWithFrame:frame];
    window.windowLevel = UIWindowLevelStatusBar+2;
    [window addSubview:[HEMConfidentialityWarningView new]];
    window.hidden = NO;
    window.userInteractionEnabled = NO;
    return window;
}

- (instancetype)init
{
    CGRect frame = CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds), HEMConfidentialityWarningViewHeight);
    if (self = [super initWithFrame:frame]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setNeedsLayout) name:SENAuthorizationServiceDidAuthorizeNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setNeedsLayout) name:SENAuthorizationServiceDidDeauthorizeNotification object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)layoutSubviews
{
    self.hidden = ![SENAuthorizationService isAuthorized];
    self.backgroundColor = [UIColor clearColor];
    if (!self.textLabel) {
        self.textLabel = [[UILabel alloc] initWithFrame:self.frame];
        self.textLabel.backgroundColor = [UIColor clearColor];
        self.textLabel.textColor = [HelloStyleKit backViewTextColor];
        self.textLabel.font = [UIFont confidentialityWarningFont];
        self.textLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.textLabel];
    }
    self.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"confidentiality-warning.format", nil), [SENAuthorizationService emailAddressOfAuthorizedUser] ?: @""];
}

@end
