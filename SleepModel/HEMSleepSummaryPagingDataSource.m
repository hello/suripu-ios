
#import "HEMSleepSummaryPagingDataSource.h"
#import "HEMMainStoryboard.h"
#import "HEMSleepGraphCollectionViewController.h"

@implementation HEMSleepSummaryPagingDataSource

#pragma mark - UIPageViewControllerDataSource

- (UIViewController*)pageViewController:(UIPageViewController*)pageViewController
      viewControllerAfterViewController:(UIViewController*)viewController
{
    return [self sleepSummaryControllerWithTimeIntervalOffset:60 * 60 * 24 fromReferenceDate:[(HEMSleepGraphCollectionViewController*)viewController dateForNightOfSleep]];
}

- (UIViewController*)pageViewController:(UIPageViewController*)pageViewController
     viewControllerBeforeViewController:(UIViewController*)viewController
{
    return [self sleepSummaryControllerWithTimeIntervalOffset:-60 * 60 * 24 fromReferenceDate:[(HEMSleepGraphCollectionViewController*)viewController dateForNightOfSleep]];
}

- (UIViewController*)sleepSummaryControllerWithTimeIntervalOffset:(NSTimeInterval)offset fromReferenceDate:(NSDate*)date
{
    HEMSleepGraphCollectionViewController* controller = (HEMSleepGraphCollectionViewController*)[HEMMainStoryboard instantiateSleepGraphController];
    NSDate* nextViewControllerDate = [NSDate dateWithTimeInterval:offset sinceDate:date];
    [controller setDateForNightOfSleep:nextViewControllerDate];
    return controller;
}

@end
