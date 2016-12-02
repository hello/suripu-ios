
#import <SenseKit/SENAuthorizationService.h>
#import <SenseKit/SENPreference.h>

#import "HEMNotificationHandler.h"
#import "HEMAppDelegate.h"
#import "HEMAccountService.h"

@implementation HEMNotificationHandler

+ (void)registerForRemoteNotifications {
    [[UIApplication sharedApplication] registerForRemoteNotifications];
}

+ (void)clearNotifications {
    UIApplication* app = [UIApplication sharedApplication];
    app.applicationIconBadgeNumber = 1;
    app.applicationIconBadgeNumber = 0;
}

+ (void)registerForRemoteNotificationsIfEnabled {
    if (![SENAuthorizationService isAuthorized])
        return;
    
    __weak typeof(self) weakSelf = self;
    [[HEMAccountService sharedService] refresh:^(SENAccount * _Nullable account, NSDictionary<NSNumber *,SENPreference *> * _Nullable preferences) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!preferences) {
            return;
        }
        SENPreference* pushConditions = preferences[@(SENPreferenceTypePushConditions)];
        SENPreference* pushScore = preferences[@(SENPreferenceTypePushScore)];
        if ([pushConditions isEnabled] || [pushScore isEnabled]) {
            [strongSelf registerForRemoteNotifications];
        }
    }];
}

@end
