
#import "HEMNotificationHandler.h"

@implementation HEMNotificationHandler

+ (void)registerForRemoteNotifications
{
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerForRemoteNotifications)]) {
        [self registerInteractiveNotificationTypes];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    } else {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound)];
    }
}

+ (void)registerInteractiveNotificationTypes
{
    NSSet* categories = [NSSet setWithArray:@[
                                               [self qualityNotificationCategory],
                                               [self yesNoNotificationCategory],
                                               [self frequencyNotificationCategory],
                                            ]];
    UIUserNotificationSettings* settings = [UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeAlert | UIUserNotificationTypeSound)categories:categories];
    [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
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
    qualityCategory.identifier = @"freuqency";
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
