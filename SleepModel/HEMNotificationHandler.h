
#import <Foundation/Foundation.h>

@interface HEMNotificationHandler : NSObject

+ (void)registerForRemoteNotifications;

/**
 *  Register for remote notifications if the user has enabled push notifications in preferences
 */
+ (void)registerForRemoteNotificationsIfEnabled;

/**
 *  Parse notification info and navigate to a specified view if needed
 *
 *  @param userInfo          notification payload
 *  @param completionHandler fetch handler or NULL
 */
+ (void)handleRemoteNotificationWithInfo:(NSDictionary *)userInfo
                  fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler;

/**
 *  Clear all notifications from notification center and badge count
 */
+ (void)clearNotifications;

@end
