#import <SenseKit/SENAuthorizationService.h>
#import "HEMAppDelegate.h"

@implementation HEMAppDelegate

- (BOOL)application:(UIApplication*)application didFinishLaunchingWithOptions:(NSDictionary*)launchOptions
{
    [self configureAppearance];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showOnboardingFlow) name:SENAuthorizationServiceDidDeauthorizeNotification object:nil];
    return YES;
}

- (void)applicationDidBecomeActive:(UIApplication*)application
{
    if (![SENAuthorizationService isAuthorized]) {
        [self showOnboardingFlow];
    }
}

- (void)showOnboardingFlow
{
    UINavigationController* rootNavigationController = (UINavigationController*)self.window.rootViewController;
    if (rootNavigationController.presentedViewController) {
        [rootNavigationController dismissViewControllerAnimated:NO completion:NULL];
    }
    [rootNavigationController popToRootViewControllerAnimated:NO];
    UIStoryboard* onboardingStoryboard = [UIStoryboard storyboardWithName:@"Onboarding" bundle:[NSBundle mainBundle]];
    [rootNavigationController presentViewController:[onboardingStoryboard instantiateInitialViewController] animated:YES completion:NULL];
}

- (void)configureAppearance
{
    [[UINavigationBar appearance] setBackgroundImage:[[UIImage alloc] init]
                                      forBarPosition:UIBarPositionAny
                                          barMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setShadowImage:[[UIImage alloc] init]];
}

@end
