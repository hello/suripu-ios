#import <SenseKit/SENAuthorizationService.h>
#import <SenseKit/SENKeyedArchiver.h>
#import <SenseKit/SENAPINotification.h>
#import <SenseKit/SENAPIQuestions.h>
#import <SenseKit/SENServiceQuestions.h>
#import <SenseKit/SENAnswer.h>
#import <SenseKit/SENSettings.h>

#import <FCDynamicPanesNavigationController/FCDynamicPanesNavigationController.h>
#import <Crashlytics/Crashlytics.h>

#import "HEMAppDelegate.h"
#import "HEMMainStoryboard.h"
#import "HEMSleepSummarySlideViewController.h"
#import "HEMSleepGraphCollectionViewController.h"
#import "HEMNotificationHandler.h"
#import "HEMSleepQuestionsViewController.h"
#import "HEMConfidentialityWarningView.h"
#import "HEMDeviceCenter.h"

@implementation HEMAppDelegate

- (BOOL)application:(UIApplication*)application didFinishLaunchingWithOptions:(NSDictionary*)launchOptions
{
    [SENAuthorizationService authorizeRequestsFromKeychain];
    [self configureSettingsDefaults];
    [self configureAppearance];
    [self registerForNotifications];
    [self createAndShowWindow];
    [self showConfidentialityNotice];
#ifndef DEBUG
    [Crashlytics startWithAPIKey:@"f464ccd280d3e5730dcdaa9b64d1d108694ee9a9"];
#endif
    [HEMNotificationHandler registerForRemoteNotifications];
    return YES;
}

- (void)applicationDidBecomeActive:(UIApplication*)application
{
    if (![SENAuthorizationService isAuthorized]) {
        [self showOnboardingFlowAnimated:NO];
    }
}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
    [SENAPINotification registerForRemoteNotificationsWithTokenData:deviceToken completion:NULL];
}

- (void)application:(UIApplication*)application handleActionWithIdentifier:(NSString*)identifier forRemoteNotification:(NSDictionary*)userInfo completionHandler:(void (^)())completionHandler
{
    SENAnswer* answer = [[SENAnswer alloc] initWithId:nil answer:identifier questionId:userInfo[@"qid"]];
    [SENAPIQuestions sendAnswer:answer completion:^(id data, NSError* error) {
                                                      // something something
                                                  }];
}

- (void)resetAndShowOnboarding
{
    [[HEMDeviceCenter sharedCenter] clearCache];
    [SENKeyedArchiver removeAllObjects];
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
    [dynamicPanesController presentViewController:rootController animated:animated completion:^{
        FCDynamicPane* foregroundPane = [[dynamicPanesController viewControllers] lastObject];
        [foregroundPane setState:FCDynamicPaneStateRetracted];
    }];
}

- (void)configureAppearance
{
    UIFont* navbarTextFont = [UIFont fontWithName:@"Agile-Light" size:18.0f];
    [[UINavigationBar appearance] setBackgroundImage:[[UIImage alloc] init]
                                      forBarPosition:UIBarPositionAny
                                          barMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setShadowImage:[[UIImage alloc] init]];
    [[UINavigationBar appearance] setTitleTextAttributes:@{
        NSForegroundColorAttributeName : [UIColor whiteColor],
        NSFontAttributeName : navbarTextFont
    }];
    [[UIBarButtonItem appearance] setTitleTextAttributes:@{
        NSFontAttributeName : navbarTextFont
    } forState:UIControlStateNormal];
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

- (void)showConfidentialityNotice
{
    [self.window addSubview:[HEMConfidentialityWarningView viewInNewWindow]];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
}

- (void)configureSettingsDefaults
{
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary* settingsDefaults = [SENSettings defaults];
    // combine any other default settings here for the Settings.bundle
    [userDefaults registerDefaults:settingsDefaults];
    [userDefaults synchronize];
}

@end
