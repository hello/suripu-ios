#import <SenseKit/SENAccount.h>
#import <SenseKit/SENPreference.h>

#import "HEMHeightPickerViewController.h"
#import "HEMOnboardingService.h"
#import "HEMActionButton.h"
#import "HEMOnboardingStoryboard.h"
#import "HEMRulerView.h"
#import "HEMStyle.h"
#import "HEMMathUtil.h"
#import "HEMAccountUpdateDelegate.h"

CGFloat const HEMHeightPickerCentimetersPerInch = 2.54f;

static NSInteger const HEMInchesPerFeet = 12;
static NSUInteger const HEMHeightTotalSegments = 274; // 1:1 segment:cm
static CGFloat const HEMHeightDefaultInCm = 172.72f;

@interface HEMHeightPickerViewController () <UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *heightLabel;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *currentMarkerView;
@property (weak, nonatomic) IBOutlet HEMActionButton *doneButton;
@property (weak, nonatomic) IBOutlet UIButton *skipButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightLabelTrailingConstraint;

@property (assign, nonatomic) CGFloat selectedHeightInCm;
@property (strong, nonatomic) HEMRulerView* ruler;
@property (assign, nonatomic, getter=isOffsetInitialized) BOOL offsetInitialized;
@property (assign, nonatomic) BOOL useMetric;

@end

@implementation HEMHeightPickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self configureButtons];
    [self configureRuler];
    [self trackAnalyticsEvent:HEMAnalyticsEventHeight];

}

- (void)configureButtons {
    [self stylePrimaryButton:[self doneButton]
             secondaryButton:[self skipButton]
                withDelegate:[self delegate] != nil];
    
    [self enableBackButton:NO];
}

- (void)configureRuler {
    [[self heightLabel] setFont:[UIFont h1]];
    [self setUseMetric:[SENPreference useMetricUnitForHeight]];
    
    [self setRuler:[[HEMRulerView alloc] initWithSegments:HEMHeightTotalSegments
                                                direction:HEMRulerDirectionVertical]];
    
    [[self scrollView] addSubview:[self ruler]];
    [[self scrollView] setBackgroundColor:[UIColor clearColor]];
    
    [[self currentMarkerView] setBackgroundColor:[UIColor tintColor]];
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
    
    if (![self isOffsetInitialized]) {
        CGPoint offset = [[self scrollView] contentOffset];
        offset.y = contentSize.height - CGRectGetHeight([[self scrollView] bounds]);
        [[self scrollView] setContentOffset:offset];
        [self setOffsetInitialized:YES];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self scrollToSetHeight];
}

- (void)scrollToSetHeight {
    NSNumber* cm = [self heightInCm] ?: @(HEMHeightDefaultInCm);
    CGFloat spacePerSegment = (HEMRulerSegmentSpacing+HEMRulerSegmentWidth);
    CGFloat offset = ((HEMHeightTotalSegments - [cm CGFloatValue]) * spacePerSegment) - [[self scrollView] contentInset].top;
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
    CGFloat topInset = [scrollView contentInset].top;
    CGFloat spacePerSegment = (HEMRulerSegmentSpacing+HEMRulerSegmentWidth);
    // it is important that we floor the value here b/c our API floors the value
    // when it is processed, which means that if we don't floor here, the value
    // shown may be different from what got stored
    CGFloat cm = floorCGFloat(HEMHeightTotalSegments - MAX(0.0f, (offY + topInset) / spacePerSegment));
    
    if ([self useMetric]) {
        [self updateLabelWithCentimeters:cm];
    } else {
        [self updateLabelWithInches:HEMToInches(@(cm))];
    }
    
    [self setSelectedHeightInCm:cm];
}

- (void)updateLabelWithCentimeters:(CGFloat)cm {
    self.heightLabel.text = [NSString stringWithFormat:NSLocalizedString(@"measurement.cm.format", nil), (long)cm];
}

- (void)updateLabelWithInches:(CGFloat)totalInches {
    CGFloat feet = floorCGFloat(totalInches / HEMInchesPerFeet);
    CGFloat inches = totalInches - (feet * HEMInchesPerFeet);
    NSString* feetFormat = [NSString stringWithFormat:NSLocalizedString(@"measurement.ft.format", nil), (long)feet];
    NSString* inchFormat = [NSString stringWithFormat:NSLocalizedString(@"measurement.in.format", nil), (long)inches];
    self.heightLabel.text = [NSString stringWithFormat:@"%@ %@", feetFormat, inchFormat];
}

#pragma mark - Actions

- (IBAction)done:(id)sender {
    if ([self delegate]) {
        SENAccount* tempAccount = [SENAccount new];
        [tempAccount setHeight:@([self selectedHeightInCm])];
        [[self delegate] update:tempAccount];
    } else {
        SENAccount* account = [[HEMOnboardingService sharedService] currentAccount];
        [account setHeight:@([self selectedHeightInCm])];
        
        [self next];
    }
}

- (IBAction)skip:(id)sender {
    if ([self delegate]) {
        [[self delegate] cancel];
    } else {
        [self next];
    }
}

- (void)next {
    [self performSegueWithIdentifier:[HEMOnboardingStoryboard weightSegueIdentifier]
                              sender:self];
}

@end
