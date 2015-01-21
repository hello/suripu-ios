
#import <SenseKit/SENAccount.h>

#import "UIFont+HEMStyle.h"

#import "HEMWeightPickerViewController.h"
#import "HEMOnboardingCache.h"
#import "HelloStyleKit.h"
#import "HEMBaseController+Protected.h"
#import "HEMActionButton.h"
#import "HEMOnboardingStoryboard.h"
#import "HEMMathUtil.h"
#import "HEMOnboardingUtils.h"
#import "HEMRulerView.h"

NSInteger const HEMWeightPickerMaxWeight = 900;

static CGFloat const HEMWeightDefaultFemale = 110.0f;
static CGFloat const HEMWeightDefaultMale = 175.0f;

@interface HEMWeightPickerViewController () <UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UILabel* topWeightLabel;
@property (weak, nonatomic) IBOutlet UILabel* botWeightLabel;
@property (weak, nonatomic) IBOutlet HEMActionButton *doneButton;
@property (weak, nonatomic) IBOutlet UIButton *skipButton;
@property (weak, nonatomic) IBOutlet UIView *currentWeightMarker;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scrollBottomConstraint;

@property (strong, nonatomic) HEMRulerView* ruler;
@property (assign, nonatomic) CGFloat weightInKgs;

@end

@implementation HEMWeightPickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configureButtons];
    [self configureScale];
    
    if ([self delegate] == nil) {
        [SENAnalytics track:kHEMAnalyticsEventOnBWeight];
    }
}

- (void)configureScale {
    [self setRuler:[[HEMRulerView alloc] initWithSegments:HEMWeightPickerMaxWeight
                                                direction:HEMRulerDirectionHorizontal]];
    
    [[self scrollView] addSubview:[self ruler]];
    [[self scrollView] setBackgroundColor:[UIColor clearColor]];
    [[self scrollView] setShowsHorizontalScrollIndicator:NO];
    [[self scrollView] setShowsVerticalScrollIndicator:NO];
    
    [[self currentWeightMarker] setBackgroundColor:[HelloStyleKit senseBlueColor]];
}

- (void)configureButtons {
    [[[self skipButton] titleLabel] setFont:[UIFont secondaryButtonFont]];
    [[self skipButton] setTitleColor:[HelloStyleKit senseBlueColor]
                            forState:UIControlStateNormal];
    
    if ([self delegate] != nil) {
        NSString* done = NSLocalizedString(@"status.success", nil);
        NSString* cancel = NSLocalizedString(@"actions.cancel", nil);
        [[self doneButton] setTitle:done forState:UIControlStateNormal];
        [[self skipButton] setTitle:cancel forState:UIControlStateNormal];
    } else {
        [self enableBackButton:NO];
    }
}

- (void)adjustConstraintsForIPhone4 {
    [super adjustConstraintsForIPhone4];
    [self updateConstraint:[self scrollBottomConstraint] withDiff:35.0f];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    CGRect rulerFrame = [[self ruler] frame];
    rulerFrame.origin.x = CGRectGetMidX([[self currentWeightMarker] frame]);
    [[self ruler] setFrame:rulerFrame];
    
    CGSize contentSize = CGSizeZero;
    contentSize.width = CGRectGetWidth(rulerFrame) + (CGRectGetMinX(rulerFrame)*2);
    contentSize.height = CGRectGetHeight([[self scrollView] bounds]);
    [[self scrollView] setContentSize:contentSize];
    
    CGPoint point = [[self ruler] convertPoint:[[self ruler] frame].origin
                                        toView:[self currentWeightMarker]];
    CGFloat markerX = CGRectGetMinX([[self currentWeightMarker] frame]);
    CGFloat diff = floorf(markerX - point.x);
    
    if (diff <= 0) {
        [[self scrollView] setContentInset:UIEdgeInsetsMake(0.0f, diff, 0.0f, diff)];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    SENAccountGender gender = [[[HEMOnboardingCache sharedCache] account] gender];
    CGFloat genderWeight = gender == SENAccountGenderFemale ? HEMWeightDefaultFemale : HEMWeightDefaultMale;
    CGFloat initialWeight = [self defaultWeightLbs] >0 ? [self defaultWeightLbs] : genderWeight;
    CGFloat leftInset = [[self scrollView] contentInset].left;
    CGFloat initialOffset = (initialWeight*HEMRulerSegmentSpacing)-leftInset;
    [[self scrollView] setContentOffset:CGPointMake(initialOffset, 0.0f)
                               animated:YES];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat offX = [scrollView contentOffset].x;
    CGFloat markX = ((offX + [scrollView contentInset].left) / HEMRulerSegmentSpacing);
    CGFloat lbs = MAX(0.0f, markX);
    CGFloat kgs = HEMToKilograms(@(lbs));

    NSString* lbsText = [NSString stringWithFormat:NSLocalizedString(@"measurement.lb.format", nil), lbs];
    [[self topWeightLabel] setText:lbsText];
    
    NSString* kgsText = [NSString stringWithFormat:NSLocalizedString(@"measurement.kg.format", nil), kgs];
    [[self botWeightLabel] setText:kgsText];
    
    [self setWeightInKgs:kgs];
}

#pragma mark - Actions

- (IBAction)done:(id)sender {
    if ([self delegate] != nil) {
        [[self delegate] didSelectWeightInKgs:[self weightInKgs] from:self];
    } else {
        [[[HEMOnboardingCache sharedCache] account] setWeight:@(ceilf([self weightInKgs] * 1000))];
        [self next];
    }
}

- (IBAction)skip:(id)sender {
    if ([self delegate] != nil) {
        [[self delegate] didCancelWeightFrom:self];
    } else {
        [self next];
    }
}

- (void)next {
    [self performSegueWithIdentifier:[HEMOnboardingStoryboard locationSegueIdentifier]
                              sender:self];
}

@end
