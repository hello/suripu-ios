
#import <Foundation/Foundation.h>

@interface HEMNotificationHandler : NSObject

+ (void)registerForRemoteNotifications;

+ (void)handleRemoteNotificationWithInfo:(NSDictionary *)userInfo
                  fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler;

@end
