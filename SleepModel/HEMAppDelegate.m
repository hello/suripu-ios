#import <SenseKit/SenseKit.h>
#import <Crashlytics/Crashlytics.h>

#import "HEMAppDelegate.h"
#import "HEMRootViewController.h"
#import "HEMNotificationHandler.h"
#import "HEMSleepQuestionsViewController.h"
#import "HEMCurrentConditionsViewController.h"
#import "HEMStyledNavigationViewController.h"
#import "HelloStyleKit.h"
#import "HEMLogUtils.h"
#import "HEMOnboardingUtils.h"
#import "HEMOnboardingStoryboard.h"
#import "HEMSnazzBarController.h"
#import "HEMAudioCache.h"
#import "UIFont+HEMStyle.h"
#import "HEMStyledNavigationViewController.h"

@implementation HEMAppDelegate

static NSString* const HEMAppAPIProdPath = @"https://api.hello.is/v1";
static NSString* const HEMAppAPIProdClientID = @"cbaf8aaf-609a-46f8-98d9-292d5376a6b7";
static NSString* const HEMAppAPIDevPath  = @"https://dev-api.hello.is/v1";
static NSString* const HEMAppAPIDevClientID = @"iphone_pill";
static NSString* const HEMAppForceLogout = @"HEMAppForceLogout";
static NSString* const HEMAppFirstLaunch = @"HEMAppFirstLaunch";

- (BOOL)application:(UIApplication*)application didFinishLaunchingWithOptions:(NSDictionary*)launchOptions
{
#if !BETA
    [application setApplicationSupportsShakeToEdit:NO];
#endif

    [self configureAPI];
    [HEMLogUtils enableLogger];

    if (launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey])
        [HEMNotificationHandler handleRemoteNotificationWithInfo:launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey]
                                          fetchCompletionHandler:NULL];

    [self deauthorizeIfNeeded];
    [self configureAnalytics];
    [self configureAppearance];
    [self registerForNotifications];
    [self syncData];
    [self createAndShowWindow];
    
    return YES;
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    NSURLComponents* components = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:NO];
    for (NSURLQueryItem* item in components.queryItems) {
        if ([item.name isEqualToString:@"sensor"]) {
            [self openDetailViewForSensorNamed:item.value];
            break;
        }
    }
    return YES;
}

- (void)openDetailViewForSensorNamed:(NSString*)name
{
    if (![SENAuthorizationService isAuthorized] || [self deauthorizeIfNeeded])
        return;

    HEMRootViewController* root = (id)self.window.rootViewController;
    [root showSettingsDrawerTabAtIndex:HEMRootDrawerTabConditions animated:NO];
    HEMSnazzBarController* controller = (id)root.backController;
    UINavigationController* nav = (id)[controller selectedViewController];

    void (^presentController)() = ^{
        [nav popToRootViewControllerAnimated:NO];
        HEMCurrentConditionsViewController* controller = (id)nav.topViewController;
        [controller openDetailViewForSensorNamed:name];
    };
    if (nav.presentedViewController) {
        [nav dismissViewControllerAnimated:NO completion:presentController];
    } else {
        presentController();
    }
}

- (void)applicationDidBecomeActive:(UIApplication*)application
{
    [HEMNotificationHandler clearNotifications];
    if (![self deauthorizeIfNeeded]) {
        [self resume:NO];
    }
}

- (void)syncData {
    if ([SENAuthorizationService isAuthorized]) {
        [[SENServiceAccount sharedService] refreshAccount:^(NSError *error) {
            [HEMAnalytics trackUserSession]; // update user session data
        }];
    }
}

- (void)configureAPI {
    NSString* path = nil;
    NSString* clientID = nil;
#if DEBUG
    path = HEMAppAPIDevPath;
    clientID = HEMAppAPIDevClientID;
#else
    path = HEMAppAPIProdPath;
    clientID = HEMAppAPIProdClientID;
#endif
    [SENAPIClient setBaseURLFromPath:path];
    [SENAuthorizationService setClientAppID:clientID];
}

- (void)configureAnalytics {
    NSString* analyticsToken = nil;
#if !DEBUG
    NSString* accountId = [SENAuthorizationService accountIdOfAuthorizedUser];
    [Crashlytics startWithAPIKey:@"f464ccd280d3e5730dcdaa9b64d1d108694ee9a9"];
    if (accountId != nil) [Crashlytics setUserIdentifier:accountId];
    analyticsToken = @"43c61cc553f0ccf2b3e1f73bc30bbfb4";
#else
    analyticsToken = @"d62a169fe4856dea26f3a322750613a8";
#endif
    [SENAuthorizationService authorizeRequestsFromKeychain];
    [SENAnalytics configure:SENAnalyticsProviderNameLogger with:nil];
    [SENAnalytics configure:SENAnalyticsProviderNameMixpanel
                       with:@{kSENAnalyticsProviderToken : analyticsToken}];
    [HEMAnalytics trackUserSession];
}

