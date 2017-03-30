#import <Bugsnag/Bugsnag.h>

#import <SenseKit/SenseKit.h>

#import "Sense-Swift.h"

#import "HEMAppDelegate.h"
#import "HEMStyle.h"
#import "HEMSleepQuestionsViewController.h"
#import "HEMAlarmListViewController.h"
#import "HEMStyledNavigationViewController.h"
#import "HEMLogUtils.h"
#import "HEMOnboardingStoryboard.h"
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
#import "HEMFacebookService.h"

#import "Sense-Swift.h"

@interface HEMAppDelegate()

@property (nonatomic, strong) PushNotificationService* pushService;
@property (nonatomic, strong) NightModeService* nightModeService;
@property (nonatomic, strong) HEMLocationService* locationService;

@end

@implementation HEMAppDelegate

static NSString* const kHEMAppExtRoom = @"room";

static NSString* const HEMAppFirstLaunch = @"HEMAppFirstLaunch";
static NSString* const HEMApiXVersionHeader = @"X-Client-Version";
static NSString* const HEMApiUserAgentFormat = @"%@/%@ Platform/iOS OS/%@";

static NSString* const HEMShortcutTypeAddAlarm = @"is.hello.sense.shortcut.addalarm";
static NSString* const HEMShortcutTypeEditAlarms = @"is.hello.sense.shortcut.editalarms";

- (BOOL)application:(UIApplication*)application didFinishLaunchingWithOptions:(NSDictionary*)launchOptions {
    // order matters
    [self configureProperties];
    [self configureAPI];
    [self configureCrashReport];
    
    [self loadTheme];
    
    [HEMDebugController disableDebugMenuIfNeeded];
    [HEMLogUtils enableLogger];
    [SENAnalytics enableAnalytics];

    [self deauthorizeIfNeeded];
    [self renewPushNotificationToken];
    [self listenForAuthorizationChanges];
    [self createAndShowWindow];
    
    return YES;
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    HEMFacebookService* fb = [HEMFacebookService new];
    if (![fb open:application url:url source:sourceApplication annotation:annotation]) {
        NSString* fullPath = [NSString stringWithFormat:@"%@%@", [url host], [url path]];
        HEMShortcutAction action = [HEMShortcutService actionForType:fullPath];
        if (action != HEMShortcutActionUnknown) {
            [self performShortcutAction:action data:nil];
        }
    }
    return YES;
}

- (BOOL)performShortcutAction:(HEMShortcutAction)action data:(id)data {
    BOOL performed = NO;
    RootViewController* rootVC = [RootViewController currentRootViewController];
    if ([rootVC conformsToProtocol:@protocol(ShortcutHandler)]) {
        id<ShortcutHandler> handler = (id) rootVC;
        if ([handler canHandleActionWithAction:action]) {
            [handler takeActionWithAction:action data:data];
            performed = YES;
        }
    }
    return performed;
}

- (void)application:(UIApplication *)application performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem completionHandler:(void (^)(BOOL))completionHandler {
    NSString *shortcutType = shortcutItem.type;
    DDLogDebug(@"incoming shortcut %@", shortcutType);
    BOOL handled = NO;
    HEMShortcutAction action = [HEMShortcutService actionForType:shortcutType];
    if (action != HEMShortcutActionUnknown) {
        handled = [self performShortcutAction:action data:nil];
    }
    completionHandler(handled);
}

- (MainViewController*)mainViewController {
    RootViewController* rootVC = [RootViewController currentRootViewController];
    MainViewController* mainVC = [rootVC mainViewController];
    return mainVC;
}

- (void)applicationDidBecomeActive:(UIApplication*)application {
    [application clearBadgeFromNotification];
    if (![self deauthorizeIfNeeded]) {
        [self loadTheme];
        [self syncData];
    }
}
    
- (void)loadTheme {
    [SenseStyle loadSavedThemeWithAuto:YES]; // load whatever first, then override as needed
    
    if (![self nightModeService]) {
        [self setNightModeService:[NightModeService new]];
    }
    
    if ([[self nightModeService] isScheduled]) {
        BOOL override = [[self mainViewController] showingMainTabs];
        [[self nightModeService] loadThemeWithOverride:override];
        // update lat / long
        if (![self locationService]) {
            [self setLocationService:[HEMLocationService new]];
        }
        switch ([[self locationService] authorizationStatus]) {
            case HEMLocationAuthStatusAuthorized: {
                __block BOOL updated = NO;
                __weak typeof(self) weakSelf = self;
                [[self locationService] quickLocation:^(HEMLocation* location, NSError * error) {
                    __strong typeof(weakSelf) strongSelf = weakSelf;
                    if (updated) {
                        return;
                    }
                    
                    updated = YES;
                    
                    if (location) {
                        [[strongSelf nightModeService] updateLocationWithLatitude:location.lat
                                                                        longitude:location.lon];
                    }
                }];
                break;
            }
            default:
                break;
        }
    }
}

