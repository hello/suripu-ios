#import <SenseKit/SENAuthorizationService.h>
#import <SenseKit/SENAlarm.h>
#import <SenseKit/SENSensor.h>
#import <FCDynamicPanesNavigationController/FCDynamicPanesNavigationController.h>

#import "HEMAppDelegate.h"
#import "HEMMainStoryboard.h"
#import "HEMSleepSummarySlideViewController.h"
#import "HEMSleepGraphCollectionViewController.h"

@interface HEMAppDelegate ()

@end

@implementation HEMAppDelegate

- (BOOL)application:(UIApplication*)application didFinishLaunchingWithOptions:(NSDictionary*)launchOptions
{
    [self configureAppearance];
    [self registerForNotifications];
    [self createAndShowWindow];
    return YES;
}

- (void)applicationDidBecomeActive:(UIApplication*)application
{
    if (![SENAuthorizationService isAuthorized]) {
        [self showOnboardingFlowAnimated:NO];
    }
}

- (void)resetAndShowOnboarding
{
    [SENAlarm clearSavedAlarms];
    [SENSensor clearCachedSensors];
    [self showOnboardingFlowAnimated:YES];
}

- (void)showOnboardingFlowAnimated:(BOOL)animated
{
    FCDynamicPanesNavigationController* dynamicPanesController = (FCDynamicPanesNavigationController*)self.window.rootViewController;
    UINavigationController* navController = (UINavigationController*)((FCDynamicPane*)[dynamicPanesController.viewControllers firstObject]).viewController;
    [navController popToRootViewControllerAnimated:NO];
    [dynamicPanesController popViewControllerAnimated:animated];
    
    UIStoryboard* onboardingStoryboard = [UIStoryboard storyboardWithName:@"Onboarding" bundle:[NSBundle mainBundle]];
    UIViewController* rootController = [onboardingStoryboard instantiateInitialViewController];
    [dynamicPanesController presentViewController:rootController animated:animated completion:NULL];
}

- (void)configureAppearance
{
    [[UINavigationBar appearance] setBackgroundImage:[[UIImage alloc] init]
                                      forBarPosition:UIBarPositionAny
                                          barMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setShadowImage:[[UIImage alloc] init]];
}

- (void)createAndShowWindow
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    NSArray* viewControllers = @[
        [HEMMainStoryboard instantiateCurrentNavController],
        [[HEMSleepSummarySlideViewController alloc] init]
    ];

    FCDynamicPanesNavigationController* dynamicPanes = [[FCDynamicPanesNavigationController alloc] initWithViewControllers:viewControllers];
    self.window.rootViewController = dynamicPanes;
    [self.window makeKeyAndVisible];
}

- (void)registerForNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetAndShowOnboarding) name:SENAuthorizationServiceDidDeauthorizeNotification object:nil];
}

@end
