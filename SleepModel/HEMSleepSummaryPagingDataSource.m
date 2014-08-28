
#import "HEMSleepSummaryPagingDataSource.h"
#import "HEMMainStoryboard.h"
#import "HEMSleepGraphCollectionViewController.h"

@implementation HEMSleepSummaryPagingDataSource

#pragma mark - UIPageViewControllerDataSource

- (UIViewController*)controllerAfter:(UIViewController*)viewController {
    HEMSleepGraphCollectionViewController* sleepVC =
        (HEMSleepGraphCollectionViewController*)viewController;
    NSDate* date = [sleepVC dateForNightOfSleep];
    NSInteger dayInterval = 60 * 60 * 24;
    NSDate* nextDay = [date dateByAddingTimeInterval:dayInterval];
    if ([nextDay compare:[NSDate date]] == NSOrderedDescending) {
        return nil; // no data to show in the future
    }
    return [self sleepSummaryControllerWithTimeIntervalOffset:dayInterval
                                            fromReferenceDate:date];
}

- (UIViewController*)controllerBefore:(UIViewController*)viewController {
        return [self sleepSummaryControllerWithTimeIntervalOffset:-60 * 60 * 24 fromReferenceDate:[(HEMSleepGraphCollectionViewController*)viewController dateForNightOfSleep]];
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

- (UIViewController*)sleepSummaryControllerWithTimeIntervalOffset:(NSTimeInterval)offset fromReferenceDate:(NSDate*)date
{
    HEMSleepGraphCollectionViewController* controller = (HEMSleepGraphCollectionViewController*)[HEMMainStoryboard instantiateSleepGraphController];
    NSDate* nextViewControllerDate = [NSDate dateWithTimeInterval:offset sinceDate:date];
    [controller setDateForNightOfSleep:nextViewControllerDate];
    return controller;
}

#pragma mark - HEMSlideViewControllerDataSource

- (UIViewController*)slideViewController:(HEMSlideViewController *)slideController
                         controllerAfter:(UIViewController *)controller {
    return [self controllerAfter:controller];
}

- (UIViewController*)slideViewController:(HEMSlideViewController *)slideController
                        controllerBefore:(UIViewController *)controller {
    return [self controllerBefore:controller];
}

@end
