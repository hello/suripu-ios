
#import "HEMActionButton.h"
#import "HelloStyleKit.h"

static CGFloat const kHEMActionCornerRadius = 20.0f;
static CGFloat const kHEMActionBorderWidth = 2.0f;

@interface HEMActionButton()

@property (nonatomic, assign) CGRect originalFrame;
@property (nonatomic, copy)   NSString* originalTitle;
@property (nonatomic, assign) BOOL showingActivity;
@property (nonatomic, strong) UIActivityIndicatorView* activityView;

@end

@implementation HEMActionButton

- (id)initWithCoder:(NSCoder*)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        self.layer.cornerRadius = kHEMActionCornerRadius;
        self.backgroundColor = [UIColor clearColor];
        self.layer.borderColor = [HelloStyleKit mediumBlueColor].CGColor;
        self.layer.borderWidth = kHEMActionBorderWidth;
        [self setTitle:@"" forState:UIControlStateDisabled];
    }
    return self;
}

- (void)addActivityView {
    // TODO (jimmy): we should animate a border around the circle instead, similar to the sleep number view
    if ([self activityView] == nil) {
        [self setActivityView:[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray]];
        [[self activityView] hidesWhenStopped];
    }
    // re-center it
    [[self activityView] setCenter:CGPointMake(CGRectGetWidth([self bounds])/2, CGRectGetHeight([self bounds])/2)];
    [self addSubview:[self activityView]];
}

- (void)showActivity {
    if ([self showingActivity]) return;
    
    if (CGRectIsEmpty([self originalFrame])) {
        [self setOriginalFrame:[self frame]];
    }
    
    if ([self activityView] == nil) {
        [self setActivityView:[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray]];
        [[self activityView] setCenter:CGPointMake(CGRectGetWidth([self bounds])/2, CGRectGetHeight([self bounds])/2)];
        [[self activityView] hidesWhenStopped];
        [self addSubview:[self activityView]];
    }
    // take the height as the diameter
    CGFloat size = CGRectGetHeight([self bounds]);
    CGFloat radius = size / 2.0f;
    CGPoint center = [self center];
    center.x = CGRectGetMidX([self frame]);

    [self setShowingActivity:YES];
    [self setOriginalTitle:[self titleForState:UIControlStateNormal]]; // always take latest
    [self setTitle:@"" forState:UIControlStateNormal];
    [self setTitle:@"" forState:UIControlStateDisabled];
    [self setEnabled:NO];
    
    [UIView animateWithDuration:0.25f
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

- (void)stopActivity {
    [[self activityView] stopAnimating];
    [UIView animateWithDuration:0.25f
                     animations:^{
                         [self setFrame:[self originalFrame]];
                         [[self layer] setCornerRadius:kHEMActionCornerRadius];
                     }
                     completion:^(BOOL finished) {
                         [self setShowingActivity:NO];
                         [self setTitle:[self originalTitle] forState:UIControlStateNormal];
                         [self setTitle:[self originalTitle] forState:UIControlStateDisabled];
                         [self setEnabled:YES];
                     }];
}

@end