- (BOOL)deauthorizeIfNeeded {
    SENLocalPreferences* preferences = [SENLocalPreferences sharedPreferences];
    if ([[preferences persistentPreferenceForKey:HEMAppForceLogout] boolValue]) {
        [SENAuthorizationService deauthorize];
        [preferences setPersistentPreference:nil forKey:HEMAppForceLogout];
        return YES;
    } else if (![preferences persistentPreferenceForKey:HEMAppFirstLaunch]) {
        [SENAuthorizationService deauthorize];
        [preferences setPersistentPreference:HEMAppFirstLaunch forKey:HEMAppFirstLaunch];
        return YES;
    }
    return NO;
}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
    [SENAPINotification registerForRemoteNotificationsWithTokenData:deviceToken completion:NULL];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    [HEMNotificationHandler handleRemoteNotificationWithInfo:userInfo fetchCompletionHandler:completionHandler];
}

- (void)application:(UIApplication*)application handleActionWithIdentifier:(NSString*)identifier forRemoteNotification:(NSDictionary*)userInfo completionHandler:(void (^)())completionHandler
{
    // FIXME (jimmy): does the server even support this?  I don't see anything
    // on the server side ...
    NSNumber* qId = userInfo[@"qid"];
    NSNumber* aQId = userInfo[@"aqid"];
    SENQuestion* question = [[SENQuestion alloc] initWithId:qId
                                          questionAccountId:aQId
                                                   question:nil
                                                       type:SENQuestionTypeChoice
                                                    choices:nil];
    SENAnswer* answer = [[SENAnswer alloc] initWithId:nil answer:identifier questionId:qId];
    [SENAPIQuestions sendAnswer:answer forQuestion:question completion:^(id data, NSError* error) {
                                                      // something something
                                                  }];
}

- (void)resetAndShowOnboarding
{
    SENClearModel();
    [HEMAudioCache clearCache];
    [[SENLocalPreferences sharedPreferences] removeSessionPreferences];
    [HEMOnboardingUtils resetOnboardingCheckpoint];
    [self resume:YES];
}

- (void)configureAppearance
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:NO];
    UINavigationBar* appearance = [UINavigationBar appearanceWhenContainedIn:[HEMStyledNavigationViewController class], nil];
    [appearance setBackgroundImage:[[UIImage alloc] init]
                    forBarPosition:UIBarPositionAny
                        barMetrics:UIBarMetricsDefault];
    [appearance setShadowImage:[[UIImage alloc] init]];
    [appearance setTitleTextAttributes:@{
        NSForegroundColorAttributeName : [UIColor blackColor],
        NSFontAttributeName : [UIFont settingsTitleFont]
    }];
    [[UIBarButtonItem appearance] setTitleTextAttributes:@{
        NSFontAttributeName : [UIFont navButtonTitleFont],
        NSForegroundColorAttributeName : [HelloStyleKit tintColor]
    } forState:UIControlStateNormal];
}

- (void)createAndShowWindow
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = [HEMRootViewController new];
    [self.window makeKeyAndVisible];
}

- (void)registerForNotifications
{
    [HEMNotificationHandler registerForRemoteNotificationsIfEnabled];
    NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
    
    [center addObserver:self
               selector:@selector(resetAndShowOnboarding)
                   name:SENAuthorizationServiceDidDeauthorizeNotification
                 object:nil];
}

- (void)openSettingsDrawer {
    HEMRootViewController* controller = (id)self.window.rootViewController;
    [controller openSettingsDrawer];
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
    [self openSettingsDrawer];
}

#pragma mark - Resume Where Last Off

- (void)resume:(BOOL)animated
{
    UIViewController* dynamicPanesController = (UIViewController*)self.window.rootViewController;
    if ([dynamicPanesController presentedViewController] != nil) return;
    
    BOOL authorized = [SENAuthorizationService isAuthorized];
    HEMOnboardingCheckpoint checkpoint = [HEMOnboardingUtils onboardingCheckpoint];
    UIViewController* onboardingController = [HEMOnboardingUtils onboardingControllerForCheckpoint:checkpoint authorized:authorized];
    
    if (onboardingController != nil) {
        UINavigationController* onboardingNav
            = [[HEMStyledNavigationViewController alloc] initWithRootViewController:onboardingController];
        [[onboardingNav navigationBar] setTintColor:[HelloStyleKit senseBlueColor]];
        
        if (checkpoint == HEMOnboardingCheckpointStart) {
            [self listenForAccountCreationNotification];
        } else {
            [self openSettingsDrawer];
        }
        
        [dynamicPanesController presentViewController:onboardingNav
                                             animated:animated
                                           completion:^{
                                               HEMRootViewController* root = (id)self.window.rootViewController;
                                               [root showStatusBar];
                                           }];
    } // let it just start the application up normally
}

@end
