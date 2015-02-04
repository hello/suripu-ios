
#import <Foundation/Foundation.h>

@interface HEMNotificationHandler : NSObject

+ (void)registerForRemoteNotifications;

/**
 *  Register for remote notifications if the user has enabled push notifications in preferences
 */
+ (void)registerForRemoteNotificationsIfEnabled;

+ (void)handleRemoteNotificationWithInfo:(NSDictionary *)userInfo
                  fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler;

@end
