#import <SenseKit/SENAuthorizationService.h>
#import <SenseKit/Model.h>
#import <SenseKit/SENAPINotification.h>
#import <SenseKit/SENAPIQuestions.h>
#import <SenseKit/SENServiceQuestions.h>
#import <SenseKit/SENAPIAccount.h>
#import <SenseKit/SENAnalytics.h>

#import <FCDynamicPanesNavigationController/FCDynamicPanesNavigationController.h>
#import <Crashlytics/Crashlytics.h>

#import "HEMAppDelegate.h"
#import "HEMRootViewController.h"
#import "HEMMainStoryboard.h"
#import "HEMSleepSummarySlideViewController.h"
#import "HEMNotificationHandler.h"
#import "HEMSleepQuestionsViewController.h"
#import "HEMConfidentialityWarningView.h"
#import "HEMCurrentConditionsTableViewController.h"
#import "HEMDeviceCenter.h"
#import "HelloStyleKit.h"
#import "HEMLogUtils.h"
#import "HEMOnboardingUtils.h"
#import "HEMOnboardingStoryboard.h"
#import "HEMAudioCache.h"
#import "HEMDeviceCenter.h"
#import "UIFont+HEMStyle.h"

@implementation HEMAppDelegate

static NSString* const HEMAppForceLogout = @"HEMAppForceLogout";
static NSString* const HEMAppFirstLaunch = @"HEMAppFirstLaunch";

- (BOOL)application:(UIApplication*)application didFinishLaunchingWithOptions:(NSDictionary*)launchOptions
{
    [HEMLogUtils enableLogger];
    [self deauthorizeIfNeeded];
    [self configureSettingsDefaults];
    [self setupAnalytics];
    [self configureAppearance];
    [self registerForNotifications];
    [self createAndShowWindow];
    [self showConfidentialityNotice];

#pragma message ("TODO - create preprocessor macro to distinguish APP_STORE from Internal")
    [application setApplicationSupportsShakeToEdit:YES];
    
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
    [self openSettingsDrawer];
    FCDynamicPanesNavigationController* dynamicPanesController = (id)self.window.rootViewController;
    FCDynamicPane* root = [[dynamicPanesController viewControllers] firstObject];
    UINavigationController* nav = (id)root.viewController;
    void (^presentController)() = ^{
        [nav popToRootViewControllerAnimated:NO];
        HEMCurrentConditionsTableViewController* controller = (id)nav.topViewController;
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
    if (![self deauthorizeIfNeeded]) {
        [self resume:NO];
    }
}

- (void)setupAnalytics {
    NSString* analyticsToken = nil;
    NSString* accountId = [SENAuthorizationService accountIdOfAuthorizedUser];
#if !DEBUG
    [Crashlytics startWithAPIKey:@"f464ccd280d3e5730dcdaa9b64d1d108694ee9a9"];
    if (accountId != nil) [Crashlytics setUserIdentifier:accountId];
    analyticsToken = @"8fea5e93a27fbac95b3c19aed0b36980";
#else
    analyticsToken = @"b353e69e990cfce15a9557287ce7fbf8";
#endif
    NSString* version = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey];
    [SENAuthorizationService authorizeRequestsFromKeychain];
    [SENAnalytics configure:SENAnalyticsProviderNameLogger with:nil];
    [SENAnalytics configure:SENAnalyticsProviderNameAmplitude
                       with:@{kSENAnalyticsProviderToken : analyticsToken}];
    [SENAnalytics setUserId:accountId
                 properties:@{kHEMAnalyticsUserPropVersionNumber : version}];
}

- (BOOL)deauthorizeIfNeeded {
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults boolForKey:HEMAppForceLogout]) {
        [SENAuthorizationService deauthorize];
        [defaults removeObjectForKey:HEMAppForceLogout];
        [defaults synchronize];
        return YES;
    } else if (![defaults stringForKey:HEMAppFirstLaunch]) {
        [SENAuthorizationService deauthorize];
        [defaults setObject:HEMAppFirstLaunch forKey:HEMAppFirstLaunch];
        [defaults synchronize];
        return YES;
    }
    return NO;
}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
    [SENAPINotification registerForRemoteNotificationsWithTokenData:deviceToken completion:NULL];
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
    [[HEMDeviceCenter sharedCenter] clearCache];
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults removePersistentDomainForName:[[NSBundle mainBundle] bundleIdentifier]];
    [defaults setObject:HEMAppFirstLaunch forKey:HEMAppFirstLaunch];
    [defaults synchronize];
    [HEMOnboardingUtils resetOnboardingCheckpoint];
    [self resume:YES];
}

