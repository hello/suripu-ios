#import <SenseKit/SenseKit.h>
#import "HEMSleepSummaryPagingDataSource.h"
#import "HEMMainStoryboard.h"
#import "HEMSleepGraphViewController.h"
#import "NSDate+HEMRelative.h"
#import "HEMOnboardingService.h"

@interface HEMSleepSummaryPagingDataSource ()
@property (nonatomic, strong) NSCalendar* calendar;
@end

@implementation HEMSleepSummaryPagingDataSource

- (instancetype)init {
    if (self = [super init]) {
        _calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    }
    return self;
}

#pragma mark - UIPageViewControllerDataSource

- (UIViewController*)controllerAfter:(UIViewController*)viewController {
    HEMSleepGraphViewController* sleepVC = (HEMSleepGraphViewController*)viewController;
    NSDate* nextDay = [[sleepVC dateForNightOfSleep] nextDay];
    NSDate* now = [NSDate date];
    if ([nextDay isOnSameDay:now]
        || [nextDay compare:now] == NSOrderedDescending
        || [nextDay shouldCountAsPreviousDay]) {
        return nil; // no data to show in the future
    }
    return [self sleepSummaryControllerWithDate:nextDay];
}

- (UIViewController*)controllerBefore:(UIViewController*)viewController {
    NSDate* currentDate = [(HEMSleepGraphViewController*)viewController dateForNightOfSleep];
    NSDate* createdAt = [[[SENServiceAccount sharedService] account] createdAt];
    if (!createdAt) {
       createdAt = [[[HEMOnboardingService sharedService] currentAccount] createdAt];
    }
    NSDate* previousDay = [currentDate previousDay];
    if (!createdAt || [createdAt compare:previousDay] == NSOrderedAscending)
        return [self sleepSummaryControllerWithDate:previousDay];
    return nil;
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
