#import <SenseKit/SenseKit.h>
#import "HEMSleepSummaryPagingDataSource.h"
#import "HEMMainStoryboard.h"
#import "HEMSleepGraphViewController.h"
#import "NSDate+HEMRelative.h"
#import "HEMOnboardingService.h"
#import "HEMAccountService.h"
#import "HEMTimelineService.h"

@interface HEMSleepSummaryPagingDataSource ()
@property (nonatomic, strong) NSCalendar* calendar;
@property (nonatomic, strong) HEMTimelineService* timelineService;
@end

@implementation HEMSleepSummaryPagingDataSource

- (instancetype)init {
    if (self = [super init]) {
        _calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        _timelineService = [HEMTimelineService new];
    }
    return self;
}

#pragma mark - UIPageViewControllerDataSource

- (UIViewController*)controllerAfter:(UIViewController*)viewController {
    HEMSleepGraphViewController* sleepVC = (id) viewController;
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
    HEMAccountService* accountService = [HEMAccountService sharedService];
    HEMOnboardingService* onboardingService = [HEMOnboardingService sharedService];
    SENAccount* account = [accountService account] ?: [onboardingService currentAccount];
    NSDate* currentDate = [(HEMSleepGraphViewController*)viewController dateForNightOfSleep];
    BOOL canView = [[self timelineService] canViewTimelinesBefore:currentDate forAccount:account];
    return !canView ? nil : [self sleepSummaryControllerWithDate:[currentDate previousDay]];
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
