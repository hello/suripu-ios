#import <SenseKit/SENAuthorizationService.h>
#import <SenseKit/SENKeyedArchiver.h>
#import <SenseKit/SENAPINotification.h>
#import <SenseKit/SENAPIQuestions.h>
#import <SenseKit/SENServiceQuestions.h>
#import <SenseKit/SENAnswer.h>
#import <SenseKit/SENSettings.h>
#import <SenseKit/SENAPIAccount.h>
#import <SenseKit/SENAnalytics.h>

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
#import "HEMLogUtils.h"
#import "HEMOnboardingUtils.h"
#import "HEMOnboardingStoryboard.h"
#import "HEMDeviceCenter.h"

@implementation HEMAppDelegate

- (BOOL)application:(UIApplication*)application didFinishLaunchingWithOptions:(NSDictionary*)launchOptions
{
    [HEMLogUtils enableLogger];
    [self configureSettingsDefaults];
    NSString* analyticsToken = nil;
#if !DEBUG
    [Crashlytics startWithAPIKey:@"f464ccd280d3e5730dcdaa9b64d1d108694ee9a9"];
    analyticsToken = @"8fea5e93a27fbac95b3c19aed0b36980";
#else
    analyticsToken = @"b353e69e990cfce15a9557287ce7fbf8";
#endif
    [SENAuthorizationService authorizeRequestsFromKeychain];
    [SENAnalytics configure:SENAnalyticsProviderNameLogger with:nil];
    [SENAnalytics configure:SENAnalyticsProviderNameAmplitude
                       with:@{kSENAnalyticsProviderToken : analyticsToken}];
    [SENAnalytics setUserId:[SENAuthorizationService accountIdOfAuthorizedUser]
                 properties:@{}];
    [self configureAppearance];
    [self registerForNotifications];
    [self createAndShowWindow];
    [self showConfidentialityNotice];
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
    [self resume:NO];
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
    [HEMOnboardingUtils resetOnboardingCheckpoint];
    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:[[NSBundle mainBundle] bundleIdentifier]];
    [self resume:YES];
}

- (void)showOnboardingAtSenseSetup
{
    [HEMOnboardingUtils saveOnboardingCheckpoint:HEMOnboardingCheckpointAccountDone];
    [self resume:YES];
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

    FCDynamicPanesNavigationController* dynamicPanes = [[FCDynamicPanesNavigationController alloc] initWithViewControllers:viewControllers hintOnLoad:YES];
    self.window.rootViewController = dynamicPanes;
    [self.window makeKeyAndVisible];
}

- (void)registerForNotifications
{
    NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
    
    [center addObserver:self
               selector:@selector(resetAndShowOnboarding)
                   name:SENAuthorizationServiceDidDeauthorizeNotification
                 object:nil];
    
    [center addObserver:self
               selector:@selector(showOnboardingAtSenseSetup)
                   name:kHEMDeviceNotificationFactorySettingsRestored
                 object:nil];
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

- (void)showAppInRetractedState {
    FCDynamicPanesNavigationController* dynamicPanesController
    = (FCDynamicPanesNavigationController*)self.window.rootViewController;
    FCDynamicPane* foregroundPane = [[dynamicPanesController viewControllers] lastObject];
    if (foregroundPane != nil) {
        [foregroundPane setState:FCDynamicPaneStateRetracted];
    }
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
    NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self name:kSENAccountNotificationAccountCreated object:nil];
    // when sign up is complete, show the "settings" area instead of the Timeline,
    // but only do so after sign up and not sign in, or any other scenario
    [self showAppInRetractedState];
}

#pragma mark - Resume Where Last Off

- (void)resume:(BOOL)animated
{
    UIViewController* onboardingController = nil;
    
    switch ([HEMOnboardingUtils onboardingCheckpoint]) {
        case HEMOnboardingCheckpointStart: {
            // hmm, this is a bit hairy.  To ensure that user is logged in even
            // after the app is deleted, or even for existing users who have already
            // signed up, we need to check that they are not authenticated before
            // actually starting from beginning.  However, this gives user a way
            // to by pass onboarding by creating the app and
            
            // TODO (jimmy:) create API to check validity of the user's account
            // and if it's not properly setup, sign out the user
            if (![SENAuthorizationService isAuthorized]) {
                onboardingController = [self startOnboardingFromBeginning];
            }
            break;
        }
        case HEMOnboardingCheckpointAccountCreated: {
            onboardingController = [self resumeAccountSetup];
            break;
        }
        case HEMOnboardingCheckpointAccountDone: {
            onboardingController = [self resumeSenseSetup];
            break;
        }
        case HEMOnboardingCheckpointSenseDone: {
            onboardingController = [self resumePillSetup];
            break;
        }
        case HEMOnboardingCheckpointPillDone:
        default: {
            break;
        }
    }

    if (onboardingController != nil) {
        FCDynamicPanesNavigationController* dynamicPanesController = (FCDynamicPanesNavigationController*)self.window.rootViewController;
        UINavigationController* navController = (UINavigationController*)((FCDynamicPane*)[dynamicPanesController.viewControllers firstObject]).viewController;
        [navController popToRootViewControllerAnimated:NO];
        [dynamicPanesController popViewControllerAnimated:animated];

        
        if ([onboardingController isKindOfClass:[UINavigationController class]]) {
            UINavigationController* navVC = (UINavigationController*)onboardingController;
            [[navVC navigationBar] setTintColor:[HelloStyleKit onboardingBlueColor]];
        }
        
        [dynamicPanesController presentViewController:onboardingController
                                             animated:animated completion:nil];
    } // let it just start the application up normally
}

- (UIViewController*)startOnboardingFromBeginning {
    UIStoryboard* onboardingStoryboard = [UIStoryboard storyboardWithName:@"Onboarding"
                                                                   bundle:[NSBundle mainBundle]];
    [self listenForAccountCreationNotification];
    return [onboardingStoryboard instantiateInitialViewController];
}

- (UIViewController*)resumeOnboardingWithController:(UIViewController*)controller {
    [self showAppInRetractedState];
    return [[UINavigationController alloc] initWithRootViewController:controller];
}

- (UIViewController*)resumeAccountSetup {
    return [self resumeOnboardingWithController:[HEMOnboardingStoryboard instantiateDobViewController]];
}

- (UIViewController*)resumeSenseSetup {
    return [self resumeOnboardingWithController:[HEMOnboardingStoryboard instantiateGetSetupViewController]];
}

- (UIViewController*)resumePillSetup {
    return [self resumeOnboardingWithController:[HEMOnboardingStoryboard instantiatePillIntroViewController]];
}

@end
