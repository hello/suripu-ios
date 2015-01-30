
#import "HEMSleepSummaryPagingDataSource.h"
#import "HEMMainStoryboard.h"
#import "HEMSleepGraphViewController.h"
#import "NSDate+HEMRelative.h"

@implementation HEMSleepSummaryPagingDataSource

#pragma mark - UIPageViewControllerDataSource

- (UIViewController*)controllerAfter:(UIViewController*)viewController {
    HEMSleepGraphViewController* sleepVC = (HEMSleepGraphViewController*)viewController;
    NSDate* nextDay = [[sleepVC dateForNightOfSleep] nextDay];
    if ([nextDay isOnSameDay:[NSDate date]] || [nextDay compare:[NSDate date]] == NSOrderedDescending) {
        return nil; // no data to show in the future
    }
    return [self sleepSummaryControllerWithDate:nextDay];
}

- (UIViewController*)controllerBefore:(UIViewController*)viewController {
    NSDate* currentDate = [(HEMSleepGraphViewController*)viewController dateForNightOfSleep];
    return [self sleepSummaryControllerWithDate:[currentDate previousDay]];
} 

#pragma mark - UIPageViewController

- (UIViewController*)pageViewController:(UIPageViewController*)pageViewController
      viewControllerAfterViewController:(UIViewController*)viewController {
    return [self controllerAfter:viewController];
}

- (UIViewController*)pageViewController:(UIPageViewController*)pageViewController
     viewControllerBeforeViewController:(UIViewController*)viewController {
    return [self controllerBefore:viewController];
}

- (UIViewController*)sleepSummaryControllerWithDate:(NSDate*)date
{
    HEMSleepGraphViewController* controller = (id)[HEMMainStoryboard instantiateSleepGraphController];
    [controller setDateForNightOfSleep:date];
    return controller;
}

@end
