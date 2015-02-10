
#import <SenseKit/SENAuthorizationService.h>
#import <SenseKit/SENServiceAccount.h>
#import <SenseKit/SENPreference.h>
#import "HEMNotificationHandler.h"
#import "HEMAppDelegate.h"
#import "HEMRootViewController.h"

@implementation HEMNotificationHandler

static NSString* const HEMNotificationPayload = @"aps";
static NSString* const HEMNotificationTarget = @"target";
static NSString* const HEMNotificationDetail = @"details";
static NSString* const HEMNotificationTargetSensor = @"sensor";
static NSString* const HEMNotificationTargetTrends = @"trends";
static NSString* const HEMNotificationTargetTimeline = @"timeline";
static NSString* const HEMNotificationTargetInsights = @"insights";
static NSString* const HEMNotificationTargetTimelineDateFormat = @"yyyy-MM-dd";
static NSString* const HEMNotificationTargetAlarms = @"alarms";
static NSString* const HEMNotificationTargetSettings = @"settings";

+ (void)registerForRemoteNotifications
{
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerForRemoteNotifications)]) {
        [self registerInteractiveNotificationTypes];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    } else {
        UIRemoteNotificationType types = (UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeBadge);
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:types];
    }
}

+ (void)clearNotifications
{
    UIApplication* app = [UIApplication sharedApplication];
    app.applicationIconBadgeNumber = 1;
    app.applicationIconBadgeNumber = 0;
}

+ (void)registerForRemoteNotificationsIfEnabled
{
    if (![SENAuthorizationService isAuthorized])
        return;
    [[SENServiceAccount sharedService] refreshAccount:^(NSError *error) {
        if (error)
            return;
        NSDictionary* preferences = [[SENServiceAccount sharedService] preferences];
        SENPreference* pushConditions = preferences[@(SENPreferenceTypePushConditions)];
        SENPreference* pushScore = preferences[@(SENPreferenceTypePushScore)];
        if ([pushConditions isEnabled] || [pushScore isEnabled]) {
            [self registerForRemoteNotifications];
        }
    }];
}

+ (void)registerInteractiveNotificationTypes
{
    NSSet* categories = [NSSet setWithArray:@[
                                               [self qualityNotificationCategory],
                                               [self yesNoNotificationCategory],
                                               [self frequencyNotificationCategory],
                                            ]];
    UIUserNotificationType types = (UIUserNotificationTypeAlert | UIUserNotificationTypeSound | UIUserNotificationTypeBadge);
    UIUserNotificationSettings* settings = [UIUserNotificationSettings settingsForTypes:types categories:categories];
    [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
}

+ (void)handleRemoteNotificationWithInfo:(NSDictionary *)userInfo
                  fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    NSDictionary* payload = userInfo[HEMNotificationPayload];
    if (![payload isKindOfClass:[NSDictionary class]])
        return;
    NSString* target = payload[HEMNotificationTarget];

    if (![target isKindOfClass:[NSString class]]) {
        if (completionHandler)
            completionHandler(UIBackgroundFetchResultNoData);
        return;
    }
    NSString* detail = payload[HEMNotificationDetail];
    HEMAppDelegate* delegate = (id)[UIApplication sharedApplication].delegate;
    HEMRootViewController* controller = [HEMRootViewController rootViewControllerForKeyWindow];
    NSDateFormatter* formatter = [NSDateFormatter new];
    formatter.dateFormat = HEMNotificationTargetTimelineDateFormat;
    if ([target isEqualToString:HEMNotificationTargetSensor]) {
        if (detail) {
            [delegate openDetailViewForSensorNamed:detail];
        } else {
            [controller showSettingsDrawerTabAtIndex:HEMRootDrawerTabConditions animated:NO];
        }
    } else if ([target isEqualToString:HEMNotificationTargetTimeline]) {
        [controller closeSettingsDrawer];
        NSDate* date = [formatter dateFromString:detail];
        if (date) {
            [controller reloadTimelineSlideViewControllerWithDate:date];
        }
    } else if ([target isEqualToString:HEMNotificationTargetTrends]) {
        [controller showSettingsDrawerTabAtIndex:HEMRootDrawerTabTrends animated:NO];
    } else if ([target isEqualToString:HEMNotificationTargetInsights]) {
        [controller showSettingsDrawerTabAtIndex:HEMRootDrawerTabInsights animated:NO];
    } else if ([target isEqualToString:HEMNotificationTargetAlarms]) {
        [controller showSettingsDrawerTabAtIndex:HEMRootDrawerTabAlarms animated:NO];
    } else if ([target isEqualToString:HEMNotificationTargetSettings]) {
        [controller showSettingsDrawerTabAtIndex:HEMRootDrawerTabSettings animated:NO];
    }
    if (completionHandler)
        completionHandler(UIBackgroundFetchResultNewData);
}

