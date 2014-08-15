#import <FCDynamicPanesNavigationController/FCDynamicPanesNavigationController.h>

#import "HEMSleepSummaryPageViewController.h"
#import "HEMSleepSummaryViewController.h"
#import "HEMSleepSummaryPagingDataSource.h"
#import "HEMMainStoryboard.h"

@interface HEMSleepSummaryPageViewController () <FCDynamicPaneViewController>

@property (nonatomic, strong) HEMSleepSummaryPagingDataSource* sleepSummaryDataSource;
@end

@implementation HEMSleepSummaryPageViewController

- (id)init
{
    if (self = [super initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:@{}]) {
        HEMSleepSummaryViewController* controller = (HEMSleepSummaryViewController*)[HEMMainStoryboard instantiateLastNightController];
        [controller setDateForNightOfSleep:[NSDate dateWithTimeInterval:-(60 * 60 * 24)sinceDate:[NSDate date]]];
        [self setViewControllers:@[ controller ] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.sleepSummaryDataSource = [[HEMSleepSummaryPagingDataSource alloc] init];
    self.dataSource = self.sleepSummaryDataSource;
}

- (void)dealloc
{
    _sleepSummaryDataSource = nil;
}

- (void)viewDidPop
{
    self.dataSource = nil;
    for (UIViewController* viewController in self.viewControllers) {
        if ([viewController respondsToSelector:@selector(viewDidPop)]) {
            [(UIViewController<FCDynamicPaneViewController>*)viewController viewDidPop];
        }
    }
}

- (void)viewDidPush
{
    for (UIViewController* viewController in self.viewControllers) {
        if ([viewController respondsToSelector:@selector(viewDidPush)]) {
            [(UIViewController<FCDynamicPaneViewController>*)viewController viewDidPush];
        }
    }
    self.dataSource = self.sleepSummaryDataSource;
}

@end
