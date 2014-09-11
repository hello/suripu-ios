
#import "HEMSleepSummaryPagingDataSource.h"
#import "HEMMainStoryboard.h"
#import "HEMSleepGraphCollectionViewController.h"

@interface NSDate (HEMEqualityChecker)

- (BOOL)isOnSameDay:(NSDate*)otherDate;
@end

@implementation HEMSleepSummaryPagingDataSource

static CGFloat const HEMSleepSummaryDayInterval = 60 * 60 * 24;

#pragma mark - UIPageViewControllerDataSource

- (UIViewController*)controllerAfter:(UIViewController*)viewController {
    HEMSleepGraphCollectionViewController* sleepVC =
        (HEMSleepGraphCollectionViewController*)viewController;
    NSDate* date = [sleepVC dateForNightOfSleep];
    NSDate* nextDay = [date dateByAddingTimeInterval:HEMSleepSummaryDayInterval];
    if ([nextDay isOnSameDay:[NSDate date]] || [nextDay compare:[NSDate date]] == NSOrderedDescending) {
        return nil; // no data to show in the future
    }
    return [self sleepSummaryControllerWithTimeIntervalOffset:HEMSleepSummaryDayInterval
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

@implementation NSDate (HEMEqualityChecker)

+ (NSCalendar*)sharedCalendar
{
    static NSCalendar* calendar;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        calendar = [NSCalendar currentCalendar];
    });
    return calendar;
}

- (BOOL)isOnSameDay:(NSDate *)otherDate
{
    NSCalendar *calendar = [[self class] sharedCalendar];
    NSCalendarUnit flags = (NSMonthCalendarUnit| NSYearCalendarUnit | NSDayCalendarUnit);
    NSDateComponents *components = [calendar components:flags fromDate:self];
    NSDateComponents *otherComponents = [calendar components:flags fromDate:otherDate];

    return ([components day] == [otherComponents day] && [components month] == [otherComponents month] && [components year] == [otherComponents year]);
}

@end