- (void)configureProperties {
    [self setPushService:[PushNotificationService new]];
}

- (void)configureAPI {
    // User-Agent should be in the format: Sense/<App version> Platform/<iOS> OS/<Version>
    UIDevice* device = [UIDevice currentDevice];
    NSBundle* bundle = [NSBundle mainBundle];
    NSString* appName = [bundle objectForInfoDictionaryKey:@"CFBundleDisplayName"];
    NSString* version = [bundle objectForInfoDictionaryKey:@"CFBundleVersion"];
    NSString* osVersion = [device systemVersion];
    NSString* userAgent = [NSString stringWithFormat:HEMApiUserAgentFormat, appName, version, osVersion];
    NSString* path = [HEMConfig stringForConfig:HEMConfAPIURL];
    NSString* clientID = [HEMConfig stringForConfig:HEMConfClientId];
    
    [SENAPIClient setBaseURLFromPath:path];
    [SENAPIClient setValue:userAgent forHTTPHeaderField:@"User-Agent"];
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

- (void)createAndShowWindow {
    UIWindow* window = [UIWindow new];
    if (CGSizeEqualToSize(window.bounds.size, CGSizeZero))
        window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window = window;
    [self.window makeKeyWindow];
    self.window.rootViewController = [HEMMainStoryboard instantiateRootViewController];
    [self.window makeKeyAndVisible];
}

#pragma mark - Data sync

- (void)syncData {
    BOOL finishedOnboarding = [[HEMOnboardingService sharedService] hasFinishedOnboarding];
    BOOL signedIn = [SENAuthorizationService isAuthorized];
    
    if (signedIn && finishedOnboarding) {
        // pre fetch account information so that it's readily availble to the user
        // when the account is accessed.  This is per discussion with design and James
        HEMAccountService* acctService = [HEMAccountService sharedService];
        [acctService refreshWithPhoto:YES completion:^(SENAccount * account, NSDictionary<NSNumber *,SENPreference *> * preferences) {
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

#pragma mark - Remote / Push Notifications

- (void)application:(UIApplication*)application
didReceiveRemoteNotification:(nonnull NSDictionary *)userInfo
fetchCompletionHandler:(nonnull void (^)(UIBackgroundFetchResult))completionHandler {
    DDLogVerbose(@"received remote notification %@ in background or foreground", userInfo);
    UIBackgroundFetchResult result = UIBackgroundFetchResultNoData;
    if ([application applicationState] == UIApplicationStateInactive) { // opened notification
        PushNotification* notification = [[PushNotification alloc] initWithInfo:userInfo];
        HEMShortcutAction action = [HEMShortcutService actionForNotification:notification];
        if (action != HEMShortcutActionUnknown) {
            [self performShortcutAction:action data:notification];
            result = UIBackgroundFetchResultNewData;
        }
        [SENAnalytics trackPushNotification:notification];
    }
    completionHandler(result);
}

- (void)application:(UIApplication*)application didRegisterUserNotificationSettings:(nonnull UIUserNotificationSettings *)notificationSettings {
    if (![application renewPushNotificationToken] && [application shouldShowPushSettings]) {
        [application showPushSettings];
    }
}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken {
    DDLogVerbose(@"received push notification token");
    [[self pushService] uploadPushTokenWithData:deviceToken];
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(nonnull NSError *)error {
    [SENAnalytics trackError:error];
}

- (void)renewPushNotificationToken {
    if ([[self pushService] canRegisterForPushNotifications]) {
        [[UIApplication sharedApplication] renewPushNotificationToken];
    }
}

#pragma mark - Account changes

- (void)listenForAuthorizationChanges {
    NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
    [center addObserver:self
               selector:@selector(reset)
                   name:SENAuthorizationServiceDidDeauthorizeNotification
                 object:nil];
    [center addObserver:self
               selector:@selector(didSignIn)
                   name:SENAuthorizationServiceDidAuthorizeNotification
                 object:nil];
}

- (void)didSignIn {
    [self loadTheme];
    
    if ([[HEMOnboardingService sharedService] hasFinishedOnboarding]) {
        [self renewPushNotificationToken];
    }
}

- (void)reset {
    SENClearModel();
    [HEMAudioCache clearCache];
    [SENAnalytics reset:nil];
    [[SENLocalPreferences sharedPreferences] removeSessionPreferences];
    [[HEMOnboardingService sharedService] reset];
    [[SENServiceDevice sharedService] reset];
    [[SenseStyle theme] unloadWithAuto:YES];
}

@end
