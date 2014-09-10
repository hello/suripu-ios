
#import <SenseKit/SENAccount.h>
#import <iCarousel/iCarousel.h>

#import "HEMWeightPickerViewController.h"
#import "HEMUserDataCache.h"
#import "HelloStyleKit.h"

CGFloat const HEMWeightPickerPoundsPerKilogram = 2.20462f;
CGFloat const HEMWeightPickerKilogramsPerPound = 0.453592f;
NSInteger const HEMWeightPickerMaxWeight = 900;

@interface HEMWeightPickerViewController () <iCarouselDataSource, iCarouselDelegate>

@property (weak,   nonatomic) IBOutlet iCarousel* carousel;
@property (weak,   nonatomic) IBOutlet UILabel* topWeightLabel;
@property (weak,   nonatomic) IBOutlet UILabel* botWeightLabel;
@property (assign, nonatomic) NSInteger weightInKgs;

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
    NSInteger lbs = roundf([carousel scrollOffset] * 10);
    NSInteger kgs = lbs * HEMWeightPickerKilogramsPerPound;
    
    NSString* lbsText =
        [NSString stringWithFormat:NSLocalizedString(@"measurement.lb.format", nil), lbs];
    [[self topWeightLabel] setText:lbsText];

    NSString* kgsText =
        [NSString stringWithFormat:NSLocalizedString(@"measurement.kg.format", nil), kgs];
    [[self botWeightLabel] setText:kgsText];
    
    [self setWeightInKgs:kgs];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [[[HEMUserDataCache sharedUserDataCache] account] setWeight:@([self weightInKgs])];
}

#pragma mark - Cleanup

- (void)dealloc {
    [[self carousel] setDelegate:nil];
    [[self carousel] setDataSource:nil];
}


@end
