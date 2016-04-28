#import <Bugsnag/Bugsnag.h>

#import <SenseKit/SenseKit.h>

#import "HEMAppDelegate.h"
#import "HEMStyle.h"
#import "HEMRootViewController.h"
#import "HEMNotificationHandler.h"
#import "HEMSleepQuestionsViewController.h"
#import "HEMCurrentConditionsViewController.h"
#import "HEMAlarmListViewController.h"
#import "HEMStyledNavigationViewController.h"
#import "HEMLogUtils.h"
#import "HEMOnboardingStoryboard.h"
#import "HEMSnazzBarController.h"
#import "HEMAudioCache.h"
#import "HEMStyledNavigationViewController.h"
#import "HEMAuthenticationViewController.h"
#import "HEMConfig.h"
#import "HEMMainStoryboard.h"
#import "HEMSegmentProvider.h"
#import "HEMDebugController.h"
#import "HEMAccountService.h"
#import "HEMHealthKitService.h"
#import "HEMShortcutService.h"

typedef NS_ENUM(NSInteger, HEMAppDelegateError) {
    HEMAppDelegateErrorInvalidState = -1
};

@implementation HEMAppDelegate

static NSString* const HEMAppFirstLaunch = @"HEMAppFirstLaunch";
static NSString* const HEMApiXVersionHeader = @"X-Client-Version";

static NSString* const HEMShortcutTypeAddAlarm = @"is.hello.sense.shortcut.addalarm";
static NSString* const HEMShortcutTypeEditAlarms = @"is.hello.sense.shortcut.editalarms";

static NSString* const HEMAppErrorDomain = @"is.hello.app";

- (BOOL)application:(UIApplication*)application didFinishLaunchingWithOptions:(NSDictionary*)launchOptions {
    // order matters
    [self configureAPI];
    [self configureCrashReport];
    
    [HEMDebugController disableDebugMenuIfNeeded];
    [HEMLogUtils enableLogger];
    [SENAnalytics enableAnalytics];

    if (launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey]) {
        [HEMNotificationHandler handleRemoteNotificationWithInfo:launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey]
                                          fetchCompletionHandler:NULL];
    }

    [self deauthorizeIfNeeded];
    [self configureAppearance];
    [self registerForNotifications];
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

- (void)application:(UIApplication *)application performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem completionHandler:(void (^)(BOOL))completionHandler {
    NSString *shortcutType = shortcutItem.type;
    DDLogDebug(@"incoming shortcut %@", shortcutType);
    completionHandler([[HEMShortcutService sharedService] canHandle3DTouchType:shortcutType]);
}

- (void)openDetailViewForSensorNamed:(NSString*)name {
    if (![SENAuthorizationService isAuthorized] || [self deauthorizeIfNeeded])
        return;

    HEMRootViewController* root = (id)self.window.rootViewController;
    [root showSettingsDrawerTabAtIndex:HEMRootDrawerTabConditions animated:NO];
    HEMSnazzBarController* controller = (id)root.backController;
    UIViewController* visibleController = (id)[controller selectedViewController];

    void (^presentController)() = ^{
        UIViewController* topController = visibleController;
        if ([topController isKindOfClass:[UINavigationController class]]) {
            UINavigationController* nav = (id)topController;
            topController = nav.topViewController;
        }
        if ([topController isKindOfClass:[HEMCurrentConditionsViewController class]]) {
            HEMCurrentConditionsViewController* currentConditionsVC = (id)topController;
            [currentConditionsVC openDetailViewForSensorNamed:name];
        } else {
            NSString* clazz = NSStringFromClass([topController class]);
            NSDictionary* info = @{NSLocalizedDescriptionKey : clazz};
            [SENAnalytics trackError:[NSError errorWithDomain:HEMAppErrorDomain
                                                         code:HEMAppDelegateErrorInvalidState
                                                     userInfo:info]
                       withEventName:kHEMAnalyticsEventWarning];
        }
    };
    if (visibleController.presentedViewController) {
        [visibleController dismissViewControllerAnimated:NO completion:presentController];
    } else {
        presentController();
    }
}

- (void)applicationDidBecomeActive:(UIApplication*)application {
    [HEMNotificationHandler clearNotifications];
    [self deauthorizeIfNeeded];
    [self syncData];
}

- (void)syncData {
    BOOL finishedOnboarding = [[HEMOnboardingService sharedService] hasFinishedOnboarding];
    BOOL signedIn = [SENAuthorizationService isAuthorized];
    
    if (signedIn && finishedOnboarding) {
        // pre fetch account information so that it's readily availble to the user
        // when the account is accessed.  This is per discussion with design and James
        HEMAccountService* acctService = [HEMAccountService sharedService];
        [acctService refresh:^(SENAccount * _Nonnull account, NSDictionary<NSNumber *,SENPreference *> * _Nonnull preferences) {
            [SENAnalytics trackUserSession:account];
        }];
        // write timeline data in to Health app, if enabled and data is available
        [self syncHealthKit];
    }
}

