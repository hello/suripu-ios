
#import <SenseKit/SENAccount.h>
#import <iCarousel/iCarousel.h>

#import "UIFont+HEMStyle.h"

#import "HEMWeightPickerViewController.h"
#import "HEMOnboardingCache.h"
#import "HelloStyleKit.h"
#import "HEMBaseController+Protected.h"
#import "HEMActionButton.h"
#import "HEMOnboardingStoryboard.h"
#import "HEMMathUtil.h"
#import "HEMOnboardingUtils.h"

NSInteger const HEMWeightPickerMaxWeight = 900;

static CGFloat const HEMWeightDefaultFemale = 110.0f;
static CGFloat const HEMWeightDefaultMale = 175.0f;

@interface HEMWeightPickerViewController () <iCarouselDataSource, iCarouselDelegate>

@property (weak,   nonatomic) IBOutlet iCarousel* carousel;
@property (weak,   nonatomic) IBOutlet UILabel* topWeightLabel;
@property (weak,   nonatomic) IBOutlet UILabel* botWeightLabel;
@property (weak,   nonatomic) IBOutlet HEMActionButton *doneButton;
@property (weak,   nonatomic) IBOutlet UIButton *skipButton;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *carouselHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lineHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *carouselCenterYConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lineToCarouselTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lbsToLineTopConstraint;

@property (assign, nonatomic) CGFloat weightInKgs;

@end

@implementation HEMWeightPickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[[self skipButton] titleLabel] setFont:[UIFont secondaryButtonFont]];
    [[self descriptionLabel] setAttributedText:[HEMOnboardingUtils demographicReason]];
    [self setupCarousel];
    
    if ([self delegate] == nil) {
        [self enableBackButton:NO];
        [SENAnalytics track:kHEMAnalyticsEventOnBWeight];
    }
}

- (void)setupCarousel {
    [[self carousel] setType:iCarouselTypeWheel];
    [[self carousel] setDataSource:self];
    [[self carousel] setDelegate:self];
    [[self carousel] setScrollToItemBoundary:NO];
    [[self carousel] setClipsToBounds:YES];
    
    SENAccountGender gender = [[[HEMOnboardingCache sharedCache] account] gender];
    CGFloat genderWeight = gender == SENAccountGenderFemale ? HEMWeightDefaultFemale : HEMWeightDefaultMale;
    CGFloat initialWeight = [self defaultWeightLbs] >0 ? [self defaultWeightLbs] : genderWeight;
    [[self carousel] scrollToOffset:initialWeight / 10.0f duration:0.0f];
    
    if ([self delegate] != nil) {
        NSString* done = NSLocalizedString(@"status.success", nil);
        NSString* cancel = NSLocalizedString(@"actions.cancel", nil);
        [[self doneButton] setTitle:done forState:UIControlStateNormal];
        [[self skipButton] setTitle:cancel forState:UIControlStateNormal];
    }
}

- (void)adjustConstraintsForIPhone4 {
    CGFloat carouselCenterYDiff = 15.0f;
    [self updateConstraint:[self carouselCenterYConstraint] withDiff:carouselCenterYDiff];
    [self updateConstraint:[self lineToCarouselTopConstraint] withDiff:carouselCenterYDiff];
    [self updateConstraint:[self lbsToLineTopConstraint] withDiff:carouselCenterYDiff];
    
    [self updateConstraint:[self carouselHeightConstraint] withDiff:-60];
    [self updateConstraint:[self lineHeightConstraint] withDiff:-30.0f];
}

#pragma mark - iCarousel

- (NSUInteger)numberOfItemsInCarousel:(iCarousel*)carousel {
    return HEMWeightPickerMaxWeight / 10;
}
- (UIView *)carousel:(__unused iCarousel *)carousel
  viewForItemAtIndex:(NSUInteger)index
         reusingView:(UIView *)view {
    
    UILabel* weightLabel = nil;
    
    if (view == nil) {
        CGRect labelFrame = {0.0f, 0.0f, 50.0f, 60.0f};
        weightLabel = [[UILabel alloc] initWithFrame:labelFrame];
        [weightLabel setBackgroundColor:[[self view] backgroundColor]];
        [weightLabel setTextAlignment:NSTextAlignmentCenter];
        [weightLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:18.0f]];
        [weightLabel setTextColor:[HelloStyleKit senseBlueColor]];
        [weightLabel setClipsToBounds:NO];
    } else {
        weightLabel = (UILabel*)view;
    }

    [weightLabel setText:[NSString stringWithFormat:@"%ld", (long)index*10]];

    return weightLabel;
    
}

- (CGFloat)carousel:(iCarousel *)carousel
     valueForOption:(iCarouselOption)option
        withDefault:(CGFloat)value {
    switch (option) {
        case iCarouselOptionVisibleItems:
            return 4;
        case iCarouselOptionRadius:
            return value * 0.5f; // take half the radius to move items closer
        case iCarouselOptionArc:
            return M_PI; // half a circle
        case iCarouselOptionAngle:
            return ((45.0f) / 180.0 * M_PI); // 45degs approximately between items
        default:
            return value;
    }
}

- (void)carouselDidScroll:(iCarousel *)carousel {
    CGFloat lbs = roundf([carousel scrollOffset] * 10);
    CGFloat kgs = HEMToKilograms(@(lbs));
    
    NSString* lbsText =
        [NSString stringWithFormat:NSLocalizedString(@"measurement.lb.format", nil), (long)lbs];
    [[self topWeightLabel] setText:lbsText];

    NSString* kgsText =
        [NSString stringWithFormat:NSLocalizedString(@"measurement.kg.format", nil), (long)kgs];
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

#pragma mark - Cleanup

- (void)dealloc {
    [[self carousel] setDelegate:nil];
    [[self carousel] setDataSource:nil];
}


@end
