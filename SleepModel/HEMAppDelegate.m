#import <SenseKit/SENAuthorizationService.h>
#import <SenseKit/SENKeyedArchiver.h>
#import <SenseKit/SENAPINotification.h>
#import <SenseKit/SENAPIQuestions.h>
#import <SenseKit/SENServiceQuestions.h>
#import <SenseKit/SENAnswer.h>
#import <SenseKit/SENSettings.h>
#import <SenseKit/SENAPIAccount.h>

#import <FCDynamicPanesNavigationController/FCDynamicPanesNavigationController.h>
#import <Crashlytics/Crashlytics.h>

#import "HEMAppDelegate.h"
#import "HEMMainStoryboard.h"
#import "HEMSleepSummarySlideViewController.h"
#import "HEMNotificationHandler.h"
#import "HEMSleepQuestionsViewController.h"
#import "HEMConfidentialityWarningView.h"
#import "HEMDeviceCenter.h"
#import "HelloStyleKit.h"

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

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    // TODO (jimmy): implement custom URL actions?  don't know any requirements yet
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
    [self listenForAccountCreationNotification];
    
    FCDynamicPanesNavigationController* dynamicPanesController = (FCDynamicPanesNavigationController*)self.window.rootViewController;
    UINavigationController* navController = (UINavigationController*)((FCDynamicPane*)[dynamicPanesController.viewControllers firstObject]).viewController;
    [navController popToRootViewControllerAnimated:NO];
    [dynamicPanesController popViewControllerAnimated:animated];

    UIStoryboard* onboardingStoryboard = [UIStoryboard storyboardWithName:@"Onboarding" bundle:[NSBundle mainBundle]];
    UIViewController* rootController = [onboardingStoryboard instantiateInitialViewController];
    if ([rootController isKindOfClass:[UINavigationController class]]) {
        UINavigationController* navVC = (UINavigationController*)rootController;
        [[navVC navigationBar] setTintColor:[HelloStyleKit onboardingBlueColor]];
    }
    [dynamicPanesController presentViewController:rootController animated:animated completion:nil];
}

- (void)configureAppearance
{
    UIFont* navbarTextFont = [UIFont fontWithName:@"Calibre-Medium" size:18.0f];
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
    NSUserDefaults* userDefaults = [[NSUserDefaults alloc] initWithSuiteName:SENSettingsAppGroup];
    NSDictionary* settingsDefaults = [SENSettings defaults];
    // combine any other default settings here for the Settings.bundle
    [userDefaults registerDefaults:settingsDefaults];
    [userDefaults synchronize];
}

#pragma mark - App Notifications

- (void)listenForAccountCreationNotification {
    NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self name:kSENAccountNotificationAccountCreated object:nil];
    [center addObserver:self
               selector:@selector(didCreateAccount:)
                   name:kSENAccountNotificationAccountCreated
                 object:nil];
}

- (void)didCreateAccount:(NSNotification*)notification {
    // when sign up is complete, show the "settings" area instead of the Timeline,
    // but only do so after sign up and not sign in, or any other scenario
    FCDynamicPanesNavigationController* dynamicPanesController
        = (FCDynamicPanesNavigationController*)self.window.rootViewController;
    FCDynamicPane* foregroundPane = [[dynamicPanesController viewControllers] lastObject];
    if (foregroundPane != nil) {
        [foregroundPane setState:FCDynamicPaneStateRetracted];
    }
    
    NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self name:kSENAccountNotificationAccountCreated object:nil];
}

@end
