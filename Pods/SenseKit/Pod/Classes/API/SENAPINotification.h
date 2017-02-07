
#import <Foundation/Foundation.h>

@class SENNotificationSetting;
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

/**
 *  Get a list of notification settings that are supported by the server
 *  @param completion: the block to call when the operation completes
 */
+ (void)getNotificationSettings:(SENAPIDataBlock)completion;

/**
 *  Update the list of settings on the server.  This is a PUT operation, which 
 *  means the entire list of the settings retrieved through the GET should be
 *  sent, even if only 1 setting was modified.
 *
 *  @param completion: the block to call when the operation completes
 */
+ (void)updateSettings:(NSArray<SENNotificationSetting*>*)settings completion:(SENAPIDataBlock)completion;

@end