- (void)showOnboardingAtSenseSetup
{
    [HEMOnboardingUtils saveOnboardingCheckpoint:HEMOnboardingCheckpointAccountDone];
    [self resume:YES];
}

- (void)configureAppearance
{
    [[UINavigationBar appearance] setBackgroundImage:[[UIImage alloc] init]
                                      forBarPosition:UIBarPositionAny
                                          barMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setShadowImage:[[UIImage alloc] init]];
    [[UINavigationBar appearance] setTitleTextAttributes:@{
        NSForegroundColorAttributeName : [UIColor whiteColor],
        NSFontAttributeName : [UIFont settingsTitleFont]
    }];
    [[UIBarButtonItem appearance] setTitleTextAttributes:@{
        NSFontAttributeName : [UIFont navButtonTitleFont],
        NSForegroundColorAttributeName : [HelloStyleKit senseBlueColor]
    } forState:UIControlStateNormal];
}

- (void)createAndShowWindow
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    NSArray* viewControllers = @[
        [HEMMainStoryboard instantiateCurrentNavController],
        [[HEMSleepSummarySlideViewController alloc] init]
    ];

    FCDynamicPanesNavigationController* dynamicPanes = [[HEMRootViewController alloc] initWithViewControllers:viewControllers hintOnLoad:YES];
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
    [[[[UIApplication sharedApplication] delegate] window] setWindowLevel:UIWindowLevelStatusBar+1];
    [self.window addSubview:[HEMConfidentialityWarningView viewInNewWindow]];
}

- (void)configureSettingsDefaults
{
    NSUserDefaults* userDefaults = [[NSUserDefaults alloc] initWithSuiteName:SENSettingsAppGroup];
    NSDictionary* settingsDefaults = [SENSettings defaults];
    // combine any other default settings here for the Settings.bundle
    [userDefaults registerDefaults:settingsDefaults];
    [userDefaults synchronize];
}

- (void)openSettingsDrawer {
    FCDynamicPanesNavigationController* dynamicPanesController
    = (FCDynamicPanesNavigationController*)self.window.rootViewController;
    FCDynamicPane* foregroundPane = [[dynamicPanesController viewControllers] lastObject];
    if (foregroundPane != nil) {
        [foregroundPane setState:FCDynamicPaneStateRetracted];
    }
}

- (void)closeSettingsDrawer {
    FCDynamicPanesNavigationController* dynamicPanesController
    = (FCDynamicPanesNavigationController*)self.window.rootViewController;
    FCDynamicPane* foregroundPane = [[dynamicPanesController viewControllers] lastObject];
    if (foregroundPane != nil) {
        [foregroundPane setState:FCDynamicPaneStateActive];
    }
}

- (void)toggleSettingsDrawer {
    FCDynamicPanesNavigationController* dynamicPanesController
    = (FCDynamicPanesNavigationController*)self.window.rootViewController;
    FCDynamicPane* foregroundPane = [[dynamicPanesController viewControllers] lastObject];
    if (foregroundPane != nil) {
        FCDynamicPaneState state = foregroundPane.state == FCDynamicPaneStateActive
            ? FCDynamicPaneStateRetracted
            : FCDynamicPaneStateActive;
        [foregroundPane setState:state];
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
    [self openSettingsDrawer];
}

#pragma mark - Resume Where Last Off

- (void)resume:(BOOL)animated
{
    FCDynamicPanesNavigationController* dynamicPanesController = (FCDynamicPanesNavigationController*)self.window.rootViewController;
    if ([dynamicPanesController presentedViewController] != nil) return;
    
    BOOL authorized = [SENAuthorizationService isAuthorized];
    HEMOnboardingCheckpoint checkpoint = [HEMOnboardingUtils onboardingCheckpoint];
    UIViewController* onboardingController = [HEMOnboardingUtils onboardingControllerForCheckpoint:checkpoint authorized:authorized];
    
    if (onboardingController != nil) {
        UINavigationController* navController = (UINavigationController*)((FCDynamicPane*)[dynamicPanesController.viewControllers firstObject]).viewController;
        [navController popToRootViewControllerAnimated:NO];
        [dynamicPanesController popViewControllerAnimated:animated];
        
        UINavigationController* onboardingNav = [[UINavigationController alloc] initWithRootViewController:onboardingController];
        [[onboardingNav navigationBar] setTintColor:[HelloStyleKit senseBlueColor]];
        
        if (checkpoint == HEMOnboardingCheckpointStart) {
            [self listenForAccountCreationNotification];
        } else {
            [self openSettingsDrawer];
        }
        
        [dynamicPanesController presentViewController:onboardingNav
                                             animated:animated completion:nil];
    } // let it just start the application up normally
}

@end
