
#import "HEMActionButton.h"
#import "HelloStyleKit.h"

static CGFloat const kHEMActionCornerRadius = 20.0f;
static CGFloat const kHEMActionBorderWidth = 2.0f;
static CGFloat const kHEMActionDisabledAlpha = 0.3f;

@interface HEMActionButton()

@property (nonatomic, assign) CGRect originalFrame;
@property (nonatomic, copy)   NSString* originalTitle;
@property (nonatomic, assign, getter=isShowingActivity) BOOL showingActivity;
@property (nonatomic, strong) UIActivityIndicatorView* activityView;
@property (nonatomic, weak)   NSLayoutConstraint* widthConstraint;

@end

@implementation HEMActionButton

- (id)initWithCoder:(NSCoder*)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        self.layer.cornerRadius = kHEMActionCornerRadius;
        self.backgroundColor = [UIColor clearColor];
        self.layer.borderColor = [HelloStyleKit onboardingBlueColor].CGColor;
        self.layer.borderWidth = kHEMActionBorderWidth;
        [self setTitleColor:[HelloStyleKit onboardingBlueColor] forState:UIControlStateNormal];
        [self setTitleColor:[[HelloStyleKit onboardingBlueColor] colorWithAlphaComponent:kHEMActionDisabledAlpha]
                   forState:UIControlStateDisabled];
        [self.titleLabel setFont:[UIFont fontWithName:@"Calibre-Medium" size:16.f]];
    }
    return self;
}

- (void)setEnabled:(BOOL)enabled {
    UIColor* color = [HelloStyleKit onboardingBlueColor];
    if (!enabled) {
        color = [color colorWithAlphaComponent:kHEMActionDisabledAlpha];
    }
    [[self layer] setBorderColor:[color CGColor]];
    [super setEnabled:enabled];
}

- (void)addActivityView {
    // TODO (jimmy): we should animate a border around the circle instead, similar to the sleep number view
    if ([self activityView] == nil) {
        [self setActivityView:[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray]];
        [[self activityView] setHidesWhenStopped:YES];
    }
    // re-center it
    [[self activityView] setCenter:CGPointMake(CGRectGetWidth([self bounds])/2, CGRectGetHeight([self bounds])/2)];
    [self addSubview:[self activityView]];
}

- (void)prepareForActivity {
    if (CGRectIsEmpty([self originalFrame])) {
        [self setOriginalFrame:[self frame]];
    }
    
    if ([self activityView] == nil) {
        [self setActivityView:[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray]];
        [[self activityView] setCenter:CGPointMake(CGRectGetWidth([self bounds])/2, CGRectGetHeight([self bounds])/2)];
        [[self activityView] hidesWhenStopped];
        [self addSubview:[self activityView]];
    }
    
    [self setShowingActivity:YES];
    [self setOriginalTitle:[self titleForState:UIControlStateNormal]]; // always take latest
    [self setTitle:@"" forState:UIControlStateNormal];
    [self setTitle:@"" forState:UIControlStateDisabled];
    [self setEnabled:NO];
}

- (void)showActivity {
    if ([self isShowingActivity]) return;
    
    [self prepareForActivity];
    
    // take the height as the diameter
    CGFloat size = CGRectGetHeight([self bounds]);
    CGFloat radius = size / 2.0f;
    CGPoint center = [self center];
    center.x = CGRectGetMidX([self frame]);
    
    [UIView animateWithDuration:0.25f
                          delay:0.0f
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         CGRect bounds = [self bounds];
                         bounds.size.width = size;
                         [self setBounds:bounds];
                         [self setCenter:center];
                         [[self layer] setCornerRadius:radius];
                     }
                     completion:^(BOOL finished) {
                         [self addActivityView];
                         [[self activityView] startAnimating];
                     }];
}

- (void)showActivityWithWidthConstraint:(NSLayoutConstraint*)constraint {
    if ([self isShowingActivity]) return;
    
    [self prepareForActivity];
    [self setWidthConstraint:constraint];
    
    [UIView animateWithDuration:0.25f
                          delay:0.0f
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         [constraint setConstant:CGRectGetHeight([self bounds])];
                         [self layoutIfNeeded];
                     }
                     completion:^(BOOL finished) {
                         [self addActivityView];
                         [[self activityView] startAnimating];
                     }];
}

- (void)stopActivity {
    if (![self isShowingActivity]) return;
    
    [[self activityView] stopAnimating];
    [UIView animateWithDuration:0.25f
                          delay:0.0f
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         if ([self widthConstraint] != nil) {
                             CGFloat width = CGRectGetWidth([self originalFrame]);
                             [[self widthConstraint] setConstant:width];
                             [self layoutIfNeeded];
                         } else {
                             [self setFrame:[self originalFrame]];
                         }
                     }
                     completion:^(BOOL finished) {
                         [self setShowingActivity:NO];
                         [[self activityView] stopAnimating];
                         [self setTitle:[self originalTitle] forState:UIControlStateNormal];
                         [self setTitle:[self originalTitle] forState:UIControlStateDisabled];
                         [self setEnabled:YES];
                     }];
}

@end
