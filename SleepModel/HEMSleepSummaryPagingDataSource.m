
#import "HEMSleepSummaryPagingDataSource.h"
#import "HEMMainStoryboard.h"
#import "HEMSleepSummaryViewController.h"

@implementation HEMSleepSummaryPagingDataSource

#pragma mark - UIPageViewControllerDataSource

- (UIViewController*)pageViewController:(UIPageViewController*)pageViewController
      viewControllerAfterViewController:(UIViewController*)viewController
{
    return [self sleepSummaryControllerWithTimeIntervalOffset:60 * 60 * 24 fromReferenceDate:[(HEMSleepSummaryViewController*)viewController dateForNightOfSleep]];
}

- (UIViewController*)pageViewController:(UIPageViewController*)pageViewController
     viewControllerBeforeViewController:(UIViewController*)viewController
{
    return [self sleepSummaryControllerWithTimeIntervalOffset:-60 * 60 * 24 fromReferenceDate:[(HEMSleepSummaryViewController*)viewController dateForNightOfSleep]];
}

- (UIViewController*)sleepSummaryControllerWithTimeIntervalOffset:(NSTimeInterval)offset fromReferenceDate:(NSDate*)date
{
    HEMSleepSummaryViewController* controller = (HEMSleepSummaryViewController*)[HEMMainStoryboard instantiateLastNightController];
    NSDate* nextViewControllerDate = [NSDate dateWithTimeInterval:offset sinceDate:date];
    [controller setDateForNightOfSleep:nextViewControllerDate];
    return controller;
}

@end