/**
 * Sync sleep data to the Health app if available.  If data has already been written
 * for the day, this will have no effect.
 */
- (void)syncHealthKit {
    [[HEMHealthKitService sharedService] sync:^(NSError *error) {
        if (error != nil) {
            switch ([error code]) {
                case HEMHKServiceErrorAlreadySynced:
                    DDLogVerbose(@"healthkit has already been synced, ignore");
                    break; // do nothing
                case HEMHKServiceErrorNotAuthorized: {
                    NSDictionary* props = @{kHEMAnalyticsEventPropHealthKit : kHEManaltyicsEventStatusDenied};
                    [SENAnalytics setUserProperties:props];
                    break;
                }
                case HEMHKServiceErrorNotSupported: {
                    NSDictionary* props = @{kHEMAnalyticsEventPropHealthKit : kHEManaltyicsEventStatusNotSupported};
                    [SENAnalytics setUserProperties:props];
                    break;
                }
                case HEMHKServiceErrorNotEnabled: {
                    NSDictionary* props = @{kHEMAnalyticsEventPropHealthKit : kHEManaltyicsEventStatusDisabled};
                    [SENAnalytics setUserProperties:props];
                    break;
                }
                case HEMHKServiceErrorNoDataToWrite:
                default:
                    [SENAnalytics trackError:error withEventName:kHEMAnalyticsEventWarning];
                    break;
            }
        } else {
            [SENAnalytics track:HEMAnalyticsEventHealthSync];
            [SENAnalytics setUserProperties:@{kHEMAnalyticsEventPropHealthKit : kHEManaltyicsEventStatusEnabled}];
        }
    }];
}

- (void)configureAPI {
    NSString* path = [HEMConfig stringForConfig:HEMConfAPIURL];
    NSString* clientID = [HEMConfig stringForConfig:HEMConfClientId];
    NSString *version = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
    [SENAPIClient setBaseURLFromPath:path];
    [SENAPIClient setValue:version forHTTPHeaderField:HEMApiXVersionHeader];
    [SENAuthorizationService setClientAppID:clientID];
    [SENAuthorizationService authorizeRequestsFromKeychain];
}

- (void)configureCrashReport {
    NSString* token = [HEMConfig stringForConfig:HEMConfCrashReportToken];
    if (token) {
        [Bugsnag startBugsnagWithApiKey:token];

        BugsnagConfiguration* bugsnagConfig = [Bugsnag configuration];
        
        NSString* accountId = [SENAuthorizationService accountIdOfAuthorizedUser];
        if (accountId) {
            [bugsnagConfig setUser:accountId withName:nil andEmail:nil];
        }
        
        NSString* env = [HEMConfig stringForConfig:HEMConfEnvironmentName];
        if (env) {
            [bugsnagConfig setReleaseStage:env];
        }
        
    }
}

- (BOOL)deauthorizeIfNeeded {
    SENLocalPreferences* preferences = [SENLocalPreferences sharedPreferences];
    if (![preferences persistentPreferenceForKey:HEMAppFirstLaunch]) {
        [SENAuthorizationService deauthorize];
        [preferences setPersistentPreference:HEMAppFirstLaunch forKey:HEMAppFirstLaunch];
        return YES;
    }
    return NO;
}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken {
    [SENAPINotification registerForRemoteNotificationsWithTokenData:deviceToken completion:NULL];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    [HEMNotificationHandler handleRemoteNotificationWithInfo:userInfo fetchCompletionHandler:completionHandler];
}

- (void)application:(UIApplication*)application handleActionWithIdentifier:(NSString*)identifier forRemoteNotification:(NSDictionary*)userInfo completionHandler:(void (^)())completionHandler {
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

- (void)configureAppearance {
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
        NSForegroundColorAttributeName : [UIColor tintColor]
    } forState:UIControlStateNormal];
}

- (void)createAndShowWindow {
    UIWindow* window = [UIWindow new];
    if (CGSizeEqualToSize(window.bounds.size, CGSizeZero))
        window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window = window;
    [self.window makeKeyWindow];
    self.window.rootViewController = [HEMMainStoryboard instantiateRootViewController];
    [self.window makeKeyAndVisible];
}

- (void)registerForNotifications {
    [HEMNotificationHandler registerForRemoteNotificationsIfEnabled];
    NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
    [center addObserver:self
               selector:@selector(reset)
                   name:SENAuthorizationServiceDidDeauthorizeNotification
                 object:nil];
}

- (void)reset {
    SENClearModel();
    [HEMAudioCache clearCache];
    [SENAnalytics reset:nil];
    [[SENLocalPreferences sharedPreferences] removeSessionPreferences];
    [[HEMOnboardingService sharedService] resetOnboardingCheckpoint];
    [[SENServiceDevice sharedService] reset];
}

@end
