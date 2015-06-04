
#import <SenseKit/SENAccount.h>
#import <SenseKit/SENServiceHealthKit.h>

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
    [self trackAnalyticsEvent:HEMAnalyticsEventWeight];
}

- (void)configureScale {
    [self setRuler:[[HEMRulerView alloc] initWithSegments:HEMWeightPickerMaxWeight
                                                direction:HEMRulerDirectionHorizontal]];
    
    [[self scrollView] addSubview:[self ruler]];
    [[self scrollView] setBackgroundColor:[UIColor clearColor]];
    
    [[self currentWeightMarker] setBackgroundColor:[HelloStyleKit senseBlueColor]];
    
    if (![[self ruler] respondsToSelector:@selector(layoutMarginsDidChange)]) {
        [[self scrollView] setContentInset:UIEdgeInsetsMake(0.0f, 8.0f, 0.0f, 8.0f)];
    }
}

- (void)configureButtons {
    [self stylePrimaryButton:[self doneButton]
             secondaryButton:[self skipButton]
                withDelegate:[self delegate] != nil];
    
    [self enableBackButton:NO];
}

- (void)adjustConstraintsForIPhone4 {
    [super adjustConstraintsForIPhone4];
    [self updateConstraint:[self scrollBottomConstraint] withDiff:35.0f];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    CGRect rulerFrame = [[self ruler] frame];
    rulerFrame.origin.x = CGRectGetMidX([[self currentWeightMarker] frame]);
    [[self ruler] setFrame:rulerFrame];
    
    CGSize contentSize = CGSizeZero;
    contentSize.width = CGRectGetWidth(rulerFrame) + (CGRectGetMinX(rulerFrame)*2);
    contentSize.height = CGRectGetHeight([[self scrollView] bounds]);
    [[self scrollView] setContentSize:contentSize];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self scrollToSetWeight];
}

- (void)scrollToSetWeight {
    SENAccountGender gender = [[[HEMOnboardingCache sharedCache] account] gender];
    CGFloat genderWeight = gender == SENAccountGenderFemale ? HEMWeightDefaultFemale : HEMWeightDefaultMale;
    CGFloat initialWeight = [self defaultWeightLbs] > 0 ? [self defaultWeightLbs] : genderWeight;
    CGFloat initialOffset = (initialWeight*(HEMRulerSegmentSpacing+HEMRulerSegmentWidth))-[[self scrollView] contentInset].left;
    [[self scrollView] setContentOffset:CGPointMake(initialOffset, 0.0f) animated:YES];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat offX = [scrollView contentOffset].x;
    CGFloat markX = ((offX + [scrollView contentInset].left) / (HEMRulerSegmentSpacing+HEMRulerSegmentWidth));
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
    [HEMOnboardingUtils saveOnboardingCheckpoint:HEMOnboardingCheckpointAccountDone];
    
    NSString* segueId = nil;
    if ([[SENServiceHealthKit sharedService] isSupported]) {
        segueId = [HEMOnboardingStoryboard weightToHealthKitSegueIdentifier];
    } else {
        segueId = [HEMOnboardingStoryboard weightToLocationSegueIdentifier];
    }
    
    [self performSegueWithIdentifier:segueId sender:self];
}

@end
