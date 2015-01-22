#import <SenseKit/SENSettings.h>
#import <SenseKit/SENAccount.h>

#import "UIFont+HEMStyle.h"

#import "HEMHeightPickerViewController.h"
#import "HEMOnboardingCache.h"
#import "HEMActionButton.h"
#import "HEMOnboardingStoryboard.h"
#import "HEMOnboardingUtils.h"
#import "HEMBaseController+Protected.h"
#import "HEMRulerView.h"
#import "HelloStyleKit.h"
#import "HEMMathUtil.h"

CGFloat const HEMHeightPickerCentimetersPerInch = 2.54f;

static NSInteger const HEMMaxHeightInFeet = 9;
static NSInteger const HEMInchesPerFeet = 12;
static NSInteger const HEMHeightDefaultFeet = 5;
static NSInteger const HEMHeightDefaultInch = 8;

@interface HEMHeightPickerViewController () <UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *mainHeightLabel;
@property (weak, nonatomic) IBOutlet UILabel *otherHeightLabel;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *currentMarkerView;
@property (weak, nonatomic) IBOutlet HEMActionButton *doneButton;
@property (weak, nonatomic) IBOutlet UIButton *skipButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightLabelTrailingConstraint;

@property (assign, nonatomic) float selectedHeightInCm;
@property (strong, nonatomic) HEMRulerView* ruler;

@end

@implementation HEMHeightPickerViewController

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        _feet = -1;
        _inches = -1;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self configureButtons];
    [self configureRuler];
    
    if ([self delegate] == nil) {
        [SENAnalytics track:kHEMAnalyticsEventOnBHeight];
    }

}

- (void)configureButtons {
    [[[self skipButton] titleLabel] setFont:[UIFont secondaryButtonFont]];
    
    if ([self delegate] != nil) {
        NSString* done = NSLocalizedString(@"status.success", nil);
        NSString* cancel = NSLocalizedString(@"actions.cancel", nil);
        [[self doneButton] setTitle:done forState:UIControlStateNormal];
        [[self skipButton] setTitle:cancel forState:UIControlStateNormal];
    } else {
        [self enableBackButton:NO];
    }
}

- (void)configureRuler {
    [self setRuler:[[HEMRulerView alloc] initWithSegments:HEMMaxHeightInFeet*HEMInchesPerFeet
                                                direction:HEMRulerDirectionVertical]];
    
    [[self scrollView] addSubview:[self ruler]];
    [[self scrollView] setBackgroundColor:[UIColor clearColor]];
    
    [[self currentMarkerView] setBackgroundColor:[HelloStyleKit senseBlueColor]];
    
    // pre iOS 8, there are mystery default insets so this needs to be adjusted
    if (![[self ruler] respondsToSelector:@selector(layoutMarginsDidChange)]) {
        [[self scrollView] setContentInset:UIEdgeInsetsMake(8.0f, 0.0f, 8.0f, 0.0f)];
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    CGFloat scrollMinY = CGRectGetMinY([[self scrollView] frame]);
    CGFloat scrollWidth = CGRectGetWidth([[self scrollView] bounds]);
    CGFloat markerMinY = CGRectGetMinY([[self currentMarkerView] frame]);
    UIEdgeInsets insets = [[self scrollView] contentInset];
    
    CGRect rulerFrame = [[self ruler] frame];
    rulerFrame.origin.y = markerMinY - scrollMinY - insets.top;
    rulerFrame.origin.x = scrollWidth - CGRectGetWidth(rulerFrame);
    [[self ruler] setFrame:rulerFrame];

    CGSize contentSize = CGSizeZero;
    contentSize.width = scrollWidth;
    contentSize.height = CGRectGetHeight(rulerFrame) + (CGRectGetMinY(rulerFrame)*2);
    [[self scrollView] setContentSize:contentSize];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self scrollToSetHeight];
}

- (void)scrollToSetHeight {
    NSInteger feet = [self feet] >= 0 ? [self feet] : HEMHeightDefaultFeet;
    NSInteger inch = [self inches] >= 0 ? [self inches] : HEMHeightDefaultInch;
    NSInteger totalInches = (feet * HEMInchesPerFeet) + inch;
    NSInteger maxInches = HEMMaxHeightInFeet * HEMInchesPerFeet;
    CGFloat offset = ((maxInches-totalInches) * (HEMRulerSegmentSpacing+HEMRulerSegmentWidth)) - [[self scrollView] contentInset].top;
    [[self scrollView] setContentOffset:CGPointMake(0.0f, offset) animated:YES];
}

- (void)adjustConstraintsForIPhone4 {
    [super adjustConstraintsForIPhone4];
    [self updateConstraint:[self heightLabelTrailingConstraint] withDiff:-50.0f];
}

- (void)adjustConstraintsForIphone5 {
    [super adjustConstraintsForIphone5];
    [self updateConstraint:[self heightLabelTrailingConstraint] withDiff:-40.0f];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat offY = [scrollView contentOffset].y;
    CGFloat totalInches = MAX(0.0f, (offY + [scrollView contentInset].top) / (HEMRulerSegmentSpacing+HEMRulerSegmentWidth));
    CGFloat maxInches = HEMMaxHeightInFeet * HEMInchesPerFeet;
    CGFloat actualInches = maxInches - totalInches; // values are reversed
    
    NSInteger inches = (int)actualInches % HEMInchesPerFeet;
    NSInteger feet = actualInches / HEMInchesPerFeet;
    CGFloat cm = actualInches * HEMHeightPickerCentimetersPerInch;
    
    NSString* feetFormat = [NSString stringWithFormat:NSLocalizedString(@"measurement.ft.format", nil), (long)feet];
    NSString* inchFormat = [NSString stringWithFormat:NSLocalizedString(@"measurement.in.format", nil), (long)inches];
    NSString* cmFormat = [NSString stringWithFormat:NSLocalizedString(@"measurement.cm.format", nil), (long)cm];
    [[self mainHeightLabel] setText:[NSString stringWithFormat:@"%@ %@", feetFormat, inchFormat]];
    [[self otherHeightLabel] setText:[NSString stringWithFormat:@"%@", cmFormat]];

    [self setSelectedHeightInCm:cm];
    
    if ([self delegate] == nil) {
        [[[HEMOnboardingCache sharedCache] account] setHeight:@(cm)];
    }
    
}

#pragma mark - Actions

- (IBAction)done:(id)sender {
    if ([self delegate] != nil) {
        [[self delegate] didSelectHeightInCentimeters:[self selectedHeightInCm] from:self];
    } else {
        [self next];
    }
}

- (IBAction)skip:(id)sender {
    if ([self delegate] != nil) {
        [[self delegate] didCancelHeightFrom:self];
    } else {
        [self next];
    }
}

- (void)next {
    [self performSegueWithIdentifier:[HEMOnboardingStoryboard weightSegueIdentifier]
                              sender:self];
}

@end
