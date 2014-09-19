
#import <SenseKit/SENAccount.h>
#import <iCarousel/iCarousel.h>

#import "HEMWeightPickerViewController.h"
#import "HEMUserDataCache.h"
#import "HelloStyleKit.h"
#import "HEMBaseController+Protected.h"
#import "HEMActionButton.h"
#import "HEMOnboardingStoryboard.h"
#import "HEMMathUtil.h"

NSInteger const HEMWeightPickerMaxWeight = 900;

@interface HEMWeightPickerViewController () <iCarouselDataSource, iCarouselDelegate>

@property (weak,   nonatomic) IBOutlet iCarousel* carousel;
@property (weak,   nonatomic) IBOutlet UILabel* topWeightLabel;
@property (weak,   nonatomic) IBOutlet UILabel* botWeightLabel;
@property (assign, nonatomic) CGFloat weightInKgs;
@property (weak,   nonatomic) IBOutlet NSLayoutConstraint *carouselToButtonTopAlignment;
@property (weak, nonatomic) IBOutlet HEMActionButton *doneButton;

@end

@implementation HEMWeightPickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupCarousel];
}

- (void)setupCarousel {
    [[self carousel] setType:iCarouselTypeWheel];
    [[self carousel] setDataSource:self];
    [[self carousel] setDelegate:self];
    [[self carousel] setScrollToItemBoundary:NO];
    [[self carousel] setClipsToBounds:YES];
    
    if ([self defaultWeightLbs] > 0) {
        [[self carousel] scrollToOffset:[self defaultWeightLbs] / 10.0f duration:0.0f];
    }
    
    if ([self delegate] != nil) {
        NSString* title = NSLocalizedString(@"status.success", nil);
        [[self doneButton] setTitle:title forState:UIControlStateNormal];
    }
}

- (void)adjustConstraintsForIPhone4 {
    CGFloat diff = -60;
    [self updateConstraint:[self carouselToButtonTopAlignment] withDiff:diff];
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
        [weightLabel setTextColor:[HelloStyleKit mediumBlueColor]];
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
    CGFloat kgs = ToKilograms(@(lbs));
    
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
        [[[HEMUserDataCache sharedUserDataCache] account] setWeight:@(ceilf([self weightInKgs] * 1000))];
        [self performSegueWithIdentifier:[HEMOnboardingStoryboard locationSegueIdentifier] sender:self];
    }
}

#pragma mark - Cleanup

- (void)dealloc {
    [[self carousel] setDelegate:nil];
    [[self carousel] setDataSource:nil];
}


@end
