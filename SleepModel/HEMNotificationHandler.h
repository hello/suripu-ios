
#import <Foundation/Foundation.h>

@interface HEMNotificationHandler : NSObject

+ (void)registerForRemoteNotifications;

/**
 *  Register for remote notifications if the user has enabled push notifications in preferences
 */
+ (void)registerForRemoteNotificationsIfEnabled;

/**
 *  Clear all notifications from notification center and badge count
 */
+ (void)clearNotifications;

@end
