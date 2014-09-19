
#import <Foundation/Foundation.h>

/**
 *  Handling for push notification registration
 *  Depends on UIKit
 */
@interface SENAPINotification : NSObject

/**
 *  Register the app with the API to receive notifications
 *
 *  @param tokenData  raw data from application:didRegisterForRemoteNotifications:
 *  @param completion block invoked with API call is completed
 */
+ (void)registerForRemoteNotificationsWithTokenData:(NSData*)tokenData completion:(void (^)(NSError* error))completion;
@end