+ (UIUserNotificationCategory*)qualityNotificationCategory
{
    UIMutableUserNotificationAction* poorAction = [[UIMutableUserNotificationAction alloc] init];
    poorAction.identifier = @"poor";
    poorAction.title = NSLocalizedString(@"notifications.actions.poor", nil);
    poorAction.activationMode = UIUserNotificationActivationModeBackground;
    UIMutableUserNotificationAction* okAction = [[UIMutableUserNotificationAction alloc] init];
    okAction.identifier = @"ok";
    okAction.title = NSLocalizedString(@"notifications.actions.ok", nil);
    okAction.activationMode = UIUserNotificationActivationModeBackground;
    UIMutableUserNotificationAction* goodAction = [[UIMutableUserNotificationAction alloc] init];
    goodAction.identifier = @"good";
    goodAction.title = NSLocalizedString(@"notifications.actions.good", nil);
    goodAction.activationMode = UIUserNotificationActivationModeBackground;
    UIMutableUserNotificationCategory* qualityCategory = [[UIMutableUserNotificationCategory alloc] init];
    qualityCategory.identifier = @"quality";
    [qualityCategory setActions:@[ poorAction, okAction, goodAction ] forContext:UIUserNotificationActionContextDefault];
    [qualityCategory setActions:@[ poorAction, goodAction ] forContext:UIUserNotificationActionContextMinimal];
    return qualityCategory;
}

+ (UIUserNotificationCategory*)frequencyNotificationCategory
{
    UIMutableUserNotificationAction* dailyAction = [[UIMutableUserNotificationAction alloc] init];
    dailyAction.identifier = @"daily";
    dailyAction.title = NSLocalizedString(@"notifications.actions.daily", nil);
    dailyAction.activationMode = UIUserNotificationActivationModeBackground;
    UIMutableUserNotificationAction* weeklyAction = [[UIMutableUserNotificationAction alloc] init];
    weeklyAction.identifier = @"weekly";
    weeklyAction.title = NSLocalizedString(@"notifications.actions.weekly", nil);
    weeklyAction.activationMode = UIUserNotificationActivationModeBackground;
    UIMutableUserNotificationAction* infrequentlyAction = [[UIMutableUserNotificationAction alloc] init];
    infrequentlyAction.identifier = @"infrequently";
    infrequentlyAction.title = NSLocalizedString(@"notifications.actions.infrequently", nil);
    infrequentlyAction.activationMode = UIUserNotificationActivationModeBackground;
    UIMutableUserNotificationCategory* qualityCategory = [[UIMutableUserNotificationCategory alloc] init];
    qualityCategory.identifier = @"frequency";
    [qualityCategory setActions:@[ dailyAction, weeklyAction, infrequentlyAction ] forContext:UIUserNotificationActionContextDefault];
    [qualityCategory setActions:@[ weeklyAction, infrequentlyAction ] forContext:UIUserNotificationActionContextMinimal];
    return qualityCategory;
}

+ (UIUserNotificationCategory*)yesNoNotificationCategory
{
    UIMutableUserNotificationAction* noAction = [[UIMutableUserNotificationAction alloc] init];
    noAction.identifier = @"no";
    noAction.title = NSLocalizedString(@"notifications.actions.no", nil);
    noAction.activationMode = UIUserNotificationActivationModeBackground;
    UIMutableUserNotificationAction* yesAction = [[UIMutableUserNotificationAction alloc] init];
    yesAction.identifier = @"yes";
    yesAction.title = NSLocalizedString(@"notifications.actions.yes", nil);
    yesAction.activationMode = UIUserNotificationActivationModeBackground;
    UIMutableUserNotificationCategory* yesNoCategory = [[UIMutableUserNotificationCategory alloc] init];
    yesNoCategory.identifier = @"yes_no";
    [yesNoCategory setActions:@[ yesAction, noAction ] forContext:UIUserNotificationActionContextDefault];
    return yesNoCategory;
}

@end
