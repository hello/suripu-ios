
#import "HEMSleepSummaryPagingDataSource.h"
#import "HEMMain_iPhoneStoryboard.h"

@implementation HEMSleepSummaryPagingDataSource

#pragma mark - UIPageViewControllerDataSource

- (UIViewController*)pageViewController:(UIPageViewController*)pageViewController
      viewControllerAfterViewController:(UIViewController*)viewController
{
    return [HEMMain_iPhoneStoryboard instantiateLastNightController];
}

- (UIViewController*)pageViewController:(UIPageViewController*)pageViewController
     viewControllerBeforeViewController:(UIViewController*)viewController
{
    return [HEMMain_iPhoneStoryboard instantiateLastNightController];
}

@end
